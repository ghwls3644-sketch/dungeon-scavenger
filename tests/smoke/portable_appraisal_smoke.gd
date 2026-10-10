extends "res://tests/smoke/expedition_costs_smoke.gd"

var _portable_cases := 0
var _storage_cases := 0
var _domain_cases := 0


func _ready() -> void:
	_directory = OS.get_environment("TEMP").path_join("dungeon-portable-%d-%d" % [OS.get_process_id(), Time.get_ticks_usec()])
	DirAccess.make_dir_recursive_absolute(_directory)
	_check_portable_examples()
	_check_portable_quotes()
	_check_portable_storage()
	_check_controller()
	_write(_directory.path_join("portable-appraisal.json"), {"passed": _failures.is_empty(), "examples": _portable_cases, "storage_cases": _storage_cases, "domain_cases": _domain_cases, "failures": _failures})
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"portable_appraisal_passed", _directory)
	get_tree().quit(0 if _failures.is_empty() else 1)


func _portable_hub(stock: Array = [], money: int = 100, lures: Array = []) -> HubState:
	var data := HubState.new().to_save_data()
	data.money = str(money)
	data.paid_appraisals = stock.size()
	data.paid_lures = lures.size()
	data.costs = ExpeditionCosts.new_book(money, lures, false, stock)
	var result := HubState.from_save_data(data, CATALOG)
	_expect(result != null, "Cannot seed portable hub.")
	return result


func _prepare(hub: HubState, count: int, price: int = 10) -> void:
	var rule := AppraisalPreparation.RULE.duplicate() as AppraisalSupplyRule
	rule.unit_price = price
	_expect(hub.apply_portable_appraisals(hub.quote_portable_appraisals(count, rule), rule), "Portable preparation rejected.")


func _portable_end(hub: HubState, used: int, sale: int, reward: bool, mode: String, lure_used: int = 0) -> Dictionary:
	if reward:
		_expect(hub.select_objective(ExpeditionObjective.RULE.offer(), hub.to_save_data()), "Objective selection failed.")
	var id := hub.reserve_departure()
	_expect(id > 0 and hub.mark_departure_started(id), "Portable departure failed.")
	if mode == "interrupted":
		_expect(hub.recover_departure() and not hub.recover_departure(), "Started recovery not exactly once.")
		return hub.get_last_costs()
	var items: Array[InventoryItem] = []
	if sale >= 30:
		items.append(InventoryItem.from_definition(CATALOG.find_item(&"test_g1_heavy"), true))
	if sale == 40:
		items.append(InventoryItem.from_definition(CATALOG.find_item(&"test_g1_light"), true))
	var outcome := ExplorationOutcome.failure(2) if mode == "failure" else ExplorationOutcome.safe_return_inventory_items(items)
	outcome.record_lure_usage(hub.create_departure_loadout().lure_count, lure_used)
	outcome.record_appraisal_usage(hub.create_departure_loadout().appraisal_count, used)
	_expect(hub.prepare_settlement(id, outcome, ECONOMY), "Portable settlement rejected.")
	if hub.get_pending_settlement() == null:
		return {}
	var preview := hub.get_pending_settlement().get_cost_summary()
	_expect(hub.apply_settlement(id) and not hub.apply_settlement(id), "Portable settlement duplicated or failed.")
	_expect(hub.get_last_costs() == preview and HubState.from_save_data(hub.to_save_data(), CATALOG) != null, "Portable report/state mismatch.")
	return preview


func _check_portable_examples() -> void:
	var cases: Array[Dictionary] = [
		{"stock": [], "carry": 2, "used": 1, "sale": 40, "reward": true, "mode": "safe", "expected": [10,0,36,26,126,10,46]},
		{"stock": ["10"], "carry": 1, "used": 1, "sale": 30, "mode": "safe", "expected": [10,0,17,27,127,0,27]},
		{"stock": [], "carry": 2, "used": 1, "mode": "failure", "expected": [10,10,-20,-20,80,0,0]},
		{"stock": ["8","10"], "carry": 2, "used": 1, "mode": "failure", "expected": [8,10,-18,0,100,0,0]},
		{"stock": [], "carry": 1, "used": 0, "mode": "safe", "expected": [0,0,0,-10,90,10,0]},
		{"stock": [], "carry": 2, "used": 0, "mode": "reserved", "expected": [0,0,0,-20,80,20,0]},
		{"stock": ["8","10"], "carry": 1, "used": 1, "sale": 40, "mode": "safe", "expected": [8,0,28,36,136,10,36]},
		{"stock": [], "carry": 1, "used": 1, "sale": 40, "reward": true, "lures": true, "mode": "safe", "expected": [10,0,31,26,126,0,46]},
		{"stock": [], "carry": 0, "used": 0, "mode": "safe", "expected": [0,0,0,0,100,0,0]},
		{"stock": [], "carry": 2, "used": 0, "mode": "interrupted", "expected": [0,20,-20,-20,80,0,0]},
	]
	for row in cases:
		var hub := _portable_hub(row.stock)
		_prepare(hub, row.carry)
		if row.get("lures", false):
			_buy(hub, 4)
		var mode: String = row.mode
		if mode == "reserved":
			var before := hub.to_save_data()
			_expect(hub.reserve_departure() > 0 and hub.recover_departure() and not hub.recover_departure(), "Reserved tools not returned once.")
			_expect(hub.to_save_data().costs == before.costs and hub.get_money() == 80, "Reservation recovery changed period/cash.")
			_prepare(hub, 0)
			mode = "safe"
		var summary := _portable_end(hub, row.used, row.get("sale", 0), row.get("reward", false), mode, 3 if row.get("lures", false) else 0)
		if summary.is_empty():
			continue
		var actual := [summary.appraisal_used_cost, summary.appraisal_lost_cost, summary.profit, summary.cash_change, hub.get_money(), ExpeditionCosts.total(summary.appraisal_stock_after), summary.settlement_credit]
		_expect(actual == row.expected, "P%02d mismatch: %s" % [_portable_cases + 1, actual])
		_expect(summary.profit - summary.cash_change == ExpeditionCosts.total(summary.appraisal_stock_after) + ExpeditionCosts.total(summary.stock_after) - ExpeditionCosts.total(row.stock), "Two-tool inventory/cash identity failed.")
		_portable_cases += 1


func _check_portable_quotes() -> void:
	for stock in range(3):
		for count in range(3):
			for money in [0, 9, 10, 19, 20, 100]:
				var costs: Array = []
				for index in stock:
					costs.append("8")
				var hub := _portable_hub(costs, money)
				var before := hub.to_save_data()
				var quote := hub.quote_portable_appraisals(count)
				var expected_cost := maxi(count - stock, 0) * 10
				_expect(quote != null and quote.get_cost() == expected_cost and quote.can_afford() == (money >= expected_cost), "Quote boundary wrong.")
				var applied := hub.apply_portable_appraisals(quote)
				_expect(applied == (money >= expected_cost), "Quote affordability wrong.")
				if not applied:
					_expect(hub.to_save_data() == before, "Failed quote changed state.")
				else:
					_expect(hub.get_money() == money - expected_cost and hub.get_paid_appraisals() == maxi(count, stock), "Purchase/refund changed wrong amount.")
				_domain_cases += 1
	var hub := _portable_hub()
	for value in [-1, 3, 0.5, true, "1", NAN, INF, null]:
		_expect(hub.quote_portable_appraisals(value) == null, "Invalid count accepted.")
	var stale := hub.quote_portable_appraisals(1)
	_prepare(hub, 2)
	_expect(not hub.apply_portable_appraisals(stale), "Stale preparation changed newer stock.")
	var before := hub.to_save_data()
	var repriced := AppraisalPreparation.RULE.duplicate() as AppraisalSupplyRule
	repriced.unit_price = 11
	_expect(not hub.apply_portable_appraisals(hub.quote_portable_appraisals(0), repriced) and hub.to_save_data() == before, "Changed price accepted.")
	for value in [0, -1, 9223372036854775807]:
		repriced.unit_price = value
		_expect(hub.quote_portable_appraisals(2, repriced) == null, "Invalid/overflow price accepted.")
	var maximum := _portable_hub([], 9223372036854775807)
	_prepare(maximum, 2, 4611686018427387903)
	_expect(maximum.get_money() == 1, "Exact int64 purchase lost precision.")
	_expect(_portable_end(maximum, 1, 0, false, "failure").profit == -9223372036854775806, "Exact int64 loss failed.")


func _raw(hub: Dictionary, version: int = ProgressStore.SCHEMA_VERSION) -> Dictionary:
	return {"schema_version": version, "content_version": ProgressStore.CONTENT_VERSION, "resume_state": "hub", "hub": hub}


func _check_portable_storage() -> void:
	var path := _directory.path_join("migration.json")
	var store := ProgressStore.new(path)
	for version in range(1, 10):
		for phase in (["none"] if version <= 5 else ["none", "reserved", "started", "settled"]):
			var hub := _portable_hub([], 100, ["5","7"] if version >= 6 else [])
			if version >= 6:
				_buy(hub, 4)
			if phase in ["reserved", "started"]:
				var id := hub.reserve_departure()
				if phase == "started":
					hub.mark_departure_started(id)
			elif phase == "settled":
				_portable_end(hub, 0, 0, false, "safe", 3)
			var old := LegacyProgressFixture.before_appraisal(hub.to_progress_data())
			if version <= 8 and old.has("costs"):
				old.costs.period.erase("tax_sales")
				old.costs.period.erase("tax_legacy_income")
				if not old.costs.last.is_empty():
					old.costs.last.period.erase("tax_sales")
					old.costs.last.period.erase("tax_legacy_income")
					old.costs.last.erase("loot_tax")
			if version <= 7:
				old.erase("objective")
				if not old.costs.last.is_empty():
					old.costs.last.erase("objective")
			if version <= 6:
				old.erase("costs")
			if version <= 5:
				for key in ["paid_lures", "selected_lures", "pending_departure"]:
					old.erase(key)
			if version <= 4:
				old.erase("harness_upgrades")
			if version <= 3:
				old.erase("harness_modules")
			if version <= 2:
				old.erase("harness_durability")
			if version == 1:
				old.erase("registered_items")
			_write(path, _raw(old, version))
			var bytes := FileAccess.get_file_as_bytes(path)
			var loaded := store.load_data()
			_expect(not loaded.is_empty() and bytes == FileAccess.get_file_as_bytes(path), "Read rejected/rewrote legacy %d %s." % [version, phase])
			if loaded.is_empty():
				continue
			_expect(loaded.paid_appraisals == 0 and loaded.selected_appraisals == 0 and loaded.costs.appraisal_stock.is_empty() and loaded.money == old.money, "Legacy appraisal granted or charged tools.")
			hub = HubState.from_save_data(loaded, CATALOG)
			if phase in ["reserved", "started"]:
				_expect(hub.recover_departure(), "Legacy journal recovery failed.")
			_expect(store.save_data(hub.to_save_data()) == OK and HubState.from_save_data(store.load_data(), CATALOG).to_save_data() == hub.to_save_data(), "Migration roundtrip failed.")
			_storage_cases += 1
	var base := _portable_hub(["8", "10"]).to_save_data()
	var bad_cases: Array[Dictionary] = []
	for key in ["paid_appraisals", "selected_appraisals"]:
		var missing := base.duplicate(true)
		missing.erase(key)
		bad_cases.append(missing)
		for value in [true, null, -1, 3, 1.5, "1"]:
			var bad := base.duplicate(true)
			bad[key] = value
			bad_cases.append(bad)
	for key in ["appraisal_stock", "appraisal_carried"]:
		var missing := base.duplicate(true)
		missing.costs.erase(key)
		bad_cases.append(missing)
		for value in [null, [""], [8], ["-1"], ["01"], ["9223372036854775808"], ["9223372036854775807", "1"]]:
			var bad := base.duplicate(true)
			bad.costs[key] = value
			bad_cases.append(bad)
	var started := _portable_hub(["8","10"])
	_prepare(started, 1)
	var id := started.reserve_departure()
	started.mark_departure_started(id)
	for value in [null, 0, 2, true]:
		var bad := started.to_progress_data()
		bad.pending_departure.appraisals = value
		bad_cases.append(bad)
	var finished := _portable_hub(["8","10"])
	_prepare(finished, 2)
	_portable_end(finished, 1, 0, false, "safe")
	for key in ["appraisal_count", "appraisal_used"]:
		for value in [null, true, -1, 3, 0.5]:
			var bad := finished.to_save_data()
			bad.costs.last[key] = value
			bad_cases.append(bad)
	for bad in bad_cases:
		_write(path, _raw(bad))
		var bytes := FileAccess.get_file_as_bytes(path)
		_expect(HubState.from_save_data(bad, CATALOG) == null and store.load_data().is_empty() and store.save_data(base) != OK and bytes == FileAccess.get_file_as_bytes(path), "Bad appraisal save accepted/replaced.")
		_storage_cases += 1
	_write(path, _raw(base, 9))
	_expect(store.load_data().is_empty(), "Hybrid schema 9 accepted.")
	_write(path, _raw(base, 11))
	_expect(store.load_data().is_empty() and store.get_last_error() == ERR_UNAVAILABLE, "Future schema accepted.")
	_expect(store.save_data(base, true) == OK, "Cannot seed save-failure check.")
	var bytes := FileAccess.get_file_as_bytes(path)
	var candidate := _portable_hub()
	_prepare(candidate, 2)
	DirAccess.make_dir_absolute(path + ".tmp")
	_expect(store.save_data(candidate.to_save_data()) != OK and bytes == FileAccess.get_file_as_bytes(path), "Failed save altered file.")
	DirAccess.remove_absolute(path + ".tmp")
	_expect(store.save_data(candidate.to_save_data()) == OK and HubState.from_save_data(store.load_data(), CATALOG).to_save_data() == candidate.to_save_data(), "Save retry failed.")


func _check_controller() -> void:
	var inventory := PlayerInventory.new()
	inventory.configure_capacity(3, 2.5, 4.0)
	add_child(inventory)
	var definition := CATALOG.find_item(&"test_g1_light").duplicate(true) as ItemDefinition
	var first := InventoryItem.from_definition(definition, false)
	var second := InventoryItem.from_definition(definition, false)
	inventory.try_add_inventory_item(first)
	inventory.try_add_inventory_item(second)
	var tool := PortableAppraisalController.new()
	add_child(tool)
	_expect(tool.configure(inventory, 2, func(): return true) and not tool.configure(inventory, 2, func(): return true), "Controller reconfigured supply.")
	_expect(tool.request_selected().is_empty(), "Inactive controller allowed use.")
	tool.set_active(true)

	_expect(ExpeditionObjective.eligible_count(inventory.get_inventory_items()) == 0, "Unknown scrap counted for objective.")
	inventory.select_item(0)
	var quote := tool.request_selected()
	inventory.select_item(1)
	_expect(not tool.confirm(quote.token) and tool.get_remaining_uses() == 2 and not first.is_identified(), "Stale selection consumed/identified.")
	quote = tool.request_selected()
	definition.value_max += 1
	_expect(not tool.confirm(quote.token) and tool.get_remaining_uses() == 2, "Changed definition accepted.")
	quote = tool.request_selected()
	tool.cancel_pending()
	_expect(not tool.confirm(quote.token), "Canceled token succeeded.")
	quote = tool.request_selected()
	_expect(tool.confirm(quote.token) and second.is_identified() and not first.is_identified() and tool.get_remaining_uses() == 1, "Same-ID item identity/consumption failed.")
	_expect(ExpeditionObjective.eligible_count(inventory.get_inventory_items()) == 1, "Field identification omitted scrap objective progress.")
	_expect(not tool.confirm(quote.token) and tool.request_selected().is_empty(), "Duplicate/reappraisal consumed tool.")
	var identified := inventory.drop_selected_item()
	_expect(identified == definition and ExpeditionObjective.eligible_count(inventory.get_inventory_items()) == 0, "Drop retained field objective progress.")
	inventory.try_add_inventory_item(second)
	inventory.select_item(0)
	quote = tool.request_selected()
	inventory.drop_selected_item()
	_expect(not tool.confirm(quote.token) and tool.get_remaining_uses() == 1, "Removed item consumed tool.")
	var protected_definition := definition.duplicate(true) as ItemDefinition
	protected_definition.category = ItemDefinition.CATEGORY_UNIQUE_ARTIFACT
	var protected_item := InventoryItem.from_definition(protected_definition, false)
	inventory.try_add_inventory_item(protected_item)
	quote = tool.request_selected()
	_expect(tool.confirm(quote.token) and protected_item.is_identified() and inventory.drop_selected_item() == null, "Appraisal bypassed protected item.")
	_expect(tool.get_remaining_uses() == 0 and tool.request_selected().is_empty(), "Empty stock used.")
	tool.set_active(false)
	tool.set_active(true)
	_expect(tool.get_remaining_uses() == 0, "Activation replenished stock.")
	tool.free()
	inventory.free()
