extends "res://tests/smoke/hub_harness_smoke.gd"

const UPGRADES := preload("res://src/data/prototype_harness_upgrades.tres")
var _upgrade_panel: HubUpgradePanel
var _growth_evidence: Array[Dictionary] = []


func _ready() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--upgrade-directory="):
			_directory = argument.trim_prefix("--upgrade-directory=")
		if argument.begins_with("--upgrade-case="):
			_case = argument.trim_prefix("--upgrade-case=")
	_render = "--upgrade-render" in OS.get_cmdline_user_args()
	if _directory.is_empty():
		_directory = OS.get_environment("TEMP").path_join("dungeon-upgrade-%d-%d" % [OS.get_process_id(), Time.get_ticks_usec()])
	_expect(DirAccess.make_dir_recursive_absolute(_directory) == OK, "Cannot create upgrade directory.")
	_path = _directory.path_join("progress.json")
	_store = ProgressStore.new(_path)
	var settings := SettingsStore.new(_directory.path_join("settings.cfg"))
	if _case != "continue":
		_check_growth_domain()
		_check_growth_migration()
		if _case == "write":
			await _check_growth_effects()
			await _check_observation_states()
		var data := _repair_data(120 if _case == "purchase" else (60 if _case == "support" else 0), 0 if _case == "support" else 3)
		_expect(_store.save_data(data) == OK and settings.save_settings(GameSettings.new()) == OK, "Cannot seed growth session.")
	var original := FileAccess.get_file_as_bytes(_path)
	_settings_bytes = FileAccess.get_file_as_bytes(_directory.path_join("settings.cfg"))
	_entry = ENTRY.instantiate()
	_entry.configure_progress(_store)
	_entry.configure_settings(settings)
	add_child(_entry)
	await _frames(5)
	_hub = _entry.get_node("Interface/HubPanel")
	_panel = _hub.get_node("HarnessPanel")
	_upgrade_panel = _hub.get_node("UpgradePanel")
	_repair = _hub.get_node("RepairPanel")
	_results = _entry.get_node("Interface/Results")
	_hub.upgrade_requested.emit()
	_upgrade_panel.confirmation_requested.emit()
	_expect(not _upgrade_panel.visible and FileAccess.get_file_as_bytes(_path) == original, "Title allowed upgrades.")
	_click(_entry.get_node("Interface/TitleScreen/%ContinueButton"))
	await _frames(5)
	_expect(GameState.get_current_state() == GameState.State.HUB and FileAccess.get_file_as_bytes(_path) == original, "Continue rewrote growth save.")
	if _case == "continue":
		_expect(_entry.get_departure_preview().harness_upgrades.size() == 2, "New process lost improvements.")
		await _capture_wear("continued", _hub.get_node("Center/Card"))
		await _check_owned_departure()
	elif _case == "support":
		await _purchase_growth(0, true)
		_expect(_entry.get_hub_money() == 0 and _entry.get_hub_harness_durability() == 0, "Purchase repaired equipment or left money.")
		_expect(HubRepairTestInput.prepare_departure(_entry) == 0, "Spent-all purchase blocked minimum support.")
		_click(_hub.get_node("%DepartureButton"))
		await _frames(5)
		_tap(KEY_E)
		await _frames(5)
		_click(_results.get_node("NextStep/SettleButton"))
		await _frames(5)
		_expect(_store.load_data().harness_upgrades == [HarnessUpgradeRule.OBSERVATION], "Support/empty return lost owned improvement.")
	elif _case == "purchase":
		await _purchase_growth(1, true)
		await _purchase_growth(0)
		_expect(_entry.get_hub_money() == 0, "Two purchases charged incorrectly.")
		await _check_owned_departure()
	else:
		await _recover_pair(HarnessModules.DEFAULT)
		await _recover_pair(HarnessModules.DEFAULT)
		_expect(_entry.get_hub_money() == 72, "Actual earnings missing before purchase.")
		await _purchase_growth(0, true)
		await _choose_pair(1)
		await _discover_growth(true)
		await _discover_growth(false)
		_expect(_entry.get_departure_preview().harness_upgrades.size() == 2, "Purchase and free discovery did not join ownership.")
		await _check_owned_departure()
	_expect(FileAccess.get_file_as_bytes(_directory.path_join("settings.cfg")) == _settings_bytes, "Upgrades changed settings.")
	_release()
	_write_json(_directory.path_join("upgrade-%s.json" % _case), {"passed": _failures.is_empty(), "case": _case,
		"effects": _growth_evidence, "final_hub": _store.load_data(), "failures": _failures})
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"hub_upgrade_passed", _case)
	get_tree().quit(0 if _failures.is_empty() else 1)


func _check_growth_domain() -> void:
	for money in [0, 59, 60, 61, 120, 9223372036854775807]:
		for id in HarnessUpgradeRule.ALL:
			var hub := HubState.from_save_data(_repair_data(money, 0), CATALOG)
			var source := hub.to_save_data()
			var quote := hub.quote_harness_upgrade(id, UPGRADES)
			_expect(quote != null and quote.get_cost() == 60 and quote.can_afford() == (money >= 60), "Growth quote/affordability incorrect.")
			var candidate := hub.copy()
			_expect(candidate.apply_harness_upgrade(quote, UPGRADES) == (money >= 60), "Growth payment boundary incorrect.")
			_expect(hub.to_save_data() == source, "Candidate mutated source.")
			if money >= 60:
				_expect(candidate.get_money() == money - 60 and candidate.create_departure_loadout().harness_upgrades == [id], "Payment/ownership incorrect.")
				_expect(not candidate.apply_harness_upgrade(quote, UPGRADES) and candidate.quote_harness_upgrade(id, UPGRADES) == null, "Duplicate purchase accepted.")
				var preview := candidate.create_departure_loadout()
				preview.harness_upgrades.clear()
				_expect(candidate.create_departure_loadout().harness_upgrades == [id] and candidate.get_harness_durability() == 0, "Ownership aliased or repaired.")
			var changed := UPGRADES.duplicate(true) as HarnessUpgradeRule
			changed.golem_bonus += 1.0
			_expect(not hub.apply_harness_upgrade(quote, changed), "Stale effect quote accepted.")
			changed = UPGRADES.duplicate(true) as HarnessUpgradeRule
			changed.observation_cost += 1
			_expect(not hub.apply_harness_upgrade(quote, changed), "Stale price quote accepted.")
			hub.select_bag_slots(2)
			_expect(not hub.apply_harness_upgrade(quote, UPGRADES), "Stale state quote accepted.")
			hub.begin_expedition()
			_expect(hub.quote_harness_upgrade(id, UPGRADES) == null and not hub.apply_harness_upgrade(quote, UPGRADES), "Active run allowed upgrade purchase.")
	for order in [HarnessUpgradeRule.ALL, [HarnessUpgradeRule.EMERGENCY, HarnessUpgradeRule.OBSERVATION]]:
		var hub := HubState.from_save_data(_repair_data(120, 0), CATALOG)
		for id in order:
			_expect(hub.apply_harness_upgrade(hub.quote_harness_upgrade(id, UPGRADES), UPGRADES), "Purchase order failed.")
		_expect(hub.get_money() == 0 and hub.create_departure_loadout().harness_upgrades.size() == 2, "Ownership cap incorrect.")
		_expect(hub.apply_repair(hub.quote_repair(1, ECONOMY, true), ECONOMY) and hub.can_depart(ECONOMY), "Upgrade spend removed minimum support.")
		var run_id := hub.begin_expedition()
		_expect(hub.prepare_settlement(run_id, ExplorationOutcome.failure(2), ECONOMY) and hub.apply_settlement(run_id), "Growth failure settlement failed.")
		_expect(hub.create_departure_loadout().harness_upgrades.size() == 2 and hub.get_registered_items().size() == 2, "Failure lost prior ownership/research.")
	for invalid in [null, {}, "observation_timing", [1], [true], ["unknown"], [HarnessUpgradeRule.OBSERVATION, HarnessUpgradeRule.OBSERVATION], HarnessUpgradeRule.ALL + [HarnessUpgradeRule.OBSERVATION]]:
		var data := _repair_data(120, 3)
		data.harness_upgrades = invalid
		_expect(HubState.from_save_data(data, CATALOG) == null, "Invalid improvement payload accepted.")
	var services := HubState.from_save_data(_repair_data(300, 1), CATALOG)
	_expect(services.apply_harness_upgrade(services.quote_harness_upgrade(HarnessUpgradeRule.OBSERVATION, UPGRADES), UPGRADES), "Cannot seed owned service check.")
	_expect(services.apply_appraisal(services.quote_appraisal(PackedInt32Array([0]), ECONOMY), ECONOMY), "Appraisal with ownership failed.")
	_expect(services.apply_sale(services.quote_sale(PackedInt32Array([0]), ECONOMY), ECONOMY), "Sale with ownership failed.")
	_expect(services.apply_repair(services.quote_repair(2, ECONOMY), ECONOMY), "Repair with ownership failed.")
	_expect(services.select_harness_modules(HarnessModules.PAIRS[2], services.to_save_data()) and services.select_bag_slots(2), "Preparation with ownership failed.")
	_expect(services.copy().create_departure_loadout().harness_upgrades == [HarnessUpgradeRule.OBSERVATION], "Existing service erased ownership.")


func _check_growth_migration() -> void:
	var path := _directory.path_join("migration-growth.json")
	var store := ProgressStore.new(path)
	for version in [1, 2, 3, 4]:
		var data := _repair_data(60, 1)
		data.harness_modules = HarnessModules.PAIRS[1].duplicate()
		data.erase("harness_upgrades")
		data.erase("paid_lures")
		data.erase("selected_lures")
		data.erase("pending_departure")
		data.erase("costs")
		data.erase("objective")
		if version < 4:
			data.erase("harness_modules")
		if version < 3:
			data.erase("harness_durability")
		if version == 1:
			data.erase("registered_items")
		_write_json(path, _envelope(version, data))
		var original := FileAccess.get_file_as_bytes(path)
		var loaded := store.load_data()
		_expect(loaded.size() == 13 and loaded.harness_upgrades.is_empty() and FileAccess.get_file_as_bytes(path) == original, "Legacy growth read changed file or granted upgrades.")
		_expect(loaded.harness_modules == (HarnessModules.PAIRS[1] if version == 4 else HarnessModules.DEFAULT), "Legacy growth migration replaced equipment.")
		_expect(store.save_data(loaded) == OK and store.load_data() == loaded and JSON.parse_string(FileAccess.get_file_as_string(path)).schema_version == ProgressStore.SCHEMA_VERSION, "Growth migration write failed.")
	for invalid in [null, {}, ["unknown"], [HarnessUpgradeRule.EMERGENCY, HarnessUpgradeRule.EMERGENCY]]:
		var bad := _repair_data(60, 3)
		bad.harness_upgrades = invalid
		_check_bad_file(store, path, _envelope(5, bad))
	var missing := _repair_data(60, 3)
	missing.erase("harness_upgrades")
	_check_bad_file(store, path, _envelope(5, missing))


func _purchase_growth(index: int, retry := false) -> void:
	var before := _store.load_data()
	_click(_hub.get_node("%UpgradeButton"))
	await _frames(3)
	_hub.departure_requested.emit()
	_hub.appraisal_requested.emit()
	_hub.sale_requested.emit()
	_hub.registration_requested.emit()
	_hub.repair_requested.emit()
	_hub.harness_requested.emit()
	_expect(_upgrade_panel.visible and not _panel.visible and not _repair.visible and _store.load_data() == before and GameState.get_current_state() == GameState.State.HUB, "Growth service interleaved other operations.")
	_upgrade_panel.get_node("%UpgradeChoice").select(index)
	_upgrade_panel.get_node("%UpgradeChoice").item_selected.emit(index)
	await _capture_wear("purchase-choice-%d" % index, _upgrade_panel.get_node("Center/Card"))
	_click(_upgrade_panel.get_node("%ReviewUpgrade"))
	await _frames(2)
	_tap(KEY_ESCAPE)
	await _frames(2)
	_expect(_store.load_data() == before and _upgrade_panel.visible, "Cancel applied purchase.")
	_upgrade_panel.get_node("%UpgradeChoice").select(index)
	_upgrade_panel.get_node("%UpgradeChoice").item_selected.emit(index)
	_click(_upgrade_panel.get_node("%ReviewUpgrade"))
	await _frames(2)
	if retry:
		var bytes := FileAccess.get_file_as_bytes(_path)
		_expect(DirAccess.make_dir_absolute(_path + ".tmp") == OK, "Cannot block purchase write.")
		for attempt in range(2):
			_click(_upgrade_panel.get_node("%ConfirmUpgrade"))
			await _frames(2)
			_expect(_entry.get_hub_money() == before.money.to_int() and FileAccess.get_file_as_bytes(_path) == bytes and _entry.get_departure_preview().harness_upgrades == before.harness_upgrades, "Failed purchase partially applied.")
		await _capture_wear("purchase-save-failure", _upgrade_panel.get_node("Center/Card"))
		_expect(DirAccess.remove_absolute(_path + ".tmp") == OK, "Cannot unblock purchase.")
	_upgrade_panel.get_node("%ConfirmUpgrade").grab_focus()
	_tap(KEY_ENTER)
	await _frames(4)
	_upgrade_panel.confirmation_requested.emit()
	before.money = str(before.money.to_int() - 60)
	before.costs.period.upgrade_paid = str(before.costs.period.upgrade_paid.to_int() + 60)
	before.harness_upgrades.append(HarnessUpgradeRule.ALL[index])
	_expect(_store.load_data() == before, "Purchase changed unrelated state or charged twice.")
	await _capture_wear("purchase-complete-%d" % index, _upgrade_panel.get_node("Center/Card"))
	_tap(KEY_ESCAPE)
	await _frames(3)
	_expect(not _upgrade_panel.visible, "Esc did not close growth service.")


func _discover_growth(fail: bool) -> void:
	HubRepairTestInput.prepare_departure(_entry)
	var before := _store.load_data()
	_click(_hub.get_node("%DepartureButton"))
	await _frames(5)
	var world: PrototypeExploration = _entry.get_node("PrototypeExploration")
	var player: PlayerController = world.get_node("Player")
	for point in [Vector2(-650, -260), Vector2(100, -260), Vector2(100, -315)]:
		await _walk(player, point)
	_tap(KEY_Q)
	await _frames(3)
	_expect(world.get_node("RemainingZoneEntrance").is_open(), "Discovery path did not open.")
	for point in [Vector2(100, -480), Vector2(20, -500)]:
		await _walk(player, point)
	_tap(KEY_E)
	_expect(await InteractionTestInput.wait_for_work(player), "Discovery inspection failed.")
	_expect(world.get_node("ExplorationRun").get_harness_discoveries() == [HarnessUpgradeRule.EMERGENCY], "Actual E discovery did not record reward.")
	_expect(_entry.get_departure_preview().harness_upgrades == before.harness_upgrades and world.get_start_loadout().harness_upgrades == before.harness_upgrades, "Discovery applied mid-run.")
	await _capture_wear("found-pending", world.get_node("%HarnessStatus"))
	for point in [Vector2(100, -480), Vector2(100, -260), Vector2(-500, -260)]:
		await _walk(player, point)
	if fail:
		for point in [Vector2(-500, 0), Vector2(-500, 200), Vector2(-170, 200)]:
			await _walk(player, point)
		await _frames(100)
		_expect(_entry.get_pending_outcome().is_failure(), "Discovery failure route missing.")
	else:
		for point in [Vector2(-650, -260), Vector2(-650, 0), Vector2(-720, 0)]:
			await _walk(player, point)
		_tap(KEY_E)
		await _frames(5)
		_expect(_entry.get_pending_outcome().get_harness_upgrades() == [HarnessUpgradeRule.EMERGENCY], "Safe return lost found reward.")
	var bytes := FileAccess.get_file_as_bytes(_path)
	_expect(DirAccess.make_dir_absolute(_path + ".tmp") == OK, "Cannot block discovery settlement.")
	_click(_results.get_node("NextStep/SettleButton"))
	await _frames(3)
	_expect(FileAccess.get_file_as_bytes(_path) == bytes and _entry.get_departure_preview().harness_upgrades == before.harness_upgrades, "Failed discovery save applied ownership.")
	await _capture_wear("discovery-failure" if fail else "discovery-return", _results.get_node("NextStep"))
	_expect(DirAccess.remove_absolute(_path + ".tmp") == OK, "Cannot unblock discovery save.")
	_click(_results.get_node("NextStep/SettleButton"))
	await _frames(4)
	_results.settlement_requested.emit()
	_expect(_entry.get_hub_money() == before.money.to_int() and _store.load_data().harness_upgrades.size() == (1 if fail else 2), "Found reward duplicated money/ownership or survived failure.")


func _check_owned_departure() -> void:
	if _entry.get_departure_preview().harness_modules != HarnessModules.PAIRS[2]:
		await _choose_pair(2)
	HubRepairTestInput.prepare_departure(_entry)
	_click(_hub.get_node("%DepartureButton"))
	await _frames(5)
	var world: PrototypeExploration = _entry.get_node("PrototypeExploration")
	_expect(not world.get_node("HarnessUpgradeDiscovery").visible and world.get_start_loadout().harness_upgrades.size() == 2, "Owned upgrade spawned again or was not passed to run.")
	_hub.upgrade_requested.emit()
	_upgrade_panel.review_requested.emit(HarnessUpgradeRule.EMERGENCY)
	_upgrade_panel.confirmation_requested.emit()
	_expect(not _upgrade_panel.visible, "Active expedition opened upgrade service.")
	_tap(KEY_E)
	await _frames(5)
	_click(_results.get_node("NextStep/SettleButton"))
	await _frames(5)
	_expect(_store.load_data().harness_upgrades.size() == 2, "Return replaced purchased/found ownership.")


func _check_growth_effects() -> void:
	for improved in [false, true]:
		for kind in ["golem", "door", "debris"]:
			var world: PrototypeExploration = WORLD.instantiate()
			add_child(world)
			await _frames(3)

			var loadout := HubState.new().create_departure_loadout()
			loadout.harness_modules.assign(HarnessModules.PAIRS[2])
			if improved:
				loadout.harness_upgrades = HarnessUpgradeRule.ALL.duplicate()
			_expect(world.prepare_departure(loadout) and world.start_exploration(), "Growth effect setup failed.")
			var player: PlayerController = world.get_node("Player")
			var harness: HarnessController = player.get_node("HarnessController")
			var golem: BrokenGuardGolem = world.get_node("BrokenGuardGolem")
			golem.set_physics_process(false)
			world.get_node("%GolemContactThreat").set_active(false)
			var target: Node2D = golem if kind == "golem" else world.get_node("RetreatDoor" if kind == "door" else "RiskHazard")
			player.position = target.position + Vector2(-100, 0)
			if kind == "door":
				player.position = Vector2(628, -70)
				_expect(target.interact(player), "Door close failed.")
			await _frames(5)
			var duration := 0.0
			if kind == "door":
				_expect(harness.use_current_harness_action(), "Door growth action failed.")
				duration = target.get_hold_remaining()
				_expect(is_equal_approx(duration, 8.0 if improved else 6.0), "Door duration incorrect.")
			else:
				if kind == "golem":
					_expect(harness.use_current_harness_action(), "Golem growth action failed.")
					duration = golem.get_analysis_remaining()
					_expect(is_equal_approx(duration, 3.0 if improved else 2.0), "Golem duration incorrect.")
				else:
					target.begin_warning()
					duration = target.get_analysis_remaining()
				_expect(harness.analyze_current_target(), "Timed analysis failed.")
				_expect(("남은 시간" in harness.get_precise_analysis()) == improved, "Timer information ignored ownership.")
				var charge := harness.get_current_charge()
				await _frames(7)
				_expect(not harness.analyze_current_target() and harness.get_current_charge() == charge, "Timer ticking caused repurchase.")
				_tap(KEY_M)
				await _frames(2)
				var paused := harness.get_precise_analysis()
				await _frames(8)
				_expect(harness.get_precise_analysis() == paused, "Paused observation changed.")
				_tap(KEY_M)
				await _frames(2)
				await _capture_wear("effect-%s-%s" % [kind, improved], world.get_node("%HarnessStatus"))
			var before := harness.get_current_charge()
			_expect(not harness.use_current_harness_action() and harness.get_current_charge() == before, "Repeat/unequipped action spent charge.")
			await _frames(510 if kind == "door" else 210)
			_expect(not target.is_held() if kind == "door" else (golem.get_state() != BrokenGuardGolem.State.DISABLED if kind == "golem" else target.get_state() == UnstableDebrisHazard.State.TRIGGERED), "Improved effect did not expire.")
			if kind != "door":
				_expect(harness.get_precise_analysis().is_empty(), "Changed state retained paid reading.")
			_growth_evidence.append({"improved": improved, "target": kind, "duration": duration})
			world.queue_free()
			await _frames(3)


func _check_observation_states() -> void:
	for pair in HarnessModules.PAIRS:
		var world: PrototypeExploration = WORLD.instantiate()
		add_child(world)
		await _frames(3)
		var loadout := HubState.new().create_departure_loadout()
		loadout.harness_modules.assign(pair)
		loadout.harness_upgrades = HarnessUpgradeRule.ALL.duplicate()
		_expect(world.prepare_departure(loadout) and world.start_exploration(), "State analysis setup failed.")
		var player: PlayerController = world.get_node("Player")
		var golem: BrokenGuardGolem = world.get_node("BrokenGuardGolem")
		var harness: HarnessController = player.get_node("HarnessController")
		golem.set_physics_process(false)
		world.get_node("%GolemContactThreat").set_active(false)
		player.position = golem.position + Vector2(-100, 0)
		await _frames(3)
		for state in [BrokenGuardGolem.State.SUSPICIOUS, BrokenGuardGolem.State.SEARCH]:
			# Prepare the existing state machine, then inspect through actual player commands.
			golem._set_state(state)
			var timer: Timer = golem.get_node("SuspicionTimer" if state == BrokenGuardGolem.State.SUSPICIOUS else "SearchTimer")
			timer.start(2.0)
			player.get_node("HazardDetector").refresh_current_hazard()
			var before := harness.get_current_charge()
			var allowed: bool = HarnessModules.ANALYSIS in pair
			_expect(harness.analyze_current_target() == allowed and harness.get_current_charge() == before - (1 if allowed else 0), "Owned analysis ignored module gate.")
			_expect(("남은 시간" in harness.get_precise_analysis()) == allowed, "State timer missing or leaked through unequipped module.")
			if allowed:
				var initial := harness.get_precise_analysis()
				await _frames(12)
				_expect(harness.get_precise_analysis() != initial and not harness.can_analyze_current_target(), "Live countdown did not update or reopened purchase.")
				timer.start(3.0)
				_expect(not harness.can_analyze_current_target() and "3.0초" in harness.get_precise_analysis(), "Same-state restart invalidated analysis or kept old time.")
				player.position += Vector2(-300, 0)
				await _frames(3)
				player.position -= Vector2(-300, 0)
				await _frames(3)
				_expect(harness.get_precise_analysis().is_empty(), "Re-entry retained expired analysis.")
				timer.stop()
		var charge := harness.get_current_charge()
		golem._set_state(BrokenGuardGolem.State.PATROL)
		player.get_node("HazardDetector").refresh_current_hazard()
		var emergency: bool = HarnessModules.EMERGENCY in pair
		_expect(harness.use_current_harness_action() == emergency and harness.get_current_charge() == charge - (1 if emergency else 0), "Owned emergency ignored module gate.")
		if emergency:
			_expect(is_equal_approx(golem.get_analysis_remaining(), 3.0), "Equipped purchased emergency lacked bonus.")
		world.queue_free()
		await _frames(3)
