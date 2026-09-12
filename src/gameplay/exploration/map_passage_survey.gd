class_name MapPassageSurvey
extends Node2D

@export var observation_distance := 0.0
@export_flags_2d_physics var obstruction_mask := 0

var _state: ExplorationMapState
var _observer: Node2D
var _passages: Array[MapPassageDefinition] = []
var _enabled := false


func configure(state: ExplorationMapState, observer: Node2D) -> bool:
	if _state != null or state == null or not state.is_configured() or not is_instance_valid(observer):
		return false
	if not is_finite(observation_distance) or observation_distance <= 0.0 or obstruction_mask == 0:
		return false
	_state = state
	_observer = observer
	_passages = state.get_definition().passages
	return true


func set_observation_enabled(enabled: bool) -> void:
	_enabled = enabled


func _physics_process(_delta: float) -> void:
	if not _enabled or _state == null or not is_instance_valid(_observer) or not _observer.is_inside_tree():
		return
	var space := get_world_2d().direct_space_state
	for passage in _passages:
		var start := to_global(passage.start)
		var end := to_global(passage.end)
		if not _can_observe(start, space) and not _can_observe(end, space):
			continue
		var direction := end - start
		# Check the travel footprint, not just a zero-width line through a narrow gap.
		var width_scale := global_transform.basis_xform((passage.end - passage.start).normalized().orthogonal()).length()
		var shape := CapsuleShape2D.new()
		shape.radius = passage.clearance_radius * width_scale
		shape.height = direction.length() + shape.radius * 2.0
		var query := PhysicsShapeQueryParameters2D.new()
		query.shape = shape
		query.transform = Transform2D(direction.angle() - PI * 0.5, (start + end) * 0.5)
		query.collision_mask = obstruction_mask
		query.collide_with_areas = false
		query.exclude = _observer_exclusions()
		var blocked := not space.intersect_shape(query, 1).is_empty()
		_state.observe_passage(passage.stable_id, ExplorationMapState.PassageStatus.BLOCKED if blocked else ExplorationMapState.PassageStatus.OPEN)


func _can_observe(point: Vector2, space: PhysicsDirectSpaceState2D) -> bool:
	if _observer.global_position.distance_to(point) > observation_distance:
		return false
	var ray := PhysicsRayQueryParameters2D.create(_observer.global_position, point, obstruction_mask, _observer_exclusions())
	ray.collide_with_areas = false
	ray.hit_from_inside = true
	return space.intersect_ray(ray).is_empty()


func _observer_exclusions() -> Array[RID]:
	var excluded: Array[RID] = []
	if _observer is CollisionObject2D:
		excluded.append((_observer as CollisionObject2D).get_rid())
	return excluded
