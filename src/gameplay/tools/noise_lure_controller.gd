class_name NoiseLureController
extends Node2D

signal status_changed
signal lure_landed(position: Vector2, radius: float)
signal throw_rejected(reason: String)

@export var player_path: NodePath
@export var rule: NoiseLureRule
@export_flags_2d_physics var obstruction_mask := 8

var _active := false
var _initialized := false
var _remaining := 0
var _pressed := false
var _pending := false
var _requested_position := Vector2.ZERO
var _aim_viewport_position := Vector2.ZERO
var _flying := false
var _flight_elapsed := 0.0
var _origin := Vector2.ZERO
var _landing_position := Vector2.ZERO
var _preview_position := Vector2.ZERO
var _marker_remaining := 0.0

@onready var _player := get_node_or_null(player_path) as PlayerController


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_aim_viewport_position = InputActions.get_aim_position(get_viewport())


func set_active(active: bool) -> void:
	_active = active
	if active and not _initialized and rule != null and rule.is_valid():
		_remaining = rule.starting_uses
		_initialized = true
	_pressed = InputActions.is_pressed(InputActions.USE_TOOL)
	cancel_pending()
	if not active:
		_flying = false
		_marker_remaining = 0.0
	status_changed.emit()
	queue_redraw()


func cancel_pending() -> void:
	_pending = false


func get_remaining_uses() -> int:
	return _remaining


func get_capacity() -> int:
	return rule.starting_uses if rule != null and rule.is_valid() else 0


func is_in_flight() -> bool:
	return _flying


func get_landing_position() -> Vector2:
	return _landing_position


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		cancel_pending()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_aim_viewport_position = event.position
		return
	if event.is_action_released(InputActions.USE_TOOL):
		_pressed = false
		return
	if not event.is_action_pressed(InputActions.USE_TOOL) or event.is_echo() or _pressed:
		return
	_pressed = true
	if not _can_process_tool() or _flying or _pending:
		return
	if _remaining <= 0:
		throw_rejected.emit("소음 유인물이 없습니다.")
		return
	_requested_position = _mouse_world_position()
	_pending = true


func _physics_process(delta: float) -> void:
	if not _can_process_tool():
		cancel_pending()
		queue_redraw()
		return
	_preview_position = _calculate_destination(_mouse_world_position())
	if _pending:
		_pending = false
		_launch(_requested_position)
	elif _flying:
		_flight_elapsed += delta
		if _flight_elapsed >= rule.flight_duration:
			_flying = false
			_marker_remaining = rule.marker_duration
			status_changed.emit()
			lure_landed.emit(_landing_position, rule.hearing_radius)
	else:
		_marker_remaining = maxf(_marker_remaining - delta, 0.0)
	queue_redraw()


func _can_process_tool() -> bool:
	return (
		_active and not get_tree().paused and is_instance_valid(_player)
		and _player.can_process() and rule != null and rule.is_valid()
	)


func _mouse_world_position() -> Vector2:
	return get_canvas_transform().affine_inverse() * _aim_viewport_position


func _calculate_destination(target: Vector2) -> Vector2:
	var origin := _player.global_position
	if not target.is_finite() or origin.distance_to(target) < rule.minimum_distance:
		return origin
	var destination := origin + (target - origin).limit_length(rule.maximum_distance)
	var query := PhysicsRayQueryParameters2D.create(origin, destination, obstruction_mask)
	query.hit_from_inside = true
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		var hit_position: Vector2 = hit.position
		var distance := maxf(origin.distance_to(hit_position) - rule.wall_clearance, 0.0)
		destination = origin + (destination - origin).normalized() * distance
	return destination


func _launch(target: Vector2) -> void:
	var destination := _calculate_destination(target)
	if _player.global_position.distance_to(destination) < rule.minimum_distance:
		throw_rejected.emit("너무 가깝거나 벽에 막혀 던질 수 없습니다.")
		return
	_origin = _player.global_position
	_landing_position = destination
	_remaining -= 1
	_flight_elapsed = 0.0
	_marker_remaining = 0.0
	_flying = true
	status_changed.emit()


func _draw() -> void:
	if not _can_process_tool():
		return
	var gold := Color(1.0, 0.82, 0.35, 0.9)
	if _flying:
		draw_line(to_local(_origin), to_local(_landing_position), Color(1, 0.82, 0.35, 0.35), 2.0)
		var fraction := clampf(_flight_elapsed / rule.flight_duration, 0.0, 1.0)
		var point := _origin.lerp(_landing_position, fraction) + Vector2(0, -sin(fraction * PI) * 20.0)
		draw_circle(to_local(point), 7.0, gold)
	elif _remaining > 0 and _player.global_position.distance_to(_preview_position) >= rule.minimum_distance:
		var point := to_local(_preview_position)
		draw_line(point - Vector2(10, 0), point + Vector2(10, 0), gold, 2.0)
		draw_line(point - Vector2(0, 10), point + Vector2(0, 10), gold, 2.0)
	if _marker_remaining > 0.0:
		var radius := lerpf(12.0, 32.0, 1.0 - _marker_remaining / rule.marker_duration)
		draw_arc(to_local(_landing_position), radius, 0, TAU, 32, gold, 2.0)
		draw_circle(to_local(_landing_position), 5.0, gold)
