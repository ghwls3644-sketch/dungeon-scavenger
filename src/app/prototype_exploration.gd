class_name PrototypeExploration
extends Node2D

signal exploration_ended(outcome: ExplorationOutcome)

# Extends the prototype with one optional northern room. G1 fixtures stay fixed.
const WALLS: Array[Rect2] = [
	Rect2(-800, -380, 840, 24), Rect2(160, -380, 640, 24), Rect2(-800, 356, 1600, 24),
	Rect2(-800, -380, 24, 760), Rect2(776, -380, 24, 760),
	Rect2(-360, -20, 840, 40),
	Rect2(-250, 20, 160, 140), Rect2(-250, 240, 160, 116),
]

const MAP_DEFINITION := preload("res://src/data/prototype_exploration_map.tres")
const INTERACTION_TIMING := preload("res://src/data/prototype_interaction_timing.tres")

var _map_state := ExplorationMapState.new()
var _loadout: ExpeditionLoadout
var _started := false
var _finished := false
var _timing_configured := false

@onready var _player: PlayerController = %Player
@onready var _inventory: PlayerInventory = $Player/Inventory
@onready var _harness: HarnessController = $Player/HarnessController
@onready var _run: ExplorationRun = %ExplorationRun
@onready var _hazard: UnstableDebrisHazard = %RiskHazard
@onready var _golem: BrokenGuardGolem = %BrokenGuardGolem
@onready var _inventory_panel: InventoryPanel = %InventoryPanel
@onready var _survival: PlayerSurvival = %PlayerSurvival
@onready var _interaction: InteractionController = $Player/InteractionController


func _ready() -> void:
	_timing_configured = _interaction.configure_timing(INTERACTION_TIMING, _survival)
	_interaction.work_canceled.connect(func(reason: String): %ChoiceStatus.text = reason)
	_inventory_panel.opening.connect(_interaction.cancel_work)
	%ExplorationMapPanel.opening.connect(_interaction.cancel_work)
	_golem.obstacle_contacted.connect(%RetreatDoor.note_obstacle_contact)
	%RetreatDoor.status_changed.connect($Player/InteractionDetector.refresh_current_interactable)
	%RetreatDoor.held.connect(func(): %ChoiceStatus.text = "문을 잠시 고정했습니다. 해제 안내를 확인하고 거리를 벌리세요.")
	%MalfunctioningTrap.body_caught.connect(_on_trap_hit)
	%MalfunctioningTrap.stabilized.connect(func(): %ChoiceStatus.text = "함정을 잠시 멈췄습니다. 불빛이 다시 점멸하면 물러나세요.")
	_golem.sight_lost.connect(func(_position: Vector2): %ChoiceStatus.text = "골렘의 시야를 벗어났습니다. 마지막으로 본 위치를 수색하며 소음에는 반응할 수 있습니다.")
	%NoiseLureController.status_changed.connect(_update_tool_status)
	%NoiseLureController.lure_landed.connect(_on_lure_landed)
	%NoiseLureController.throw_rejected.connect(func(reason: String): %ChoiceStatus.text = reason)
	_inventory_panel.opening.connect(%NoiseLureController.cancel_pending)
	%ExplorationMapPanel.opening.connect(%NoiseLureController.cancel_pending)
	%GolemHearing.noise_heard.connect(_on_movement_noise_heard)
	%QuickDropController.status_changed.connect(_update_quick_drop_status)
	_inventory_panel.opening.connect(%QuickDropController.cancel_hold)
	%ExplorationMapPanel.opening.connect(%QuickDropController.cancel_hold)
	_inventory.item_dropped.connect(func(item: ItemDefinition): %ChoiceStatus.text = "%s을(를) 버렸습니다." % item.display_name)
	_map_state.configure(MAP_DEFINITION)
	%ReturnRouteStatus.bind_map(_map_state)
	_inventory_panel.opening.connect(%ReturnRouteStatus.hide)
	%ExplorationMapPanel.opening.connect(%ReturnRouteStatus.hide)
	%RemainingZoneEntrance.configure(_map_state, _player)
	%RemainingZoneEntrance.opened.connect(func(): %ChoiceStatus.text = "입구가 안정화되었습니다. 안쪽을 살펴본 뒤 같은 길로 돌아올 수 있습니다.")
	%RemainingZoneEntrance.discovered.connect(func(): %ChoiceStatus.text = "잔여 구역 발견 · 지도에 이번 탐험의 발견을 기록했습니다. 귀환은 원래 입구에서 할 수 있습니다.")
	%RemainingZoneEntrance.discovered.connect(func(): %MalfunctioningTrap.set_exploration_active(true))
	%MapClue.configure(_map_state)
	%MapClue.clue_read.connect(_on_map_clue_read)
	%MapPassageSurvey.configure(_map_state, _player)
	%ExplorationMapPanel.bind_map(_map_state)
	%ExplorationMapPanel.opening.connect(_inventory_panel.close_inventory)
	_inventory_panel.opening.connect(%ExplorationMapPanel.close_map)
	_build_walls()
	_player.get_node("Camera2D").enabled = false
	_hazard.get_node("Status").add_theme_font_size_override("font_size", 22)
	_golem.get_node("Status").add_theme_font_size_override("font_size", 22)
	_golem.get_node("Status").z_index = 1
	_golem.get_node("Status").add_theme_color_override("font_outline_color", Color("#0a1018"))
	_golem.get_node("Status").add_theme_constant_override("outline_size", 4)
	_set_simulation_enabled(false)
	_inventory_panel.process_mode = Node.PROCESS_MODE_DISABLED
	$Overlay.hide()
	%InteractionPrompt.bind_source(null)
	_inventory.inventory_changed.connect(_update_load_status)
	_harness.charge_changed.connect(func(_current: int, _capacity: int): _update_load_status())
	_inventory.item_added.connect(func(item: ItemDefinition): %ChoiceStatus.text = "%s 회수" % item.display_name)
	_inventory.item_add_rejected.connect(_on_pickup_rejected)
	_hazard.warning_started.connect(func(_duration: float): %ChoiceStatus.text = (
		"먼지와 진동이 커집니다. Q로 안정화하거나 신속히 통과·후퇴하세요." if _harness.has_module(HarnessModules.STABILIZATION)
		else "먼지와 진동이 커집니다. 안정화 미장착 · 신속히 통과하거나 후퇴하세요."))
	_hazard.body_caught.connect(_on_body_caught)
	%GolemContactThreat.body_caught.connect(_on_golem_caught)
	%GolemContactThreat.status_changed.connect(_update_contact_status)
	_inventory_panel.opening.connect(%ContactStatus.hide)
	%ExplorationMapPanel.opening.connect(%ContactStatus.hide)
	_run.run_ended.connect(_on_run_ended)
	_survival.incapacitated.connect(func(cause: StringName): _run.complete_failure(cause))
	_survival.state_changed.connect(_update_survival_status)
	_survival.state_changed.connect(_update_load_status)


func _physics_process(_delta: float) -> void:
	if _started and not _finished:
		_update_contact_status()
		_update_survival_status()
		_map_state.observe_position(_player.position)
		$OverviewCamera.position.y = minf(-100.0, _player.position.y + 80.0)
		%ReturnRouteStatus.refresh(
			get_global_transform_with_canvas(),
			$Player/InteractionDetector.get_current_interactable() == %EntranceExit,
			_inventory_panel.visible or %ExplorationMapPanel.visible,
		)


func get_map_state() -> ExplorationMapState:
	return _map_state


func exclude_secured_originals(ids: Array[StringName]) -> void:
	# Called before entering the tree, so excluded pickups never become interactive.
	if is_inside_tree():
		return
	for child in find_children("*", "", true, false):
		if is_instance_valid(child) and child is PickupInteractable and child.item_definition != null \
				and child.item_definition.is_original() and child.item_definition.stable_id in ids:
			child.get_parent().remove_child(child)
			child.free()


func prepare_departure(loadout: ExpeditionLoadout) -> bool:
	if not is_node_ready() or _loadout != null or loadout == null or not loadout.is_valid():
		return false
	if not _harness.configure_modules(loadout.harness_modules):
		return false
	_loadout = loadout.copy()
	_inventory.configure_capacity(_loadout.slot_capacity, _loadout.burden_weight, _loadout.overload_weight)
	_harness.configure_charge(_loadout.charge_capacity, _loadout.starting_charge)
	return true


func get_start_loadout() -> ExpeditionLoadout:
	return _loadout.copy() if _loadout != null else null


func start_exploration() -> bool:
	if _loadout == null or _started or _finished or not _timing_configured:
		return false
	if not _survival.start_exploration():
		return false
	_started = true
	_map_state.observe_position(_player.position)
	%ExplorationMapPanel.set_input_enabled(true)
	$OverviewCamera.enabled = true
	$Overlay.show()
	_set_simulation_enabled(true)
	_inventory_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	%InteractionPrompt.bind_source($Player/InteractionController)
	%ChoiceStatus.text = "위쪽 물품부터 살펴보거나 아래쪽 위험 경로로 들어가세요."
	_update_load_status()
	return true


func _set_simulation_enabled(enabled: bool) -> void:
	_interaction.set_active(enabled)
	%GolemContactThreat.set_active(enabled)
	%ReturnRouteStatus.set_active(enabled)
	%RetreatDoor.set_exploration_active(enabled)
	if not enabled:
		%MalfunctioningTrap.set_exploration_active(false)
	%NoiseLureController.set_active(enabled)
	%MovementNoiseEmitter.set_active(enabled)
	%GolemHearing.set_active(enabled)
	%QuickDropController.set_active(enabled)
	%RemainingZoneEntrance.set_exploration_active(enabled)
	%MapClue.set_interaction_enabled(enabled)
	%MapPassageSurvey.set_observation_enabled(enabled)
	var mode := Node.PROCESS_MODE_PAUSABLE if enabled else Node.PROCESS_MODE_DISABLED
	_player.process_mode = mode
	_hazard.process_mode = mode
	_golem.process_mode = mode


func _on_body_caught(body: Node2D) -> void:
	if _started and not _finished and body == _player:
		_survival.incapacitate()


func _on_trap_hit(body: Node2D) -> void:
	if _started and not _finished and body == _player:
		_survival.apply_trap_damage()


func _on_golem_caught(body: Node2D) -> void:
	if _started and not _finished and body == _player:
		_survival.incapacitate(&"golem_capture")


func _update_survival_status() -> void:
	var remaining := _survival.get_injury_remaining()
	var condition := "부상 %.1f초 · 이동 %d%% · 조사/회수 %d%%" % [remaining, roundi(_survival.get_movement_multiplier() * 100.0), roundi(_survival.get_interaction_multiplier() * 100.0)] if remaining > 0.0 else "부상 없음"
	if remaining <= 0.0 and _survival.get_health() < _survival.get_max_health():
		condition += " · 건강 잔량은 회복되지 않습니다"
	%SurvivalStatus.text = "건강 %d/%d · %s" % [_survival.get_health(), _survival.get_max_health(), condition]
	%SurvivalStatus.modulate = Color("#ffd086") if remaining > 0.0 else Color.WHITE


func _update_contact_status() -> void:
	var threat: GolemContactThreat = %GolemContactThreat
	%ContactStatus.visible = threat.is_warning() and not _inventory_panel.visible and not %ExplorationMapPanel.visible
	%ChoiceStatus.visible = not %ContactStatus.visible
	if threat.is_warning():
		%ContactStatus.text = "골렘 접촉! %.1f초 뒤 행동 불능\n이동으로 이탈 · G 길게: 선택한 짐 버리기 · Q: 방전 (충전 필요)" % threat.get_remaining_time()


func _on_pickup_rejected(_item: ItemDefinition, reason: StringName) -> void:
	if reason == PlayerInventory.REJECT_SLOT_LIMIT:
		%ChoiceStatus.text = "가방이 가득 찼습니다. Tab으로 물품을 비교하고 버릴지 선택하세요."


func _update_load_status() -> void:
	%LoadStatus.text = "가방 %d/%d칸 · 무게 %.1f · %s · 이동 %d%% · 소음 %s · 충전 %d/%d" % [
		_inventory.get_used_slots(), _inventory.slot_capacity, _inventory.get_total_weight(),
		["정상", "부담", "과적"][_inventory.get_weight_stage()],
		roundi(_player.get_movement_speed_multiplier() * 100.0),
		["작음", "큼", "매우 큼"][_inventory.get_weight_stage()],
		_harness.get_current_charge(), _harness.get_charge_capacity(),
	]


func _on_run_ended(outcome: ExplorationOutcome) -> void:
	if not _started or _finished:
		return
	_finished = true
	_survival.end_exploration()
	%ExplorationMapPanel.set_input_enabled(false)
	_inventory_panel.close_inventory()
	_inventory_panel.process_mode = Node.PROCESS_MODE_DISABLED
	_set_simulation_enabled(false)
	%InteractionPrompt.bind_source(null)
	$Overlay.hide()
	exploration_ended.emit(outcome)


func _draw() -> void:
	draw_rect(Rect2(-4000, -3000, 8000, 6000), Color("#0a1018"))
	draw_rect(Rect2(-800, -380, 1600, 760), Color("#0c121b"))
	draw_rect(Rect2(-740, -330, 1480, 300), Color("#16363d"))
	draw_rect(Rect2(-740, 30, 1480, 300), Color("#402719"))
	draw_rect(Rect2(-740, -100, 340, 200), Color("#1b2934"))
	draw_rect(Rect2(500, -330, 240, 660), Color("#203b35"))
	for wall in WALLS:
		draw_rect(wall, Color("#69717d"))


func _build_walls() -> void:
	var walls := StaticBody2D.new()
	walls.collision_layer = 8
	walls.collision_mask = 0
	for rect in WALLS:
		var shape := CollisionShape2D.new()
		var rectangle := RectangleShape2D.new()
		rectangle.size = rect.size
		shape.shape = rectangle
		shape.position = rect.get_center()
		walls.add_child(shape)
	add_child(walls)


func _update_quick_drop_status() -> void:
	var item := _inventory.get_quick_drop_item()
	if item == null:
		%QuickDropStatus.text = "빠른 버리기 · Tab 가방에서 물품을 직접 선택하세요."
	elif %QuickDropController.is_holding():
		%QuickDropStatus.text = "버리기 준비 %d%% · %s\nG를 놓으면 취소" % [roundi(%QuickDropController.get_progress() * 100.0), item.get_definition().display_name]
	else:
		%QuickDropStatus.text = "G 길게 누르기 · %s 버리기" % item.get_definition().display_name


func _on_movement_noise_heard(escalated: bool) -> void:
	%ChoiceStatus.text = "큰 이동 소음이 반복되어 골렘의 경보가 높아졌습니다. 추적에 대비하세요." if escalated else "이동 소음에 골렘이 반응했습니다. 멈추거나 짐을 줄여 소음을 낮출 수 있습니다."


func _update_tool_status() -> void:
	var tool: NoiseLureController = %NoiseLureController
	%ToolStatus.text = "소음 유인물 %d/%d · F 투척\n마우스로 목표 위치 지정\n%s" % [
		tool.get_remaining_uses(), tool.get_capacity(),
		"투척 중" if tool.is_in_flight() else "플레이어를 못 본 골렘을 유인합니다.",
	]


func _on_lure_landed(position: Vector2, radius: float) -> void:
	var heard: bool = %GolemHearing.hear_lure(position, radius)
	%ChoiceStatus.text = "골렘이 소음 유인물이 떨어진 위치를 확인합니다." if heard else "소음 유인물이 떨어졌습니다."


func _on_map_clue_read(clue: MapClueDefinition) -> void:
	%ChoiceStatus.text = "%s\nM 지도 → 단서 보기에서 다시 읽을 수 있습니다." % clue.hint_text
