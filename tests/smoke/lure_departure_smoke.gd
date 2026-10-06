extends "res://tests/smoke/lure_preparation_smoke.gd"

const BOUNDARY_STORE := preload("res://tests/fixtures/lure_boundary_store.gd")


func _ready() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	var mode := "retry"
	var stop_call := 0
	var stop_after := false
	var expected_stock := 2
	var expected_next := "2"
	_directory = OS.get_environment("TEMP").path_join("dungeon-lure-boundary-%d-%d" % [OS.get_process_id(), Time.get_ticks_usec()])
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--lure-directory="):
			_directory = argument.trim_prefix("--lure-directory=")
		if argument.begins_with("--boundary-mode="):
			mode = argument.trim_prefix("--boundary-mode=")
		if argument.begins_with("--boundary-call="):
			stop_call = argument.trim_prefix("--boundary-call=").to_int()
		if argument.begins_with("--expected-stock="):
			expected_stock = argument.trim_prefix("--expected-stock=").to_int()
		if argument.begins_with("--expected-next="):
			expected_next = argument.trim_prefix("--expected-next=")
	stop_after = "--boundary-after" in OS.get_cmdline_user_args()
	_render = "--lure-render" in OS.get_cmdline_user_args()
	DirAccess.make_dir_recursive_absolute(_directory)
	_path = _directory.path_join("progress.json")
	var boundary := BOUNDARY_STORE.new(_path)
	boundary.directory = _directory
	_store = boundary
	var settings := SettingsStore.new(_directory.path_join("settings.cfg"))
	if mode in ["stop", "retry", "reservation-retry"]:
		var initial := _lure_data(0, 2, 4)
		_expect(ProgressStore.new(_path).save_data(initial) == OK and settings.save_settings(GameSettings.new()) == OK, "Cannot seed departure boundary.")
	if mode == "stop":
		boundary.stop_call = stop_call
		boundary.stop_after = stop_after
	if mode == "resume-retry":
		boundary.failures = [1, 2]
	_entry = ENTRY.instantiate()
	_entry.configure_progress(_store)
	_entry.configure_settings(settings)
	add_child(_entry)
	await _frames(5)
	_hub = _entry.get_node("Interface/HubPanel")
	_results = _entry.get_node("Interface/Results")
	var bytes := FileAccess.get_file_as_bytes(_path)
	if mode == "resume-retry":
		for attempt in range(2):
			_click(_entry.get_node("Interface/TitleScreen/%ContinueButton"))
			await _frames(4)
			_hub.departure_requested.emit()
			_hub.bag_slots_selected.emit(3)
			_expect(GameState.get_current_state() == GameState.State.TITLE and FileAccess.get_file_as_bytes(_path) == bytes, "Failed resume recovery enabled hub/mutated file.")
	_click(_entry.get_node("Interface/TitleScreen/%ContinueButton"))
	await _frames(5)
	if mode in ["resume", "resume-retry"]:
		var recovered := _store.load_data()
		_expect(GameState.get_current_state() == GameState.State.HUB and recovered.paid_lures == expected_stock and recovered.next_expedition_id == expected_next and recovered.pending_departure.is_empty(), "New process recovery duplicated/lost supply or reused ID.")
		var saved := FileAccess.get_file_as_bytes(_path)
		_entry._restore_progress()
		_expect(FileAccess.get_file_as_bytes(_path) == saved, "Second restore wrote/recovered twice.")
		_finish_boundary(mode)
		return
	if mode == "retry":
		boundary.failures = [2, 3]
	elif mode == "reservation-retry":
		boundary.failures = [1]
	_click(_hub.get_node("%DepartureButton"))
	await _frames(6)
	if mode in ["retry", "reservation-retry"]:
		_expect(GameState.get_current_state() == GameState.State.HUB and _entry.get_node_or_null("PrototypeExploration") == null, "Technical failure left live simulation.")
		if mode == "retry":
			var reserved := FileAccess.get_file_as_bytes(_path)
			for service in ["appraisal_requested", "sale_requested", "registration_requested", "repair_requested", "harness_requested", "upgrade_requested", "lures_requested"]:
				_hub.emit_signal(service)
			_hub.bag_slots_selected.emit(3)
			_expect(FileAccess.get_file_as_bytes(_path) == reserved and _hub.get_node("Center").visible and _store.load_data().pending_departure.phase == "reserved", "Recovery failure allowed hub mutation.")
			await _capture_wear("recovery-retry", _hub.get_node("Center/Card"))
			_click(_hub.get_node("%DepartureButton"))
			await _frames(4)
			_expect(_store.load_data().paid_lures == 2 and _store.load_data().next_expedition_id == "2" and _store.load_data().pending_departure.is_empty(), "Retry failed to return reservation exactly once.")
		else:
			_expect(FileAccess.get_file_as_bytes(_path) == bytes, "Failed reservation mutated save/id.")
		_click(_hub.get_node("%DepartureButton"))
		await _frames(6)
	_expect(GameState.get_current_state() == GameState.State.EXPLORATION, "Retry/stop route failed to depart.")
	_tap(KEY_E)
	await _frames(6)
	_click(_results.get_node("NextStep/SettleButton"))
	await _frames(5)
	_expect(_store.load_data().paid_lures == 2 and _store.load_data().pending_departure.is_empty(), "Technical retry route failed settlement.")
	_finish_boundary(mode)


func _finish_boundary(mode: String) -> void:
	_write_json(_directory.path_join("boundary-%s.json" % mode), {"passed": _failures.is_empty(), "mode": mode, "final_hub": _store.load_data(), "failures": _failures})
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"lure_departure_passed", mode)
	get_tree().quit(0 if _failures.is_empty() else 1)
