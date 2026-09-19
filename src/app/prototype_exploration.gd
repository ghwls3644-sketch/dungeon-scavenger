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

var _map_state := ExplorationMapState.new()
var _loadout: ExpeditionLoadout
var _started := false
var _finished := false

@onready var _player: PlayerController = %Player
@onready var _inventory: PlayerInventory = $Player/Inventory
@onready var _harness: HarnessController = $Player/HarnessController
@onready var _run: ExplorationRun = %ExplorationRun
@onready var _hazard: UnstableDebrisHazard = %RiskHazard
@onready var _golem: BrokenGuardGolem = %BrokenGuardGolem
@onready var _inventory_panel: InventoryPanel = %InventoryPanel


func _ready() -> void:
	%QuickDropController.status_changed.connect(_update_quick_drop_status)
	_inventory_panel.opening.connect(%QuickDropController.cancel_hold)
	%ExplorationMapPanel.opening.connect(%QuickDropController.cancel_hold)
	_inventory.item_dropped.connect(func(item: ItemDefinition): %ChoiceStatus.text = "%s을(를) 버렸습니다." % item.display_name)
	_map_state.configure(MAP_DEFINITION)
	%RemainingZoneEntrance.configure(_map_state, _player)
	%RemainingZoneEntrance.opened.connect(func(): %ChoiceStatus.text = "입구가 안정화되었습니다. 안쪽을 살펴본 뒤 같은 길로 돌아올 수 있습니다.")
	%RemainingZoneEntrance.discovered.connect(func(): %ChoiceStatus.text = "잔여 구역 발견 · 지도에 이번 탐험의 발견을 기록했습니다. 귀환은 원래 입구에서 할 수 있습니다.")
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
	_set_simulation_enabled(false)
	_inventory_panel.process_mode = Node.PROCESS_MODE_DISABLED
	$Overlay.hide()
	%InteractionPrompt.bind_source(null)
	_inventory.inventory_changed.connect(_update_load_status)
	_harness.charge_changed.connect(func(_current: int, _capacity: int): _update_load_status())
	_inventory.item_added.connect(func(item: ItemDefinition): %ChoiceStatus.text = "%s 회수" % item.display_name)
	_inventory.item_add_rejected.connect(_on_pickup_rejected)
	_hazard.warning_started.connect(func(_duration: float): %ChoiceStatus.text = "먼지와 진동이 커집니다. Q로 안정화하거나 신속히 통과·후퇴하세요.")
	_hazard.body_caught.connect(_on_body_caught)
	_run.run_ended.connect(_on_run_ended)


func _physics_process(_delta: float) -> void:
	if _started and not _finished:
		_map_state.observe_position(_player.position)
		$OverviewCamera.position.y = minf(-100.0, _player.position.y + 80.0)


func get_map_state() -> ExplorationMapState:
	return _map_state


func prepare_departure(loadout: ExpeditionLoadout) -> bool:
	if not is_node_ready() or _loadout != null or loadout == null or not loadout.is_valid():
		return false
	_loadout = loadout.copy()
	_inventory.configure_capacity(_loadout.slot_capacity, _loadout.burden_weight, _loadout.overload_weight)
	_harness.configure_charge(_loadout.charge_capacity, _loadout.starting_charge)
	return true


func get_start_loadout() -> ExpeditionLoadout:
	return _loadout.copy() if _loadout != null else null


func start_exploration() -> bool:
	if _loadout == null or _started or _finished:
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
		_run.complete_failure()


func _on_pickup_rejected(_item: ItemDefinition, reason: StringName) -> void:
	if reason == PlayerInventory.REJECT_SLOT_LIMIT:
		%ChoiceStatus.text = "가방이 가득 찼습니다. Tab으로 물품을 비교하고 버릴지 선택하세요."


func _update_load_status() -> void:
	%LoadStatus.text = "가방 %d/%d칸 · 무게 %.1f · 하네스 충전 %d/%d" % [
		_inventory.get_used_slots(), _inventory.slot_capacity, _inventory.get_total_weight(),
		_harness.get_current_charge(), _harness.get_charge_capacity(),
	]


func _on_run_ended(outcome: ExplorationOutcome) -> void:
	if not _started or _finished:
		return
	_finished = true
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


func _on_map_clue_read(clue: MapClueDefinition) -> void:
	%ChoiceStatus.text = "%s\nM 지도 → 단서 보기에서 다시 읽을 수 있습니다." % clue.hint_text
