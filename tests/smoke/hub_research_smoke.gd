extends "res://tests/smoke/hub_registration_smoke.gd"

const RESEARCH := preload("res://src/data/prototype_research_catalog.tres")


func _ready() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--research-directory="):
			_directory = argument.trim_prefix("--research-directory=")
	_read_case = "--research-continue" in OS.get_cmdline_user_args()
	_expected_registry_money = 0 if _read_case else 10
	_render = "--research-render" in OS.get_cmdline_user_args()
	if _directory.is_empty():
		_directory = OS.get_environment("TEMP").path_join("dungeon-research-%d-%d" % [OS.get_process_id(), Time.get_ticks_usec()])
	_expect(DirAccess.make_dir_recursive_absolute(_directory) == OK, "Cannot create research directory.")
	_path = _directory.path_join("progress.json")
	_store = ProgressStore.new(_path)
	var settings := SettingsStore.new(_directory.path_join("settings.cfg"))
	if not _read_case:
		_check_research_domain()
		var initial := HubState.new().to_save_data()
		initial.money = "10"
		initial.bag_slots = 3
		_expect(not _store.has_file() and _store.save_data(initial) == OK, "Research requires a fresh save.")
		_expect(settings.save_settings(GameSettings.new()) == OK, "Cannot prepare settings.")
	var settings_before := FileAccess.get_file_as_bytes(_directory.path_join("settings.cfg"))
	var initial_bytes := FileAccess.get_file_as_bytes(_path)
	_entry = MAIN_SCENE.instantiate()
	_entry.configure_progress(_store)
	_entry.configure_settings(settings)
	add_child(_entry)
	await _frames(5)
	_hub = _entry.get_node("Interface/HubPanel")
	_registration = _hub.get_node("RegistrationPanel")
	_pending_list = _registration.get_node("%RegistrationItems")
	_registered_list = _registration.get_node("%RegisteredItems")
	_hub.registration_requested.emit()
	_expect(not _registration.visible, "Research opened from title.")
	_click(_entry.get_node("Interface/TitleScreen/%ContinueButton"))
	await _frames(5)
	_expect(FileAccess.get_file_as_bytes(_path) == initial_bytes, "Continue rewrote research save.")
	if not _read_case:
		await _read_research(0, "locked")
		await _recover_originals(true)
		await _read_research(0)
		await _recover_originals(false)
		await _read_research(0)
		await _register_record_with_retry()
		await _read_research(1, "partial")
		await _check_excluded_return()
		await _read_research(1)
		await _register_second()
		await _read_research(2, "unlocked")
		await _failure_after_registration()
	else:
		await _check_excluded_return()
	await _read_research(2, "continue" if _read_case else "after-failure")
	_expect_registration_state(0, 2)
	_expect(settings_before == FileAccess.get_file_as_bytes(_directory.path_join("settings.cfg")), "Reading research changed settings.")
	var report := {"passed": _failures.is_empty(), "case": "continue" if _read_case else "write", "final_hub": _store.load_data(), "research": ResearchProgress.get_entries(_entry.get_hub_registered_items(), RESEARCH, CATALOG)}
	_write_json(_directory.path_join("research-continue.json" if _read_case else "research-write.json"), report)
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"hub_research_passed", report.case)
	get_tree().quit(0 if _failures.is_empty() else 1)


func _check_research_domain() -> void:
	_expect(RESEARCH.is_valid(CATALOG), "Prototype research has invalid references.")
	var hub := HubState.new()
	var locked := ResearchProgress.get_entries(hub.get_registered_items(), RESEARCH, CATALOG)
	_expect(locked.size() == 2 and not locked[0].unlocked and not locked[1].unlocked, "Empty registry unlocked research.")
	for entry in RESEARCH.entries:
		_expect(entry.display_name not in str(locked) and entry.explanation not in str(locked) and String(entry.stable_id) not in str(locked), "Locked projection exposed content.")
	var data := hub.to_save_data()
	data.stored_items = [{"id": "test_g4_record", "identified": true, "risk_hint": ""}, {"id": "test_g4_artifact", "identified": true, "risk_hint": ""}]
	hub = HubState.from_save_data(data, CATALOG)
	_expect(ResearchProgress.get_entries(hub.get_registered_items(), RESEARCH, CATALOG) == locked, "Stored/appraised originals unlocked research.")
	for index in [0, 1]:
		var candidate := hub.copy()
		_expect(candidate.apply_registration(candidate.quote_registration(index)), "Cannot register research prerequisite.")
		var views := ResearchProgress.get_entries(candidate.get_registered_items(), RESEARCH, CATALOG)
		_expect(views[0].unlocked == (index == 0) and not views[1].unlocked, "Unlock used count rather than required ID.")
		_expect(candidate.apply_registration(candidate.quote_registration(0)), "Cannot complete research combination.")
		var before := candidate.to_save_data()
		views = ResearchProgress.get_entries(candidate.get_registered_items(), RESEARCH, CATALOG)
		_expect(views[0].unlocked and views[1].unlocked and candidate.to_save_data() == before, "Registration order or read-only query failed.")
		views[0].text = "mutated"
		var restored := HubState.from_save_data(before, CATALOG)
		_expect(ResearchProgress.get_entries(restored.get_registered_items(), RESEARCH, CATALOG)[0].text == RESEARCH.entries[0].explanation, "Returned view mutated definitions or restore lost unlock.")
	var definition := RESEARCH.entries[0].duplicate(true) as ResearchDefinition
	for ids in [[], [&"missing"], [&"test_g1_light"], [&"test_g4_record", &"test_g4_record"], [&" "]]:
		definition.required_registered_ids.assign(ids)
		var invalid := ResearchCatalog.new()
		invalid.entries = [definition]
		_expect(not invalid.is_valid(CATALOG) and ResearchProgress.get_entries([], invalid, CATALOG).is_empty(), "Invalid research requirements accepted.")
	var duplicate := ResearchCatalog.new()
	duplicate.entries = [RESEARCH.entries[0], RESEARCH.entries[0]]
	_expect(not duplicate.is_valid(CATALOG), "Duplicate research ID accepted.")
	duplicate.entries = [null]
	_expect(not duplicate.is_valid(CATALOG), "Null research entry accepted.")
	definition = RESEARCH.entries[0].duplicate(true) as ResearchDefinition
	definition.explanation = " "
	_expect(not definition.get_validation_errors().is_empty(), "Empty explanation accepted.")
	definition = RESEARCH.entries[0].duplicate(true) as ResearchDefinition
	definition.stable_id = &""
	_expect(not definition.get_validation_errors().is_empty(), "Empty research ID accepted.")
	var unknown := InventoryItem.from_definition(CATALOG.find_item(&"test_g4_record"), false)
	_expect(ResearchProgress.get_entries([unknown], RESEARCH, CATALOG) == locked, "Unknown record unlocked content.")
	var renamed := ItemCatalog.new()
	for item in CATALOG.items:
		var copy := item.duplicate(true) as ItemDefinition
		copy.display_name = "Changed display name"
		renamed.items.append(copy)
	var registered := HubState.new().to_save_data()
	registered.registered_items = data.stored_items
	var restored := HubState.from_save_data(registered, renamed)
	_expect(ResearchProgress.get_entries(restored.get_registered_items(), RESEARCH, renamed)[1].unlocked, "Research depended on display names.")
	_expect(CATALOG.find_item(&"test_g4_record").display_name == "시험용 원본 기록" and CATALOG.find_item(&"test_g4_artifact").display_name == "시험용 원본 유물", "Rename fixture changed shared product definitions.")
	var legacy := HubState.new().to_save_data()
	legacy.erase("registered_items")
	legacy.erase("harness_durability")
	legacy.erase("harness_modules")
	legacy.erase("harness_upgrades")
	var legacy_path := _directory.path_join("legacy-research.json")
	_write_json(legacy_path, _envelope(1, legacy))
	var legacy_bytes := FileAccess.get_file_as_bytes(legacy_path)
	var legacy_hub := HubState.from_save_data(ProgressStore.new(legacy_path).load_data(), CATALOG)
	_expect(ResearchProgress.get_entries(legacy_hub.get_registered_items(), RESEARCH, CATALOG) == locked and FileAccess.get_file_as_bytes(legacy_path) == legacy_bytes, "Legacy load granted research or rewrote file.")


func _register_record_with_retry() -> void:
	var before := FileAccess.get_file_as_bytes(_path)
	_click(_hub.get_node("%RegistrationButton"))
	await _frames(3)
	await _click_registry_row(_pending_list, 1)
	_click(_registration.get_node("%ReviewRegistration"))
	await _frames(3)
	var research: ItemList = _registration.get_node("%ResearchEntries")
	var quote_text: String = _registration.get_node("%RegistrationDetails").text
	research.item_selected.emit(0)
	_expect(research.focus_mode == Control.FOCUS_NONE and _registration.get_node("%RegistrationDetails").text == quote_text, "Research selection replaced confirmation.")
	_press_key(KEY_ESCAPE)
	await _frames(3)
	_expect(FileAccess.get_file_as_bytes(_path) == before, "Cancelled quote unlocked research.")
	_click(_registration.get_node("%ReviewRegistration"))
	await _frames(3)
	_expect(DirAccess.make_dir_absolute(_path + ".tmp") == OK, "Cannot simulate failed registration save.")
	_click(_registration.get_node("%ConfirmRegistration"))
	await _frames(3)
	_expect_registration_state(2, 0)
	_expect("0/2" in _registration.get_node("%ResearchCount").text and FileAccess.get_file_as_bytes(_path) == before, "Save failure unlocked research.")
	await _capture_registration("save-failure", _registration)
	_expect(DirAccess.remove_absolute(_path + ".tmp") == OK, "Cannot clear failed-save fixture.")
	_click(_registration.get_node("%ConfirmRegistration"))
	_registration.confirmation_requested.emit()
	await _frames(3)
	_expect_registration_state(1, 1)
	_expect("1/2" in _registration.get_node("%ResearchCount").text, "Successful retry did not refresh research.")
	_click(_registration.get_node("%CloseRegistration"))
	await _frames(3)


func _read_research(unlocked: int, capture := "") -> void:
	var before := FileAccess.get_file_as_bytes(_path)
	_click(_hub.get_node("%RegistrationButton"))
	await _frames(3)
	var research: ItemList = _registration.get_node("%ResearchEntries")
	_expect(research.item_count == 2 and "%d/2" % unlocked in _registration.get_node("%ResearchCount").text, "Research count is stale.")
	research.grab_focus()
	_press_key(KEY_DOWN)
	_expect(research.get_selected_items() == PackedInt32Array([0]), "Keyboard cannot select research.")
	for index in range(2):
		await _click_registry_row(research, index)
		var text: String = _registration.get_node("%RegistrationDetails").text
		if index < unlocked:
			_expect(RESEARCH.entries[index].explanation in text and RESEARCH.entries[index].display_name in research.get_item_text(index), "Unlocked text missing.")
		else:
			_expect("잠긴 연구 해설" in text and RESEARCH.entries[index].display_name not in research.get_item_text(index) and RESEARCH.entries[index].explanation not in text, "Locked title/text leaked.")
		_expect(_registration.get_node("%ReviewRegistration").disabled and _pending_list.get_selected_items().is_empty() and _registered_list.get_selected_items().is_empty(), "Reading research retained an actionable item selection.")
	_hub.departure_requested.emit()
	_hub.appraisal_requested.emit()
	_hub.sale_requested.emit()
	_hub.bag_slots_selected.emit(2)
	_registration.confirmation_requested.emit()
	_expect(GameState.get_current_state() == GameState.State.HUB and _entry.get_departure_preview().slot_capacity == 3, "Research modal allowed conflicting action.")
	_expect(FileAccess.get_file_as_bytes(_path) == before and _entry.get_hub_money() == _expected_registry_money, "Research read changed progress or money.")
	if not capture.is_empty():
		if unlocked == 1:
			await _click_registry_row(research, 0)
		await _capture_registration(capture, _registration)
	_press_key(KEY_ESCAPE)
	await _frames(3)
	_expect(not _registration.visible and _hub.get_node("%RegistrationButton").has_focus(), "Esc did not restore hub focus.")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		GameLog.error(&"SmokeTest", &"hub_research_failed", message)
