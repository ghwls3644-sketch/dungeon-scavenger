extends "res://tests/smoke/expedition_objective_smoke.gd"

var _tax_cases: Array[Dictionary] = []
var _boundary_cases: Array[Dictionary] = []


func _ready() -> void:
	_directory = OS.get_environment("TEMP").path_join("dungeon-tax-%d-%d" % [OS.get_process_id(), Time.get_ticks_usec()])
	DirAccess.make_dir_recursive_absolute(_directory)
	_check_tax_math()
	_check_tax_examples()
	_check_tax_transactions()
	_check_tax_legacy()
	_check_tax_corruption()
	_write(_directory.path_join("recovery-tax.json"), {"passed": _failures.is_empty(), "examples": _tax_cases, "integer_boundaries": _boundary_cases, "failures": _failures})
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"recovery_tax_passed", _directory)
	get_tree().quit(0 if _failures.is_empty() else 1)


func _check_tax_math() -> void:
	for gross in [0, 1, 7, 14, 40, 80, 9223372036854775807]:
		for rate in [0, 1, 10, 100]:
			var expected := 0
			if gross == 9223372036854775807:
				expected = {0: 0, 1: 92233720368547758, 10: 922337203685477580, 100: 9223372036854775807}[rate]
			else:
				@warning_ignore("integer_division")
				expected = gross * rate / 100
			var receipt := RecoveryTax.receipt(gross, rate)
			_expect(RecoveryTax.amount(gross, rate) == expected and RecoveryTax.valid_receipt(receipt), "Integer tax boundary failed: %d/%d." % [gross, rate])
			_boundary_cases.append({"gross": str(gross), "rate": rate, "paid": receipt.paid})
	for invalid in [-1, 101, 1.5, true, "10", null, INF, NAN]:
		_expect(not RecoveryTax.valid_rate(invalid), "Invalid tax rate accepted.")
	_expect(RecoveryTax.receipt(-1, 10).is_empty(), "Negative gross accepted.")
	var missing := EconomyRule.new()
	_expect(not missing.is_valid(), "Missing rate silently became 0%.")
	var explicit_zero := ECONOMY.duplicate(true) as EconomyRule
	explicit_zero.recovery_tax_percent = 0
	_expect(explicit_zero.is_valid(), "Explicit zero rate rejected.")
	_expect(not RecoveryTax.valid_receipt({"gross": "9223372036854775808", "rate": 10, "paid": "0"}), "Oversize integer wrapped.")
	_expect(not RecoveryTax.valid_receipt({"gross": "01", "rate": 10, "paid": "0"}), "Noncanonical amount accepted.")


func _tax_case(id: String, result: Dictionary, expected: Array) -> void:
	var actual := [result.recovery_tax, result.profit, result.cash_change, result.money_after, result.settlement_credit]
	_expect(actual == expected, "Tax example mismatch: " + id)
	_tax_cases.append({"id": id, "actual": actual, "expected": expected})


func _stored_hub(count: int = 1, identified: bool = true) -> HubState:
	var data := _hub().to_save_data()
	for index in count:
		data.stored_items.append({"id": "test_g1_known", "identified": identified, "risk_hint": ""})
	return HubState.from_save_data(data, CATALOG)


func _check_tax_examples() -> void:
	var hub := _hub()
	_select(hub)
	_buy(hub, 4)
	_tax_case("T01", _finish_objective(hub, 2, 3), [4, 41, 36, 136, 46])
	hub = _hub()
	_buy(hub, 4)
	_tax_case("T02", _finish_objective(hub, 2, 3), [4, 31, 26, 126, 36])
	hub = _hub()
	_buy(hub, 4)
	_tax_case("T03", _end(hub, 3, false, true), [0, -10, -10, 90, 0])
	hub = _hub(100, ["5"])
	_buy(hub, 3)
	_tax_case("T04", _end(hub, 0, false, true), [0, -5, 0, 100, 0])
	hub = _stored_hub(1, false)
	_expect(hub.apply_appraisal(hub.quote_appraisal(PackedInt32Array([0]), ECONOMY), ECONOMY), "Tax example appraisal failed.")
	_expect(hub.apply_sale(hub.quote_sale(PackedInt32Array([0]), ECONOMY), ECONOMY), "Tax example storage sale failed.")
	_tax_case("T05", _end(hub, 0), [11, 94, 94, 194, 27])
	hub = _stored_hub()
	_expect(hub.apply_sale(hub.quote_sale(PackedInt32Array([0]), ECONOMY), ECONOMY), "Failure example storage sale failed.")
	_tax_case("T06", _end(hub, 0, false, true), [8, 72, 72, 172, 0])
	hub = _hub(100, [], 2)
	_select(hub)
	_expect(hub.apply_repair(hub.quote_repair(1, ECONOMY), ECONOMY), "Tax example repair failed.")
	_expect(hub.apply_harness_upgrade(hub.quote_harness_upgrade(HarnessUpgradeRule.OBSERVATION, UPGRADES), UPGRADES), "Tax example upgrade failed.")
	_buy(hub, 4)
	_tax_case("T07", _finish_objective(hub, 2, 3), [4, 36, -29, 71, 46])
	hub = _hub()
	_tax_case("T08", _end(hub, 2, false), [0, 0, 0, 100, 0])
	var legacy := _stored_hub().to_save_data()
	legacy.money = "180"
	legacy.costs.period.storage_income = "80"
	_remove_tax_shape(legacy)
	var path := _directory.path_join("mixed-period.json")
	_write(path, _envelope(legacy, 8))
	var store := ProgressStore.new(path)
	var bytes := FileAccess.get_file_as_bytes(path)
	hub = HubState.from_save_data(store.load_data(), CATALOG)
	_expect(hub != null and bytes == FileAccess.get_file_as_bytes(path), "Mixed period migration failed or rewrote input.")
	if hub == null:
		return
	var rule := ECONOMY.duplicate(true) as EconomyRule
	rule.base_prices[&"test_g1_known"] = 20
	_expect(hub.apply_sale(hub.quote_sale(PackedInt32Array([0]), rule), rule), "Mixed period new sale failed.")
	_tax_case("T09", _end(hub, 0, false), [2, 98, 98, 198, 0])
	_expect(hub.get_last_costs().untaxed_income == 80 and "도입 전 판매 80" in CostReportText.details(hub.get_last_costs()), "Mixed period lost pretax attribution.")
	_expect(store.save_data(hub.to_save_data()) == OK and HubState.from_save_data(store.load_data(), CATALOG).to_save_data() == hub.to_save_data(), "Mixed period roundtrip changed old/new taxes.")


func _check_tax_transactions() -> void:
	var rule := ECONOMY.duplicate(true) as EconomyRule
	rule.base_prices[&"test_g1_known"] = 7
	var together := _stored_hub(2)
	var quote := together.quote_sale(PackedInt32Array([0, 1]), rule)
	_expect(quote.get_income() == 14 and quote.get_tax() == 1 and quote.get_net_income() == 13, "Batch rounding is not once per transaction.")
	_expect(together.apply_sale(quote, rule) and together.get_money() == 113, "Batch net credit failed.")
	var split := _stored_hub(2)
	for index in 2:
		_expect(split.apply_sale(split.quote_sale(PackedInt32Array([0]), rule), rule), "Split sale failed.")
	_expect(split.get_money() == 114 and split.get_preparation_costs().recovery_tax == 0 and split.to_save_data().costs.period.tax_sales.size() == 2, "Split sales were retaxed as a period aggregate.")
	var hub := _stored_hub()
	quote = hub.quote_sale(PackedInt32Array([0]), rule)
	var before := hub.to_save_data()
	quote.get_tax_receipt().paid = "999"
	rule.recovery_tax_percent = 11
	_expect(not hub.apply_sale(quote, rule) and hub.to_save_data() == before, "Same rounded amount hid changed tax policy.")
	rule.recovery_tax_percent = 10
	_expect(hub.apply_sale(quote, rule) and not hub.apply_sale(quote, rule), "Tax quote replayed or getter mutated it.")
	hub = _hub()
	var id := hub.begin_expedition()
	var outcome := ExplorationOutcome.safe_return_inventory_items(_items(2))
	_expect(hub.prepare_settlement(id, outcome, rule), "Tax preview failed.")
	rule.recovery_tax_percent = 20
	_expect(not hub.apply_settlement(id) and hub.get_money() == 100, "Stale settlement tax charged without re-confirmation.")
	_expect(hub.prepare_settlement(id, outcome, rule, true) and hub.get_pending_settlement().get_total_cost() == 8, "Changed tax preview cannot refresh.")
	_expect(hub.apply_settlement(id) and hub.get_money() == 132, "Refreshed settlement did not charge once.")
	rule.recovery_tax_percent = 100
	hub = _stored_hub()
	_expect(hub.apply_sale(hub.quote_sale(PackedInt32Array([0]), rule), rule) and hub.get_money() == 100, "100% boundary created debt or blocked zero net sale.")
	var no_price := ECONOMY.duplicate(true) as EconomyRule
	no_price.base_prices.clear()
	hub = _hub()
	id = hub.begin_expedition()
	_expect(hub.prepare_settlement(id, ExplorationOutcome.safe_return_inventory_items(_items(2)), no_price), "Unpriced recovery failed.")
	_expect(hub.get_pending_settlement().get_total_cost() == 0 and hub.get_pending_settlement().get_retained_items().size() == 2, "Unpriced retained goods taxed.")
	no_price.base_prices[&"test_g1_heavy"] = 30
	_expect(not hub.apply_settlement(id), "Newly priced retained goods bypassed review.")
	hub = _hub()
	_select(hub)
	var emergency := _finish_objective(hub, 2, 0, false, true)
	_expect(emergency.recovery_tax == 4 and emergency.objective_income == 10 and emergency.settlement_credit == 46, "Emergency return taxed reward or lost sales.")


func _remove_tax_shape(data: Dictionary) -> void:
	data.costs.period.erase("tax_sales")
	data.costs.period.erase("tax_legacy_income")
	if not data.costs.last.is_empty():
		data.costs.last.period.erase("tax_sales")
		data.costs.last.period.erase("tax_legacy_income")
		data.costs.last.erase("loot_tax")


func _check_tax_legacy() -> void:
	# Earlier versions, including reserved/started inventory, are also covered here.
	_check_storage()
	var rule := ECONOMY.duplicate(true) as EconomyRule
	rule.recovery_tax_percent = 0
	for version in [7, 8]:
		for phase in ["none", "reserved", "started", "settled"]:
			var hub := _hub()
			if version == 8:
				_select(hub)
			if phase == "settled":
				_finish_objective(hub, 2, 0, false, false, rule)
			elif phase != "none":
				var id := hub.reserve_departure()
				if phase == "started":
					hub.mark_departure_started(id)
			var old := hub.to_progress_data()
			_remove_tax_shape(old)
			if version == 7:
				old.erase("objective")
				if not old.costs.last.is_empty():
					old.costs.last.erase("objective")
			var path := _directory.path_join("legacy-%d-%s.json" % [version, phase])
			_write(path, _envelope(old, version))
			var store := ProgressStore.new(path)
			var bytes := FileAccess.get_file_as_bytes(path)
			var loaded := store.load_data()
			_expect(not loaded.is_empty() and loaded.money == old.money and bytes == FileAccess.get_file_as_bytes(path), "Legacy tax read failed/charged/rewrote file.")
			if loaded.is_empty():
				continue
			hub = HubState.from_save_data(loaded, CATALOG)
			if phase == "settled":
				_expect(hub.get_last_costs().recovery_tax == 0 and hub.get_last_costs().tax_legacy and hub.get_money() == (150 if version == 8 else 140), "Historical report taxed retroactively.")
			if phase in ["reserved", "started"]:
				_expect(hub.recover_departure() and hub.get_money() == 100 and not hub.recover_departure(), "Legacy recovery charged or repeated tax.")
			_expect(store.save_data(hub.to_save_data()) == OK, "Tax migration cannot save.")
			_expect(HubState.from_save_data(store.load_data(), CATALOG).to_save_data() == hub.to_save_data() and JSON.parse_string(FileAccess.get_file_as_string(path)).schema_version == ProgressStore.SCHEMA_VERSION, "Tax migration not lossless current schema.")


func _check_tax_corruption() -> void:
	var hub := _stored_hub()
	_expect(hub.apply_sale(hub.quote_sale(PackedInt32Array([0]), ECONOMY), ECONOMY), "Cannot seed tax validation.")
	var valid := hub.to_save_data()
	var cases: Array[Dictionary] = []
	for value in [null, {}, [null], [{"gross": "80", "rate": 10, "paid": "0"}], [{"gross": "80", "rate": "10", "paid": "8"}], [{"gross": "80", "rate": true, "paid": "8"}], [{"gross": "80", "rate": -1, "paid": "0"}], [{"gross": "80", "rate": 10, "paid": "8", "extra": 0}]]:
		var bad := valid.duplicate(true)
		bad.costs.period.tax_sales = value
		cases.append(bad)
	for key in ["tax_sales", "tax_legacy_income"]:
		var bad := valid.duplicate(true)
		bad.costs.period.erase(key)
		cases.append(bad)
	var settled := _hub()
	_finish_objective(settled, 2)
	for mutation in [{"gross": "41"}, {"paid": "0"}, {"rate": null}, {"extra": 1}]:
		var bad := settled.to_save_data()
		bad.costs.last.loot_tax.merge(mutation, true)
		cases.append(bad)
	var missing := settled.to_save_data()
	missing.costs.last.erase("loot_tax")
	cases.append(missing)
	var path := _directory.path_join("bad.json")
	var store := ProgressStore.new(path)
	for bad in cases:
		_write(path, _envelope(bad))
		var bytes := FileAccess.get_file_as_bytes(path)
		_expect(HubState.from_save_data(bad, CATALOG) == null and store.load_data().is_empty() and store.save_data(valid) != OK and bytes == FileAccess.get_file_as_bytes(path), "Bad tax state accepted or repaired silently.")
	_write(path, _envelope(valid, 8))
	_expect(store.load_data().is_empty(), "Hybrid schema 8 with tax keys accepted as legacy.")
	_write(path, _envelope(valid, ProgressStore.SCHEMA_VERSION + 1))
	_expect(store.load_data().is_empty() and store.get_last_error() == ERR_UNAVAILABLE, "Unknown tax schema accepted.")
