class_name TemporaryDoor
extends DoorInteractable

signal status_changed
signal held

@export var hold_rule: DoorHoldRule

var _rule: DoorHoldRule
var _active := false
var _hold_remaining := 0.0
var _push_elapsed := 0.0
var _contact_frame := -1
var _close_blocked := false

@onready var _status: Label = $Status


func _ready() -> void:
	process_physics_priority = 1 # Consume collision reports after character movement.
	if hold_rule != null and hold_rule.is_valid():
		_rule = hold_rule.duplicate(true) as DoorHoldRule
	_set_open(true)


func set_exploration_active(active: bool) -> void:
	_active = active and _rule != null
	_contact_frame = -1
	$HoldTarget.set_deferred(&"collision_layer", 4 if _active else 0)
	_render()


func is_interaction_available(_interactor: Node = null) -> bool:
	return _active and can_process() and not is_held()


func get_interaction_prompt() -> String:
	return "문 닫기" if is_open else "문 열기"


func get_hold_remaining() -> float:
	return _hold_remaining


func get_push_elapsed() -> float:
	return _push_elapsed


func is_held() -> bool:
	return _hold_remaining > 0.0


func get_status_text() -> String:
	return _status.text


func get_basic_analysis() -> String:
	if not _active:
		return ""
	return "%s\nE로 무료 개폐 · 닫힌 문은 Q로 임시 고정. 골렘은 고정되지 않은 문을 경고 후 밀어 엽니다." % get_status_text()


func get_hold_cost() -> int:
	return _rule.charge_cost if _rule != null else 0


func can_hold() -> bool:
	return _active and can_process() and not is_open and not is_held()


func hold_closed() -> bool:
	if not can_hold():
		return false
	_hold_remaining = _rule.hold_duration
	_push_elapsed = 0.0
	_close_blocked = false
	_render()
	held.emit()
	return true


func note_obstacle_contact(obstacle: Node2D) -> void:
	# Connected only to the expedition golem's actual slide collisions.
	if _active and can_process() and obstacle == _barrier_collision.get_parent():
		_contact_frame = Engine.get_physics_frames()


func _physics_process(delta: float) -> void:
	if not _active or get_tree().paused:
		return
	if is_held():
		_hold_remaining = maxf(0.0, _hold_remaining - delta)
		_push_elapsed = 0.0
		_render()
		return # Expiry never consumes any of the subsequent opening warning.
	if not is_open and _contact_frame == Engine.get_physics_frames():
		# The first contact starts the warning; preceding frame time cannot skip it.
		_push_elapsed = 0.000001 if _push_elapsed == 0.0 else _push_elapsed + delta
		if _push_elapsed >= _rule.push_open_duration:
			_set_open(true)
	else:
		_push_elapsed = 0.0
	_render()


func _perform_interaction(_interactor: Node) -> bool:
	if is_open and _has_body_in_doorway():
		_close_blocked = true
		_render()
		return false
	_set_open(not is_open)
	return true


func _has_body_in_doorway() -> bool:
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = _barrier_collision.shape
	query.transform = _barrier_collision.global_transform
	query.collision_mask = 17 # Player and golem bodies; never close through either.
	query.collide_with_areas = false
	return not get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty()


func _set_open(open: bool) -> void:
	is_open = open
	_push_elapsed = 0.0
	_contact_frame = -1
	_close_blocked = false
	_barrier_collision.set_deferred(&"disabled", open)
	open_state_changed.emit(open)
	_render()


func _render() -> void:
	var text := "문 열림 · E로 닫기" if is_open else "문 닫힘 · E 열기 / Q 고정"
	var color := Color("#9c7558")
	if _close_blocked:
		text = "문 안에 대상이 있어 닫을 수 없습니다"
	elif is_held():
		text = "문 고정 · 잠시 열 수 없음"
		color = Color("#69bcac")
		if _hold_remaining <= _rule.release_warning_duration:
			text = "고정 해제 임박 · 물러날 준비"
			color = Color("#edbd60")
	elif _push_elapsed > 0.0:
		text = "골렘이 문을 밀고 있습니다! 곧 열립니다"
		color = Color("#edbd60")
	_door_visual.color = color
	_door_visual.modulate.a = 0.25 if is_open else 1.0
	if _status.text != text:
		_status.text = text
		status_changed.emit()
