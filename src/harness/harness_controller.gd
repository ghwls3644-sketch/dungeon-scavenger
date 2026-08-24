class_name HarnessController
extends Node

signal charge_changed(current_charge: int, charge_capacity: int)
signal status_changed(prompt: String, should_show_prompt: bool, current_charge: int, charge_capacity: int)
signal action_succeeded(hazard: StabilizableHazard)
signal action_rejected(reason: StringName)

const REJECT_NO_TARGET: StringName = &"no_target"
const REJECT_INVALID_COST: StringName = &"invalid_cost"
const REJECT_INSUFFICIENT_CHARGE: StringName = &"insufficient_charge"
const REJECT_TARGET_UNAVAILABLE: StringName = &"target_unavailable"

@export var detector_path: NodePath

var _detector: HazardDetector
var _charge_capacity := 0
var _current_charge := 0


func _ready() -> void:
	_detector = get_node_or_null(detector_path) as HazardDetector
	assert(_detector != null, "HarnessController requires a HazardDetector.")
	_detector.current_hazard_changed.connect(_on_current_hazard_changed)
	_publish_status()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed(InputActions.USE_HARNESS):
		return
	if not use_current_harness_action():
		return

	get_viewport().set_input_as_handled()


func configure_charge(capacity: int, starting_charge := -1) -> bool:
	if capacity < 0:
		return false

	_charge_capacity = capacity
	_current_charge = capacity if starting_charge < 0 else clampi(starting_charge, 0, capacity)
	charge_changed.emit(_current_charge, _charge_capacity)
	_publish_status()
	return true


func get_charge_capacity() -> int:
	return _charge_capacity


func get_current_charge() -> int:
	return _current_charge


func get_current_prompt() -> String:
	var hazard := _detector.get_current_hazard()
	if hazard == null or not hazard.can_stabilize():
		return ""
	return hazard.get_harness_prompt()


func use_current_harness_action() -> bool:
	var hazard := _detector.get_current_hazard()
	if hazard == null:
		return _reject_action(REJECT_NO_TARGET)

	var charge_cost := hazard.get_stabilization_charge_cost()
	if charge_cost <= 0:
		return _reject_action(REJECT_INVALID_COST)
	if _current_charge < charge_cost:
		return _reject_action(REJECT_INSUFFICIENT_CHARGE)
	if not hazard.stabilize():
		return _reject_action(REJECT_TARGET_UNAVAILABLE)

	_current_charge -= charge_cost
	charge_changed.emit(_current_charge, _charge_capacity)
	action_succeeded.emit(hazard)
	_detector.refresh_current_hazard()
	_publish_status()
	return true


func publish_status() -> void:
	_publish_status()


func _on_current_hazard_changed(_hazard: StabilizableHazard) -> void:
	_publish_status()


func _publish_status() -> void:
	var prompt := get_current_prompt()
	status_changed.emit(prompt, not prompt.is_empty(), _current_charge, _charge_capacity)


func _reject_action(reason: StringName) -> bool:
	action_rejected.emit(reason)
	_publish_status()
	return false
