class_name HarnessController
extends Node

signal charge_changed(current_charge: int, charge_capacity: int)
signal status_changed(prompt: String, should_show_prompt: bool, current_charge: int, charge_capacity: int)
signal action_succeeded(hazard: StabilizableHazard)
signal discharge_succeeded(golem: BrokenGuardGolem)
signal analysis_completed(target: Node2D, information: String)
signal action_rejected(reason: StringName)

const REJECT_NO_TARGET: StringName = &"no_target"
const REJECT_INVALID_COST: StringName = &"invalid_cost"
const REJECT_INSUFFICIENT_CHARGE: StringName = &"insufficient_charge"
const REJECT_TARGET_UNAVAILABLE: StringName = &"target_unavailable"
const REJECT_ALREADY_ANALYZED: StringName = &"already_analyzed"

@export var detector_path: NodePath

var _detector: HazardDetector
var _charge_capacity := 0
var _current_charge := 0
var _action_in_progress := false
var _analyzed_target: Node2D
var _precise_information := ""


func _ready() -> void:
	_detector = get_node_or_null(detector_path) as HazardDetector
	assert(_detector != null, "HarnessController requires a HazardDetector.")
	_detector.current_harness_target_changed.connect(_on_current_target_changed)
	_publish_status()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed(InputActions.USE_HARNESS):
		return
	use_current_harness_action()
	get_viewport().set_input_as_handled()


func configure_charge(capacity: int, starting_charge := -1) -> bool:
	if capacity < 0 or _action_in_progress:
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
	var target := _detector.get_current_harness_target()
	if target is StabilizableHazard and target.can_stabilize():
		return "%s · 충전 %d" % [target.get_harness_prompt(), target.get_stabilization_charge_cost()]
	if target is BrokenGuardGolem and target.can_emergency_discharge():
		return "경비 골렘 비상 방전 · 충전 %d" % target.get_discharge_charge_cost()
	return ""


func get_basic_analysis() -> String:
	var target := _detector.get_current_harness_target()
	if target is StabilizableHazard:
		return target.get_basic_analysis()
	if target is BrokenGuardGolem:
		return target.get_basic_analysis()
	return ""


func get_precise_analysis() -> String:
	var target := _detector.get_current_harness_target()
	if not is_instance_valid(_analyzed_target) or target != _analyzed_target:
		return ""
	# A purchased reading describes the current state, never a later state for free.
	if _read_precise_information(target) != _precise_information:
		return ""
	return _precise_information


func get_analysis_charge_cost() -> int:
	var target := _detector.get_current_harness_target()
	if target is StabilizableHazard:
		return target.get_analysis_charge_cost()
	if target is BrokenGuardGolem:
		return target.get_analysis_charge_cost()
	return 0


func can_analyze_current_target() -> bool:
	var cost := get_analysis_charge_cost()
	return (
		not _action_in_progress and not get_tree().paused
		and cost > 0 and cost <= _current_charge
		and get_precise_analysis().is_empty()
		and not _read_precise_information(_detector.get_current_harness_target()).is_empty()
	)


func analyze_current_target() -> bool:
	if _action_in_progress or get_tree().paused:
		return false
	_detector.refresh_current_hazard()
	var target := _detector.get_current_harness_target()
	if target == null:
		return _reject_action(REJECT_NO_TARGET)
	if not get_precise_analysis().is_empty():
		return _reject_action(REJECT_ALREADY_ANALYZED)
	var information := _read_precise_information(target)
	if information.is_empty():
		return _reject_action(REJECT_TARGET_UNAVAILABLE)
	if not _reserve_charge(get_analysis_charge_cost()):
		return false

	_analyzed_target = target
	_precise_information = information
	charge_changed.emit(_current_charge, _charge_capacity)
	analysis_completed.emit(target, information)
	_action_in_progress = false
	_publish_status()
	return true


func use_current_harness_action() -> bool:
	if _action_in_progress or get_tree().paused:
		return false
	_detector.refresh_current_hazard()
	var target := _detector.get_current_harness_target()
	if target == null:
		return _reject_action(REJECT_NO_TARGET)

	var charge_cost := 0
	if target is StabilizableHazard and target.can_stabilize():
		charge_cost = target.get_stabilization_charge_cost()
	elif target is BrokenGuardGolem and target.can_emergency_discharge():
		charge_cost = target.get_discharge_charge_cost()
	else:
		return _reject_action(REJECT_TARGET_UNAVAILABLE)
	if not _reserve_charge(charge_cost):
		return false

	var succeeded := false
	if target is StabilizableHazard:
		succeeded = target.stabilize()
	elif target is BrokenGuardGolem:
		succeeded = target.emergency_discharge()
	if not succeeded:
		_current_charge += charge_cost
		_action_in_progress = false
		return _reject_action(REJECT_TARGET_UNAVAILABLE)

	charge_changed.emit(_current_charge, _charge_capacity)
	if target is StabilizableHazard:
		action_succeeded.emit(target)
	elif target is BrokenGuardGolem:
		discharge_succeeded.emit(target)
	_action_in_progress = false
	_detector.refresh_current_hazard()
	_publish_status()
	return true


func publish_status() -> void:
	_publish_status()


func _reserve_charge(charge_cost: int) -> bool:
	if charge_cost <= 0:
		return _reject_action(REJECT_INVALID_COST)
	if _current_charge < charge_cost:
		return _reject_action(REJECT_INSUFFICIENT_CHARGE)
	# Reserve before target callbacks; nested commands cannot spend the same charge.
	_action_in_progress = true
	_current_charge -= charge_cost
	return true


func _read_precise_information(target: Node2D) -> String:
	if target is StabilizableHazard:
		return target.get_precise_analysis()
	if target is BrokenGuardGolem:
		return target.get_precise_analysis()
	return ""


func _on_current_target_changed(target: Node2D) -> void:
	if target != _analyzed_target or _read_precise_information(target) != _precise_information:
		_analyzed_target = null
		_precise_information = ""
	_publish_status()


func _publish_status() -> void:
	var prompt := get_current_prompt()
	status_changed.emit(prompt, not prompt.is_empty(), _current_charge, _charge_capacity)


func _reject_action(reason: StringName) -> bool:
	action_rejected.emit(reason)
	_publish_status()
	return false
