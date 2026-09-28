class_name EmergencyEscape
extends Interactable

@export var rule: EmergencyEscapeRule
@export var player_path: NodePath
@export var run_path: NodePath
@export var survival_path: NodePath
@export var route_probe_path: NodePath

var _rule: EmergencyEscapeRule
var _player: PlayerController
var _run: ExplorationRun
var _survival: PlayerSurvival
var _probe: FixedReturnRouteProbe
var _detector: InteractionDetector
var _harness: HarnessController
var _active := false
var _ended := false
var _route_lost := false
var _deadline := 0.0
var _preparation := 0.0
var _preparing := false
var _start_position := Vector2.ZERO
var _start_health := 0
var _committing := false


func _ready() -> void:
	process_physics_priority = 3 # After movement, hazards and passage changes.
	_player = get_node_or_null(player_path) as PlayerController
	_run = get_node_or_null(run_path) as ExplorationRun
	_survival = get_node_or_null(survival_path) as PlayerSurvival
	_probe = get_node_or_null(route_probe_path) as FixedReturnRouteProbe
	if is_instance_valid(_player):
		_detector = _player.get_node("InteractionDetector") as InteractionDetector
		_harness = _player.get_node("HarnessController") as HarnessController
	if rule != null and rule.is_valid():
		_rule = rule.duplicate(true) as EmergencyEscapeRule


func is_configured() -> bool:
	return _rule != null and is_instance_valid(_player) and is_instance_valid(_run) and is_instance_valid(_survival) and is_instance_valid(_probe) and _probe.is_configured()


func set_exploration_active(active: bool) -> void:
	if not active:
		if _active:
			_ended = true
		_active = false
		cancel_preparation()
		return
	_active = not _ended and is_configured() and _survival.is_exploration_active() and _run.is_active()


func is_route_lost() -> bool:
	return _route_lost


func get_time_remaining() -> float:
	return _deadline


func is_preparing() -> bool:
	return _preparing


func get_preparation_remaining() -> float:
	return _preparation


func get_preparation_duration() -> float:
	return _rule.preparation_duration if _rule != null else 0.0


func get_charge_cost() -> int:
	return _rule.charge_cost if _rule != null else 0


func is_interaction_available(interactor: Node = null) -> bool:
	return super.is_interaction_available(interactor) and _can_act() and _route_lost and (interactor == null or interactor == _player)


func get_interaction_prompt() -> String:
	if _rule == null:
		return ""
	if _preparing:
		return "비상 탈출 준비 %.1f초 · 다시 E: 취소\n움직이거나 메뉴를 열면 취소" % _preparation
	return "비상 탈출 · %.1f초 · 충전 %d · 회수품 유지" % [_rule.preparation_duration, _rule.charge_cost]


func get_interaction_block_reason(_interactor: Node) -> String:
	if not _preparing and _harness.get_current_charge() < _rule.charge_cost:
		return "비상 탈출에 필요한 하네스 충전이 부족합니다."
	return ""


func interact(interactor: Node) -> bool:
	# Validate reach before Interactable acquires its re-entry lock, because
	# the detector deliberately excludes a currently committing interactable.
	if interactor != _player or not is_instance_valid(_detector) or not _detector.is_in_reach(self):
		return false
	return super.interact(interactor)


func _perform_interaction(_interactor: Node) -> bool:
	if _preparing:
		cancel_preparation()
		return true
	if _probe.has_return_route() or not get_interaction_block_reason(_player).is_empty():
		return false
	_preparing = true
	_preparation = _rule.preparation_duration
	_start_position = _player.global_position
	_start_health = _survival.get_health()
	return true


func cancel_preparation() -> void:
	_preparing = false
	_preparation = 0.0


func _notification(what: int) -> void:
	if what in [NOTIFICATION_PAUSED, NOTIFICATION_EXIT_TREE]:
		cancel_preparation()


func _can_act() -> bool:
	return _active and not _committing and can_process() and is_configured() and _survival.is_exploration_active() and _run.is_active()


func _physics_process(delta: float) -> void:
	if not _can_act():
		return
	if _probe.has_return_route():
		_route_lost = false
		_deadline = 0.0
		cancel_preparation()
		return
	if not _route_lost:
		_route_lost = true
		_deadline = _rule.time_limit
		return
	_deadline = maxf(0.0, _deadline - delta)
	# A deadline reached on the completion tick wins over preparation completion.
	if _deadline <= 0.0:
		_committing = true
		cancel_preparation()
		_run.complete_failure(&"escape_timeout")
		_committing = false
		return
	if not _preparing:
		return
	_detector.refresh_current_interactable()
	if _detector.get_current_interactable() != self or not _detector.is_in_reach(self) or _player.global_position.distance_to(_start_position) > 1.0 or _survival.get_health() < _start_health or _harness.get_current_charge() < _rule.charge_cost:
		cancel_preparation()
		return
	_preparation = maxf(0.0, _preparation - delta)
	if _preparation <= 0.0:
		_committing = true
		cancel_preparation()
		_harness.commit_charge_action(_rule.charge_cost, _run.complete_emergency_return)
		_committing = false
