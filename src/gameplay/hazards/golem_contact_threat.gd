class_name GolemContactThreat
extends Node

signal status_changed
signal body_caught(body: Node2D)

@export var golem_path: NodePath
@export var player_path: NodePath
@export var rule: GolemContactRule

var _golem: BrokenGuardGolem
var _player: PlayerController
var _rule: GolemContactRule
var _active := false
var _caught := false
var _warning := false
var _elapsed := 0.0


func _ready() -> void:
	# Evaluate the live positions after both bodies have moved.
	process_physics_priority = 2
	_golem = get_node_or_null(golem_path) as BrokenGuardGolem
	_player = get_node_or_null(player_path) as PlayerController
	if rule != null and rule.is_valid():
		_rule = rule.duplicate(true) as GolemContactRule


func set_active(active: bool) -> void:
	_active = active and _rule != null and not _caught
	if not _active:
		_clear_warning()


func is_warning() -> bool:
	return _warning


func get_remaining_time() -> float:
	return maxf(_rule.warning_duration - _elapsed, 0.0) if _warning else 0.0


func _physics_process(delta: float) -> void:
	if not _active or _caught:
		return
	if not _is_contact():
		_clear_warning()
		return
	if not _warning:
		_warning = true
		_elapsed = 0.0
		status_changed.emit()
		return # The first contact always grants the full warning, even after a long frame.
	_elapsed += delta
	if _elapsed < _rule.warning_duration:
		status_changed.emit()
		return
	_caught = true
	_active = false
	_clear_warning()
	body_caught.emit(_player)


func _is_contact() -> bool:
	return is_instance_valid(_golem) and not _golem.is_queued_for_deletion() \
		and is_instance_valid(_player) and not _player.is_queued_for_deletion() \
		and _golem.can_process() and _player.can_process() \
		and _golem.get_state() == BrokenGuardGolem.State.CHASE \
		and _golem.global_position.distance_to(_player.global_position) <= _rule.contact_distance \
		and _golem.is_visually_tracking(_player)


func _clear_warning() -> void:
	if not _warning:
		return
	_warning = false
	_elapsed = 0.0
	status_changed.emit()
