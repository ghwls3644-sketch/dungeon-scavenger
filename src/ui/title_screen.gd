class_name TitleScreen
extends Control

signal new_game_requested
signal new_game_confirmed
signal new_game_cancelled
signal continue_requested
signal quit_requested
signal settings_requested(settings: GameSettings)

var _continue_available := false
var _busy := false
var _settings := GameSettings.new()
var _settings_notice := ""
var _settings_writable := false

@onready var _new_game: Button = %NewGameButton
@onready var _continue: Button = %ContinueButton
@onready var _options_button: Button = %OptionsButton
@onready var _quit: Button = %QuitButton
@onready var _options: Control = %OptionsOverlay
@onready var _back: Button = %OptionsBackButton
@onready var _status: Label = %Status
@onready var _screen_mode: OptionButton = %ScreenMode
@onready var _window_size: OptionButton = %WindowSize
@onready var _volume: HSlider = %MasterVolume
@onready var _volume_value: Label = %VolumeValue
@onready var _apply: Button = %ApplySettingsButton
@onready var _options_status: Label = %OptionsStatus
@onready var _new_game_confirm: ConfirmationDialog = %NewGameConfirm


func _ready() -> void:
	_new_game.pressed.connect(func(): new_game_requested.emit())
	_continue.pressed.connect(func(): continue_requested.emit())
	_quit.pressed.connect(func(): quit_requested.emit())
	_options_button.pressed.connect(_open_options)
	_back.pressed.connect(_close_options)
	_screen_mode.add_item("창 모드")
	_screen_mode.add_item("전체 화면")
	for window_size in GameSettings.WINDOW_SIZES:
		_window_size.add_item("%d × %d" % [window_size.x, window_size.y])
	_screen_mode.item_selected.connect(func(_index: int):
		_window_size.disabled = _screen_mode.selected == 1 or not _settings_writable
		_on_settings_edited()
	)
	_window_size.item_selected.connect(func(_index: int): _on_settings_edited())
	_volume.value_changed.connect(func(value: float):
		_volume_value.text = "%d%%" % int(value)
		_on_settings_edited()
	)
	_apply.pressed.connect(_request_settings)
	_new_game_confirm.confirmed.connect(func():
		_new_game_confirm.hide()
		_render_buttons()
		new_game_confirmed.emit()
	)
	_new_game_confirm.canceled.connect(func():
		_new_game_confirm.hide()
		_render_buttons()
		new_game_cancelled.emit()
		focus_start()
	)
	_render_buttons()


func confirm_new_game() -> void:
	_new_game_confirm.popup_centered()
	_new_game_confirm.get_cancel_button().grab_focus()
	_render_buttons()


func is_new_game_confirmation_open() -> bool:
	return _new_game_confirm.visible


func configure_settings(settings: GameSettings, notice: String = "", writable: bool = true) -> void:
	_settings = settings.copy()
	_settings_notice = notice
	_settings_writable = writable
	if is_node_ready():
		_render_settings()


func set_options_status(message: String) -> void:
	_options_status.text = message


func _render_settings() -> void:
	_screen_mode.select(1 if _settings.screen_mode == "fullscreen" else 0)
	_window_size.select(_settings.window_size_index)
	_screen_mode.disabled = not _settings_writable
	_window_size.disabled = _screen_mode.selected == 1 or not _settings_writable
	_volume.editable = _settings_writable
	_volume.set_value_no_signal(_settings.master_volume)
	_volume_value.text = "%d%%" % _settings.master_volume
	_apply.disabled = not _settings_writable
	_options_status.text = _settings_notice if not _settings_notice.is_empty() else "적용을 누르면 저장됩니다. 돌아가기·Esc는 변경을 취소합니다."


func _on_settings_edited() -> void:
	if _settings_writable:
		_options_status.text = "변경한 설정은 아직 저장되지 않았습니다. 적용을 눌러 저장하세요."


func _request_settings() -> void:
	if _busy or not is_visible_in_tree() or not _options.visible or not _settings_writable:
		return
	var candidate := GameSettings.new()
	candidate.screen_mode = "fullscreen" if _screen_mode.selected == 1 else "windowed"
	candidate.window_size_index = _window_size.selected
	candidate.master_volume = int(_volume.value)
	settings_requested.emit(candidate)


func present() -> void:
	show()
	focus_start()


func dismiss() -> void:
	hide()
	_options.hide()
	_new_game_confirm.hide()
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
	if is_visible_in_tree() and not _busy and not _options.visible and not _new_game_confirm.visible:
		if _continue_available:
			_continue.grab_focus()
		else:
			_new_game.grab_focus()


func _render_buttons() -> void:
	var blocked := _busy or _options.visible or _new_game_confirm.visible
	_new_game.disabled = blocked
	_continue.disabled = blocked or not _continue_available
	_options_button.disabled = blocked
	_quit.disabled = blocked


func _open_options() -> void:
	if _busy or not is_visible_in_tree():
		return
	_options.show()
	_render_settings()
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
