extends Node2D

@onready var _pause_status: Label = %PauseStatus


func _ready() -> void:
	get_tree().paused = false
	_render_pause_status()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed(InputActions.PAUSE):
		return

	get_viewport().set_input_as_handled()
	get_tree().paused = not get_tree().paused
	GameLog.info(
		&"MovementTestSpace",
		&"pause_changed",
		"paused=%s" % get_tree().paused
	)
	_render_pause_status()


func _exit_tree() -> void:
	get_tree().paused = false


func _render_pause_status() -> void:
	_pause_status.text = "일시정지" if get_tree().paused else "이동 가능"
