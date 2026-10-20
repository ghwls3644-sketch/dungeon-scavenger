extends "res://tests/smoke/hub_appraisal_smoke.gd"

var _expected_registry_money := 10

var _registration: HubRegistrationPanel
var _pending_list: ItemList
var _registered_list: ItemList


func _ready() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--registration-directory="):
			_directory = argument.trim_prefix("--registration-directory=")
	_read_case = "--registration-continue" in OS.get_cmdline_user_args()
	_expected_registry_money = 10
	_render = "--registration-render" in OS.get_cmdline_user_args()
	if _directory.is_empty():
		_directory = OS.get_environment("TEMP").path_join("dungeon-registration-%d-%d" % [OS.get_process_id(), Time.get_ticks_usec()])
	_expect(DirAccess.make_dir_recursive_absolute(_directory) == OK, "Cannot create isolated directory.")
	_path = _directory.path_join("progress.json")
	_store = ProgressStore.new(_path)
	var settings := SettingsStore.new(_directory.path_join("settings.cfg"))
	if not _read_case:
		_check_registration_domain()
		_check_migration()
		_expect(not _store.has_file(), "Write case requires a fresh directory.")
		var initial := HubState.new().to_save_data()
		initial.money = "10"
		initial.costs = ExpeditionCosts.new_book(initial.money.to_int())
		initial.bag_slots = 3
		initial.erase("registered_items")
		initial.erase("harness_durability")
		initial.erase("harness_modules")
		initial.erase("harness_upgrades")
		initial.erase("paid_lures")
		initial.erase("selected_lures")
		initial.erase("pending_departure")
		initial.erase("costs")
		initial.erase("objective")
		_write_json(_path, _envelope(1, initial))
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
	_registration.confirmation_requested.emit()
	_expect(not _registration.visible and FileAccess.get_file_as_bytes(_path) == initial_bytes, "Title accepted registration.")
	_click(_entry.get_node("Interface/TitleScreen/%ContinueButton"))
	await _frames(5)
	_expect(GameState.get_current_state() == GameState.State.HUB and FileAccess.get_file_as_bytes(_path) == initial_bytes, "Continue rewrote or failed to load the existing file.")
	if not _read_case:
		await _capture_registration("hub", _hub)
		await _check_empty_registry()
		await _recover_originals(true)
		_expect_registration_state(0, 0)
		await _recover_originals(false)
		_expect_registration_state(2, 0)
		await _register_first()
		await _check_excluded_return()
		await _register_second()
		await _failure_after_registration()
	else:
		_expect_registration_state(0, 2)
		await _check_excluded_return()
	_click(_hub.get_node("%RegistrationButton"))
	await _frames(3)
	var before_read := FileAccess.get_file_as_bytes(_path)
	await _click_registry_row(_registered_list, 1)
	_expect("핵심 기록물 · 연구자 보관" in _registration.get_node("%RegistrationDetails").text, "Record routing or reading missing.")
	_expect(CATALOG.find_item(&"test_g4_record").registration_text in _registration.get_node("%RegistrationDetails").text, "Registered text unavailable.")
	_registration.confirmation_requested.emit()
	_expect(FileAccess.get_file_as_bytes(_path) == before_read, "Reading or duplicate confirm rewrote progress.")
	await _capture_registration("registered", _registration)
	_expect(settings_before == FileAccess.get_file_as_bytes(_directory.path_join("settings.cfg")), "Registration changed settings.")
	_expect_registration_state(0, 2)
	var report := {"passed": _failures.is_empty(), "case": "continue" if _read_case else "write", "final_hub": _store.load_data()}
	_write_json(_directory.path_join("registration-continue.json" if _read_case else "registration-write.json"), report)
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"hub_registration_passed", report.case)
	get_tree().quit(0 if _failures.is_empty() else 1)


func _check_registration_domain() -> void:
	var data := HubState.new().to_save_data()
	data.money = "10"
	data.costs = ExpeditionCosts.new_book(data.money.to_int())
	data.stored_items = [
		{"id": "test_g4_artifact", "identified": true, "risk_hint": "원본 표면"},
		{"id": "test_g4_record", "identified": false, "risk_hint": "접힌 종이"},
		{"id": "test_g1_unknown", "identified": true, "risk_hint": "진동"},
		{"id": "test_g4_artifact", "identified": true, "risk_hint": "중복 경계 자료"},
	]
	var hub := HubState.from_save_data(data, CATALOG)
	for index in [-1, 1, 2, 4]:
		_expect(hub.quote_registration(index) == null and hub.to_save_data() == data, "Invalid/non-original/unknown registration changed state.")
	_expect(hub.get_registration_reason(1) == "미확인 · 감정 필요", "Hidden category leaked through eligibility.")
	_expect(hub.quote_sale(PackedInt32Array([0]), ECONOMY) == null, "Original could be sold.")
	var quote := hub.quote_registration(0)
	var candidate := hub.copy()
	_expect(candidate.apply_registration(quote) and candidate.get_money() == 10, "Registration failed or changed money.")
	_expect(candidate.get_registered_items().size() == 1 and candidate.get_stored_items().size() == 3 and candidate.get_stored_items()[2].get_risk_hint() == "중복 경계 자료", "Registration removed the wrong item.")
	_expect(not candidate.apply_registration(quote) and candidate.quote_registration(2) == null, "Same ID registered twice.")
	candidate.get_registered_items()[0].get_definition().display_name = "mutated"
	_expect(candidate.get_registered_items()[0].get_definition().display_name != "mutated" and hub.get_registered_items().is_empty(), "Registered view/candidate shared mutable state.")
	hub.select_bag_slots(3)
	_expect(not hub.apply_registration(quote), "Stale registration accepted changed hub.")
	hub = HubState.from_save_data(data, CATALOG)
	var appraisal := hub.quote_appraisal(PackedInt32Array([1]), ECONOMY)
	_expect(hub.apply_appraisal(appraisal, ECONOMY) and hub.apply_registration(hub.quote_registration(1)), "Appraised original could not register.")
	_expect(hub.get_money() == 5, "Registration charged appraisal twice.")
	hub.begin_expedition()
	_expect(hub.quote_registration(0) == null, "Active expedition accepted registration.")
	var saved := candidate.to_save_data()
	var catalog := ItemCatalog.new()
	for item in CATALOG.items:
		catalog.items.append(item.duplicate(true) as ItemDefinition)
	catalog.items[4].display_name = "이름 변경 시험"
	var renamed := HubState.from_save_data(saved, catalog)
	_expect(renamed.get_registered_items()[0].get_definition().display_name == "이름 변경 시험" and &"test_g4_artifact" in renamed.get_excluded_original_ids(), "Persistence used names instead of IDs.")
	var entry: Dictionary = saved.registered_items[0]
	for bad in [null, {}, [null], [entry, entry], [{"id": "missing", "identified": true, "risk_hint": ""}], [{"id": "test_g4_record", "identified": false, "risk_hint": ""}], [{"id": "test_g1_light", "identified": true, "risk_hint": ""}]]:
		var invalid := saved.duplicate(true)
		invalid.registered_items = bad
		_expect(HubState.from_save_data(invalid, CATALOG) == null, "Invalid registry payload accepted.")


func _envelope(version: int, hub: Dictionary) -> Dictionary:
	if version <= 9:
		hub = LegacyProgressFixture.before_appraisal(hub)
	return {"schema_version": version, "content_version": ProgressStore.CONTENT_VERSION, "resume_state": "hub", "hub": hub}


func _write_json(path: String, data: Dictionary) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	_expect(file != null, "Cannot write isolated JSON fixture.")
	if file != null:
		file.store_string(JSON.stringify(data, "\t") + "\n")
		file.close()


func _check_migration() -> void:
	var path := _directory.path_join("migration.json")
	var store := ProgressStore.new(path)
	var legacy := HubState.new().to_save_data()
	legacy.erase("registered_items")
	legacy.erase("harness_durability")
	legacy.erase("harness_modules")
	legacy.erase("harness_upgrades")
	legacy.erase("paid_lures")
	legacy.erase("selected_lures")
	legacy.erase("pending_departure")
	legacy.erase("costs")
	legacy.erase("objective")
	legacy.money = "9223372036854775807"
	legacy.stored_items = [{"id": "test_g1_unknown", "identified": false, "risk_hint": "진동"}]
	_write_json(path, _envelope(1, legacy))
	var original := FileAccess.get_file_as_bytes(path)
	var upgraded := store.load_data()
	_expect(upgraded.size() == 15 and upgraded.registered_items.is_empty() and upgraded.harness_durability == 3 and HubState.from_save_data(upgraded, CATALOG) != null and FileAccess.get_file_as_bytes(path) == original, "Legacy load was lossy or rewrote the file.")
	_expect(DirAccess.make_dir_absolute(path + ".tmp") == OK, "Cannot prepare migration write failure.")
	_expect(store.save_data(upgraded) != OK and FileAccess.get_file_as_bytes(path) == original, "Failed migration destroyed legacy file.")
	_expect(DirAccess.remove_absolute(path + ".tmp") == OK, "Cannot remove isolated failure directory.")
	_expect(store.save_data(upgraded) == OK and store.load_data() == upgraded and JSON.parse_string(FileAccess.get_file_as_string(path)).schema_version == ProgressStore.SCHEMA_VERSION, "Successful save did not upgrade losslessly.")
	for invalid in [_envelope(1, upgraded), _envelope(2, legacy), _envelope(99, upgraded)]:
		_write_json(path, invalid)
		var before := FileAccess.get_file_as_bytes(path)
		_expect(store.load_data().is_empty() and store.save_data(upgraded) != OK and FileAccess.get_file_as_bytes(path) == before, "Malformed/future file was overwritten.")


func _check_empty_registry() -> void:
	_click(_hub.get_node("%RegistrationButton"))
	await _frames(3)
	_expect(_pending_list.item_count == 0 and _registered_list.item_count == 0 and _registration.get_node("%ReviewRegistration").disabled, "Empty registry offered registration.")
	_registration.review_requested.emit(-1)
	_registration.confirmation_requested.emit()
	_expect_registration_state(0, 0)
	_press_key(KEY_ESCAPE)
	await _frames(3)


func _depart_registry() -> PrototypeExploration:
	_expected_registry_money -= HubRepairTestInput.prepare_departure(_entry)
	_click(_hub.get_node("%DepartureButton"))
	await _frames(5)
	var world := _entry.get_node("PrototypeExploration") as PrototypeExploration
	_hub.registration_requested.emit()
	_registration.confirmation_requested.emit()
	_expect(not _registration.visible, "Exploration opened registry.")
	return world


func _settle_registry() -> void:
	await _frames(5)
	_click(_entry.get_node("Interface/Results/NextStep/SettleButton"))
	await _frames(5)


func _recover_originals(failure: bool) -> void:
	var world := await _depart_registry()
	_expect(world.has_node("ArtifactPickup") and world.has_node("RecordPickup"), "Unsecured original was excluded.")
	var player: PlayerController = world.get_node("Player")
	await _walk(player, Vector2(-680, 235))
	_press_key(KEY_E)
	_expect(await InteractionTestInput.wait_for_work(player), "Actual artifact recovery failed.")
	_expect(world.get_node("Player/Inventory").get_used_slots() == 1, "Artifact was not carried.")
	if failure:
		for point in [Vector2(-500, 235), Vector2(-500, 200), Vector2(-170, 200)]:
			await _walk(player, point)
		await _frames(100)
		_expect(_entry.get_pending_outcome() != null and _entry.get_pending_outcome().is_failure(), "Original failure run did not fail.")
	else:
		await _walk(player, Vector2(-450, 235))
		_press_key(KEY_E)
		_expect(await InteractionTestInput.wait_for_work(player), "Actual record recovery failed.")
		_expect(world.get_node("Player/Inventory").get_used_slots() == 2, "Record was not carried.")
		for point in [Vector2(-650, 235), Vector2(-650, 0), Vector2(-680, 0)]:
			await _walk(player, point)
		_press_key(KEY_E)
	await _settle_registry()


func _register_first() -> void:
	_click(_hub.get_node("%RegistrationButton"))
	await _frames(3)
	_hub.appraisal_requested.emit()
	_hub.sale_requested.emit()
	_hub.departure_requested.emit()
	_hub.bag_slots_selected.emit(2)
	_expect(_registration.visible and not _hub.get_node("Center").visible and not _hub.get_node("AppraisalPanel").visible and not _hub.get_node("SalePanel").visible and _entry.get_departure_preview().slot_capacity == 3, "Registry allowed conflicting services.")
	await _click_registry_row(_pending_list, 0)
	_click(_registration.get_node("%ReviewRegistration"))
	await _frames(3)
	await _capture_registration("quote", _registration)
	var before := FileAccess.get_file_as_bytes(_path)
	_press_key(KEY_ESCAPE)
	await _frames(3)
	_expect(_registration.get_node("%ReviewRegistration").visible and FileAccess.get_file_as_bytes(_path) == before, "Cancel changed registration.")
	_click(_registration.get_node("%CloseRegistration"))
	await _frames(3)
	_click(_hub.get_node("%RegistrationButton"))
	await _frames(3)
	_expect(_pending_list.get_selected_items().is_empty(), "Reopening kept pending selection.")
	await _click_registry_row(_pending_list, 0)
	_click(_registration.get_node("%ReviewRegistration"))
	await _frames(3)
	_expect(DirAccess.make_dir_absolute(_path + ".tmp") == OK, "Cannot prepare registration save failure.")
	_click(_registration.get_node("%ConfirmRegistration"))
	await _frames(3)
	_expect_registration_state(2, 0)
	_expect(FileAccess.get_file_as_bytes(_path) == before and "저장 실패" in _registration.get_node("%RegistrationDetails").text, "Failed registration changed file or hid retry.")
	await _capture_registration("retry", _registration)
	_expect(DirAccess.remove_absolute(_path + ".tmp") == OK, "Cannot remove isolated failure directory.")
	_click(_registration.get_node("%ConfirmRegistration"))
	_registration.confirmation_requested.emit()
	await _frames(3)
	_expect_registration_state(1, 1)
	before = FileAccess.get_file_as_bytes(_path)
	await _click_registry_row(_registered_list, 0)
	_expect("고유 유물 · 수집 등록" in _registration.get_node("%RegistrationDetails").text and FileAccess.get_file_as_bytes(_path) == before, "Artifact reading mutated registration or lost routing.")
	_click(_registration.get_node("%CloseRegistration"))
	await _frames(3)
	_click(_hub.get_node("%AppraisalButton"))
	await _frames(3)
	_hub.registration_requested.emit()
	_expect(not _registration.visible, "Appraisal allowed registry overlap.")
	_click(_hub.get_node("AppraisalPanel/%CloseAppraisal"))
	await _frames(3)
	_click(_hub.get_node("%SaleButton"))
	await _frames(3)
	_hub.registration_requested.emit()
	_expect(not _registration.visible, "Sale allowed registry overlap.")
	_click(_hub.get_node("SalePanel/%CloseSale"))
	await _frames(3)


func _check_excluded_return() -> void:
	var world := await _depart_registry()
	_expect(not world.has_node("ArtifactPickup") and not world.has_node("RecordPickup") and world.has_node("SafeLightPickup"), "Registered/stored originals respawned or ordinary loot disappeared.")
	await _walk(world.get_node("Player"), Vector2(-680, 0))
	_press_key(KEY_E)
	await _settle_registry()


func _register_second() -> void:
	_click(_hub.get_node("%RegistrationButton"))
	await _frames(3)
	_pending_list.grab_focus()
	_press_key(KEY_DOWN)
	_expect(_pending_list.get_selected_items() == PackedInt32Array([0]), "Keyboard could not select the remaining record.")
	_click(_registration.get_node("%ReviewRegistration"))
	await _frames(3)
	_click(_registration.get_node("%ConfirmRegistration"))
	await _frames(3)
	_expect_registration_state(0, 2)
	_click(_registration.get_node("%CloseRegistration"))
	await _frames(3)


func _failure_after_registration() -> void:
	var world := await _depart_registry()
	_expect(not world.has_node("ArtifactPickup") and not world.has_node("RecordPickup"), "Registered originals returned.")
	var player: PlayerController = world.get_node("Player")
	for point in [Vector2(-500, -200), Vector2(-275, -200)]:
		await _walk(player, point)
	_press_key(KEY_E)
	_expect(await InteractionTestInput.wait_for_work(player), "Failure run ordinary pickup failed.")
	for point in [Vector2(-500, -200), Vector2(-500, 200), Vector2(-170, 200)]:
		await _walk(player, point)
	await _frames(100)
	_expect(_entry.get_pending_outcome() != null and _entry.get_pending_outcome().is_failure(), "Post-registration failure did not occur.")
	await _settle_registry()
	_expect_registration_state(0, 2)


func _expect_registration_state(stored: int, registered: int) -> void:
	var saved := _store.load_data()
	_expect(_entry.get_hub_money() == _expected_registry_money and _entry.get_hub_stored_items().size() == stored and _entry.get_hub_registered_items().size() == registered, "Live original counts or money changed.")
	_expect(saved.size() == 15 and saved.money == str(_expected_registry_money) and saved.stored_items.size() == stored and saved.registered_items.size() == registered, "Saved registration differs from memory.")


func _click_registry_row(list: ItemList, index: int) -> void:
	var scroll := list.get_v_scroll_bar()
	scroll.value = list.get_item_rect(index).position.y
	await _frames(3)
	var point := list.global_position + list.get_item_rect(index).get_center() - Vector2(0, scroll.value)
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		get_viewport().push_input(event)
	await _frames(3)


func _capture_registration(label: String, panel: Control) -> void:
	for size in [Vector2i(1152, 648), Vector2i(1600, 900)]:
		get_tree().root.size = size
		await _frames(4)
		_expect(get_viewport().get_visible_rect().encloses(panel.get_node("Center/Card").get_global_rect()), "Hub/registration card exceeds viewport.")
		if _render and DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
			_expect(get_viewport().get_texture().get_image().save_png(_directory.path_join("%s-%d.png" % [label, size.x])) == OK, "Registration screenshot failed.")
	get_tree().root.size = Vector2i(1152, 648)
	await _frames(4)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		GameLog.error(&"SmokeTest", &"hub_registration_failed", message)
