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
