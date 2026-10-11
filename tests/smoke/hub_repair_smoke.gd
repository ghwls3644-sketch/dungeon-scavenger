extends "res://tests/smoke/equipment_wear_smoke.gd"

var _repair: HubRepairPanel
var _settings_bytes: PackedByteArray
var _events: Array[Dictionary] = []


func _ready() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--repair-directory="):
			_directory = argument.trim_prefix("--repair-directory=")
		if argument.begins_with("--repair-case="):
			_case = argument.trim_prefix("--repair-case=")
	_render = "--repair-render" in OS.get_cmdline_user_args()
	if _directory.is_empty():
		_directory = OS.get_environment("TEMP").path_join("dungeon-repair-%d-%d" % [OS.get_process_id(), Time.get_ticks_usec()])
	_expect(DirAccess.make_dir_recursive_absolute(_directory) == OK, "Cannot create repair directory.")
	_path = _directory.path_join("progress.json")
	_store = ProgressStore.new(_path)
	var settings := SettingsStore.new(_directory.path_join("settings.cfg"))
	if not _case.begins_with("continue"):
		_check_repair_domain()
		_expect(not _store.has_file() and _store.save_data(_repair_data(4 if _case == "support" else 20, 0)) == OK, "Cannot seed repair fixture.")
		_expect(settings.save_settings(GameSettings.new()) == OK, "Cannot seed settings.")
	_settings_bytes = FileAccess.get_file_as_bytes(_directory.path_join("settings.cfg"))
	var original := FileAccess.get_file_as_bytes(_path)
	_entry = ENTRY.instantiate()
	_entry.configure_progress(_store)
	_entry.configure_settings(settings)
	add_child(_entry)
	await _frames(5)
	_hub = _entry.get_node("Interface/HubPanel")
	_repair = _hub.get_node("RepairPanel")
	_results = _entry.get_node("Interface/Results")
	_hub.repair_requested.emit()
	_repair.confirmation_requested.emit()
	_expect(not _repair.visible and FileAccess.get_file_as_bytes(_path) == original, "Title accepted repair.")
	_click(_entry.get_node("Interface/TitleScreen/%ContinueButton"))
	await _frames(5)
	_expect(GameState.get_current_state() == GameState.State.HUB and FileAccess.get_file_as_bytes(_path) == original, "Continue changed progress.")
	if _case.begins_with("continue"):
		var money := 4 if _case == "continue-support" else 0
		_check_repair_state(money, 1)
		await _repair_expedition(false, money, 1, 0)
		await _support_cycle(money)
	elif _case == "support":
		await _support_cycle(4, true)
		await _repair_expedition(true, 4, 1, 0)
		await _support_cycle(4)
	else:
		await _paid_cycle()
	_expect(FileAccess.get_file_as_bytes(_directory.path_join("settings.cfg")) == _settings_bytes, "Repair changed settings.")
	_release()
	_write_json(_directory.path_join("repair-%s.json" % _case), {
		"passed": _failures.is_empty(), "case": _case, "events": _events,
		"final_hub": _store.load_data(), "failures": _failures,
	})
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"hub_repair_passed", _case)
	get_tree().quit(0 if _failures.is_empty() else 1)


func _repair_data(money: int, durability: int) -> Dictionary:
	var data := _initial_data()
	data.money = str(money)
	data.costs = ExpeditionCosts.new_book(data.money.to_int())
	data.harness_durability = durability
	data.stored_items = [{"id": "test_g1_unknown", "identified": false, "risk_hint": "진동"}]
	return data


func _check_repair_domain() -> void:
	for money in [0, 4, 5, 6, 15, 9223372036854775807]:
		for durability in [0, 1, 2, 3]:
			var data := _repair_data(money, durability)
			var hub := HubState.from_save_data(data, CATALOG)
			_expect(hub.can_depart(ECONOMY) == (durability >= 1), "Departure threshold incorrect.")
			for amount in [-1, 0, 4, 9223372036854775807]:
				_expect(hub.quote_repair(amount, ECONOMY) == null, "Invalid amount accepted.")
			var support := hub.quote_repair(1, ECONOMY, true)
			_expect((support != null) == (durability == 0 and money < 5), "Support eligibility boundary incorrect.")
			for amount in range(1, 4 - durability):
				var quote := hub.quote_repair(amount, ECONOMY)
				_expect(quote != null and quote.get_cost() == amount * 5 and quote.can_afford() == (money >= amount * 5), "Paid quote amount/affordability incorrect.")
				var candidate := hub.copy()
				var expected := data.duplicate(true)
				if money >= amount * 5:
					expected.money = str(money - amount * 5)
					expected.costs.period.repair_paid = str(amount * 5)
					expected.harness_durability = durability + amount
				_expect(candidate.apply_repair(quote, ECONOMY) == (money >= amount * 5) and candidate.to_save_data() == expected, "Paid repair partially applied or changed other fields.")
				_expect(not candidate.apply_repair(quote, ECONOMY), "Duplicate/unaffordable repair accepted.")
				_expect(hub.to_save_data() == data, "Quote/candidate mutated source.")
			if support != null:
				_expect(hub.apply_repair(support, ECONOMY) and hub.get_money() == money and hub.get_harness_durability() == 1, "Support charged money or exceeded minimum.")
				_expect(hub.quote_repair(1, ECONOMY, true) == null and not hub.apply_repair(support, ECONOMY), "Support repeated without another loss.")
	var hub := HubState.from_save_data(_repair_data(20, 0), CATALOG)
	var quote := hub.quote_repair(1, ECONOMY)
	var changed := ECONOMY.duplicate(true) as EconomyRule
	changed.repair_cost_per_durability = 4
	_expect(not hub.apply_repair(quote, changed), "Changed price accepted old quote.")
	changed = ECONOMY.duplicate(true)
	changed.minimum_departure_durability = 2
	_expect(not hub.apply_repair(quote, changed), "Changed minimum accepted old quote.")
	hub.select_bag_slots(2)
	_expect(not hub.apply_repair(quote, ECONOMY), "Changed hub accepted old quote.")
	hub.begin_expedition()
	_expect(hub.quote_repair(1, ECONOMY) == null and not hub.apply_repair(quote, ECONOMY), "Active run allowed repair.")
	for value in [-1, 9223372036854775807]:
		changed = ECONOMY.duplicate(true)
		changed.repair_cost_per_durability = value
		_expect(HubState.from_save_data(_repair_data(20, 0), CATALOG).quote_repair(2, changed) == null, "Invalid/overflow price accepted.")
	for minimum in [0, 4]:
		changed = ECONOMY.duplicate(true)
		changed.minimum_departure_durability = minimum
		var invalid := HubState.from_save_data(_repair_data(20, 0), CATALOG)
		_expect(not invalid.can_depart(changed) and invalid.get_repair_offers(changed).is_empty(), "Invalid minimum accepted.")
	changed = ECONOMY.duplicate(true)
	changed.repair_cost_per_durability = 0
	hub = HubState.from_save_data(_repair_data(0, 0), CATALOG)
	_expect(hub.quote_repair(1, changed, true) == null and hub.apply_repair(hub.quote_repair(3, changed), changed), "Zero-price rule required support or failed repair.")
	changed = ECONOMY.duplicate(true)
	var settlement := SettlementResult.from_outcome(ExplorationOutcome.safe_return([]), changed, WEAR, 1)
	_expect(settlement.get_full_repair_estimate() == 15 and settlement.get_total_cost() == 0, "Repair estimate charged settlement.")
	changed.repair_cost_per_durability = 99
	_expect(settlement.get_full_repair_estimate() == 15, "Repair estimate is not a snapshot.")


func _paid_cycle() -> void:
	_check_repair_state(20, 0)
	await _capture_wear("hub-blocked", _hub.get_node("Center/Card"))
	var before := FileAccess.get_file_as_bytes(_path)
	_click(_hub.get_node("%DepartureButton"))
	await _frames(4)
	_expect(_repair.visible and GameState.get_current_state() == GameState.State.HUB and FileAccess.get_file_as_bytes(_path) == before, "Zero departure did not route to unpaid repair.")
	_hub.appraisal_requested.emit()
	_hub.sale_requested.emit()
	_hub.registration_requested.emit()
	_hub.bag_slots_selected.emit(2)
	_hub.departure_requested.emit()
	_expect(not _hub.get_node("AppraisalPanel").visible and not _hub.get_node("SalePanel").visible and not _hub.get_node("RegistrationPanel").visible and _entry.get_departure_preview().slot_capacity == 3, "Repair modal allowed competing actions.")
	await _review_choice(2)
	_expect("예상 비용 15" in _repair.get_node("%RepairDetails").text and "복구 후 보유금 5" in _repair.get_node("%RepairDetails").text, "Full quote omitted cost/balance.")
	await _capture_wear("full-quote", _repair.get_node("Center/Card"))
	_tap(KEY_ESCAPE)
	await _frames(3)
	_click(_repair.get_node("%CloseRepair"))
	await _frames(3)
	_expect(FileAccess.get_file_as_bytes(_path) == before, "Cancel charged or restored durability.")
	await _open_repair()
	await _review_choice(0)
	await _confirm_repair(15, 1, true)
	await _capture_wear("partial-complete", _repair.get_node("Center/Card"))
	await _close_repair()
	await _repair_expedition(false, 15, 1, 0)
	await _open_repair()
	await _review_choice(2)
	await _confirm_repair(0, 3)
	_expect(_repair.get_node("%ReviewRepair").disabled and "수리할 손상이 없습니다" in _repair.get_node("%RepairDetails").text, "Full equipment offered repair.")
	await _capture_wear("full-complete", _repair.get_node("Center/Card"))
	await _close_repair()
	await _repair_expedition(false, 0, 3, 2)
	await _repair_expedition(true, 0, 2, 0)
	await _support_cycle(0)


func _support_cycle(money: int, retry := false) -> void:
	_check_repair_state(money, 0)
	await _open_repair()
	await _review_choice(3)
	_expect(_repair.get_node("%ConfirmRepair").disabled and "부족" in _repair.get_node("%RepairStatus").text, "Unaffordable full repair enabled confirmation.")
	var before := FileAccess.get_file_as_bytes(_path)
	_repair.confirmation_requested.emit()
	_expect(FileAccess.get_file_as_bytes(_path) == before, "Forced unaffordable confirmation changed save.")
	await _capture_wear("insufficient", _repair.get_node("Center/Card"))
	_tap(KEY_ESCAPE)
	await _frames(3)
	await _review_choice(0)
	_expect("최소 복구 지원" in _repair.get_node("%RepairDetails").text and "예상 비용 0" in _repair.get_node("%RepairDetails").text, "Support quote missing.")
	await _capture_wear("support-quote", _repair.get_node("Center/Card"))
	await _confirm_repair(money, 1, retry)
	await _capture_wear("support-complete", _repair.get_node("Center/Card"))
	await _close_repair()


func _open_repair() -> void:
	_click(_hub.get_node("%RepairButton"))
	await _frames(3)
	_expect(_repair.visible, "Repair did not open.")


func _close_repair() -> void:
	_click(_repair.get_node("%CloseRepair"))
	await _frames(3)
	_expect(not _repair.visible and _hub.get_node("Center").visible, "Repair did not close.")


func _review_choice(index: int) -> void:
	var choice: OptionButton = _repair.get_node("%RepairChoice")
	choice.grab_focus()
	# Keyboard selects an option through the native popup, then confirms its quote.
	_tap(KEY_ENTER)
	await _frames(2)
	for step in range(absi(index - choice.selected)):
		_tap(KEY_DOWN if index > choice.selected else KEY_UP)
	_tap(KEY_ENTER)
	await _frames(3)
	_expect(choice.selected == index, "Keyboard repair choice failed.")
	_click(_repair.get_node("%ReviewRepair"))
	await _frames(3)
	_expect(_repair.get_node("%ConfirmRepair").visible, "Quote did not open.")


func _confirm_repair(money: int, durability: int, retry := false) -> void:
	var before := FileAccess.get_file_as_bytes(_path)
	var old_money := _entry.get_hub_money()
	var old_durability := _entry.get_hub_harness_durability()
	if retry:
		_expect(DirAccess.make_dir_absolute(_path + ".tmp") == OK, "Cannot block repair save.")
		for attempt in range(2):
			_click(_repair.get_node("%ConfirmRepair"))
			await _frames(3)
			_expect(FileAccess.get_file_as_bytes(_path) == before and _entry.get_hub_money() == old_money and _entry.get_hub_harness_durability() == old_durability and "저장 실패" in _repair.get_node("%RepairStatus").text, "Failed repair save changed progress or hid retry.")
		await _capture_wear("save-failure", _repair.get_node("Center/Card"))
		_expect(DirAccess.remove_absolute(_path + ".tmp") == OK, "Cannot unblock repair save.")
	_repair.get_node("%ConfirmRepair").grab_focus()
	_tap(KEY_ENTER)
	await _frames(3)
	_repair.confirmation_requested.emit()
	_check_repair_state(money, durability)
	_expect("이번 지불액 %d" % (old_money - money) in _repair.get_node("%RepairStatus").text, "Completion omitted actual payment.")
	_events.append({"kind": "repair", "before": old_durability, "after": durability, "paid": old_money - money, "balance": money, "save_retry": retry})


func _repair_expedition(failure: bool, money: int, before: int, after: int) -> void:
	_click(_hub.get_node("%DepartureButton"))
	await _frames(5)
	var world: PrototypeExploration = _entry.get_node("PrototypeExploration")
	_expect(world != null and world.get_node("Player/HarnessController").get_current_charge() == 3 and world.get_node("PlayerSurvival").get_health() == 2, "Repair changed next-run charge/health or failed to depart.")
	_hub.repair_requested.emit()
	_expect(not _repair.visible, "Exploration allowed repair.")
	if failure:
		for point in [Vector2(-500, 0), Vector2(-500, 200), Vector2(-170, 200)]:
			await _walk(world.get_node("Player"), point)
		await _frames(100)
	else:
		_tap(KEY_E)
		await _frames(5)
	_expect(GameState.get_current_state() == GameState.State.RESULTS and _entry.get_pending_outcome().is_failure() == failure, "Actual repair-loop outcome missing.")
	var text: String = _results.get_node("NextStep/EquipmentDamage").text
	_expect("%d/3 → %d/3" % [before, after] in text and "완전 수리 예상 %d" % ((3 - after) * 5) in text and "이번 준비·탐험 손익" in _results.get_node("NextStep/ProfitTitle").text, "Result combined estimate with actual cost or lost damage.")
	await _capture_wear("failure-result" if failure else "return-result", _results.get_node("NextStep"))
	_click(_results.get_node("NextStep/SettleButton"))
	await _frames(5)
	_check_repair_state(money, after)
	_events.append({"kind": "failure" if failure else "return", "before": before, "after": after, "balance": money})


func _check_repair_state(money: int, durability: int) -> void:
	var saved := _store.load_data()
	_expect(_entry.get_hub_money() == money and _entry.get_hub_harness_durability() == durability and saved.money == str(money) and saved.harness_durability == durability, "Live/saved repair state mismatch.")
	var expected := _repair_data(money, durability)
	for key in ["bag_slots", "stored_items", "registered_items"]:
		_expect(saved[key] == expected[key], "Repair changed retained progress: %s" % key)
	_expect(saved.size() == 15 and ResearchProgress.get_entries(_entry.get_hub_registered_items(), RESEARCH, CATALOG)[1].unlocked, "Repair changed schema/research progress.")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		GameLog.error(&"SmokeTest", &"hub_repair_failed", message)
