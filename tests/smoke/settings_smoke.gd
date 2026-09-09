extends Node

const MAIN_SCENE := preload("res://src/app/main.tscn")

var _failures := PackedStringArray()
var _directory := ""
var _case := "default"
var _entry: GameEntry
var _title: TitleScreen


func _ready() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--settings-case="):
			_case = argument.trim_prefix("--settings-case=")
		if argument.begins_with("--settings-test-directory="):
			_directory = argument.trim_prefix("--settings-test-directory=")
	if _directory.is_empty():
		_directory = OS.get_environment("TEMP").path_join("dungeon-settings-%d-%d" % [OS.get_process_id(), Time.get_ticks_usec()])
	_expect(DirAccess.make_dir_recursive_absolute(_directory) == OK, "Test directory could not be created.")
	if _case == "default":
		_check_store()
		_check_audio()
	await _check_ui()
	if "--settings-render" in OS.get_cmdline_user_args() and DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(_directory.path_join("options.png"))
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"settings_passed", _case)
	get_tree().quit(0 if _failures.is_empty() else 1)


func _check_store() -> void:
	var path := _directory.path_join("store.cfg")
	var store := SettingsStore.new(path)
	_expect(store.load_settings() == OK and store.get_settings().master_volume == 100, "Missing file did not use defaults.")
	_expect(not FileAccess.file_exists(path), "Loading created a settings file.")
	var candidate := GameSettings.new()
	candidate.master_volume = 37
	candidate.screen_mode = "fullscreen"
	candidate.window_size_index = 2
	_expect(store.save_settings(candidate) == OK, "Initial save failed.")
	candidate.master_volume = 80
	_expect(store.get_settings().master_volume == 37, "Caller mutation changed saved settings.")
	store.get_settings().master_volume = 90
	_expect(store.get_settings().master_volume == 37, "Read mutation changed saved settings.")
	var reloaded := SettingsStore.new(path)
	_expect(reloaded.load_settings() == OK, "Round-trip load failed.")
	_expect(reloaded.get_settings().screen_mode == "fullscreen" and reloaded.get_settings().window_size_index == 2 and reloaded.get_settings().master_volume == 37, "Round-trip values changed.")
	candidate.master_volume = 0
	_expect(store.save_settings(candidate) == OK, "Replacing an existing file failed.")
	var previous := FileAccess.get_file_as_bytes(path)
	candidate.master_volume = 101
	_expect(store.save_settings(candidate) == ERR_INVALID_DATA, "Invalid settings were saved.")
	_expect(FileAccess.get_file_as_bytes(path) == previous, "Rejected save changed the file.")
	DirAccess.make_dir_absolute(path + ".tmp")
	candidate.master_volume = 45
	_expect(store.save_settings(candidate) != OK, "Blocked temporary path accepted a save.")
	_expect(store.get_settings().master_volume == 0 and FileAccess.get_file_as_bytes(path) == previous, "Failed save changed memory or the previous file.")
	DirAccess.remove_absolute(path + ".tmp")
	var config := ConfigFile.new()
	config.load(path)
	config.set_value("settings", "schema_version", 99)
	config.save(path)
	previous = FileAccess.get_file_as_bytes(path)
	_expect(reloaded.load_settings() == ERR_UNAVAILABLE and not reloaded.is_writable(), "Unsupported version was accepted.")
	_expect(reloaded.save_settings(candidate) == ERR_UNAVAILABLE and FileAccess.get_file_as_bytes(path) == previous, "Unsupported file was overwritten.")
	config.set_value("settings", "schema_version", 1)
	for invalid_volume in ["37", true, -1, 101, 37.5]:
		config.set_value("audio", "master_volume", invalid_volume)
		config.save(path)
		_expect(reloaded.load_settings() == ERR_INVALID_DATA and reloaded.get_settings().master_volume == 100, "Invalid volume did not fall back to defaults.")
	config.set_value("audio", "master_volume", 50)
	config.set_value("display", "screen_mode", "invalid")
	config.save(path)
	_expect(reloaded.load_settings() == ERR_INVALID_DATA, "Invalid screen mode was accepted.")
	config.set_value("display", "screen_mode", "windowed")
	config.set_value("display", "window_size_index", 3)
	config.save(path)
	_expect(reloaded.load_settings() == ERR_INVALID_DATA, "Out-of-range size was accepted.")
	config.erase_section_key("display", "window_size_index")
	config.save(path)
	_expect(reloaded.load_settings() == ERR_INVALID_DATA, "Incomplete file was accepted.")
	DirAccess.remove_absolute(path)


func _check_audio() -> void:
	var settings := GameSettings.new()
	var master := AudioServer.get_bus_index("Master")
	for volume in [0, 37, 100]:
		settings.master_volume = volume
		SettingsRuntime.apply(settings, get_window())
		_expect(is_equal_approx(AudioServer.get_bus_volume_linear(master), float(volume) / 100.0), "Master volume was not applied.")
		_expect(AudioServer.is_bus_mute(master) == (volume == 0), "Mute/unmute did not follow volume.")


func _check_ui() -> void:
	var path := _directory.path_join("settings.cfg")
	var store := SettingsStore.new(path)
	if _case in ["invalid", "future"]:
		var fixture := ConfigFile.new()
		fixture.set_value("settings", "schema_version", 99 if _case == "future" else 1)
		fixture.save(path)
	_entry = MAIN_SCENE.instantiate()
	_entry.configure_settings(store)
	_entry.configure_progress(ProgressStore.new(OS.get_environment("TEMP").path_join("dungeon-settings_smoke-progress-%d-%d.json" % [OS.get_process_id(), Time.get_ticks_usec()])))
	var shared_progress := "--shared-progress" in OS.get_cmdline_user_args()
	if shared_progress:
		_entry.configure_progress(ProgressStore.new(_directory.path_join("progress.json")))
	add_child(_entry)
	_title = _entry.get_node("Interface/TitleScreen")
	await _frames(5)
	_expect(_title.get_node("%ContinueButton").disabled == not shared_progress, "Continue availability does not match the separate progress record.")
	_click(_title.get_node("%OptionsButton"))
	await _frames(3)
	_expect(_title.is_options_open(), "Options did not open.")
	var card: Control = _title.get_node("OptionsOverlay/Center/Card")
	_expect(Rect2(0, 0, 1152, 648).encloses(card.get_global_rect()), "Options exceed the logical viewport.")
	var volume: HSlider = _title.get_node("%MasterVolume")
	var mode: OptionButton = _title.get_node("%ScreenMode")
	var size_choice: OptionButton = _title.get_node("%WindowSize")
	if _case in ["invalid", "future"]:
		_expect(volume.value == 100 and mode.selected == 0 and size_choice.selected == 0, "Rejected file did not show default settings.")
		var previous := FileAccess.get_file_as_bytes(path)
		if _case == "future":
			_expect(_title.get_node("%ApplySettingsButton").disabled and not volume.editable, "Unsupported version allowed editing.")
			_expect("다른 버전" in _title.get_node("%OptionsStatus").text, "Unsupported version notice missing.")
			_title.settings_requested.emit(GameSettings.new())
			_expect(FileAccess.get_file_as_bytes(path) == previous, "Unsupported version was overwritten through a request.")
		else:
			_expect("읽지 못해" in _title.get_node("%OptionsStatus").text, "Invalid file notice missing.")
			_click(_title.get_node("%OptionsBackButton"))
			await _frames(2)
			_expect(FileAccess.get_file_as_bytes(path) == previous, "Opening/canceling repaired the file without Apply.")
			_click(_title.get_node("%OptionsButton"))
			await _frames(2)
			_click(_title.get_node("%ApplySettingsButton"))
			await _frames(2)
			_expect(SettingsStore.new(path).load_settings() == OK, "Explicit Apply did not repair invalid settings.")
		return
	if _case == "read":
		_expect(store.get_settings().master_volume == 37 and volume.value == 37, "Restart did not restore volume to model/UI.")
		_expect(mode.selected == 1 and size_choice.selected == 2 and size_choice.disabled, "Restart did not restore display choices.")
		_expect(is_equal_approx(AudioServer.get_bus_volume_linear(0), 0.37), "Restart did not apply audio.")
		if DisplayServer.get_name() != "headless":
			_expect(get_window().mode == Window.MODE_FULLSCREEN, "Restart did not apply fullscreen.")
		return
	volume.value = 36
	volume.grab_focus()
	_press_key(KEY_RIGHT)
	await _frames(2)
	_expect(volume.value == 37 and _title.get_node("%VolumeValue").text == "37%", "Keyboard slider input did not update the displayed volume.")
	_expect("아직 저장되지" in _title.get_node("%OptionsStatus").text, "Pending edits are not distinguished from saved values.")
	if _case == "default":
		_press_key(KEY_ESCAPE)
		await _frames(2)
		_expect(not _title.is_options_open() and not FileAccess.file_exists(path), "Cancel saved pending settings.")
		_click(_title.get_node("%OptionsButton"))
		await _frames(2)
		_expect(volume.value == 100, "Cancel did not discard pending values.")
		volume.value = 37
	mode.grab_focus()
	_press_key(KEY_SPACE)
	await _frames(2)
	_press_key(KEY_DOWN)
	_press_key(KEY_ENTER)
	await _frames(2)
	_expect(mode.selected == 1 and size_choice.disabled, "Keyboard fullscreen choice did not disable window size.")
	# Store a remembered window size even while fullscreen is selected.
	size_choice.select(2)
	_click(_title.get_node("%ApplySettingsButton"))
	await _frames(5)
	_expect(store.get_settings().master_volume == 37 and store.get_settings().screen_mode == "fullscreen", "Apply did not save selections.")
	_expect(is_equal_approx(AudioServer.get_bus_volume_linear(0), 0.37), "Apply did not reach the audio bus.")
	_expect("저장했습니다" in _title.get_node("%OptionsStatus").text, "Successful save was not reported.")
	if _case == "write":
		return
	var previous := FileAccess.get_file_as_bytes(path)
	DirAccess.make_dir_absolute(path + ".tmp")
	volume.value = 88
	_click(_title.get_node("%ApplySettingsButton"))
	await _frames(2)
	_expect("저장하지 못했습니다" in _title.get_node("%OptionsStatus").text, "Save failure was not reported.")
	_expect(FileAccess.get_file_as_bytes(path) == previous and is_equal_approx(AudioServer.get_bus_volume_linear(0), 0.37), "Failed UI save changed disk or runtime.")
	DirAccess.remove_absolute(path + ".tmp")
	_click(_title.get_node("%OptionsBackButton"))
	await _frames(2)
	_click(_title.get_node("%OptionsButton"))
	await _frames(2)
	_expect(volume.value == 37, "Reopening did not restore the last applied settings.")
	mode.select(0)
	mode.item_selected.emit(0)
	size_choice.select(0)
	volume.value = 100
	_click(_title.get_node("%ApplySettingsButton"))
	await _frames(5)
	_expect(not AudioServer.is_bus_mute(0) and is_equal_approx(AudioServer.get_bus_volume_linear(0), 1.0), "Second apply did not restore full volume.")
	if DisplayServer.get_name() != "headless":
		_expect(get_window().mode == Window.MODE_WINDOWED, "Window mode was not restored.")
		_expect(get_window().size == Vector2i(1152, 648), "Selected window size was not applied.")
		for size_index in [1, 2, 0]:
			size_choice.select(size_index)
			size_choice.item_selected.emit(size_index)
			_click(_title.get_node("%ApplySettingsButton"))
			await _frames(5)
			_expect(get_window().size == GameSettings.WINDOW_SIZES[size_index], "Window size preset did not reach the display.")
			_expect(Rect2(0, 0, 1152, 648).encloses(card.get_global_rect()), "Resizing clipped the options card.")
	DirAccess.remove_absolute(path)


func _click(button: Button) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = get_viewport().get_final_transform() * button.get_global_rect().get_center()
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
		GameLog.error(&"SmokeTest", &"settings_failed", message)
