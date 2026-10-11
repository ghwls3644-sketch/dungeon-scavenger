extends Node

const REVIEW := preload("res://tests/fixtures/g4_review_entry.gd")
var failures: Array[String] = []


func _ready() -> void:
	var prefix := "smoke-%d-%d" % [OS.get_process_id(), Time.get_ticks_usec()]
	var personal_before := {}
	for path in ["user://progress.json", "user://settings.cfg"]:
		personal_before[path] = FileAccess.get_file_as_bytes(path) if FileAccess.file_exists(path) else PackedByteArray()
	for case_name in REVIEW.CASES:
		var session: Dictionary = REVIEW.prepare_session(prefix + "-" + case_name, case_name)
		_expect(not session.is_empty(), "Cannot prepare " + case_name)
		if session.is_empty():
			continue
		var path: String = session.directory.path_join("progress.json")
		var snapshot_path: String = session.directory.path_join("initial_progress.json")
		var initial := ProgressStore.new(snapshot_path).load_data()
		var restored := HubState.from_save_data(initial, REVIEW.CATALOG)
		_expect(restored != null and restored.to_save_data() == REVIEW.initial_hub(case_name), "Initial snapshot differs " + case_name)
		var snapshot := FileAccess.get_file_as_bytes(snapshot_path)
		if case_name == "natural":
			_expect(not FileAccess.file_exists(path), "Natural case bypassed new game.")
		else:
			var store := ProgressStore.new(path)
			var evolved := store.load_data()
			evolved.money = "17"
			evolved.costs = ExpeditionCosts.new_book(17)
			_expect(store.save_data(evolved) == OK, "Cannot save evolved review state.")
			var bytes := FileAccess.get_file_as_bytes(path)
			_expect(not REVIEW.prepare_session(session.session_id, case_name).is_empty() and bytes == FileAccess.get_file_as_bytes(path), "Resume reset prepared state.")
			_expect(REVIEW.prepare_session(session.session_id, "natural").is_empty() and bytes == FileAccess.get_file_as_bytes(path), "Case mismatch overwrote progress.")
		_expect(snapshot == FileAccess.get_file_as_bytes(snapshot_path), "Resume changed initial snapshot.")
	for bad in ["../outside", "a/b", "a\\b", "", "CON", "nul", "com1", "a:b", "a."]:
		_expect(REVIEW.prepare_session(bad, "economy").is_empty(), "Unsafe session accepted.")
	_expect(REVIEW.prepare_session(prefix + "-bad", "unknown").is_empty(), "Unknown case accepted.")
	var damaged: Dictionary = REVIEW.prepare_session(prefix + "-damaged", "economy")
	var damaged_path: String = damaged.directory.path_join("progress.json")
	var bad_file := FileAccess.open(damaged_path, FileAccess.WRITE)
	bad_file.store_string("broken review")
	bad_file.close()
	_expect(REVIEW.prepare_session(damaged.session_id, "economy").is_empty() and FileAccess.get_file_as_string(damaged_path) == "broken review", "Damaged session overwritten.")
	var incomplete_id := prefix + "-incomplete"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(REVIEW.ROOT).path_join(incomplete_id))
	_expect(REVIEW.prepare_session(incomplete_id, "economy").is_empty(), "Partial session overwritten.")
	var live: Dictionary = REVIEW.prepare_session(prefix + "-live", "economy")
	var entry: GameEntry = REVIEW.create_entry(live)
	add_child(entry)
	await _frames(5)
	entry.get_node("Interface/TitleScreen/%ContinueButton").pressed.emit()
	await _frames(5)
	_expect(GameState.get_current_state() == GameState.State.HUB and entry.get_hub_money() == 100, "Review continue failed.")
	var hub: HubPanel = entry.get_node("Interface/HubPanel")
	hub.departure_requested.emit()
	await _frames(5)
	_expect(GameState.get_current_state() == GameState.State.EXPLORATION, "Review could not depart.")
	var saved := ProgressStore.new(live.directory.path_join("progress.json")).load_data()
	_expect(saved.pending_departure.get("phase") == "started", "Review wrote outside isolated progress.")
	for path in personal_before:
		var current := FileAccess.get_file_as_bytes(path) if FileAccess.file_exists(path) else PackedByteArray()
		_expect(current == personal_before[path], "Review touched personal file " + path)
	if failures.is_empty():
		GameLog.info(&"SmokeTest", &"g4_review_session_passed", "six presets / resume / rejection / isolated actual app")
	get_tree().quit(0 if failures.is_empty() else 1)


func _frames(count: int) -> void:
	for frame in range(count):
		await get_tree().process_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)
