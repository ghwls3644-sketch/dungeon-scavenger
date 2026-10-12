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
const REJECT_MODULE_MISSING: StringName = &"module_missing"

@export var detector_path: NodePath

var _detector: HazardDetector
var _charge_capacity := 0
var _current_charge := 0
var _action_in_progress := false
var _analyzed_target: Node2D
var _precise_information := ""
var _modules: Array[String] = HarnessModules.ALL.duplicate()
var _modules_configured := false
var _observation_improved := false
var _golem_bonus := 0.0
var _door_bonus := 0.0
var _analysis_revision := -1
var _displayed_precise := ""


func configure_modules(modules: Array[String], upgrades: Array[String] = [], rule: HarnessUpgradeRule = null) -> bool:
	if _modules_configured or _action_in_progress or modules.size() not in [2, 3] \
			or not HarnessModules.is_valid(modules, modules.size()) \
			or not HarnessUpgradeRule.is_valid_owned(upgrades) \
			or (not upgrades.is_empty() and (rule == null or not rule.is_valid())):
		return false
	_modules = modules.duplicate()
	_observation_improved = HarnessUpgradeRule.OBSERVATION in upgrades and HarnessModules.ANALYSIS in modules
	if HarnessUpgradeRule.EMERGENCY in upgrades and HarnessModules.EMERGENCY in modules:
		_golem_bonus = rule.golem_bonus
		_door_bonus = rule.door_bonus
	_modules_configured = true
	_publish_status()
	return true


func has_module(id: String) -> bool:
	return id in _modules


func _process(_delta: float) -> void:
	if not is_instance_valid(_detector) or not _observation_improved:
		return
	var precise := get_precise_analysis()
	if precise != _displayed_precise:
		_displayed_precise = precise
		_publish_status()


func get_action_module() -> String:
	var target := _detector.get_current_harness_target()
	if target is StabilizableHazard:
		return target.get_harness_module()
	if target is BrokenGuardGolem:
		return HarnessModules.EMERGENCY
	return ""


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
	var required := get_action_module()
	if target is BrokenGuardGolem and target.can_emergency_discharge():
		if not has_module(required):
			return "골렘 잠깐 멈추기\n비상 방전 미장착 · 거점에서 변경"
		var cost: int = target.get_discharge_charge_cost()
		return "골렘 잠깐 멈추기\n충전 부족 (필요 %d)" % cost if _current_charge < cost else "골렘 잠깐 멈추기 · 충전 %d" % cost
	if not required.is_empty() and not has_module(required):
		return "%s 미장착 · 거점에서 변경" % HarnessModules.label(required)
	if target is StabilizableHazard and target.can_stabilize():
		return "%s · 충전 %d" % [target.get_harness_prompt(), target.get_stabilization_charge_cost()]
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
	if _read_precise_information(target) != _precise_information or _read_revision(target) != _analysis_revision:
		return ""
	if _observation_improved:
		var remaining := -1.0
		if target is StabilizableHazard or target is BrokenGuardGolem:
			remaining = target.get_analysis_remaining()
		if is_finite(remaining) and remaining >= 0.0:
			return "%s\n현재 상태 남은 시간 약 %.1f초" % [_precise_information, floorf(remaining * 10.0) / 10.0]
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
		not _action_in_progress and can_process() and not get_tree().paused and has_module(HarnessModules.ANALYSIS)
		and cost > 0 and cost <= _current_charge
		and get_precise_analysis().is_empty()
		and not _read_precise_information(_detector.get_current_harness_target()).is_empty()
	)


func analyze_current_target() -> bool:
	if _action_in_progress or not can_process() or get_tree().paused:
		return false
	if not has_module(HarnessModules.ANALYSIS):
		return _reject_action(REJECT_MODULE_MISSING)
	_detector.refresh_current_hazard()
	var target := _detector.get_current_harness_target()
	if target == null:
		return _reject_action(REJECT_NO_TARGET)
	if not get_precise_analysis().is_empty():
		return _reject_action(REJECT_ALREADY_ANALYZED)
	var information := _read_precise_information(target)
	var revision := _read_revision(target)
	var analysis_cost := get_analysis_charge_cost()
	if information.is_empty():
		return _reject_action(REJECT_TARGET_UNAVAILABLE)
	if not _reserve_charge(analysis_cost):
		return false
	if not is_instance_valid(target) or target != _detector.get_current_harness_target() or revision != _read_revision(target) \
			or information != _read_precise_information(target):
		_current_charge += analysis_cost
		_action_in_progress = false
		return _reject_action(REJECT_TARGET_UNAVAILABLE)

	_analyzed_target = target
	_precise_information = information
	_analysis_revision = revision
	charge_changed.emit(_current_charge, _charge_capacity)
	analysis_completed.emit(target, information)
	_action_in_progress = false
	_publish_status()
	return true


func use_current_harness_action() -> bool:
	if _action_in_progress or not can_process() or get_tree().paused:
		return false
	_detector.refresh_current_hazard()
	var target := _detector.get_current_harness_target()
	if target == null:
		return _reject_action(REJECT_NO_TARGET)

	var charge_cost := 0
	if not has_module(get_action_module()):
		return _reject_action(REJECT_MODULE_MISSING)
	if target is StabilizableHazard and target.can_stabilize():
		charge_cost = target.get_stabilization_charge_cost()
	elif target is BrokenGuardGolem and target.can_emergency_discharge():
		charge_cost = target.get_discharge_charge_cost()
	else:
		return _reject_action(REJECT_TARGET_UNAVAILABLE)
	if not _reserve_charge(charge_cost):
		return false

	var succeeded := false
	if target is DoorHoldTarget:
		succeeded = target.stabilize_with_bonus(_door_bonus)
	elif target is StabilizableHazard:
		succeeded = target.stabilize()
	elif target is BrokenGuardGolem:
		succeeded = target.emergency_discharge(_golem_bonus)
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


func commit_charge_action(charge_cost: int, action: Callable) -> bool:
	if _action_in_progress or not can_process() or get_tree().paused or not action.is_valid():
		return false
	if not _reserve_charge(charge_cost):
		return false
	# The result callback commits before charge signals; nested actions cannot
	# spend the reservation or publish a second result during either notification.
	var succeeded: bool = action.call()
	if not succeeded:
		_current_charge += charge_cost
	charge_changed.emit(_current_charge, _charge_capacity)
	_publish_status()
	_action_in_progress = false
	return succeeded


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


func _read_revision(target: Node2D) -> int:
	if target is StabilizableHazard or target is BrokenGuardGolem:
		return target.get_analysis_revision()
	return -1


func _on_current_target_changed(target: Node2D) -> void:
	if target != _analyzed_target or _read_precise_information(target) != _precise_information \
			or _read_revision(target) != _analysis_revision:
		_analyzed_target = null
		_precise_information = ""
		_analysis_revision = -1
	_publish_status()


func _publish_status() -> void:
	var prompt := get_current_prompt()
	status_changed.emit(prompt, not prompt.is_empty(), _current_charge, _charge_capacity)


func _reject_action(reason: StringName) -> bool:
	action_rejected.emit(reason)
	_publish_status()
	return false
