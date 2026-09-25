class_name PlayerSurvival
extends Node

signal state_changed
signal incapacitated(cause: StringName)

@export var rule: SurvivalRule

enum State { READY, ACTIVE, ENDED }

var _rule: SurvivalRule
var _state := State.READY
var _health := 0
var _injury_remaining := 0.0


func _ready() -> void:
	if rule != null and rule.is_valid():
		_rule = rule.duplicate(true) as SurvivalRule
		_health = _rule.max_health


func start_exploration() -> bool:
	if _state != State.READY or _rule == null or not can_process():
		return false
	_state = State.ACTIVE
	state_changed.emit()
	return true


func end_exploration() -> void:
	_state = State.ENDED
	_injury_remaining = 0.0
	state_changed.emit()


func apply_trap_damage() -> bool:
	if not _can_receive_input():
		return false
	if _health <= _rule.trap_damage:
		return incapacitate(&"trap_damage")
	_health -= _rule.trap_damage
	# Repeated injury refreshes time; it never compounds the movement penalty.
	_injury_remaining = _rule.injury_duration
	state_changed.emit()
	return true


func incapacitate(cause: StringName = &"") -> bool:
	if not _can_receive_input():
		return false
	# Lock before notifying the run, which may synchronously end this scene.
	_state = State.ENDED
	_health = 0
	_injury_remaining = 0.0
	incapacitated.emit(cause)
	state_changed.emit()
	return true


func get_health() -> int:
	return _health


func is_exploration_active() -> bool:
	return _state == State.ACTIVE


func get_max_health() -> int:
	return _rule.max_health if _rule != null else 0


func get_injury_remaining() -> float:
	return _injury_remaining


func get_movement_multiplier() -> float:
	return _rule.injury_movement_multiplier if _injury_remaining > 0.0 else 1.0


func get_interaction_multiplier() -> float:
	return _rule.injury_interaction_multiplier if _injury_remaining > 0.0 else 1.0


func _can_receive_input() -> bool:
	return _state == State.ACTIVE and can_process() and not is_queued_for_deletion()


func _physics_process(delta: float) -> void:
	if not _can_receive_input() or _injury_remaining <= 0.0:
		return
	_injury_remaining = maxf(0.0, _injury_remaining - delta)
	if _injury_remaining == 0.0:
		state_changed.emit()
