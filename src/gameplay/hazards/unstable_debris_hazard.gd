class_name UnstableDebrisHazard
extends StabilizableHazard

signal state_changed(previous_state: int, current_state: int)
signal warning_started(duration: float)
signal stabilized
signal hazard_triggered
signal body_caught(body: Node2D)

enum State {
	IDLE,
	WARNING,
	STABILIZED,
	TRIGGERED,
}

@export var warning_duration := 2.0

var _state: State = State.IDLE
var _bodies_in_hazard: Array[Node2D] = []

@onready var _debris: Polygon2D = %Debris
@onready var _warning_glow: Polygon2D = %WarningGlow
@onready var _status: Label = %Status
@onready var _warning_timer: Timer = %WarningTimer


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_warning_timer.timeout.connect(_on_warning_timeout)
	_render_state()


func get_state() -> State:
	return _state


func get_status_text() -> String:
	return _status.text


func begin_warning() -> bool:
	if _state != State.IDLE:
		return false

	_set_state(State.WARNING)
	_warning_timer.start(maxf(warning_duration, 0.01))
	warning_started.emit(warning_duration)
	return true


func can_stabilize() -> bool:
	return _state == State.WARNING


func stabilize() -> bool:
	if not can_stabilize():
		return false

	_warning_timer.stop()
	_set_state(State.STABILIZED)
	stabilized.emit()
	return true


func _on_body_entered(body: Node2D) -> void:
	if body not in _bodies_in_hazard:
		_bodies_in_hazard.append(body)
	if _state == State.IDLE:
		begin_warning()


func _on_body_exited(body: Node2D) -> void:
	_bodies_in_hazard.erase(body)


func _on_warning_timeout() -> void:
	if _state != State.WARNING:
		return

	_set_state(State.TRIGGERED)
	hazard_triggered.emit()
	for body in _bodies_in_hazard.duplicate():
		if is_instance_valid(body):
			body_caught.emit(body)


func _set_state(next_state: State) -> void:
	if next_state == _state:
		return

	var previous_state := _state
	_state = next_state
	_render_state()
	state_changed.emit(previous_state, _state)


func _render_state() -> void:
	match _state:
		State.WARNING:
			_debris.color = Color(0.65, 0.42, 0.16, 1.0)
			_warning_glow.show()
			_status.text = "징후: 먼지와 진동"
		State.STABILIZED:
			_debris.color = Color(0.26, 0.58, 0.42, 1.0)
			_warning_glow.hide()
			_status.text = "잔해 안정화됨"
		State.TRIGGERED:
			_debris.color = Color(0.72, 0.2, 0.18, 1.0)
			_warning_glow.hide()
			_status.text = "잔해 붕괴 발생"
		_:
			_debris.color = Color(0.36, 0.38, 0.42, 1.0)
			_warning_glow.hide()
			_status.text = "불안정한 잔해"
