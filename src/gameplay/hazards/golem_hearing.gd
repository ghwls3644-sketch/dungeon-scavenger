class_name GolemHearing
extends Node

signal noise_heard(escalated: bool)

@export var source_path: NodePath
@export var golem_path: NodePath

var _active := false
var _elapsed := 0.0
var _loud_times: Array[float] = []

@onready var _source := get_node_or_null(source_path) as MovementNoiseEmitter
@onready var _golem := get_node_or_null(golem_path) as BrokenGuardGolem


func _ready() -> void:
	if _source != null:
		_source.noise_emitted.connect(_on_noise_emitted)
	if _golem != null:
		_golem.state_changed.connect(_on_golem_state_changed)


func set_active(active: bool) -> void:
	_active = active
	_elapsed = 0.0
	_loud_times.clear()


func get_loud_noise_count() -> int:
	return _loud_times.size()


func _physics_process(delta: float) -> void:
	if not _can_listen():
		return
	_elapsed += delta
	_expire_old_noise()


func _can_listen() -> bool:
	return (
		_active and not get_tree().paused
		and is_instance_valid(_golem) and _golem.can_process()
		and is_instance_valid(_source) and _source.noise_rule != null
		and _source.noise_rule.is_valid()
	)


func _expire_old_noise() -> void:
	while not _loud_times.is_empty() and _loud_times[0] < _elapsed - _source.noise_rule.loud_noise_window:
		_loud_times.pop_front()


func _on_noise_emitted(source_position: Vector2, radius: float, loud: bool) -> void:
	if not _can_listen() or not source_position.is_finite() or not is_finite(radius) or radius <= 0.0:
		return
	if _golem.global_position.distance_to(source_position) > radius or not _golem.can_investigate_noise():
		return
	_expire_old_noise()
	if loud:
		_loud_times.append(_elapsed)
	var escalated := _loud_times.size() >= _source.noise_rule.loud_noise_count
	var accepted := _golem.raise_alarm(source_position) if escalated else _golem.investigate_noise(source_position)
	if accepted:
		noise_heard.emit(escalated)


func hear_lure(position: Vector2, radius: float) -> bool:
	if not _can_listen() or not position.is_finite() or not is_finite(radius) or radius <= 0.0:
		return false
	if _golem.global_position.distance_to(position) > radius:
		return false
	# Lure noise never adds to or clears the movement-noise alarm history.
	return _golem.investigate_lure(position)


func _on_golem_state_changed(_previous: int, current: int) -> void:
	if current in [BrokenGuardGolem.State.DISABLED, BrokenGuardGolem.State.CHASE, BrokenGuardGolem.State.PATROL]:
		_loud_times.clear()
