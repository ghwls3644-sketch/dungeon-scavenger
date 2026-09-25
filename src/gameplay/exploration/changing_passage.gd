class_name ChangingPassage
extends Node2D

signal warning_started
signal passage_blocked

enum Phase { OPEN, WARNING, WAITING, BLOCKED }

@export var rule: PassageChangeRule
@export var trigger_bounds := Rect2(40, -162, 180, 260)

var _rule: PassageChangeRule
var _observer: Node2D
var _phase := Phase.OPEN
var _remaining := 0.0
var _started := false
var _active := false

@onready var _barrier: CollisionShape2D = $Barrier/CollisionShape2D


func _ready() -> void:
	process_physics_priority = 2 # Read the current positions after character movement.
	if rule != null and rule.is_valid():
		_rule = rule.duplicate(true) as PassageChangeRule
	queue_redraw()


func start_exploration(observer: Node2D) -> bool:
	if not is_node_ready() or _started or _rule == null or not is_instance_valid(observer) or not observer.is_inside_tree():
		return false
	if not trigger_bounds.position.is_finite() or not trigger_bounds.size.is_finite() or trigger_bounds.size.x <= 0.0 or trigger_bounds.size.y <= 0.0:
		return false
	_observer = observer
	_started = true
	_active = true
	return true


func end_exploration() -> void:
	_active = false


func get_phase() -> Phase:
	return _phase


func get_warning_remaining() -> float:
	return _remaining


func is_active() -> bool:
	return _active


func _physics_process(delta: float) -> void:
	if not _active or get_tree().paused or not is_instance_valid(_observer) or not _observer.is_inside_tree():
		return
	if _phase == Phase.OPEN:
		if trigger_bounds.has_point(to_local(_observer.global_position)):
			_phase = Phase.WARNING
			_remaining = _rule.warning_duration
			queue_redraw()
			warning_started.emit()
		return # The entry frame starts the warning without consuming prior time.
	if _phase not in [Phase.WARNING, Phase.WAITING]:
		return
	_remaining = maxf(0.0, _remaining - delta)
	if _remaining > 0.0:
		return
	if _has_body_in_passage():
		_phase = Phase.WAITING
		return
	# Called during physics processing, not an overlap callback. Collision and
	# state change together; no actor is moved or damaged to clear the passage.
	_barrier.disabled = false
	_phase = Phase.BLOCKED
	queue_redraw()
	passage_blocked.emit()


func _has_body_in_passage() -> bool:
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = _barrier.shape
	query.transform = _barrier.global_transform
	query.collision_mask = 17 # Player and golem, including bodies entering this tick.
	query.collide_with_areas = false
	query.margin = 2.0
	return not get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty()


func _draw() -> void:
	var bounds := Rect2(-14, -188, 28, 376)
	var color := Color("#edbd60") if _phase in [Phase.WARNING, Phase.WAITING] else Color("#576772")
	if _phase == Phase.BLOCKED:
		draw_rect(bounds, Color("#69717d"))
	else:
		draw_rect(bounds.grow(8), Color(color, 0.2))
		draw_rect(bounds, color, false, 3)
	for y in range(-176, 177, 32):
		draw_line(Vector2(-12, y), Vector2(12, y + 16), color, 3)
