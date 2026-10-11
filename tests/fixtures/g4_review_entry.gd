extends Node

const ENTRY := preload("res://src/app/main.tscn")
const CATALOG := preload("res://src/data/prototype_item_catalog.tres")
const CASES := ["natural", "economy", "services", "growth_before", "growth_after", "recovery"]
const ROOT := "res://.godot/g4-playtests"


func _ready() -> void:
	var case_name := "economy"
	var session_id := "review-%d-%d" % [int(Time.get_unix_time_from_system()), OS.get_process_id()]
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--g4-case="):
			case_name = argument.trim_prefix("--g4-case=")
		if argument.begins_with("--g4-session="):
			session_id = argument.trim_prefix("--g4-session=")
	var session := prepare_session(session_id, case_name)
	if session.is_empty():
		push_error("G4 review session rejected. Use a new session ID; existing files are preserved.")
		get_tree().quit(1)
		return
	var entry := create_entry(session)
	add_child(entry)
	get_window().title = "Dungeon Scavenger · G4 검토 · %s · %s" % [case_name, session_id]
	GameLog.info(&"G4Review", &"ready", "%s %s %s" % [case_name, session_id, session.directory])


static func valid_id(session_id: String) -> bool:
	if session_id.is_empty() or session_id.length() > 80:
		return false
	for character in session_id:
		if not character in "abcdefghijklmnopqrstuvwxyz0123456789_-":
			return false
	return not session_id.to_upper() in ["CON", "PRN", "AUX", "NUL", "COM1", "COM2", "COM3", "COM4", "COM5", "COM6", "COM7", "COM8", "COM9", "LPT1", "LPT2", "LPT3", "LPT4", "LPT5", "LPT6", "LPT7", "LPT8", "LPT9"]


static func initial_hub(case_name: String) -> Dictionary:
	if case_name not in CASES:
		return {}
	var data := HubState.new().to_save_data()
	if case_name == "natural":
		return data
	data.bag_slots = 3
	if case_name == "economy":
		data.money = "100"
	elif case_name == "services":
		data.money = "30"
		for id in ["test_g1_unknown", "test_g4_artifact", "test_g4_record"]:
			data.stored_items.append({"id": id, "identified": false, "risk_hint": ""})
	elif case_name == "growth_after":
		data.harness_upgrades = HarnessUpgradeRule.ALL.duplicate()
	elif case_name == "recovery":
		data.harness_durability = 0
	data.costs = ExpeditionCosts.new_book(data.money.to_int())
	return data


static func prepare_session(session_id: String, case_name: String) -> Dictionary:
	if not valid_id(session_id) or case_name not in CASES:
		return {}
	var directory := ProjectSettings.globalize_path(ROOT).path_join(session_id)
	var session := {"directory": directory, "case": case_name, "session_id": session_id}
	var progress := ProgressStore.new(directory.path_join("progress.json"))
	var settings := SettingsStore.new(directory.path_join("settings.cfg"))
	var manifest_path := directory.path_join("session.json")
	if DirAccess.dir_exists_absolute(directory):
		if not FileAccess.file_exists(manifest_path) or not FileAccess.file_exists(directory.path_join("initial_progress.json")) or not FileAccess.file_exists(directory.path_join("settings.cfg")):
			return {}
		var manifest: Variant = JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
		if typeof(manifest) != TYPE_DICTIONARY or manifest.get("ticket") != "DEV-0425" or manifest.get("case") != case_name or manifest.get("session_id") != session_id:
			return {}
		if progress.has_file():
			if HubState.from_save_data(progress.load_data(), CATALOG) == null:
				return {}
		elif case_name != "natural":
			return {}
		if settings.load_settings() != OK or not settings.is_writable():
			return {}
		return session
	if DirAccess.make_dir_recursive_absolute(directory) != OK:
		return {}
	var data := initial_hub(case_name)
	if HubState.from_save_data(data, CATALOG) == null:
		return {}
	# Snapshot records prepared state separately from human-earned progression.
	if ProgressStore.new(directory.path_join("initial_progress.json")).save_data(data) != OK:
		return {}
	if case_name != "natural" and progress.save_data(data) != OK:
		return {}
	if settings.save_settings(GameSettings.new()) != OK:
		return {}
	var manifest := {"ticket": "DEV-0425", "session_id": session_id, "case": case_name,
		"prepared_state": case_name != "natural", "created_at_utc": Time.get_datetime_string_from_system(true),
		"human_evaluation": "pending"}
	var file := FileAccess.open(manifest_path, FileAccess.WRITE)
	if file == null:
		return {}
	file.store_string(JSON.stringify(manifest, "\t") + "\n")
	var error := file.get_error()
	file.close()
	return session if error == OK else {}


static func create_entry(session: Dictionary) -> GameEntry:
	var entry := ENTRY.instantiate() as GameEntry
	entry.configure_progress(ProgressStore.new(session.directory.path_join("progress.json")))
	entry.configure_settings(SettingsStore.new(session.directory.path_join("settings.cfg")))
	return entry
