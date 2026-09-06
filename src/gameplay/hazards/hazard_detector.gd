class_name HazardDetector
extends Area2D

signal current_hazard_changed(hazard: StabilizableHazard)
signal current_harness_target_changed(target: Node2D)

var _candidates: Array[Node2D] = []
var _current_hazard: StabilizableHazard
var _current_target: Node2D
var _current_information := ""


func _ready() -> void:
	area_entered.connect(_on_target_entered)
	area_exited.connect(_on_target_exited)
	body_entered.connect(_on_target_entered)
	body_exited.connect(_on_target_exited)


func _physics_process(_delta: float) -> void:
	_update_current_hazard()


func get_current_hazard() -> StabilizableHazard:
	return _current_hazard if is_instance_valid(_current_hazard) else null


func get_current_harness_target() -> Node2D:
	if not is_instance_valid(_current_target) or _current_target.is_queued_for_deletion():
		return null
	return _current_target


func refresh_current_hazard() -> void:
	_update_current_hazard(true)


func _on_target_entered(target: Node2D) -> void:
	if not (target is StabilizableHazard or target is BrokenGuardGolem) or target in _candidates:
		return

	_candidates.append(target)
	_update_current_hazard()


func _on_target_exited(target: Node2D) -> void:
	_candidates.erase(target)
	_update_current_hazard()


func _update_current_hazard(force_emit := false) -> void:
	var nearest: Node2D
	var nearest_distance_squared := INF
	var nearest_has_action := false
	var nearest_hazard: StabilizableHazard
	var hazard_distance_squared := INF

	for candidate in _candidates.duplicate():
		if not is_instance_valid(candidate):
			_candidates.erase(candidate)
			continue
		if candidate.is_queued_for_deletion():
			continue

		var distance_squared := global_position.distance_squared_to(candidate.global_position)
		var has_action := false
		if candidate is StabilizableHazard:
			has_action = candidate.can_stabilize()
			if has_action and distance_squared < hazard_distance_squared:
				nearest_hazard = candidate
				hazard_distance_squared = distance_squared
		else:
			has_action = (candidate as BrokenGuardGolem).can_emergency_discharge()

		# Prefer an actionable threat over a target that only offers information.
		if nearest == null or (has_action and not nearest_has_action) or (
			has_action == nearest_has_action and distance_squared < nearest_distance_squared
		):
			nearest = candidate
			nearest_distance_squared = distance_squared
			nearest_has_action = has_action

	if force_emit or nearest_hazard != _current_hazard:
		_current_hazard = nearest_hazard
		current_hazard_changed.emit(_current_hazard)

	var information := ""
	if nearest is StabilizableHazard:
		information = nearest.get_precise_analysis()
	elif nearest is BrokenGuardGolem:
		information = nearest.get_precise_analysis()
	if force_emit or nearest != _current_target or information != _current_information:
		_current_target = nearest
		_current_information = information
		current_harness_target_changed.emit(_current_target)
