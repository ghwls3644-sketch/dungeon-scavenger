class_name HazardDetector
extends Area2D

signal current_hazard_changed(hazard: StabilizableHazard)

var _candidates: Array[StabilizableHazard] = []
var _current_hazard: StabilizableHazard


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


func _physics_process(_delta: float) -> void:
	_update_current_hazard()


func get_current_hazard() -> StabilizableHazard:
	return _current_hazard


func refresh_current_hazard() -> void:
	_update_current_hazard(true)


func _on_area_entered(area: Area2D) -> void:
	var hazard := area as StabilizableHazard
	if hazard == null or hazard in _candidates:
		return

	_candidates.append(hazard)
	_update_current_hazard()


func _on_area_exited(area: Area2D) -> void:
	var hazard := area as StabilizableHazard
	if hazard == null:
		return

	_candidates.erase(hazard)
	_update_current_hazard()


func _update_current_hazard(force_emit := false) -> void:
	var nearest: StabilizableHazard
	var nearest_distance_squared := INF

	for candidate in _candidates.duplicate():
		if not is_instance_valid(candidate):
			_candidates.erase(candidate)
			continue
		if not candidate.can_stabilize():
			continue

		var distance_squared := global_position.distance_squared_to(candidate.global_position)
		if distance_squared < nearest_distance_squared:
			nearest = candidate
			nearest_distance_squared = distance_squared

	if not force_emit and nearest == _current_hazard:
		return

	_current_hazard = nearest
	current_hazard_changed.emit(_current_hazard)
