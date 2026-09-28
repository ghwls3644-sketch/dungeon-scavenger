class_name FixedReturnRouteProbe
extends Node2D

# A fixed test layout has two connections to the entrance side. Reopenable
# interior doors are not permanent route loss. This is not a general pathfinder.
@export var observer_path: NodePath
@export var entrance_side := Rect2()
@export var connections: Array[PackedVector2Array] = []
@export var clearance_radius := 14.0

var _observer: Node2D
var _valid := false


func _ready() -> void:
	_observer = get_node_or_null(observer_path) as Node2D
	_valid = is_instance_valid(_observer) and entrance_side.position.is_finite() and entrance_side.size.is_finite() and entrance_side.size.x > 0 and entrance_side.size.y > 0 and is_finite(clearance_radius) and clearance_radius > 0 and not connections.is_empty()
	for segment in connections:
		if segment.size() != 2 or not segment[0].is_finite() or not segment[1].is_finite() or segment[0].is_equal_approx(segment[1]):
			_valid = false


func is_configured() -> bool:
	return _valid and is_instance_valid(_observer) and _observer.is_inside_tree()


func has_return_route() -> bool:
	if not is_configured():
		return false
	if entrance_side.has_point(to_local(_observer.global_position)):
		return true
	for segment in connections:
		var start := to_global(segment[0])
		var end := to_global(segment[1])
		var direction := end - start
		var width_scale := global_transform.basis_xform((segment[1] - segment[0]).normalized().orthogonal()).length()
		var shape := CapsuleShape2D.new()
		shape.radius = clearance_radius * width_scale
		shape.height = direction.length() + shape.radius * 2.0
		var query := PhysicsShapeQueryParameters2D.new()
		query.shape = shape
		query.transform = Transform2D(direction.angle() - PI * 0.5, (start + end) * 0.5)
		query.collision_mask = 8
		query.collide_with_areas = false
		if get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty():
			return true
	return false
