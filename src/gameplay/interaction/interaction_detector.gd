class_name InteractionDetector
extends Area2D

signal current_interactable_changed(interactable: Interactable)

var _candidates: Array[Interactable] = []
var _current_interactable: Interactable


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


func _physics_process(_delta: float) -> void:
	_update_current_interactable()


func get_current_interactable() -> Interactable:
	return _current_interactable


func refresh_current_interactable() -> void:
	_update_current_interactable(true)


func is_in_reach(target: Interactable) -> bool:
	if not is_instance_valid(target) or not target.is_interaction_available():
		return false
	# Query at the current transform; overlap signals can lag behind this tick's move.
	var collision := $CollisionShape2D as CollisionShape2D
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = collision.shape
	query.transform = collision.global_transform
	query.collision_mask = collision_mask
	query.collide_with_areas = true
	query.collide_with_bodies = false
	for hit in get_world_2d().direct_space_state.intersect_shape(query):
		if hit.collider == target:
			return true
	return false


func _on_area_entered(area: Area2D) -> void:
	var interactable := area as Interactable
	if interactable == null or interactable in _candidates:
		return

	_candidates.append(interactable)
	_update_current_interactable()


func _on_area_exited(area: Area2D) -> void:
	var interactable := area as Interactable
	if interactable == null:
		return

	_candidates.erase(interactable)
	_update_current_interactable()


func _update_current_interactable(force_emit := false) -> void:
	var nearest: Interactable
	var nearest_distance_squared := INF

	for candidate in _candidates.duplicate():
		if not is_instance_valid(candidate):
			_candidates.erase(candidate)
			continue
		if not candidate.is_interaction_available():
			continue

		var distance_squared := global_position.distance_squared_to(candidate.global_position)
		if distance_squared < nearest_distance_squared:
			nearest = candidate
			nearest_distance_squared = distance_squared

	if not force_emit and nearest == _current_interactable:
		return

	_current_interactable = nearest
	current_interactable_changed.emit(_current_interactable)
