extends Node2D

# This small, fixed map supplies comparison evidence, not production balance.
const WALLS: Array[Rect2] = [
	Rect2(-800, -380, 1600, 24), Rect2(-800, 356, 1600, 24),
	Rect2(-800, -380, 24, 760), Rect2(776, -380, 24, 760),
	Rect2(-360, -20, 840, 40),
	Rect2(-250, 20, 160, 140), Rect2(-250, 240, 160, 116),
]

var _started := false
var _finished := false
var _automated := false
var _active_seconds := 0.0
var _paused_seconds := 0.0
var _walked_pixels := 0.0
var _last_position := Vector2.ZERO
var _maximum_weight := 0.0
var _peak_slots := 0
var _burdened_seconds := 0.0
var _overloaded_seconds := 0.0
var _events: Array[Dictionary] = []
var _counts := {
	"inspections": 0, "pickups": 0, "drops": 0, "slot_rejections": 0,
	"analyses": 0, "stabilizations": 0, "discharges": 0,
	"golem_warnings": 0, "chases": 0, "bypass_entries": 0, "inventory_opens": 0,
}
var _outcome_name := "not_started"
var _recovered_count := 0
var _unknown_count := 0
var _lost_count := 0

@onready var _player: PlayerController = %Player
@onready var _inventory: PlayerInventory = $Player/Inventory
@onready var _harness: HarnessController = $Player/HarnessController
@onready var _hazard: UnstableDebrisHazard = %RiskHazard
@onready var _golem: BrokenGuardGolem = %BrokenGuardGolem
@onready var _run: ExplorationRun = %ExplorationRun
@onready var _inventory_panel: InventoryPanel = %InventoryPanel
@onready var _harness_status: HarnessStatus = %HarnessStatus
@onready var _interaction_prompt: InteractionPrompt = %InteractionPrompt
@onready var _outcome_panel: ExplorationOutcomePanel = %ExplorationOutcomePanel
@onready var _choice_status: Label = %ChoiceStatus
@onready var _load_status: Label = %LoadStatus
@onready var _report_text: Label = %ReportText
@onready var _start_panel: PanelContainer = %StartPanel
@onready var _report_panel: PanelContainer = %ReportPanel
@onready var _load_choice: OptionButton = %LoadChoice


func _ready() -> void:
	_build_walls()
	_player.get_node("Camera2D").enabled = false
	_hazard.get_node("Status").add_theme_font_size_override("font_size", 22)
	_golem.get_node("Status").add_theme_font_size_override("font_size", 22)
	var known_item: ItemDefinition = %KnownRewardPickup.item_definition
	$KnownLabel.text = "정밀 부품 · 무게 %.1f\n%s" % [
		known_item.weight, ItemValueText.format_item_value(known_item),
	]
	_set_simulation_enabled(false)
	_inventory_panel.process_mode = Node.PROCESS_MODE_DISABLED
	_harness_status.hide()
	_interaction_prompt.bind_source(null)
	_outcome_panel.hide()
	_report_panel.hide()
	_load_choice.add_item("기본 비교 · 가방 2칸", 2)
	_load_choice.add_item("여유 비교 · 가방 3칸", 3)
	%StartButton.pressed.connect(func() -> void: start_playtest(_load_choice.get_selected_id()))
	%RetryButton.pressed.connect(_on_retry_pressed)
	%CopyButton.pressed.connect(_on_copy_pressed)
	_inventory.item_added.connect(_on_item_added)
	_inventory.item_dropped.connect(_on_item_dropped)
	_inventory.item_add_rejected.connect(_on_item_add_rejected)
	_inventory.inventory_changed.connect(_on_inventory_changed)
	_inventory_panel.visibility_changed.connect(_on_inventory_visibility_changed)
	%UnknownPickup.inspection_completed.connect(_on_inspection_completed)
	_harness.analysis_completed.connect(_on_analysis_completed)
	_harness.action_succeeded.connect(_on_stabilized)
	_harness.discharge_succeeded.connect(_on_discharged)
	_hazard.warning_started.connect(_on_hazard_warning)
	_hazard.body_caught.connect(_on_body_caught)
	_golem.warning_started.connect(_on_golem_warning)
	_golem.chase_started.connect(_on_golem_chase)
	%BypassMarker.body_entered.connect(_on_bypass_entered)
	_run.run_ended.connect(_on_run_ended)


func _draw() -> void:
	draw_rect(Rect2(-4000, -3000, 8000, 6000), Color("#0a1018"))
	draw_rect(Rect2(-800, -380, 1600, 760), Color("#0c121b"))
	draw_rect(Rect2(-740, -330, 1480, 300), Color("#16363d"))
	draw_rect(Rect2(-740, 30, 1480, 300), Color("#402719"))
	draw_rect(Rect2(-740, -100, 340, 200), Color("#1b2934"))
	draw_rect(Rect2(500, -330, 240, 660), Color("#203b35"))
	for wall in WALLS:
		draw_rect(wall, Color("#69717d"))


func _process(delta: float) -> void:
	if not _started or _finished:
		return
	if get_tree().paused:
		_paused_seconds += delta
		return
	_active_seconds += delta
	_walked_pixels += _player.global_position.distance_to(_last_position)
	_last_position = _player.global_position
	match _inventory.get_weight_stage():
		PlayerInventory.WeightStage.BURDENED:
			_burdened_seconds += delta
		PlayerInventory.WeightStage.OVERLOADED:
			_overloaded_seconds += delta


func start_playtest(slots := 2, automated := false) -> bool:
	if _started or slots not in [2, 3]:
		return false
	_automated = automated
	_inventory.configure_capacity(slots, 2.5, 4.0)
	_harness.configure_charge(3)
	_on_inventory_changed()
	_started = true
	_outcome_name = "active"
	_last_position = _player.global_position
	_start_panel.hide()
	_set_simulation_enabled(true)
	_inventory_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	_harness_status.show()
	_interaction_prompt.bind_source($Player/InteractionController)
	_record(&"started", {"slots": slots, "automated": automated})
	_choice_status.text = "위쪽 물품부터 살펴보거나 아래쪽 위험 경로로 들어가세요."
	return true


func get_report() -> Dictionary:
	return {
		"source": "automated" if _automated else "human",
		"outcome": _outcome_name,
		"slot_capacity": _inventory.slot_capacity,
		"burden_weight": _inventory.burden_weight,
		"overload_weight": _inventory.overload_weight,
		"movement_slowdown_enabled": false,
		"active_seconds": snappedf(_active_seconds, 0.01),
		"paused_seconds": snappedf(_paused_seconds, 0.01),
		"walked_pixels": snappedf(_walked_pixels, 0.1),
		"maximum_weight": _maximum_weight,
		"peak_slots": _peak_slots,
		"burdened_seconds": snappedf(_burdened_seconds, 0.01),
		"overloaded_seconds": snappedf(_overloaded_seconds, 0.01),
		"charge_remaining": _harness.get_current_charge(),
		"recovered_count": _recovered_count,
		"unidentified_count": _unknown_count,
		"lost_count": _lost_count,
		"counts": _counts.duplicate(true),
		"events": _events.duplicate(true),
	}


func get_report_text() -> String:
	return _report_text.text


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


func _set_simulation_enabled(enabled: bool) -> void:
	var mode := Node.PROCESS_MODE_PAUSABLE if enabled else Node.PROCESS_MODE_DISABLED
	_player.process_mode = mode
	_hazard.process_mode = mode
	_golem.process_mode = mode


func _record(event: StringName, details: Dictionary = {}) -> void:
	_events.append({"seconds": snappedf(_active_seconds, 0.01), "event": event, "details": details.duplicate(true)})


func _on_inventory_changed() -> void:
	_peak_slots = maxi(_peak_slots, _inventory.get_used_slots())
	_maximum_weight = maxf(_maximum_weight, _inventory.get_total_weight())
	var stage: String = ["정상", "부담", "과적"][_inventory.get_weight_stage()]
	_load_status.text = "가방 %d/%d칸 · 무게 %.1f · %s · 충전 %d/3" % [
		_inventory.get_used_slots(), _inventory.slot_capacity,
		_inventory.get_total_weight(), stage, _harness.get_current_charge(),
	]


func _on_item_added(item: ItemDefinition) -> void:
	_counts.pickups += 1
	_record(&"pickup", {"id": item.stable_id})
	_choice_status.text = "%s 회수. 더 살펴볼지 입구로 돌아갈지 선택하세요." % item.display_name


func _on_item_dropped(item: ItemDefinition) -> void:
	_counts.drops += 1
	_record(&"drop", {"id": item.stable_id})
	_choice_status.text = "%s을(를) 버려 가방에 자리를 만들었습니다." % item.display_name


func _on_item_add_rejected(_item: ItemDefinition, reason: StringName) -> void:
	if reason == PlayerInventory.REJECT_SLOT_LIMIT:
		_counts.slot_rejections += 1
		_record(&"slot_rejected")
		_choice_status.text = "가방이 가득 찼습니다. Tab에서 무엇을 남길지 비교하세요."


func _on_inventory_visibility_changed() -> void:
	if _started and not _finished and _inventory_panel.visible:
		_counts.inventory_opens += 1
		_record(&"inventory_open")


func _on_inspection_completed(_summary: String, _risk_hint: String) -> void:
	_counts.inspections += 1
	_record(&"inspection")
	_choice_status.text = %UnknownPickup.get_inspection_text()


func _on_analysis_completed(_target: Node2D, _information: String) -> void:
	_counts.analyses += 1
	_record(&"precise_analysis")
	_on_inventory_changed()
	_choice_status.text = "정밀 분석에 충전을 썼습니다. 위험 대응에 남길 충전도 생각하세요."


func _on_stabilized(_target: StabilizableHazard) -> void:
	_counts.stabilizations += 1
	_record(&"stabilized")
	_on_inventory_changed()
	_choice_status.text = "잔해를 안정화했습니다. 안쪽까지 들어갈지 결정하세요."


func _on_discharged(_target: BrokenGuardGolem) -> void:
	_counts.discharges += 1
	_record(&"discharged")
	_on_inventory_changed()
	_choice_status.text = "골렘이 잠시 멈췄습니다. 지나가거나 물러날 틈입니다."


func _on_hazard_warning(_duration: float) -> void:
	_record(&"hazard_warning")
	_choice_status.text = "먼지와 진동이 커집니다. Q로 안정화하거나 물러나세요."


func _on_body_caught(body: Node2D) -> void:
	if _started and not _finished and body == _player:
		_record(&"hazard_caught")
		_run.complete_failure()


func _on_golem_warning(_position: Vector2) -> void:
	_counts.golem_warnings += 1
	_record(&"golem_warning")


func _on_golem_chase(_position: Vector2) -> void:
	_counts.chases += 1
	_record(&"golem_chase")


func _on_bypass_entered(body: Node2D) -> void:
	if _started and not _finished and body == _player:
		_counts.bypass_entries += 1
		_record(&"bypass_entered")


func _on_run_ended(outcome: ExplorationOutcome) -> void:
	if _finished:
		return
	if _inventory_panel.visible:
		_inventory_panel.close_inventory()
	_finished = true
	_outcome_name = "safe_return" if outcome.is_safe_return() else "failure"
	if outcome.is_safe_return():
		var result := outcome.get_recovery_result()
		_recovered_count = result.get_item_count()
		_unknown_count = result.get_unidentified_item_count()
	else:
		_lost_count = outcome.get_lost_item_count()
	_record(&"ended", {"outcome": _outcome_name})
	_set_simulation_enabled(false)
	_inventory_panel.process_mode = Node.PROCESS_MODE_DISABLED
	_interaction_prompt.bind_source(null)
	_harness_status.bind_source(null)
	_harness_status.hide()
	_outcome_panel.bind_outcome(outcome)
	_outcome_panel.show()
	_report_text.text = (
		"가방 %d칸 비교\n탐험 %.1f초 · 가방 확인 %.1f초\n최대 무게 %.1f · 최대 사용 %d칸"
		+ "\n부담 %.1f초 · 과적 %.1f초\n조사 %d · 회수 %d · 버리기 %d"
		+ "\n가방 부족 %d · 우회 통과 %d\n정밀 분석 %d · 안정화 %d · 방전 %d"
		+ "\n추적 %d · 남은 충전 %d\n\n기록을 복사해 플레이 의견과 함께 남겨 주세요."
	) % [
		_inventory.slot_capacity, _active_seconds, _paused_seconds, _maximum_weight, _peak_slots,
		_burdened_seconds, _overloaded_seconds, _counts.inspections, _counts.pickups, _counts.drops,
		_counts.slot_rejections, _counts.bypass_entries, _counts.analyses, _counts.stabilizations,
		_counts.discharges, _counts.chases, _harness.get_current_charge(),
	]
	_report_panel.show()
	_load_status.hide()
	_choice_status.text = "결과와 선택 기록입니다. 돌아올 때의 느낌도 함께 남겨 주세요."
	GameLog.info(&"G1Playtest", &"completed", JSON.stringify(get_report()))


func _on_copy_pressed() -> void:
	DisplayServer.clipboard_set(_report_text.text + "\n\n" + JSON.stringify(get_report(), "  "))
	%CopyButton.text = "기록 복사됨"


func _on_retry_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
