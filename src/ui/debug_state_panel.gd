extends Control

@onready var _state_value: Label = %StateValue
@onready var _next_state_button: Button = %NextStateButton
@onready var _transition_status: Label = %TransitionStatus


func _ready() -> void:
	GameState.state_changed.connect(_on_state_changed)
	GameState.transition_rejected.connect(_on_transition_rejected)
	_render_current_state()
	_transition_status.text = "전환 대기 중"


func _on_next_state_button_pressed() -> void:
	var target_state := GameState.get_next_debug_state()
	_next_state_button.disabled = true
	_transition_status.text = "전환 중: %s → %s" % [
		GameState.get_state_name(GameState.get_current_state()),
		GameState.get_state_name(target_state),
	]

	if not GameState.request_transition(target_state):
		_next_state_button.disabled = false


func _on_state_changed(_previous_state: int, _current_state: int) -> void:
	_next_state_button.disabled = false
	_transition_status.text = "전환 완료"
	_render_current_state()


func _on_transition_rejected(
	_current_state: int,
	_requested_state: int,
	reason: StringName
) -> void:
	_next_state_button.disabled = false
	_transition_status.text = "전환 거절: %s" % reason


func _render_current_state() -> void:
	_state_value.text = GameState.get_state_name(GameState.get_current_state())
	_next_state_button.text = "다음 상태: %s" % GameState.get_state_name(
		GameState.get_next_debug_state()
	)
