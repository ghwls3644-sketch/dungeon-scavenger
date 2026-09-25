class_name MalfunctioningTrap
extends StabilizableHazard

signal phase_changed(phase: int)
signal stabilized
signal body_caught(body: Node2D)

enum Phase { DORMANT, QUIET, WARNING, ACTIVE, STABILIZED }

@export var cycle_rule: TrapCycleRule
@export var survival_damage := false

var _rule: TrapCycleRule
var _phase := Phase.DORMANT
var _active := false
var _remaining := 0.0
var _quiet_index := 0
var _caught_ids: Array[int] = []

@onready var _status: Label = $Status


func _ready() -> void:
	if cycle_rule != null and cycle_rule.is_valid():
		_rule = cycle_rule.duplicate(true) as TrapCycleRule
	hide()
	body_entered.connect(_on_body_entered)
	_render()


func set_exploration_active(active: bool) -> void:
	if active == _active:
		return
	_active = active and _rule != null
	visible = _active
	set_deferred(&"collision_layer", 4 if _active else 0)
	if _active:
		_quiet_index = 0
		_set_phase(Phase.QUIET, _rule.quiet_durations[0])


func get_phase() -> Phase:
	return _phase


func get_remaining_time() -> float:
	return _remaining


func get_status_text() -> String:
	return _status.text


func get_analysis_charge_cost() -> int:
	return 0


func get_stabilization_charge_cost() -> int:
	return _rule.stabilization_cost if _rule != null else 0


func get_basic_analysis() -> String:
	if not _active:
		return ""
	var consequence := "작동 범위에 들어가면 건강 감소·일시 부상을 입고, 건강이 소진되면 탐험에 실패합니다." if survival_damage else "작동 범위에 들어가면 탐험에 실패합니다."
	return "%s\n불빛이 꺼진 동안 통과하거나 옆으로 돌아가세요. Q로 잠시 멈출 수 있습니다. %s" % [get_status_text(), consequence]


func can_stabilize() -> bool:
	return _active and can_process() and _phase in [Phase.QUIET, Phase.WARNING, Phase.ACTIVE]


func stabilize() -> bool:
	if not can_stabilize():
		return false
	_set_phase(Phase.STABILIZED, _rule.stabilization_duration)
	stabilized.emit()
	return true


func _physics_process(delta: float) -> void:
	if not _active or get_tree().paused:
		return
	_remaining = maxf(0.0, _remaining - delta)
	if _remaining <= 0.0:
		# One transition per tick preserves a full warning even after a long frame.
		match _phase:
			Phase.QUIET, Phase.STABILIZED:
				_set_phase(Phase.WARNING, _rule.warning_duration)
			Phase.WARNING:
				_set_phase(Phase.ACTIVE, _rule.active_duration)
			Phase.ACTIVE:
				_quiet_index = (_quiet_index + 1) % _rule.quiet_durations.size()
				_set_phase(Phase.QUIET, _rule.quiet_durations[_quiet_index])
	if _phase == Phase.ACTIVE:
		for body in get_overlapping_bodies():
			_on_body_entered(body)
	if _phase == Phase.WARNING:
		queue_redraw()


func _on_body_entered(body: Node2D) -> void:
	if not _active or not can_process() or _phase != Phase.ACTIVE:
		return
	if not is_instance_valid(body) or body.is_queued_for_deletion() or not body is PlayerController:
		return
	var body_id := body.get_instance_id()
	if body_id in _caught_ids:
		return
	_caught_ids.append(body_id)
	body_caught.emit(body)


func _set_phase(phase: Phase, duration: float) -> void:
	_phase = phase
	_remaining = duration
	_caught_ids.clear()
	_render()
	phase_changed.emit(_phase)


func _render() -> void:
	match _phase:
		Phase.QUIET:
			_status.text = "함정 대기 · 불빛 꺼짐"
		Phase.WARNING:
			_status.text = "함정 경고 · 점멸! 물러나세요"
		Phase.ACTIVE:
			_status.text = "함정 작동 · 진입 위험"
		Phase.STABILIZED:
			_status.text = "함정 임시 정지 · 다시 점멸하면 후퇴"
		_:
			_status.text = ""
	queue_redraw()


func _draw() -> void:
	if not _active:
		return
	var color := Color("#53646e")
	if _phase == Phase.WARNING:
		# A slow pulse remains legible without rapid flashing.
		color = Color("#edbd60") if fmod(_remaining, 0.8) < 0.5 else Color("#887443")
	elif _phase == Phase.ACTIVE:
		color = Color("#ed675e")
	elif _phase == Phase.STABILIZED:
		color = Color("#69bcac")
	draw_rect(Rect2(-32, -32, 64, 64), color.darkened(0.65))
	draw_rect(Rect2(-32, -32, 64, 64), color, false, 3.0)
	for offset in [-20, 0, 20]:
		draw_line(Vector2(offset, -25), Vector2(offset, 25), color, 3.0)
	if _phase in [Phase.WARNING, Phase.ACTIVE]:
		draw_line(Vector2(-25, -25), Vector2(25, 25), color, 4.0)
		draw_line(Vector2(-25, 25), Vector2(25, -25), color, 4.0)
