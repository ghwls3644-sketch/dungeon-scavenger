class_name GameEntry
extends Node

const DEV_SCENE := preload("res://src/app/dev_main.tscn")

var _has_saved_game := Callable()
var _restore_saved_game := Callable()
var _starting := false

@onready var _title: TitleScreen = $TitleScreen
@onready var _hub: Control = $HubPlaceholder


func _ready() -> void:
	if OS.is_debug_build():
		for argument in OS.get_cmdline_user_args():
			if argument.begins_with("--dev-state="):
				get_tree().change_scene_to_packed.call_deferred(DEV_SCENE)
				return
	_title.new_game_requested.connect(_on_new_game_requested)
	_title.continue_requested.connect(_on_continue_requested)
	_title.quit_requested.connect(_on_quit_requested)
	$HubPlaceholder/Center/Card/Content/QuitButton.pressed.connect(_on_quit_requested)
	GameState.state_changed.connect(_on_state_changed)
	_boot.call_deferred()


func configure_continue(has_saved_game: Callable, restore_saved_game: Callable) -> void:
	_has_saved_game = has_saved_game
	_restore_saved_game = restore_saved_game
	if is_node_ready():
		refresh_continue()


func refresh_continue() -> void:
	_title.set_menu_state(_can_continue(), _starting)


func _boot() -> void:
	if GameState.get_current_state() == GameState.State.BOOT:
		GameState.request_transition(GameState.State.TITLE)
	else:
		_on_state_changed(GameState.get_current_state(), GameState.get_current_state())


func _can_continue() -> bool:
	return _has_saved_game.is_valid() and _restore_saved_game.is_valid() and _has_saved_game.call() == true


func _can_start() -> bool:
	return not _starting and GameState.get_current_state() == GameState.State.TITLE and not _title.is_options_open()


func _on_new_game_requested() -> void:
	if not _can_start():
		return
	_starting = true
	_title.set_menu_state(false, true)
	_enter_hub()


func _on_continue_requested() -> void:
	if not _can_start():
		return
	_starting = true
	_title.set_menu_state(false, true)
	if not _can_continue():
		_restore_title("이어할 기록이 없습니다.")
		return
	if _restore_saved_game.call() != true:
		_restore_title("기록을 불러오지 못했습니다. 다시 시도해 주세요.")
		return
	_enter_hub()


func _enter_hub() -> void:
	if not GameState.request_transition(GameState.State.HUB):
		_restore_title("게임을 시작하지 못했습니다. 다시 시도해 주세요.")


func _restore_title(message: String) -> void:
	_starting = false
	refresh_continue()
	_title.set_status(message)
	_title.focus_start()


func _on_state_changed(_previous_state: int, current_state: int) -> void:
	_starting = false
	_hub.visible = current_state == GameState.State.HUB
	if current_state == GameState.State.TITLE:
		refresh_continue()
		_title.present()
	else:
		_title.dismiss()
	if _hub.visible:
		$HubPlaceholder/Center/Card/Content/QuitButton.grab_focus()


func _on_quit_requested() -> void:
	GameLog.info(&"GameEntry", &"quit_requested")
	get_tree().quit()
