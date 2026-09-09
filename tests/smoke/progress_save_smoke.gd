extends Node

const MAIN := preload("res://src/app/main.tscn")
const CATALOG := preload("res://src/data/prototype_item_catalog.tres")

var _failures := PackedStringArray()
var _directory := ""
var _path := ""
var _case := "default"
var _store: ProgressStore
var _entry: GameEntry
var _title: TitleScreen
var _settings_bytes := PackedByteArray()


func _ready() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	get_tree().root.gui_embed_subwindows = true
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--progress-case="):
			_case = argument.trim_prefix("--progress-case=")
		if argument.begins_with("--progress-test-directory="):
			_directory = argument.trim_prefix("--progress-test-directory=")
	if _directory.is_empty():
		_directory = OS.get_environment("TEMP").path_join("dungeon-progress-%d-%d" % [OS.get_process_id(), Time.get_ticks_usec()])
	_expect(DirAccess.make_dir_recursive_absolute(_directory) == OK, "Cannot create test directory.")
	_path = _directory.path_join("progress.json")
	_store = ProgressStore.new(_path)
	if _case == "default":
		_check_data()
	_prepare_fixture()
	var settings := GameSettings.new()
	settings.master_volume = 37
	var settings_store := SettingsStore.new(_directory.path_join("settings.cfg"))
	_expect(settings_store.save_settings(settings) == OK, "Cannot prepare separate settings fixture.")
	_settings_bytes = FileAccess.get_file_as_bytes(_directory.path_join("settings.cfg"))
	_entry = MAIN.instantiate()
	_entry.configure_progress(_store)
	_entry.configure_settings(settings_store)
	add_child(_entry)
	_title = _entry.get_node("Interface/TitleScreen")
	await _frames(5)
	if _case == "read":
		await _check_restart()
	elif _case in ["replace", "invalid", "future", "unknown_id"]:
		await _check_existing_record()
	elif _case == "disappeared":
		_expect(not _title.get_node("%ContinueButton").disabled, "Valid record was not available.")
		DirAccess.remove_absolute(_path)
		_click(_title.get_node("%ContinueButton"))
		await _frames(3)
		_expect(GameState.get_current_state() == GameState.State.TITLE and not _store.has_file(), "A removed record was restored or recreated.")
		_expect(_title.get_node("%ContinueButton").disabled, "Stale availability was not refreshed.")
	else:
		await _check_transactions()
	_expect(FileAccess.get_file_as_bytes(_directory.path_join("settings.cfg")) == _settings_bytes, "Progress operation changed settings.")
	if "--progress-render" in OS.get_cmdline_user_args() and DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(_directory.path_join("progress-%s.png" % _case))
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"progress_save_passed", _case)
	get_tree().quit(0 if _failures.is_empty() else 1)


func _check_data() -> void:
	var path := _directory.path_join("boundary.json")
	var store := ProgressStore.new(path)
	_expect(store.load_data().is_empty() and store.get_last_error() == ERR_FILE_NOT_FOUND, "Missing file was treated as a record.")
	var data := HubState.new().to_save_data()
	data.money = "9223372036854775807"
	data.next_expedition_id = "9223372036854775807"
	data.bag_slots = 3
	data.stored_items = [{"id": "test_g1_unknown", "identified": false, "risk_hint": "진동\n표식"}]
	_expect(store.save_data(data) == OK, "Could not write valid boundary data.")
	var hub := HubState.from_save_data(store.load_data(), CATALOG)
	_expect(hub != null, "Valid saved data failed to restore.")
	if hub == null:
		return
	_expect(hub.get_money() == 9223372036854775807 and hub.begin_expedition() == 0, "Int64 boundary lost precision or wrapped the run ID.")
	_expect(not hub.get_stored_items()[0].is_identified() and hub.get_stored_items()[0].get_risk_hint() == "진동\n표식", "Known item state changed.")
	hub.get_stored_items()[0].identify()
	hub.get_stored_items()[0].get_definition().display_name = "changed"
	_expect(not hub.get_stored_items()[0].is_identified() and CATALOG.find_item(&"test_g1_unknown").display_name != "changed", "Restored state shares mutable data.")
	var renamed_catalog := _copy_catalog()
	renamed_catalog.items[3].display_name = "이름 변경 시험"
	var renamed := HubState.from_save_data(data, renamed_catalog)
	_expect(renamed != null and renamed.get_stored_items()[0].get_definition().display_name == "이름 변경 시험", "Restore used display names instead of stable IDs.")
	var protected_catalog := _copy_catalog()
	protected_catalog.items[3].sale_protected = true
	var protected_hub := HubState.from_save_data(data, protected_catalog)
	_expect(protected_hub.get_stored_items()[0].get_definition().is_protected(), "Restore discarded definition protection.")
	var duplicate_catalog := _copy_catalog()
	duplicate_catalog.items.append(duplicate_catalog.items[0])
	_expect(HubState.from_save_data(data, duplicate_catalog) == null, "Ambiguous catalog was accepted.")
	_expect(CATALOG.find_item(&"test_g1_unknown").display_name == "시험용 낡은 장치" and not CATALOG.find_item(&"test_g1_unknown").sale_protected, "Test catalogs mutated the runtime definitions.")
	for invalid_money in [-1, 12.5, true, "-1", "01", "9223372036854775808", "bad"]:
		var invalid := data.duplicate(true)
		invalid.money = invalid_money
		_expect(HubState.from_save_data(invalid, CATALOG) == null, "Invalid money was accepted.")
	for change in [{"bag_slots": 2.5}, {"bag_slots": true}, {"bag_slots": 99}, {"next_expedition_id": "0"}, {"stored_items": [null]}, {"stored_items": [{"id": "unknown", "identified": false, "risk_hint": ""}]}, {"stored_items": [{"id": "test_g1_unknown", "identified": "false", "risk_hint": ""}]}]:
		var invalid := data.duplicate(true)
		invalid.merge(change, true)
		_expect(HubState.from_save_data(invalid, CATALOG) == null, "Invalid record was partially restored.")
	var active := HubState.new()
	active.begin_expedition()
	_expect(active.to_save_data().is_empty(), "Active exploration was serializable as settled progress.")
	var previous := FileAccess.get_file_as_bytes(path)
	DirAccess.make_dir_absolute(path + ".tmp")
	_expect(store.save_data(HubState.new().to_save_data()) != OK and FileAccess.get_file_as_bytes(path) == previous, "Failed write changed the old file.")
	DirAccess.remove_absolute(path + ".tmp")
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string("{broken")
	file.close()
	_expect(store.load_data().is_empty() and store.get_last_error() == ERR_INVALID_DATA, "Malformed JSON was accepted.")
	previous = FileAccess.get_file_as_bytes(path)
	_expect(store.save_data(data) != OK and FileAccess.get_file_as_bytes(path) == previous, "Invalid old file was overwritten without replacement approval.")
	_expect(store.save_data(data, true) == OK, "Explicit replacement could not create a valid record.")
	var future: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	future.schema_version = 99
	file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(future))
	file.close()
	_expect(store.load_data().is_empty() and store.get_last_error() == ERR_UNAVAILABLE, "Unsupported version was accepted.")
	previous = FileAccess.get_file_as_bytes(path)
	_expect(store.save_data(data) != OK and FileAccess.get_file_as_bytes(path) == previous, "Unsupported record was overwritten automatically.")
	DirAccess.remove_absolute(path)


func _copy_catalog() -> ItemCatalog:
	var copy := ItemCatalog.new()
	for definition in CATALOG.items:
		copy.items.append(definition.duplicate(true) as ItemDefinition)
	return copy


func _prepare_fixture() -> void:
	if _case in ["default", "read"]:
		return
	var data := HubState.new().to_save_data()
	data.money = "40"
	data.bag_slots = 3
	if _case == "unknown_id":
		data.stored_items = [{"id": "unknown", "identified": false, "risk_hint": ""}]
	_expect(_store.save_data(data) == OK, "Cannot prepare record fixture.")
	if _case == "invalid":
		var file := FileAccess.open(_path, FileAccess.WRITE)
		file.store_string("{broken")
		file.close()
	elif _case == "future":
		var root: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(_path))
		root.schema_version = 99
		var file := FileAccess.open(_path, FileAccess.WRITE)
		file.store_string(JSON.stringify(root))
		file.close()


func _check_transactions() -> void:
	_expect(_title.get_node("%ContinueButton").disabled and not _store.has_file(), "No-record title enabled Continue or wrote progress.")
	DirAccess.make_dir_absolute(_path + ".tmp")
	_click(_title.get_node("%NewGameButton"))
	await _frames(3)
	_expect(GameState.get_current_state() == GameState.State.TITLE and not _store.has_file(), "Failed new game entered Hub or created progress.")
	_expect("저장하지 못했습니다" in _title.get_node("%Status").text, "New game save failure was hidden.")
	DirAccess.remove_absolute(_path + ".tmp")
	_click(_title.get_node("%NewGameButton"))
	await _frames(5)
	_expect(GameState.get_current_state() == GameState.State.HUB and _store.has_file(), "New game did not save before entering Hub.")
	var hub: HubPanel = _entry.get_node("Interface/HubPanel")
	var previous := FileAccess.get_file_as_bytes(_path)
	DirAccess.make_dir_absolute(_path + ".tmp")
	hub.bag_slots_selected.emit(3)
	_expect(_entry.get_departure_preview().slot_capacity == 2 and FileAccess.get_file_as_bytes(_path) == previous, "Failed preparation changed the selection or file.")
	_expect("저장하지 못해" in hub.get_node("%HubStatus").text, "Preparation save failure was hidden.")
	DirAccess.remove_absolute(_path + ".tmp")
	hub.bag_slots_selected.emit(3)
	_expect(_store.load_data().bag_slots == 3, "Preparation was not saved.")
	previous = FileAccess.get_file_as_bytes(_path)
	_click(hub.get_node("%DepartureButton"))
	await _frames(5)
	var world: PrototypeExploration = _entry.get_node("PrototypeExploration")
	var inventory: PlayerInventory = world.get_node("Player/Inventory")
	inventory.try_add_item(CATALOG.find_item(&"test_g1_light"))
	inventory.try_add_item(CATALOG.find_item(&"test_g1_unknown"), false, "희미한 진동이 느껴집니다.")
	_expect(FileAccess.get_file_as_bytes(_path) == previous, "Exploration pickups changed permanent progress.")
	world.get_node("ExplorationRun").complete_safe_return()
	await _frames(5)
	_expect(FileAccess.get_file_as_bytes(_path) == previous, "Result preview changed permanent progress.")
	DirAccess.make_dir_absolute(_path + ".tmp")
	var results: ExpeditionResultsScreen = _entry.get_node("Interface/Results")
	_click(results.get_node("NextStep/SettleButton"))
	await _frames(3)
	_expect(GameState.get_current_state() == GameState.State.RESULTS and _entry.get_hub_money() == 0 and _entry.get_hub_stored_items().is_empty(), "Failed save applied settlement or left results.")
	_expect(FileAccess.get_file_as_bytes(_path) == previous and "저장하지 못했습니다" in results.get_node("NextStep/Notice").text, "Failed settlement changed the record or hid the failure.")
	_expect(Rect2(0, 0, 1152, 648).encloses(results.get_node("NextStep/QuitButton").get_global_rect()), "Save failure pushed result actions offscreen.")
	if "--progress-render" in OS.get_cmdline_user_args() and DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(_directory.path_join("settlement-save-failure.png"))
	DirAccess.remove_absolute(_path + ".tmp")
	_click(results.get_node("NextStep/SettleButton"))
	_click(results.get_node("NextStep/SettleButton"))
	await _frames(5)
	_expect(GameState.get_current_state() == GameState.State.HUB and _entry.get_hub_money() == 10 and _entry.get_hub_stored_items().size() == 1, "Retry lost or duplicated settlement.")
	var restored := HubState.from_save_data(_store.load_data(), CATALOG)
	_expect(restored != null and restored.get_money() == 10 and restored.get_stored_items().size() == 1, "Committed memory differs from saved progress.")
	_expect("200" not in hub.get_node("%StoredItems").text and "감정 대기" in hub.get_node("%StoredItems").text, "Stored unknown item leaked its value.")


func _check_restart() -> void:
	_expect(not _title.get_node("%ContinueButton").disabled and _title.get_node("%ContinueButton").has_focus(), "Persisted record did not enable/focus Continue.")
	var previous := FileAccess.get_file_as_bytes(_path)
	_click(_title.get_node("%ContinueButton"))
	_click(_title.get_node("%ContinueButton"))
	await _frames(5)
	_expect(GameState.get_current_state() == GameState.State.HUB, "Continue did not restore to Hub.")
	_expect(_entry.get_hub_money() == 40 and _entry.get_hub_stored_items().size() == 1 and _entry.get_departure_preview().slot_capacity == 3, "Restart changed money, items or preparation.")
	if _entry.get_hub_stored_items().is_empty():
		return
	var item := _entry.get_hub_stored_items()[0]
	_expect(item.get_definition().stable_id == &"test_g1_unknown" and not item.is_identified() and item.get_risk_hint() == "희미한 진동이 느껴집니다.", "Restart changed unknown item identity or public knowledge.")
	_expect(FileAccess.get_file_as_bytes(_path) == previous, "Continue rewrote the record.")
	var hub: HubPanel = _entry.get_node("Interface/HubPanel")
	_click(hub.get_node("%DepartureButton"))
	await _frames(5)
	var world: PrototypeExploration = _entry.get_node("PrototypeExploration")
	_expect(world.get_node("Player/Inventory").slot_capacity == 3 and world.get_node("Player/Inventory").get_used_slots() == 0, "Restored preparation did not start a fresh expedition.")
	_expect(world.get_node("Player/HarnessController").get_current_charge() == 3, "Restored harness did not use its baseline configuration.")
	world.get_node("ExplorationRun").complete_failure()
	await _frames(5)
	_click(_entry.get_node("Interface/Results/NextStep/SettleButton"))
	await _frames(5)
	_expect(_entry.get_hub_money() == 40 and _entry.get_hub_stored_items().size() == 1 and _store.load_data().next_expedition_id == "5", "Post-restart failure changed existing holdings or reset progression.")


func _check_existing_record() -> void:
	var invalid := _case != "replace"
	_expect(_title.get_node("%ContinueButton").disabled == invalid, "Invalid/valid availability was incorrect.")
	if invalid:
		_expect("읽지 못했습니다" in _title.get_node("%Status").text, "Unreadable record was not explained.")
	var previous := FileAccess.get_file_as_bytes(_path)
	_click(_title.get_node("%NewGameButton"))
	await _frames(3)
	var dialog: ConfirmationDialog = _title.get_node("%NewGameConfirm")
	_expect(dialog.visible and dialog.get_cancel_button().has_focus(), "Existing record was not protected by a cancel-focused confirmation.")
	if "--progress-render" in OS.get_cmdline_user_args() and DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(_directory.path_join("new-game-confirmation.png"))
	var escape := InputEventKey.new()
	escape.keycode = KEY_ESCAPE
	escape.physical_keycode = KEY_ESCAPE
	escape.pressed = true
	get_viewport().push_input(escape, true)
	escape = escape.duplicate() as InputEventKey
	escape.pressed = false
	get_viewport().push_input(escape, true)
	await _frames(3)
	_expect(not dialog.visible and FileAccess.get_file_as_bytes(_path) == previous, "Escape did not cancel replacement safely.")
	_click(_title.get_node("%NewGameButton"))
	await _frames(3)
	_title.new_game_requested.emit()
	_title.continue_requested.emit()
	_expect(GameState.get_current_state() == GameState.State.TITLE and FileAccess.get_file_as_bytes(_path) == previous, "Underlying menu bypassed confirmation.")
	_click(dialog.get_cancel_button())
	await _frames(3)
	_expect(not dialog.visible and FileAccess.get_file_as_bytes(_path) == previous, "Cancel changed the old record.")
	_click(_title.get_node("%NewGameButton"))
	await _frames(3)
	DirAccess.make_dir_absolute(_path + ".tmp")
	_click(dialog.get_ok_button())
	await _frames(3)
	_expect(GameState.get_current_state() == GameState.State.TITLE and FileAccess.get_file_as_bytes(_path) == previous, "Failed confirmed replacement lost the old record.")
	DirAccess.remove_absolute(_path + ".tmp")
	_click(_title.get_node("%NewGameButton"))
	await _frames(3)
	_click(dialog.get_ok_button())
	await _frames(5)
	_expect(GameState.get_current_state() == GameState.State.HUB and _entry.get_hub_money() == 0 and _entry.get_hub_stored_items().is_empty(), "Confirmed replacement failed to start fresh.")
	_expect(_store.load_data().money == "0" and _store.load_data().bag_slots == 2, "Confirmed replacement did not persist a fresh Hub.")


func _click(button: Button) -> void:
	var viewport := button.get_viewport()
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = button.get_global_rect().get_center()
	if viewport != get_viewport() and viewport is Window:
		event.position += Vector2(viewport.position)
		viewport = get_viewport()
	event.pressed = true
	viewport.push_input(event, true)
	var release := event.duplicate() as InputEventMouseButton
	release.pressed = false
	viewport.push_input(release, true)


func _frames(count: int) -> void:
	for i in range(count):
		await get_tree().process_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		GameLog.error(&"SmokeTest", &"progress_save_failed", message)
