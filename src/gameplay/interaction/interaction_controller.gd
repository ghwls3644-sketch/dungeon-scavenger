class_name InteractionController
extends Node

signal prompt_changed(prompt: String, should_show: bool)
signal work_canceled(reason: String)

@export var detector_path: NodePath
@export var interactor_path: NodePath

var _detector: InteractionDetector
var _interactor: Node
var _survival: PlayerSurvival
var _rule: InteractionTimingRule
var _configured := false
var _active := true # Unconfigured G1 scenes retain immediate interactions.
var _committing := false
var _target: Interactable
var _action := Interactable.Action.INSTANT
var _remaining := 0.0
var _duration := 0.0
var _last_prompt := ""


func _ready() -> void:
	_detector = get_node_or_null(detector_path) as InteractionDetector
	_interactor = get_node_or_null(interactor_path)
	assert(_detector != null, "InteractionController requires an InteractionDetector.")
	assert(_interactor != null, "InteractionController requires an interactor node.")
	process_physics_priority = 1
	_detector.current_interactable_changed.connect(_on_current_interactable_changed)
	_publish_prompt()


func configure_timing(rule: InteractionTimingRule, survival: PlayerSurvival) -> bool:
	if _configured:
		return false
	_configured = true
	_active = false
	if rule == null or not rule.is_valid() or not is_instance_valid(survival):
		return false
	_rule = rule.duplicate(true) as InteractionTimingRule
	_survival = survival
	return true


func set_active(active: bool) -> void:
	_active = active and (not _configured or (_rule != null and is_instance_valid(_survival)))
	if not _active:
		cancel_work()
	_publish_prompt()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo() or not event.is_action_pressed(InputActions.INTERACT):
		return
	if interact_current():
		get_viewport().set_input_as_handled()


func interact_current() -> bool:
	if not _active or not can_process() or _committing:
		return false
	if _configured and (not is_instance_valid(_survival) or not _survival.is_exploration_active()):
		return false
	if is_working():
		cancel_work("작업을 취소했습니다.")
		return true
	_detector.refresh_current_interactable()
	var interactable := _detector.get_current_interactable()
	if not is_instance_valid(interactable) or not interactable.is_interaction_available(_interactor):
		return false
	if not _configured:
		return _commit(interactable)
	if not _detector.is_in_reach(interactable):
		return false
	var reason := interactable.get_interaction_block_reason(_interactor)
	if not reason.is_empty():
		work_canceled.emit(reason)
		return false
	var action := interactable.get_interaction_action()
	if action == Interactable.Action.INSTANT:
		return _commit(interactable)
	_target = interactable
	_action = action
	_duration = _get_duration(action)
	_remaining = _duration
	_publish_prompt()
	return true


func is_working() -> bool:
	return _duration > 0.0


func get_work_progress() -> float:
	return 1.0 - _remaining / _duration if is_working() else 0.0


func get_work_remaining() -> float:
	return _remaining / _get_efficiency() if is_working() else 0.0


func cancel_work(reason := "") -> void:
	var was_working := is_working()
	_clear_work()
	_publish_prompt()
	if was_working and not reason.is_empty():
		work_canceled.emit(reason)


func _clear_work() -> void:
	_target = null
	_duration = 0.0
	_remaining = 0.0


func _notification(what: int) -> void:
	if what == NOTIFICATION_PAUSED or what == NOTIFICATION_EXIT_TREE:
		cancel_work()


func _physics_process(delta: float) -> void:
	if not _active:
		return
	if is_working():
		_detector.refresh_current_interactable()
		# Refresh may have canceled the work after a target change.
		if is_working():
			var reason := _get_cancel_reason()
			if not reason.is_empty():
				cancel_work(reason)
			else:
				_remaining = maxf(0.0, _remaining - delta * _get_efficiency())
				if _remaining <= 0.0:
					var target := _target
					_clear_work()
					_commit(target)
	_publish_prompt()


func _get_cancel_reason() -> String:
	if not is_instance_valid(_survival) or not _survival.can_process() or not _survival.is_exploration_active():
		return "작업을 계속할 수 없습니다."
	if not is_instance_valid(_target) or not _target.is_interaction_available(_interactor):
		return "대상이 없어 작업을 취소했습니다."
	if _target != _detector.get_current_interactable() or not _detector.is_in_reach(_target):
		return "대상에서 벗어나 작업을 취소했습니다."
	if _target.get_interaction_action() != _action:
		return "대상 상태가 바뀌어 작업을 취소했습니다."
	return _target.get_interaction_block_reason(_interactor)


func _commit(target: Interactable) -> bool:
	_committing = true
	var completed := target.interact(_interactor)
	_committing = false
	_detector.refresh_current_interactable()
	return completed


func get_current_prompt() -> String:
	if not _active or not is_instance_valid(_detector):
		return ""
	if is_working():
		return "%s 중 %d%% · 남은 %.1f초\n다시 E: 취소 · 대상에서 벗어나면 취소" % [
			"조사" if _action == Interactable.Action.INSPECT else "회수",
			floori(get_work_progress() * 100.0), get_work_remaining(),
		]
	var interactable := _detector.get_current_interactable()
	if not is_instance_valid(interactable) or not interactable.is_interaction_available(_interactor):
		return ""
	var prompt := interactable.get_interaction_prompt()
	if _configured and _rule != null and interactable.get_interaction_action() != Interactable.Action.INSTANT:
		prompt += " · %.1f초" % (_get_duration(interactable.get_interaction_action()) / _get_efficiency())
	return prompt


func _get_duration(action: Interactable.Action) -> float:
	return _rule.inspection_duration if action == Interactable.Action.INSPECT else _rule.recovery_duration


func _get_efficiency() -> float:
	return _survival.get_interaction_multiplier() if is_instance_valid(_survival) else 1.0


func _on_current_interactable_changed(interactable: Interactable) -> void:
	if is_working() and interactable != _target:
		cancel_work("대상이 바뀌어 작업을 취소했습니다.")
	_publish_prompt()


func _publish_prompt() -> void:
	var prompt := get_current_prompt()
	if prompt != _last_prompt:
		_last_prompt = prompt
		prompt_changed.emit(prompt, not prompt.is_empty())
