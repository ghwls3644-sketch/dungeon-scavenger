extends "res://tests/smoke/return_route_smoke.gd"

const ENTRY := preload("res://tests/fixtures/g3_review_entry.tscn")
const ESCAPE := preload("res://tests/fixtures/emergency_escape_test_space.tscn")
const CATALOG := preload("res://src/data/prototype_item_catalog.tres")
const ECONOMY := preload("res://src/data/prototype_economy.tres")
const WEAR := preload("res://src/data/prototype_equipment_wear.tres")
const RESEARCH := preload("res://src/data/prototype_research_catalog.tres")

var _directory := ""
var _path := ""
var _case := "write"
var _render := false
var _store: ProgressStore
var _entry: GameEntry
var _hub: HubPanel
var _results: ExpeditionResultsScreen


func _ready() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--wear-directory="):
			_directory = argument.trim_prefix("--wear-directory=")
		if argument.begins_with("--wear-case="):
			_case = argument.trim_prefix("--wear-case=")
	_render = "--wear-render" in OS.get_cmdline_user_args()
	if _directory.is_empty():
		_directory = OS.get_environment("TEMP").path_join("dungeon-wear-%d-%d" % [OS.get_process_id(), Time.get_ticks_usec()])
	_expect(DirAccess.make_dir_recursive_absolute(_directory) == OK, "Cannot create isolated wear directory.")
	_path = _directory.path_join("progress.json")
	_store = ProgressStore.new(_path)
	if _case == "write":
		_check_domain()
		_check_migration()
	var settings := SettingsStore.new(_directory.path_join("settings.cfg"))
	if _case != "continue":
		_expect(not _store.has_file(), "Wear test requires a fresh directory.")
		var initial := _initial_data()
		if _case in ["legacy1", "legacy2"]:
			initial.erase("harness_durability")
			initial.erase("harness_modules")
			initial.erase("harness_upgrades")
			initial.erase("paid_lures")
			initial.erase("selected_lures")
			initial.erase("pending_departure")
			initial.erase("costs")
			if _case == "legacy1":
				initial.erase("registered_items")
			_write_json(_path, _envelope(1 if _case == "legacy1" else 2, initial))
		elif _case == "invalid":
			initial.harness_durability = -1
			_write_json(_path, _envelope(ProgressStore.SCHEMA_VERSION, initial))
		else:
			_expect(_store.save_data(initial) == OK, "Cannot seed wear fixture.")
		_expect(settings.save_settings(GameSettings.new()) == OK, "Cannot seed settings.")
	var original := FileAccess.get_file_as_bytes(_path)
	var settings_bytes := FileAccess.get_file_as_bytes(_directory.path_join("settings.cfg"))
	_entry = ENTRY.instantiate()
	_entry.configure_progress(_store)
	_entry.configure_settings(settings)
	add_child(_entry)
	await _frames(5)
	_hub = _entry.get_node("Interface/HubPanel")
	_results = _entry.get_node("Interface/Results")
	var title: TitleScreen = _entry.get_node("Interface/TitleScreen")
	if _case == "invalid":
		_expect(title.get_node("%ContinueButton").disabled, "Malformed durability enabled Continue.")
		title.continue_requested.emit()
		await _frames(3)
		_expect(GameState.get_current_state() == GameState.State.TITLE and FileAccess.get_file_as_bytes(_path) == original, "Invalid Continue overwrote or partially loaded save.")
	else:
		_expect(not title.get_node("%ContinueButton").disabled, "Valid wear save could not continue.")
		_click(title.get_node("%ContinueButton"))
		await _frames(5)
		_expect(GameState.get_current_state() == GameState.State.HUB and FileAccess.get_file_as_bytes(_path) == original, "Continue rewrote wear save.")
		if _case == "continue":
			_check_hub(0)
			await _capture_wear("continue-zero", _hub.get_node("Center/Card"))
			await _normal_return(0, false)
		elif _case in ["legacy1", "legacy2"]:
			_check_hub(3)
			_expect(DirAccess.make_dir_absolute(_path + ".tmp") == OK, "Cannot block migration write.")
			_hub.bag_slots_selected.emit(2)
			_expect(_entry.get_departure_preview().slot_capacity == 3 and FileAccess.get_file_as_bytes(_path) == original, "Failed migration changed bag/save.")
			_expect(DirAccess.remove_absolute(_path + ".tmp") == OK, "Cannot unblock migration write.")
			_hub.bag_slots_selected.emit(2)
			_expect(JSON.parse_string(FileAccess.get_file_as_string(_path)).schema_version == ProgressStore.SCHEMA_VERSION and _store.load_data().harness_durability == 3, "Next successful save failed migration.")
			_hub.bag_slots_selected.emit(3)
			await _normal_return(3, false)
		else:
			_check_hub(3)
			await _normal_return(3, true)
			await _emergency_return()
			await _actual_failure()
			_check_hub(0)
			await _capture_wear("hub-zero", _hub.get_node("Center/Card"))
			await _normal_return(0, false)
	_expect(FileAccess.get_file_as_bytes(_directory.path_join("settings.cfg")) == settings_bytes, "Wear modified settings.")
	_release()
	_write_json(_directory.path_join("wear-%s.json" % _case), {
		"passed": _failures.is_empty(), "case": _case, "final_hub": _store.load_data(), "failures": _failures,
	})
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"equipment_wear_passed", _case)
	get_tree().quit(0 if _failures.is_empty() else 1)


func _initial_data() -> Dictionary:
	var data := HubState.new().to_save_data()
	data.bag_slots = 3
	data.registered_items = [
		{"id": "test_g4_record", "identified": true, "risk_hint": ""},
		{"id": "test_g4_artifact", "identified": true, "risk_hint": ""},
	]
	return data


func _check_domain() -> void:
	_expect(WEAR.is_valid(), "Prototype wear data invalid.")
	for start in [0, 1, 2, 3]:
		for outcome in [ExplorationOutcome.safe_return([]), ExplorationOutcome.safe_return_inventory_items([], &"emergency_escape"), ExplorationOutcome.failure(2)]:
			var data := _initial_data()
			data.harness_durability = start
			var hub := HubState.from_save_data(data, CATALOG)
			var run_id := hub.begin_expedition()
			_expect(hub.cancel_expedition(run_id) and hub.get_harness_durability() == start, "Canceled departure wore equipment.")
			var next_id := hub.begin_expedition()
			_expect(not hub.prepare_settlement(run_id, outcome, ECONOMY), "Canceled/stale result accepted.")
			_expect(not hub.prepare_settlement(next_id, null, ECONOMY) and hub.get_harness_durability() == start, "Invalid result damaged equipment.")
			_expect(hub.prepare_settlement(next_id, outcome, ECONOMY), "Valid wear result rejected.")
			var damage := mini(start, 2 if outcome.is_failure() else 1)
			var expected := {"before": start, "after": start - damage, "damage": damage, "maximum": 3}
			var result := hub.get_pending_settlement()
			_expect(result.get_equipment_damage() == expected and result.get_total_cost() == 0, "Wear amount/cost incorrect.")
			result.get_equipment_damage().after = 999
			_expect(result.get_equipment_damage() == expected and hub.get_harness_durability() == start, "Preview exposed mutable or live durability.")
			_expect(not hub.prepare_settlement(next_id, outcome, ECONOMY), "Duplicate result replaced preview.")
			var candidate := hub.copy()
			_expect(candidate.apply_settlement(next_id) and not candidate.apply_settlement(next_id), "Candidate applied wear twice.")
			_expect(hub.get_harness_durability() == start and candidate.get_harness_durability() == start - damage, "Candidate changed original or misapplied wear.")
			_expect(candidate.get_money() == 0 and candidate.get_registered_items().size() == 2 and candidate.create_departure_loadout().starting_charge == 3, "Wear changed other permanent resources.")
			_expect(hub.apply_settlement(next_id) and hub.get_harness_durability() == start - damage, "Original retry changed wear amount.")
	var rule := WEAR.duplicate(true) as EquipmentWearRule
	var snapshot := SettlementResult.from_outcome(ExplorationOutcome.failure(0), ECONOMY, rule, 3)
	rule.failure_damage = 9223372036854775807
	_expect(snapshot.get_equipment_damage().after == 1, "Changed rule mutated offered damage.")
	_expect(SettlementResult.from_outcome(ExplorationOutcome.failure(0), ECONOMY, rule, 3).get_equipment_damage().after == 0, "Large damage underflowed.")
	for changes in [{"max_durability": 0}, {"return_damage": -1}, {"failure_damage": -1}]:
		var invalid := WEAR.duplicate(true) as EquipmentWearRule
		for key in changes:
			invalid.set(key, changes[key])
		_expect(not invalid.is_valid() and SettlementResult.from_outcome(ExplorationOutcome.failure(0), ECONOMY, invalid, 3) == null, "Invalid wear rule accepted.")
	var max_money := _initial_data()
	max_money.money = "9223372036854775807"
	max_money.costs = ExpeditionCosts.new_book(max_money.money.to_int())
	var full := HubState.from_save_data(max_money, CATALOG)
	var id := full.begin_expedition()
	_expect(not full.prepare_settlement(id, ExplorationOutcome.safe_return([CATALOG.find_item(&"test_g1_light")]), ECONOMY), "Overflowed accounting preview was accepted.")
	_expect(not full.apply_settlement(id) and full.get_harness_durability() == 3, "Failed income overflow applied partial damage.")


func _check_migration() -> void:
	var path := _directory.path_join("migration.json")
	var store := ProgressStore.new(path)
	for version in [1, 2]:
		var legacy := _initial_data()
		legacy.erase("harness_durability")
		legacy.erase("harness_modules")
		legacy.erase("harness_upgrades")
		legacy.erase("paid_lures")
		legacy.erase("selected_lures")
		legacy.erase("pending_departure")
		legacy.erase("costs")
		if version == 1:
			legacy.erase("registered_items")
		_write_json(path, _envelope(version, legacy))
		var bytes := FileAccess.get_file_as_bytes(path)
		var upgraded := store.load_data()
		_expect(upgraded.harness_durability == 3 and upgraded.registered_items.size() == (0 if version == 1 else 2) and FileAccess.get_file_as_bytes(path) == bytes, "Legacy load was lossy or rewrote file.")
		_expect(store.save_data(upgraded) == OK and store.load_data() == upgraded and JSON.parse_string(FileAccess.get_file_as_string(path)).schema_version == ProgressStore.SCHEMA_VERSION, "Legacy upgrade failed.")
	for value in [-1, 4, 0.5, "2", true, null, INF, NAN]:
		var bad := _initial_data()
		bad.harness_durability = value
		_expect(HubState.from_save_data(bad, CATALOG) == null and store.save_data(bad) != OK, "Malformed durability serialized/restored.")
	for value in [-1, 4, 0.5, "2", true, null]:
		var bad := _initial_data()
		bad.harness_durability = value
		_check_bad_file(store, path, _envelope(ProgressStore.SCHEMA_VERSION, bad))
	var missing := _initial_data()
	missing.erase("harness_durability")
	_check_bad_file(store, path, _envelope(ProgressStore.SCHEMA_VERSION, missing))
	var extra := _initial_data()
	extra.extra = 1
	_check_bad_file(store, path, _envelope(ProgressStore.SCHEMA_VERSION, extra))
	for version in [1, 2, 99]:
		_check_bad_file(store, path, _envelope(version, _initial_data()))


func _check_bad_file(store: ProgressStore, path: String, envelope: Dictionary) -> void:
	_write_json(path, envelope)
	var bytes := FileAccess.get_file_as_bytes(path)
	_expect(store.load_data().is_empty() and store.save_data(_initial_data()) != OK and FileAccess.get_file_as_bytes(path) == bytes, "Malformed/future file overwritten or accepted.")


func _check_hub(durability: int) -> void:
	var saved := _store.load_data()
	_expect(_entry.get_hub_harness_durability() == durability and saved.harness_durability == durability, "Live/saved durability mismatch.")
	_expect("내구 %d/3" % durability in _hub.get_node("%EquipmentStatus").text and not _hub.get_node("%DepartureButton").disabled, "Hub wear display/departure incorrect.")
	_expect(_entry.get_hub_money() == 0 and _entry.get_hub_stored_items().is_empty(), "Empty wear run charged money or created items.")
	var registered := _entry.get_hub_registered_items()
	_expect(registered.size() == (0 if _case == "legacy1" else 2), "Wear lost registered originals.")
	if _case != "legacy1":
		_expect(ResearchProgress.get_entries(registered, RESEARCH, CATALOG)[1].unlocked, "Wear lost research progress.")


func _depart_wear(emergency := false) -> PrototypeExploration:
	_expect(HubRepairTestInput.prepare_departure(_entry) == 0, "Empty wear loop charged money.")
	var durability := _entry.get_hub_harness_durability()
	var before := _store.load_data()
	_entry.review_scene = ESCAPE if emergency else null
	_click(_hub.get_node("%DepartureButton"))
	await _frames(5)
	var world: PrototypeExploration = _entry.get_node("EmergencyEscapeTestSpace" if emergency else "PrototypeExploration")
	var saved := _store.load_data()
	_expect(saved.pending_departure.phase == "started" and saved.next_expedition_id.to_int() == before.next_expedition_id.to_int() + 1, "Departure journal missing.")
	for key in ["next_expedition_id", "pending_departure"]:
		saved.erase(key)
		before.erase(key)
	_expect(GameState.get_current_state() == GameState.State.EXPLORATION and _entry.get_hub_harness_durability() == durability and saved == before, "Departure changed durability/holdings.")
	_expect(world.get_node("Player/HarnessController").get_current_charge() == 3 and world.get_node("PlayerSurvival").get_health() == 2 and world.get_node("Player/Inventory").slot_capacity == 3, "Durability changed charge, health or bag.")
	return world


func _normal_return(before: int, retry: bool) -> void:
	await _depart_wear()
	_tap(KEY_E)
	await _frames(5)
	_expect(_entry.get_pending_outcome().get_return_method() == &"entrance", "Actual empty entrance return failed.")
	before = maxi(1, before) # DEV-0407 support restores the departure minimum.
	await _settle_wear(before, maxi(0, before - 1), retry, "return" if retry else "")


func _emergency_return() -> void:
	var world := await _depart_wear(true)
	var player: PlayerController = world.get_node("Player")
	await _walk(player, Vector2(-650, -200))
	await _walk(player, Vector2(-275, -200))
	await _walk(player, Vector2(40, -280))
	await _frames(190)
	_expect(world.get_node("EmergencyEscape").is_route_lost(), "Emergency fixture did not lose route.")
	_tap(KEY_E)
	await _frames(250)
	_expect(_entry.get_pending_outcome() != null and _entry.get_pending_outcome().get_return_method() == &"emergency_escape", "Actual emergency return failed.")
	await _settle_wear(2, 1, false, "emergency")


func _actual_failure() -> void:
	var world := await _depart_wear()
	var player: PlayerController = world.get_node("Player")
	for point in [Vector2(-500, 0), Vector2(-500, 200), Vector2(-170, 200)]:
		await _walk(player, point)
	await _frames(100)
	_expect(_entry.get_pending_outcome() != null and _entry.get_pending_outcome().is_failure(), "Actual danger did not end expedition.")
	await _settle_wear(1, 0, false, "failure")


func _settle_wear(before: int, after: int, retry: bool, capture: String) -> void:
	_expect(GameState.get_current_state() == GameState.State.RESULTS and _entry.get_hub_harness_durability() == before, "Preview applied wear before save.")
	var text: String = _results.get_node("NextStep/EquipmentDamage").text
	_expect("%d/3 → %d/3" % [before, after] in text and "이번 손상 %d" % (before - after) in text and "수리비는 차감하지 않았습니다" in text, "Result damage/payment display incorrect.")
	if not capture.is_empty():
		await _capture_wear(capture, _results.get_node("NextStep"))
	var bytes := FileAccess.get_file_as_bytes(_path)
	if retry:
		_expect(DirAccess.make_dir_absolute(_path + ".tmp") == OK, "Cannot block settlement save.")
		for attempt in range(2):
			_click(_results.get_node("NextStep/SettleButton"))
			await _frames(3)
			_expect(GameState.get_current_state() == GameState.State.RESULTS and _entry.get_hub_harness_durability() == before and FileAccess.get_file_as_bytes(_path) == bytes, "Failed save applied or accumulated damage.")
		await _capture_wear("save-failure", _results.get_node("NextStep"))
		_expect(DirAccess.remove_absolute(_path + ".tmp") == OK, "Cannot unblock settlement save.")
	_results.get_node("NextStep/SettleButton").grab_focus()
	_tap(KEY_ENTER)
	await _frames(5)
	_results.settlement_requested.emit()
	_expect(GameState.get_current_state() == GameState.State.HUB, "Settlement did not return to hub.")
	_check_hub(after)


func _capture_wear(label: String, panel: Control) -> void:
	for size in [Vector2i(1152, 648), Vector2i(1600, 900)]:
		get_tree().root.size = size
		await _frames(5)
		_expect(get_viewport().get_visible_rect().encloses(panel.get_global_rect()), "Wear UI clips at supported resolution.")
		if _render and DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
			_expect(get_viewport().get_texture().get_image().save_png(_directory.path_join("%s-%d.png" % [label, size.x])) == OK, "Wear capture failed.")
	get_tree().root.size = Vector2i(1152, 648)
	await _frames(5)


func _click(button: Button) -> void:
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = button.get_global_rect().get_center()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		get_viewport().push_input(event, true)


func _envelope(version: int, hub: Dictionary) -> Dictionary:
	return {"schema_version": version, "content_version": ProgressStore.CONTENT_VERSION, "resume_state": "hub", "hub": hub}


func _write_json(path: String, data: Dictionary) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	_expect(file != null, "Cannot write fixture/report.")
	if file != null:
		file.store_string(JSON.stringify(data, "\t") + "\n")
		file.close()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		GameLog.error(&"SmokeTest", &"equipment_wear_failed", message)
