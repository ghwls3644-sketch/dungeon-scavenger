extends Node

const MAIN_SCENE := preload("res://src/app/main.tscn")

var _failures := PackedStringArray()
var _saved_game_exists := false
var _restore_succeeds := false
var _restore_calls := 0
var _hub_transitions := 0
var _entry: GameEntry
var _title: TitleScreen


func _ready() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	GameState.state_changed.connect(func(_from: int, to: int):
		if to == GameState.State.HUB:
			_hub_transitions += 1
	)
	_entry = MAIN_SCENE.instantiate()
	_entry.configure_settings(SettingsStore.new(OS.get_environment("TEMP").path_join("dungeon-title-%d.cfg" % OS.get_process_id())))
	_entry.configure_progress(ProgressStore.new(OS.get_environment("TEMP").path_join("dungeon-title_screen_smoke-progress-%d-%d.json" % [OS.get_process_id(), Time.get_ticks_usec()])))
	add_child(_entry)
	_title = _entry.get_node("Interface/TitleScreen")
	await _frames(5)
	_expect(GameState.get_current_state() == GameState.State.TITLE, "Boot did not enter Title automatically.")
	_expect(_title.visible and not _entry.get_node("Interface/HubPanel").visible, "Initial screen is incorrect.")
	_expect(_button("ContinueButton").disabled, "Continue was enabled without a save provider.")
	_expect(_button("NewGameButton").has_focus(), "New game did not receive initial keyboard focus.")
	var card: Control = _title.get_node("Center/Card")
	_expect(Rect2(Vector2.ZERO, Vector2(1152, 648)).encloses(card.get_global_rect()), "Title card exceeds the default viewport.")
	await _check_options()
	await _check_continue_failures()
	if "--title-case=quit" in OS.get_cmdline_user_args():
		if not _failures.is_empty():
			_finish()
			return
		GameLog.info(&"SmokeTest", &"title_screen_quit_requested")
		_click(_button("QuitButton"))
		await _frames(5)
		_expect(false, "Quit button did not stop the process.")
	elif "--title-case=continue" in OS.get_cmdline_user_args():
		_restore_succeeds = true
		var previous_calls := _restore_calls
		_click(_button("ContinueButton"))
		await _frames(3)
		_expect(_restore_calls == previous_calls + 1, "Continue restored more than once.")
	else:
		var previous_calls := _restore_calls
		_button("NewGameButton").grab_focus()
		_press_key(KEY_ENTER)
		await _frames(3)
		_expect(_restore_calls == previous_calls, "New game restored existing progress.")
	_expect(_hub_transitions == 1 and GameState.get_current_state() == GameState.State.HUB, "Start did not enter Hub exactly once.")
	_expect(not _title.visible and _entry.get_node("Interface/HubPanel").visible, "Start did not show the hub destination.")
	_title.continue_requested.emit()
	_title.new_game_requested.emit()
	await _frames(2)
	_expect(_hub_transitions == 1, "Hidden title accepted another start.")
	_finish()


func _check_options() -> void:
	_click(_button("OptionsButton"))
	await _frames(2)
	_expect(_title.is_options_open(), "Options did not open after a real mouse click.")
	_expect(_button("OptionsBackButton").has_focus(), "Options did not receive keyboard focus.")
	_expect(_button("NewGameButton").disabled and _button("QuitButton").disabled, "Options did not block the underlying menu.")
	_title.new_game_requested.emit()
	await _frames(2)
	_expect(GameState.get_current_state() == GameState.State.TITLE, "A start request escaped the options overlay.")
	_press_key(KEY_ESCAPE)
	await _frames(2)
	_expect(not _title.is_options_open() and _button("OptionsButton").has_focus(), "Escape did not close options and restore focus.")
	_press_key(KEY_ENTER)
	await _frames(2)
	_expect(_title.is_options_open(), "Keyboard input could not reopen options.")
	_click(_button("OptionsBackButton"))
	await _frames(2)
	_expect(not _title.is_options_open() and _button("OptionsButton").has_focus(), "Back button did not restore the menu.")
	_expect(not get_tree().paused, "Options left the application paused.")


func _check_continue_failures() -> void:
	_entry.configure_continue(_has_saved_game, _restore_saved_game)
	_expect(_button("ContinueButton").disabled, "No-save provider enabled continue.")
	_saved_game_exists = true
	_entry.refresh_continue()
	_expect(not _button("ContinueButton").disabled, "Saved progress did not enable continue.")
	_click(_button("ContinueButton"))
	await _frames(3)
	_expect(_restore_calls == 1, "Restore was not called exactly once, including reentrant input.")
	_expect(GameState.get_current_state() == GameState.State.TITLE and _title.visible, "Failed restore left Title.")
	_expect("불러오지 못했습니다" in _title.get_node("%Status").text, "Failed restore has no visible explanation.")
	_expect(not _button("NewGameButton").disabled, "Failed restore left the menu locked.")
	_saved_game_exists = false
	_click(_button("ContinueButton"))
	await _frames(3)
	_expect(_restore_calls == 1 and _button("ContinueButton").disabled, "Stale save availability was not rechecked on click.")
	_expect(GameState.get_current_state() == GameState.State.TITLE, "Missing save entered Hub.")
	_entry.configure_continue(Callable(), Callable())
	_expect(_button("ContinueButton").disabled, "Unbound save callbacks enabled continue.")
	_saved_game_exists = true
	_entry.configure_continue(_has_saved_game, _restore_saved_game)


func _has_saved_game() -> bool:
	return _saved_game_exists


func _restore_saved_game() -> bool:
	_restore_calls += 1
	_title.continue_requested.emit()
	_title.new_game_requested.emit()
	return _restore_succeeds


func _button(node_name: String) -> Button:
	return _title.get_node("%" + node_name) as Button


func _click(button: Button) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = button.get_global_rect().get_center()
	event.pressed = true
	Input.parse_input_event(event)
	var release := event.duplicate() as InputEventMouseButton
	release.pressed = false
	Input.parse_input_event(release)


func _press_key(key: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = key
	event.physical_keycode = key
	event.pressed = true
	Input.parse_input_event(event)
	var release := event.duplicate() as InputEventKey
	release.pressed = false
	Input.parse_input_event(release)


func _frames(count: int) -> void:
	for i in range(count):
		await get_tree().process_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		GameLog.error(&"SmokeTest", &"title_screen_failed", message)


func _finish() -> void:
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"title_screen_passed")
	else:
		for failure in _failures:
			GameLog.error(&"SmokeTest", &"title_screen_failed", failure)
	get_tree().quit(0 if _failures.is_empty() else 1)
