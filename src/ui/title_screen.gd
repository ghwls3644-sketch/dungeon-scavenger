class_name TitleScreen
extends Control

signal new_game_requested
signal continue_requested
signal quit_requested

var _continue_available := false
var _busy := false

@onready var _new_game: Button = %NewGameButton
@onready var _continue: Button = %ContinueButton
@onready var _options_button: Button = %OptionsButton
@onready var _quit: Button = %QuitButton
@onready var _options: Control = %OptionsOverlay
@onready var _back: Button = %OptionsBackButton
@onready var _status: Label = %Status


func _ready() -> void:
	_new_game.pressed.connect(func(): new_game_requested.emit())
	_continue.pressed.connect(func(): continue_requested.emit())
	_quit.pressed.connect(func(): quit_requested.emit())
	_options_button.pressed.connect(_open_options)
	_back.pressed.connect(_close_options)
	_render_buttons()


func present() -> void:
	show()
	focus_start()


func dismiss() -> void:
	hide()
	_options.hide()
	_render_buttons()


func set_menu_state(continue_available: bool, busy: bool) -> void:
	_continue_available = continue_available
	_busy = busy
	_status.text = "" if continue_available else "이어할 기록이 없습니다."
	_render_buttons()


func set_status(message: String) -> void:
	_status.text = message


func is_options_open() -> bool:
	return _options.visible


func focus_start() -> void:
	if is_visible_in_tree() and not _busy and not _options.visible:
		if _continue_available:
			_continue.grab_focus()
		else:
			_new_game.grab_focus()


func _render_buttons() -> void:
	var blocked := _busy or _options.visible
	_new_game.disabled = blocked
	_continue.disabled = blocked or not _continue_available
	_options_button.disabled = blocked
	_quit.disabled = blocked


func _open_options() -> void:
	if _busy or not is_visible_in_tree():
		return
	_options.show()
	_render_buttons()
	_back.grab_focus()


func _close_options() -> void:
	_options.hide()
	_render_buttons()
	if is_visible_in_tree() and not _busy:
		_options_button.grab_focus()


func _unhandled_key_input(event: InputEvent) -> void:
	if is_visible_in_tree() and _options.visible and event.is_action_pressed(InputActions.PAUSE):
		_close_options()
		get_viewport().set_input_as_handled()
