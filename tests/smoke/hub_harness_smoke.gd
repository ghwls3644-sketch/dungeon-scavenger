extends "res://tests/smoke/hub_repair_smoke.gd"

var _panel: HubHarnessPanel
var _action_evidence: Array[Dictionary] = []


func _ready() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--harness-directory="):
			_directory = argument.trim_prefix("--harness-directory=")
		if argument.begins_with("--harness-case="):
			_case = argument.trim_prefix("--harness-case=")
	_render = "--harness-render" in OS.get_cmdline_user_args()
	if _directory.is_empty():
		_directory = OS.get_environment("TEMP").path_join("dungeon-harness-%d-%d" % [OS.get_process_id(), Time.get_ticks_usec()])
	_expect(DirAccess.make_dir_recursive_absolute(_directory) == OK, "Cannot create harness directory.")
	_path = _directory.path_join("progress.json")
	_store = ProgressStore.new(_path)
	var settings := SettingsStore.new(_directory.path_join("settings.cfg"))
	if _case != "continue":
		_check_modules_domain()
		_check_module_migration()
		var initial := _repair_data(0, 3)
		if _case == "support":
			initial.harness_durability = 0
			initial.harness_modules = HarnessModules.PAIRS[1].duplicate()
		if _case.begins_with("legacy"):
			var version := _case.trim_prefix("legacy").to_int()
			initial.erase("harness_modules")
			initial.erase("harness_upgrades")
			initial.erase("paid_lures")
			initial.erase("selected_lures")
			initial.erase("pending_departure")
			if version < 3:
				initial.erase("harness_durability")
			if version == 1:
				initial.erase("registered_items")
			_write_json(_path, _envelope(version, initial))
		else:
			_expect(_store.save_data(initial) == OK, "Cannot seed equipment.")
		_expect(settings.save_settings(GameSettings.new()) == OK, "Cannot seed settings.")
		if _case == "write":
			await _check_action_pairs()
	var original := FileAccess.get_file_as_bytes(_path)
	_settings_bytes = FileAccess.get_file_as_bytes(_directory.path_join("settings.cfg"))
	_entry = ENTRY.instantiate()
	_entry.configure_progress(_store)
	_entry.configure_settings(settings)
	add_child(_entry)
	await _frames(5)
	_hub = _entry.get_node("Interface/HubPanel")
	_panel = _hub.get_node("HarnessPanel")
	_repair = _hub.get_node("RepairPanel")
	_results = _entry.get_node("Interface/Results")
	_hub.harness_requested.emit()
	_panel.confirmation_requested.emit()
	_expect(not _panel.visible and FileAccess.get_file_as_bytes(_path) == original, "Title allowed equipment.")
	_click(_entry.get_node("Interface/TitleScreen/%ContinueButton"))
	await _frames(5)
	_expect(GameState.get_current_state() == GameState.State.HUB and FileAccess.get_file_as_bytes(_path) == original, "Continue rewrote equipment save.")
	if _case.begins_with("legacy"):
		_expect("이전 기록" in _hub.get_node("%HubStatus").text and _entry.get_departure_preview().harness_modules == HarnessModules.DEFAULT, "Legacy default/notice missing.")
		await _capture_wear("legacy", _hub.get_node("Center/Card"))
		await _choose_pair(1, true)
		_expect(JSON.parse_string(FileAccess.get_file_as_string(_path)).schema_version == ProgressStore.SCHEMA_VERSION, "Successful equipment save did not migrate.")
	elif _case == "support":
		_expect(HubRepairTestInput.prepare_departure(_entry) == 0, "Minimum support charged zero balance.")
		_expect(_entry.get_departure_preview().harness_modules == HarnessModules.PAIRS[1], "Support replaced equipment.")
		await _capture_wear("supported", _hub.get_node("Center/Card"))
		await _recover_pair(HarnessModules.PAIRS[1])
	elif _case == "continue":
		_expect(_entry.get_departure_preview().harness_modules == HarnessModules.PAIRS[1], "New process lost final selection.")
		await _capture_wear("continued", _hub.get_node("Center/Card"))
		await _recover_pair(HarnessModules.PAIRS[1])
	else:
		await _check_modal_cancel()
		for index in [1, 2, 0]:
			await _choose_pair(index, index == 1)
			await _recover_pair(HarnessModules.PAIRS[index])
		await _choose_pair(1)
		# Existing actual hazard failure and paid minimum repair, with non-default equipment.
		_expect(HubRepairTestInput.prepare_departure(_entry) == 5, "Paid minimum repair cost changed.")
		var before_money := _entry.get_hub_money()
		var before_stored := _entry.get_hub_stored_items().size()
		_click(_hub.get_node("%DepartureButton"))
		await _frames(5)
		var world: PrototypeExploration = _entry.get_node("PrototypeExploration")
		for point in [Vector2(-500, 0), Vector2(-500, 200), Vector2(-170, 200)]:
			await _walk(world.get_node("Player"), point)
		await _frames(100)
		_expect(_entry.get_pending_outcome() != null and _entry.get_pending_outcome().is_failure(), "Actual failure missing.")
		_click(_results.get_node("NextStep/SettleButton"))
		await _frames(5)
		_expect(_entry.get_hub_money() == before_money and _entry.get_hub_stored_items().size() == before_stored and _entry.get_departure_preview().harness_modules == HarnessModules.PAIRS[1], "Failure erased secured progress/equipment.")
		_expect(HubRepairTestInput.prepare_departure(_entry) == 5 and _entry.get_hub_harness_durability() == 1, "Support did not restore departure minimum.")
		_expect(_entry.get_departure_preview().harness_modules == HarnessModules.PAIRS[1], "Repair changed equipment.")
		# E emergency escape is deliberately outside the emergency module gate.
		_entry.review_scene = ESCAPE
		_click(_hub.get_node("%DepartureButton"))
		await _frames(5)
		world = _entry.get_node("EmergencyEscapeTestSpace")
		for point in [Vector2(-650, -200), Vector2(-275, -200), Vector2(40, -280)]:
			await _walk(world.get_node("Player"), point)
		await _frames(190)
		_tap(KEY_E)
		await _frames(250)
		_expect(_entry.get_pending_outcome() != null and _entry.get_pending_outcome().get_return_method() == &"emergency_escape", "Missing emergency module blocked separate E escape.")
		_click(_results.get_node("NextStep/SettleButton"))
		await _frames(5)
		_expect(_store.load_data().harness_modules == HarnessModules.PAIRS[1], "Emergency return lost equipment.")
	_expect(FileAccess.get_file_as_bytes(_directory.path_join("settings.cfg")) == _settings_bytes, "Equipment changed settings.")
	_release()
	_write_json(_directory.path_join("harness-%s.json" % _case), {"passed": _failures.is_empty(), "case": _case, "actions": _action_evidence, "final_hub": _store.load_data(), "failures": _failures})
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"hub_harness_passed", _case)
	get_tree().quit(0 if _failures.is_empty() else 1)


func _check_modules_domain() -> void:
	var hub := HubState.from_save_data(_repair_data(20, 0), CATALOG)
	var source := hub.to_save_data()
	for bad in [[], [HarnessModules.ANALYSIS], HarnessModules.ALL, [HarnessModules.ANALYSIS, HarnessModules.ANALYSIS], [HarnessModules.ANALYSIS, "unknown"], [1, 2], null, {}]:
		var data := source.duplicate(true)
		data.harness_modules = bad
		_expect(HubState.from_save_data(data, CATALOG) == null and ProgressStore.new(_directory.path_join("invalid-write.json")).save_data(data) != OK, "Invalid module data accepted.")
	var candidate := hub.copy()
	var requested: Array = HarnessModules.PAIRS[1].duplicate()
	_expect(candidate.select_harness_modules(requested, source), "Valid equipment rejected.")
	requested.clear()
	_expect(candidate.create_departure_loadout().harness_modules == HarnessModules.PAIRS[1] and hub.to_save_data() == source, "Selection aliased mutable data.")
	_expect(not candidate.select_harness_modules(HarnessModules.PAIRS[1], source), "Duplicate selection accepted.")
	var expected := source.duplicate(true)
	expected.harness_modules = HarnessModules.PAIRS[1]
	_expect(candidate.to_save_data() == expected, "Equipment changed money/wear/research/items/bag/id.")
	var quote := hub.quote_repair(1, ECONOMY)
	_expect(candidate.apply_repair(quote, ECONOMY) == false, "Changed equipment accepted old repair quote.")
	hub.select_bag_slots(2)
	_expect(not hub.select_harness_modules(HarnessModules.PAIRS[1], source), "Stale selection accepted.")
	hub.begin_expedition()
	_expect(not hub.select_harness_modules(HarnessModules.PAIRS[1], {}), "Active run allowed equipment changes.")
	var snapshot := candidate.create_departure_loadout()
	snapshot.harness_modules.clear()
	_expect(candidate.create_departure_loadout().is_valid(), "Departure preview mutated saved equipment.")


func _check_module_migration() -> void:
	var path := _directory.path_join("module-migration.json")
	var store := ProgressStore.new(path)
	for version in [1, 2, 3]:
		var old := _repair_data(20, 1)
		old.erase("harness_modules")
		old.erase("harness_upgrades")
		old.erase("paid_lures")
		old.erase("selected_lures")
		old.erase("pending_departure")
		if version < 3:
			old.erase("harness_durability")
		if version == 1:
			old.erase("registered_items")
		_write_json(path, _envelope(version, old))
		var bytes := FileAccess.get_file_as_bytes(path)
		var upgraded := store.load_data()
		_expect(store.has_legacy_modules() and upgraded.harness_modules == HarnessModules.DEFAULT and FileAccess.get_file_as_bytes(path) == bytes, "Legacy read changed bytes or default.")
		_expect(upgraded.money == "20" and upgraded.stored_items == old.stored_items and upgraded.harness_durability == (1 if version == 3 else 3), "Legacy equipment upgrade lost old fields.")
		_expect(DirAccess.make_dir_absolute(path + ".tmp") == OK, "Cannot block migration.")
		_expect(store.save_data(upgraded) != OK and FileAccess.get_file_as_bytes(path) == bytes, "Failed migration destroyed file.")
		_expect(DirAccess.remove_absolute(path + ".tmp") == OK, "Cannot unblock migration.")
		_expect(store.save_data(upgraded) == OK and store.load_data() == upgraded and not store.has_legacy_modules(), "Migration did not round-trip.")
	for bad in [[], HarnessModules.ALL, [HarnessModules.ANALYSIS, "unknown"], [HarnessModules.ANALYSIS, HarnessModules.ANALYSIS]]:
		var data := _repair_data(20, 1)
		data.harness_modules = bad
		_check_bad_file(store, path, _envelope(4, data))
	var missing := _repair_data(20, 1)
	missing.erase("harness_modules")
	_check_bad_file(store, path, _envelope(4, missing))
	_check_bad_file(store, path, _envelope(99, _repair_data(20, 1)))


func _check_modal_cancel() -> void:
	var bytes := FileAccess.get_file_as_bytes(_path)
	_click(_hub.get_node("%HarnessButton"))
	await _frames(3)
	_hub.departure_requested.emit()
	_hub.bag_slots_selected.emit(2)
	_hub.appraisal_requested.emit()
	_hub.sale_requested.emit()
	_hub.registration_requested.emit()
	_hub.repair_requested.emit()
	_expect(_panel.visible and not _repair.visible and not _hub.get_node("AppraisalPanel").visible and not _hub.get_node("SalePanel").visible and not _hub.get_node("RegistrationPanel").visible and _entry.get_departure_preview().slot_capacity == 3 and GameState.get_current_state() == GameState.State.HUB, "Equipment modal allowed competing service.")
	await _review_pair(1)
	await _capture_wear("review", _panel.get_node("Center/Card"))
	_tap(KEY_ESCAPE)
	await _frames(3)
	_expect(not _panel.get_node("%ConfirmHarness").visible and _panel.visible, "Esc did not leave review.")
	_tap(KEY_ESCAPE)
	await _frames(3)
	_expect(not _panel.visible and FileAccess.get_file_as_bytes(_path) == bytes, "Esc/cancel changed saved equipment.")
	for service in ["appraisal", "sale", "registration", "repair"]:
		_hub.emit_signal(service + "_requested")
		_hub.harness_requested.emit()
		_expect(not _panel.visible, "Other service allowed equipment modal.")
		_entry.call("_on_" + service + "_closed")


func _review_pair(index: int) -> void:
	var choice: OptionButton = _panel.get_node("%HarnessChoice")
	choice.grab_focus()
	_tap(KEY_ENTER)
	await _frames(2)
	for step in range(absi(index - choice.selected)):
		_tap(KEY_DOWN if index > choice.selected else KEY_UP)
	_tap(KEY_ENTER)
	await _frames(3)
	_expect(choice.selected == index, "Keyboard equipment choice failed.")
	_click(_panel.get_node("%ReviewHarness"))
	await _frames(3)
	_expect(_panel.get_node("%ConfirmHarness").visible and "미장착" in _panel.get_node("%HarnessDetails").text, "Review omitted missing action.")


func _choose_pair(index: int, retry := false) -> void:
	var before := _store.load_data()
	var bytes := FileAccess.get_file_as_bytes(_path)
	_click(_hub.get_node("%HarnessButton"))
	await _frames(3)
	await _review_pair(index)
	if retry:
		_expect(DirAccess.make_dir_absolute(_path + ".tmp") == OK, "Cannot block equipment write.")
		for attempt in range(2):
			_panel.confirmation_requested.emit()
			_expect(FileAccess.get_file_as_bytes(_path) == bytes and _entry.get_departure_preview().harness_modules == before.harness_modules, "Failed write changed selection/file.")
		await _capture_wear("save-failure", _panel.get_node("Center/Card"))
		_expect(DirAccess.remove_absolute(_path + ".tmp") == OK, "Cannot unblock equipment write.")
	_panel.get_node("%ConfirmHarness").grab_focus()
	_tap(KEY_ENTER)
	await _frames(4)
	_panel.confirmation_requested.emit()
	before.harness_modules = HarnessModules.PAIRS[index]
	_expect(_store.load_data() == before and _entry.get_departure_preview().harness_modules == before.harness_modules, "Equipment save was partial or changed other state.")
	await _capture_wear("equipped-%d" % index, _panel.get_node("Center/Card"))
	_click(_panel.get_node("%CloseHarness"))
	await _frames(4)
	await _capture_wear("hub-%d" % index, _hub.get_node("Center/Card"))


func _recover_pair(pair: Array) -> void:
	HubRepairTestInput.prepare_departure(_entry)
	var stored_before := _entry.get_hub_stored_items().size()
	var money_before := _entry.get_hub_money()
	_click(_hub.get_node("%DepartureButton"))
	await _frames(5)
	var world: PrototypeExploration = _entry.get_node("PrototypeExploration")
	var player: PlayerController = world.get_node("Player")
	var harness: HarnessController = player.get_node("HarnessController")
	_expect(world.get_start_loadout().harness_modules == pair, "Selected equipment not passed into expedition.")
	_expect(not harness.configure_modules(HarnessModules.ALL), "Active run allowed equipment replacement.")
	var lure: NoiseLureController = world.get_node("%NoiseLureController")
	_expect(lure.get_remaining_uses() == 2, "Equipment changed initial lure uses.")
	var aim := InputEventMouseMotion.new()
	aim.position = world.get_canvas_transform() * (player.position + Vector2(100, -100))
	Input.parse_input_event(aim)
	Input.flush_buffered_events()
	_tap(KEY_F)
	await _frames(40)
	_expect(lure.get_remaining_uses() == 1 and harness.get_current_charge() == 3, "Equipment blocked lure or spent harness charge.")
	var snapshot := world.get_start_loadout()
	snapshot.harness_modules.clear()
	_expect(world.get_start_loadout().harness_modules == pair, "Mutable run snapshot.")
	_hub.harness_requested.emit()
	_panel.review_requested.emit(HarnessModules.PAIRS[0])
	_panel.confirmation_requested.emit()
	_expect(not _panel.visible and _entry.get_departure_preview().harness_modules == pair, "Hidden hub changed active run.")
	for point in [Vector2(-500, -200), Vector2(-275, -200), Vector2(80, -200)]:
		await _walk(player, point)
		if point.x > -300:
			_tap(KEY_E)
			_expect(await InteractionTestInput.wait_for_work(player), "Basic pickup did not finish.")
	await _frames(3)
	_expect(player.get_node("Inventory").get_used_slots() == 2 and harness.get_current_charge() == 3, "Free recovery used a module/charge.")
	for point in [Vector2(-500, -200), Vector2(-650, 0), Vector2(-720, 0)]:
		await _walk(player, point)
	_tap(KEY_E)
	await _frames(5)
	_expect(_entry.get_pending_outcome() != null and _entry.get_pending_outcome().is_safe_return(), "Pair could not return through entrance.")
	_click(_results.get_node("NextStep/SettleButton"))
	await _frames(5)
	_expect(_store.load_data().harness_modules == pair and _entry.get_hub_stored_items().size() == stored_before, "Return lost equipment or changed existing storage.")
	_expect(_entry.get_hub_money() == money_before + 40, "Pair recovery was not settled at the existing prices.")
	_expect(ResearchProgress.get_entries(_entry.get_hub_registered_items(), RESEARCH, CATALOG)[1].unlocked, "Equipment loop lost research.")


func _check_action_pairs() -> void:
	for pair in HarnessModules.PAIRS:
		for target_name in ["RiskHazard", "BrokenGuardGolem", "RetreatDoor", "RemainingZoneEntrance", "MalfunctioningTrap"]:
			var world: PrototypeExploration = WORLD.instantiate()
			add_child(world)
			await _frames(3)
			var loadout := HubState.new().create_departure_loadout()
			loadout.harness_modules.assign(pair)
			_expect(world.prepare_departure(loadout) and world.start_exploration(), "Action matrix preparation failed.")
			var player: PlayerController = world.get_node("Player")
			var harness: HarnessController = player.get_node("HarnessController")
			var golem: BrokenGuardGolem = world.get_node("%BrokenGuardGolem")
			golem.set_physics_process(false)
			world.get_node("%GolemContactThreat").set_active(false)
			var target: Node2D = world.get_node(target_name)
			# Isolated boundary fixtures use real targets at their real positions.
			player.position = target.position + Vector2(-100, 0)
			if target_name == "RemainingZoneEntrance":
				player.position = Vector2(100, -315)
			if target is MalfunctioningTrap:
				target.set_exploration_active(true)
			if target is TemporaryDoor:
				player.position = Vector2(628, -70)
				_expect(target.interact(player), "Free door close failed.")
			await _frames(5)
			var detector: HazardDetector = player.get_node("HazardDetector")
			var expected_target: Node2D = target.get_node("HoldTarget") if target is TemporaryDoor else target
			_expect(detector.get_current_harness_target() == expected_target, "Detector selected wrong matrix target: %s" % target_name)
			_expect(not harness.get_basic_analysis().is_empty() and harness.get_current_charge() == 3, "Free basic information missing/charged.")
			if target_name in ["RiskHazard", "BrokenGuardGolem"]:
				var allowed: bool = HarnessModules.ANALYSIS in pair
				world.get_node("%HarnessStatus/%AnalyzeButton").pressed.emit()
				_expect((not harness.get_precise_analysis().is_empty()) == allowed and harness.get_current_charge() == (2 if allowed else 3), "Analysis ignored equipment/shared charge.")
				if not allowed:
					_expect("미장착" in world.get_node("%HarnessStatus/%AnalyzeButton").text, "Analysis UI omitted missing module.")
			if target is UnstableDebrisHazard:
				target.begin_warning()
			var required := HarnessModules.EMERGENCY if target_name in ["BrokenGuardGolem", "RetreatDoor"] else HarnessModules.STABILIZATION
			var allowed: bool = required in pair
			var before := harness.get_current_charge()
			_tap(KEY_M)
			await _frames(2)
			_expect(not harness.use_current_harness_action() and harness.get_current_charge() == before, "Paused equipment action spent charge.")
			_tap(KEY_M)
			await _frames(2)
			_tap(KEY_Q)
			await _frames(3)
			_expect(harness.get_action_module() == required and harness.get_current_charge() == before - (1 if allowed else 0), "Target module/cost mapping incorrect: %s" % target_name)
			var acted := false
			match target_name:
				"RiskHazard": acted = target.get_state() == UnstableDebrisHazard.State.STABILIZED
				"BrokenGuardGolem": acted = target.get_state() == BrokenGuardGolem.State.DISABLED
				"RetreatDoor": acted = target.is_held()
				"RemainingZoneEntrance": acted = target.is_open()
				"MalfunctioningTrap": acted = target.get_phase() == MalfunctioningTrap.Phase.STABILIZED
			_expect(acted == allowed, "Q did not respect target equipment: %s" % target_name)
			if not allowed:
				_expect("미장착" in world.get_node("%HarnessStatus").get_status_text(), "Missing module prompt absent.")
				if target_name == "RiskHazard":
					await _capture_wear("missing-stabilization", world.get_node("%HarnessStatus"))
			var after := harness.get_current_charge()
			_tap(KEY_Q)
			await _frames(2)
			_expect(harness.get_current_charge() == after, "Repeat action spent charge.")
			_action_evidence.append({"pair": pair.duplicate(), "target": target_name, "required": required, "allowed": allowed, "acted": acted, "charge": after})
			world.queue_free()
			await _frames(3)
