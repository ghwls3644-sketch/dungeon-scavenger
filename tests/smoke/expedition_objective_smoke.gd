extends "res://tests/smoke/expedition_costs_smoke.gd"

var _cases := 0


func _ready() -> void:
	_directory = OS.get_environment("TEMP").path_join("dungeon-objective-%d-%d" % [OS.get_process_id(), Time.get_ticks_usec()])
	DirAccess.make_dir_recursive_absolute(_directory)
	_check_objective_domain()
	_check_objective_examples()
	_check_objective_storage()
	_write(_directory.path_join("objective.json"), {"passed": _failures.is_empty(), "outcome_cases": _cases, "examples": _examples, "failures": _failures})
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"expedition_objective_passed", _directory)
	get_tree().quit(0 if _failures.is_empty() else 1)


func _select(hub: HubState) -> void:
	_expect(hub.select_objective(ExpeditionObjective.RULE.offer(), hub.to_save_data()), "Cannot select objective.")


func _items(count: int) -> Array[InventoryItem]:
	var items: Array[InventoryItem] = []
	for index in count:
		items.append(InventoryItem.from_definition(CATALOG.find_item(&"test_g1_heavy" if index == 0 else &"test_g1_light"), true))
	return items


func _finish_objective(hub: HubState, count: int, used := 0, failure := false, emergency := false, rule: EconomyRule = ECONOMY) -> Dictionary:
	var offer := hub.get_objective_offer()
	var id := hub.reserve_departure()
	_expect(id > 0 and hub.mark_departure_started(id), "Cannot start objective run.")
	_expect(not hub.select_objective({}, hub.to_progress_data()), "Started run changed its offer.")
	var outcome := ExplorationOutcome.failure(count) if failure else ExplorationOutcome.safe_return_inventory_items(_items(count), &"emergency" if emergency else &"entrance")
	outcome.record_lure_usage(hub.create_departure_loadout().lure_count, used)
	if not hub.prepare_settlement(id, outcome, rule):
		_expect(false, "Objective settlement rejected.")
		return {}
	var pending := hub.get_pending_settlement()
	var summary := pending.get_cost_summary()
	var reward := 10 if not offer.is_empty() and count >= 2 and not failure else 0
	_expect(summary.objective_income == reward and pending.get_total_income() == pending.get_sales_income() + reward, "Objective not separate from sales.")
	var before := hub.to_progress_data()
	var candidate := hub.copy()
	_expect(candidate.apply_settlement(id) and not candidate.apply_settlement(id) and hub.to_progress_data() == before, "Settlement candidate not isolated/exactly once.")
	_expect(hub.apply_settlement(id) and hub.get_objective_offer().is_empty() and hub.to_save_data() == candidate.to_save_data(), "Settlement failed to clear selection atomically.")
	_expect(HubState.from_save_data(hub.to_save_data(), CATALOG) != null, "Settled objective cannot restore.")
	return summary


func _check_objective_domain() -> void:
	var hub := _hub()
	var source := hub.to_save_data()
	_select(hub)
	var selected := hub.to_save_data()
	hub.get_objective_offer().reward = "999"
	_expect(hub.to_save_data() == selected and not hub.select_objective({}, source), "Offer mutated or stale selection accepted.")
	_expect(hub.select_objective({}, selected) and hub.get_money() == 100, "Cancel charged money.")
	var excluded: Array[InventoryItem] = [InventoryItem.from_definition(CATALOG.find_item(&"test_g1_heavy"), false)]
	for item in CATALOG.items:
		if item.category != ItemDefinition.CATEGORY_SCRAP:
			excluded.append(InventoryItem.from_definition(item, true))
	var protected := CATALOG.find_item(&"test_g1_light").duplicate() as ItemDefinition
	protected.sale_protected = true
	excluded.append(InventoryItem.from_definition(protected, true))
	_expect(ExpeditionObjective.eligible_count(excluded) == 0 and ExpeditionObjective.eligible_count(_items(3)) == 3, "Eligibility counted unknown/residue/protected item.")
	var repeated: Array[InventoryItem] = [InventoryItem.from_definition(CATALOG.find_item(&"test_g1_light"), true), InventoryItem.from_definition(CATALOG.find_item(&"test_g1_light"), true)]
	_expect(ExpeditionObjective.eligible_count(repeated) == 2, "Same-kind items did not count independently.")
	# Preview re-evaluates eligibility without consuming protected or unidentified recoveries.
	hub = _hub()
	_select(hub)
	var mixed: Array[InventoryItem] = _items(1)
	mixed.append(InventoryItem.from_definition(CATALOG.find_item(&"test_g1_light"), false))
	mixed.append(InventoryItem.from_definition(protected, true))
	var mixed_id := hub.begin_expedition()
	_expect(hub.prepare_settlement(mixed_id, ExplorationOutcome.safe_return_inventory_items(mixed), ECONOMY), "Mixed recovery rejected.")
	_expect(hub.get_pending_settlement().get_retained_items().size() == 2 and hub.get_pending_settlement().get_total_income() == 30 and hub.get_pending_settlement().get_cost_summary().objective.status == "missed", "Objective altered protected/unknown normal settlement.")
	for selected_offer in [false, true]:
		for count in 4:
			for outcome in ["safe", "emergency", "failure"]:
				hub = _hub()
				if selected_offer: _select(hub)
				var result := _finish_objective(hub, count, 0, outcome == "failure", outcome == "emergency")
				var sales := (30 + (count - 1) * 10) if count > 0 and outcome != "failure" else 0
				_expect(result.get("loot_income") == sales and result.get("profit") == sales - RecoveryTax.amount(sales, 10) + (10 if selected_offer and count >= 2 and outcome != "failure" else 0), "Outcome matrix lost normal proceeds or awarded incorrectly.")
				_cases += 1
	# Older hub holdings do not satisfy a new objective.
	var data := _hub().to_save_data()
	data.stored_items = [{"id": "test_g1_light", "identified": true, "risk_hint": ""}]
	hub = HubState.from_save_data(data, CATALOG)
	_select(hub)
	_expect(hub.apply_sale(hub.quote_sale(PackedInt32Array([0]), ECONOMY), ECONOMY), "Cannot sell older stock.")
	var result := _finish_objective(hub, 1)
	_expect(result.objective_income == 0 and result.profit == 36, "Older stock counted for objective.")
	hub = _hub(100, [""])
	_select(hub)
	_buy(hub, 3)
	result = _finish_objective(hub, 2, 3)
	_expect(result.objective_income == 10 and result.unknown_count == 1 and "계산 보류" in CostReportText.headline(result), "Reward invented missing acquisition cost.")
	for started in [false, true]:
		hub = _hub()
		_select(hub)
		var id := hub.reserve_departure()
		if started: hub.mark_departure_started(id)
		var recovered := HubState.from_save_data(hub.to_progress_data(), CATALOG)
		_expect(recovered.recover_departure() and not recovered.recover_departure(), "Recovery not exactly once.")
		_expect(recovered.get_objective_offer().is_empty() == started and recovered.get_money() == 100, "Recovery cleared reserved selection or paid interrupted reward.")
		if started: _expect(recovered.get_last_costs().objective.status == "interrupted", "Interrupted result missing.")
	# Wallet overflow and sale-plus-reward overflow must reject the whole settlement.
	for amount in [ExpeditionCosts.LIMIT, ExpeditionCosts.LIMIT - 45]:
		hub = _hub(amount)
		_select(hub)
		var id := hub.begin_expedition()
		_expect(not hub.prepare_settlement(id, ExplorationOutcome.safe_return_inventory_items(_items(2)), ECONOMY) and hub.get_money() == amount, "Objective overflow changed wallet.")
	# Direct reward attachment also rejects a sales subtotal at the integer limit.
	var settlement := SettlementResult.new()
	settlement._total_income = ExpeditionCosts.LIMIT
	_expect(not settlement.set_objective(ExpeditionObjective.result(ExpeditionObjective.RULE.offer(), 2)), "Income overflow accepted.")
	data = _hub().to_save_data()
	data.money = str(ExpeditionCosts.LIMIT - 60)
	data.costs.period.opening_money = "0"
	data.costs.period.storage_income = str(ExpeditionCosts.LIMIT - 5)
	data.costs.period.tax_legacy_income = str(ExpeditionCosts.LIMIT - 5)
	data.costs.period.repair_paid = "55"
	hub = HubState.from_save_data(data, CATALOG)
	_select(hub)
	var overflow_id := hub.begin_expedition()
	_expect(not hub.prepare_settlement(overflow_id, ExplorationOutcome.safe_return_inventory_items(_items(2)), ECONOMY), "Aggregate period income overflow accepted despite valid final wallet.")


func _check_objective_examples() -> void:
	for index in 6:
		var hub := _hub(100, [], 2 if index == 5 else 3)
		if index != 0: _select(hub)
		if index == 5:
			_expect(hub.apply_repair(hub.quote_repair(1, ECONOMY), ECONOMY), "Example repair failed.")
			_expect(hub.apply_harness_upgrade(hub.quote_harness_upgrade(HarnessUpgradeRule.OBSERVATION, UPGRADES), UPGRADES), "Example upgrade failed.")
		if index in [2, 4, 5]: _buy(hub, 4)
		var result := _finish_objective(hub, 1 if index == 3 else 2, 3 if index in [2, 4, 5] else 0, index == 4)
		var expected: Array = [[36, 36, 36], [46, 46, 46], [41, 36, 46], [27, 27, 27], [-10, -10, 0], [36, -29, 46]][index]
		_expect(result.profit == expected[0] and result.cash_change == expected[1] and result.settlement_credit == expected[2], "Documented objective example mismatch.")
		_examples.append({"profit": result.profit, "cash_change": result.cash_change, "settlement_credit": result.settlement_credit})


func _check_objective_storage() -> void:
	var path := _directory.path_join("progress.json")
	var store := ProgressStore.new(path)
	# Older migrations are exercised by the inherited cost suite; schema 7 must preserve its actual report.
	for journal in ["none", "reserved", "started", "settled"]:
		var hub := _hub()
		if journal == "settled":
			var legacy_rule := ECONOMY.duplicate() as EconomyRule
			legacy_rule.recovery_tax_percent = 0
			_finish_objective(hub, 2, 0, false, false, legacy_rule)
		elif journal != "none":
			var id := hub.reserve_departure()
			if journal == "started": hub.mark_departure_started(id)
		var old := hub.to_progress_data()
		old.erase("objective")
		old.costs.period.erase("tax_sales")
		old.costs.period.erase("tax_legacy_income")
		if not old.costs.last.is_empty():
			old.costs.last.period.erase("tax_sales")
			old.costs.last.period.erase("tax_legacy_income")
			old.costs.last.erase("loot_tax")
		if not old.costs.last.is_empty(): old.costs.last.erase("objective")
		_write(path, _envelope(old, 7))
		var bytes := FileAccess.get_file_as_bytes(path)
		var loaded := store.load_data()
		_expect(not loaded.is_empty() and loaded.objective.is_empty() and bytes == FileAccess.get_file_as_bytes(path), "Schema 7 migration rejected/rewrote old bytes.")
		if journal == "settled": _expect(ExpeditionCosts.report_summary(loaded.costs.last).objective_income == 0 and loaded.money == "140", "Migration awarded retroactive reward.")
		_expect(store.save_data(loaded) == OK and store.load_data() == loaded, "Schema 7 upgrade roundtrip failed.")
	var hub := _hub()
	_select(hub)
	var valid := hub.to_save_data()
	var bad_cases: Array[Dictionary] = []
	for mutation in [{"id": "unsupported"}, {"version": 2}, {"version": true}, {"version": 1.5}, {"required": 3}, {"required": false}, {"reward": "11"}, {"reward": "010"}, {"reward": 10}, {"reward": "9223372036854775808"}, {"extra": 1}]:
		var bad := valid.duplicate(true)
		bad.objective.merge(mutation, true)
		bad_cases.append(bad)
	for value in [null, [], {"id": "prototype_scrap_recovery"}]:
		var bad := valid.duplicate(true)
		bad.objective = value
		bad_cases.append(bad)
	var missing := valid.duplicate(true)
	missing.erase("objective")
	bad_cases.append(missing)
	_finish_objective(hub, 2)
	for mutation in [{"count": -1}, {"count": 4}, {"count": 1.5}, {"count": true}, {"count": 0}, {"offer": {}}, {"extra": 0}]:
		var bad := hub.to_save_data()
		bad.costs.last.objective.merge(mutation, true)
		bad_cases.append(bad)
	for bad in bad_cases:
		_write(path, _envelope(bad))
		var bytes := FileAccess.get_file_as_bytes(path)
		_expect(store.load_data().is_empty() and HubState.from_save_data(bad, CATALOG) == null and store.save_data(valid) != OK and bytes == FileAccess.get_file_as_bytes(path), "Invalid/unsupported objective accepted or overwritten.")
	_expect(store.save_data(hub.to_save_data(), true) == OK, "Cannot save completed objective.")
	var resumed := HubState.from_save_data(store.load_data(), CATALOG)
	_expect(resumed.get_money() == 146 and resumed.get_objective_offer().is_empty() and not resumed.apply_settlement(1), "Reload paid reward twice or reselected.")
	_select(resumed)
	_expect(resumed.reserve_departure() == 2, "Reselection reused old settlement id.")
