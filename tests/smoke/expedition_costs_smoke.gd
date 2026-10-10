extends Node

const CATALOG := preload("res://src/data/prototype_item_catalog.tres")
const ECONOMY := preload("res://src/data/prototype_economy.tres")
const UPGRADES := preload("res://src/data/prototype_harness_upgrades.tres")
var _failures := PackedStringArray()
var _examples: Array[Dictionary] = []
var _directory := ""


func _ready() -> void:
	_directory = OS.get_environment("TEMP").path_join("dungeon-costs-%d-%d" % [OS.get_process_id(), Time.get_ticks_usec()])
	DirAccess.make_dir_recursive_absolute(_directory)
	_check_examples()
	_check_transactions()
	_check_storage()
	_write(_directory.path_join("costs.json"), {"passed": _failures.is_empty(), "examples": _examples, "failures": _failures})
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"expedition_costs_passed", _directory)
	get_tree().quit(0 if _failures.is_empty() else 1)


func _hub(money: int = 100, stock: Array = [], durability: int = 3) -> HubState:
	var data := HubState.new().to_save_data()
	data.money = str(money)
	data.harness_durability = durability
	data.paid_lures = stock.size()
	data.costs = ExpeditionCosts.new_book(money, stock)
	var result := HubState.from_save_data(data, CATALOG)
	_expect(result != null, "Cannot seed valid cost record.")
	return result


func _buy(hub: HubState, count: int, price: int = 5) -> void:
	var rule := LurePreparation.RULE.duplicate() as LureSupplyRule
	rule.unit_price = price
	_expect(hub.apply_lures(hub.quote_lures(count, rule), rule), "Cannot prepare lures.")


func _end(hub: HubState, used: int, loot: bool = true, failure: bool = false, discovery: bool = false) -> Dictionary:
	var id := hub.reserve_departure()
	_expect(id > 0 and hub.mark_departure_started(id), "Cannot start cost run.")
	var items: Array[InventoryItem] = []
	if loot:
		items.append(InventoryItem.from_definition(CATALOG.find_item(&"test_g1_heavy"), true))
	var found: Array[String] = []
	if discovery:
		found.append(HarnessUpgradeRule.EMERGENCY)
	var outcome := ExplorationOutcome.failure(1) if failure else ExplorationOutcome.safe_return_inventory_items(items, &"entrance", found)
	outcome.record_lure_usage(hub.create_departure_loadout().lure_count, used)
	if not hub.prepare_settlement(id, outcome, ECONOMY):
		_expect(false, "Cost preview rejected.")
		return {}
	var preview := hub.get_pending_settlement().get_cost_summary()
	var money := hub.get_money()
	var candidate := hub.copy()
	_expect(candidate.apply_settlement(id) and not candidate.apply_settlement(id), "Settlement not exactly once.")
	_expect(hub.get_money() == money, "Candidate altered live money.")
	_expect(hub.apply_settlement(id) and hub.get_last_costs() == preview and candidate.to_save_data() == hub.to_save_data(), "Preview/commit mismatch.")
	_expect(HubState.from_save_data(hub.to_save_data(), CATALOG) != null, "Committed costs cannot restore.")
	return preview


func _check(hub: HubState, summary: Dictionary, profit: int, cash: int, stock: Array) -> void:
	_expect(summary.get("profit") == profit and summary.get("cash_change") == cash, "Written example profit/cash mismatch.")
	_expect(summary.get("money_after") == hub.get_money() and hub.to_save_data().costs.stock == stock, "Money/stock final state mismatch.")
	_examples.append({"profit": summary.get("profit"), "cash": summary.get("cash_change"), "stock": stock})


func _check_examples() -> void:
	var hub := _hub()
	_buy(hub, 4)
	_check(hub, _end(hub, 3), 22, 17, ["5"])
	_expect(hub.get_money() == 117, "Purchase was charged again at settlement.")
	_buy(hub, 3)
	_check(hub, _end(hub, 3), 22, 27, [])
	_expect(hub.get_money() == 144, "Two-run cash sum differs.")
	hub = _hub()
	_buy(hub, 4)
	_buy(hub, 2)
	_check(hub, _end(hub, 0, false), 0, -10, ["5", "5"])
	hub = _hub(100, ["5"])
	_buy(hub, 4, 7)
	_check(hub, _end(hub, 3), 22, 20, ["7"])
	hub = _hub()
	_buy(hub, 4)
	var failed := _end(hub, 3, false, true)
	_check(hub, failed, -10, -10, [])
	_expect(failed.get("used_cost") == 5 and failed.get("lost_cost") == 5 and failed.get("lost_count") == 1, "Failure double-counted used supply.")
	hub = _hub(100, ["5"])
	_buy(hub, 3)
	_check(hub, _end(hub, 0, false, true), -5, 0, [])
	hub = _hub(100, [], 2)
	_expect(hub.apply_repair(hub.quote_repair(1, ECONOMY), ECONOMY), "Cannot pay repair.")
	_expect(hub.apply_harness_upgrade(hub.quote_harness_upgrade(HarnessUpgradeRule.OBSERVATION, UPGRADES), UPGRADES), "Cannot pay improvement.")
	_buy(hub, 4)
	_check(hub, _end(hub, 3), 17, -48, ["5"])
	_expect(hub.get_money() == 52, "Investment changed operating profit or was charged twice.")
	var data := _hub().to_save_data()
	data.stored_items = [{"id": "test_g1_known", "identified": false, "risk_hint": ""}]
	hub = HubState.from_save_data(data, CATALOG)
	_expect(hub.apply_appraisal(hub.quote_appraisal(PackedInt32Array([0]), ECONOMY), ECONOMY), "Cannot pay appraisal.")
	_expect(hub.apply_sale(hub.quote_sale(PackedInt32Array([0]), ECONOMY), ECONOMY), "Cannot sell older stock.")
	_check(hub, _end(hub, 0), 94, 94, [])
	hub = _hub()
	_check(hub, _end(hub, 0), 27, 27, [])
	_expect(hub.quote_repair(1, ECONOMY).get_cost() == 5 and hub.get_last_costs().repair_paid == 0, "Unpaid estimate became an expense.")
	hub = _hub(0, [], 0)
	_expect(hub.apply_repair(hub.quote_repair(1, ECONOMY, true), ECONOMY), "Free recovery rejected.")
	_check(hub, _end(hub, 2, false, false, true), 0, 0, [])
	_expect(HarnessUpgradeRule.EMERGENCY in hub.create_departure_loadout().harness_upgrades, "Free discovery lost.")


func _check_transactions() -> void:
	var hub := _hub(100, ["5"])
	var before := hub.to_save_data()
	var rule := LurePreparation.RULE.duplicate() as LureSupplyRule
	var quote := hub.quote_lures(4, rule)
	rule.unit_price = 7
	_expect(not hub.apply_lures(quote, rule) and hub.to_save_data() == before, "Stale price changed accounting.")
	_buy(hub, 4, 7)
	before = hub.to_save_data()
	var id := hub.reserve_departure()
	var resumed := HubState.from_save_data(hub.to_progress_data(), CATALOG)
	_expect(resumed.recover_departure() and resumed.to_save_data().costs == before.costs, "Technical recovery changed price order/period.")
	_expect(not resumed.recover_departure(), "Repeated technical recovery succeeded.")
	_expect(hub.mark_departure_started(id), "Cannot mark interrupted run.")
	resumed = HubState.from_save_data(hub.to_progress_data(), CATALOG)
	_expect(resumed.recover_departure(), "Cannot close interrupted run.")
	var last := resumed.get_last_costs()
	_expect(last.profit == -12 and last.cash_change == -7 and last.paid_used == -1 and last.lost_count == 2, "Interrupted run guessed use/omitted carried costs.")
	_expect(resumed.get_money() == 93 and resumed.get_paid_lures() == 0, "Interruption recharged/refunded purchases.")
	var original := resumed.to_save_data()
	resumed.get_last_costs().profit = 999
	resumed.get_preparation_costs().stock.append("999")
	_expect(resumed.to_save_data() == original, "Public report exposed mutable state.")
	hub = _hub(100, ["", "7"])
	_buy(hub, 4)
	var unknown := _end(hub, 3)
	_expect(unknown.unknown_count == 1 and "계산 보류" in CostReportText.headline(unknown) and hub.to_save_data().costs.stock == ["7"], "Unrecorded cost invented a profit/price.")
	_buy(hub, 3)
	_expect(_end(hub, 3).profit == 20, "Known stock after legacy use retained unknown status.")
	hub = _hub(100, [""])
	_buy(hub, 3)
	_expect(_end(hub, 2).unknown_count == 0 and hub.to_save_data().costs.stock == [""], "Unused unknown stock suppressed known result.")
	hub = _hub(ExpeditionCosts.LIMIT)
	id = hub.begin_expedition()
	_expect(not hub.prepare_settlement(id, ExplorationOutcome.safe_return([CATALOG.find_item(&"test_g1_heavy")]), ECONOMY) and hub.get_money() == ExpeditionCosts.LIMIT, "Money overflow accepted/wrapped.")
	var overflow := _hub().to_save_data()
	overflow.costs.period.storage_income = str(ExpeditionCosts.LIMIT)
	_expect(HubState.from_save_data(overflow, CATALOG) == null, "Counter overflow accepted.")
	hub = _hub(100, [str(ExpeditionCosts.LIMIT)], 2)
	before = hub.to_save_data()
	_expect(not hub.apply_repair(hub.quote_repair(1, ECONOMY), ECONOMY) and hub.to_save_data() == before, "Preparation allowed an unreportable future loss.")


func _check_storage() -> void:
	var path := _directory.path_join("progress.json")
	var store := ProgressStore.new(path)
	for version in range(1, 7):
		var data := _hub(100, ["5", "7"]).to_save_data()
		data.erase("costs")
		data.erase("objective")
		if version <= 5:
			for key in ["paid_lures", "selected_lures", "pending_departure"]:
				data.erase(key)
		if version <= 4:
			data.erase("harness_upgrades")
		if version <= 3:
			data.erase("harness_modules")
		if version <= 2:
			data.erase("harness_durability")
		if version == 1:
			data.erase("registered_items")
		_write(path, _envelope(data, version))
		var bytes := FileAccess.get_file_as_bytes(path)
		var loaded := store.load_data()
		_expect(not loaded.is_empty() and FileAccess.get_file_as_bytes(path) == bytes, "Legacy read rewrote/rejected record.")
		if loaded.is_empty():
			continue
		_expect(loaded.costs.period.partial and loaded.costs.period.opening_money == "100" and loaded.costs.stock == (["", ""] if version == 6 else []), "Legacy baseline/unknown costs incorrect.")
		_expect(store.save_data(loaded) == OK and store.load_data() == loaded, "Legacy atomic upgrade failed.")
	for started in [false, true]:
		var hub := _hub(100, ["5", "7"])
		_buy(hub, 4)
		var id := hub.reserve_departure()
		if started:
			hub.mark_departure_started(id)
		var old := hub.to_progress_data()
		old.erase("costs")
		old.erase("objective")
		_write(path, _envelope(old, 6))
		var loaded := HubState.from_save_data(store.load_data(), CATALOG)
		_expect(loaded.recover_departure(), "Legacy journal could not recover.")
		_expect(loaded.get_last_costs().get("unknown_count", 0) == (2 if started else 0) and loaded.get_paid_lures() == (0 if started else 2), "Legacy recovery invented cost or returned lost tools.")
	var valid := _hub().to_save_data()
	var bad_cases: Array[Dictionary] = []
	for book in [null, {}, {"stock": [], "carried": [], "period": {}, "last": {}}]:
		var bad := valid.duplicate(true)
		bad.costs = book
		bad_cases.append(bad)
	for key in ["opening_money", "storage_income", "appraisal_paid", "repair_paid", "upgrade_paid"]:
		for value in [true, -1, "-1", "01", "9223372036854775808"]:
			var bad := valid.duplicate(true)
			bad.costs.period[key] = value
			bad_cases.append(bad)
	for stock in [[5], ["-1"], ["01"], ["9223372036854775808"], ["5", "7", "9"]]:
		var bad := valid.duplicate(true)
		bad.costs.stock = stock
		bad_cases.append(bad)
	var mismatched := valid.duplicate(true)
	mismatched.costs.period.repair_paid = "5"
	bad_cases.append(mismatched)
	var completed := _hub(100, ["5", "7"])
	_buy(completed, 4)
	_end(completed, 3)
	var report_base := completed.to_save_data()
	for mutation in [{"id": "2"}, {"id": "0"}, {"id": "9223372036854775807"},
		{"outcome": "unknown"}, {"outcome": "failure"}, {"paid_count": 3}, {"paid_used": 2.5},
		{"paid_used": true}, {"paid_used": -1}, {"free_used": 1}, {"loot_income": "31"}]:
		var bad := report_base.duplicate(true)
		bad.costs.last.merge(mutation, true)
		bad_cases.append(bad)
	for key in ["partial", "opening_money", "opening_stock"]:
		var bad := report_base.duplicate(true)
		bad.costs.period[key] = {"partial": true, "opening_money": "129", "opening_stock": ["5"]}[key]
		bad_cases.append(bad)
	var unknown_purchase := valid.duplicate(true)
	unknown_purchase.costs.period.bought_costs = [""]
	unknown_purchase.costs.stock = [""]
	unknown_purchase.paid_lures = 1
	bad_cases.append(unknown_purchase)
	for bad in bad_cases:
		_write(path, _envelope(bad))
		var bytes := FileAccess.get_file_as_bytes(path)
		_expect(store.load_data().is_empty() and HubState.from_save_data(bad, CATALOG) == null and store.save_data(valid) != OK and FileAccess.get_file_as_bytes(path) == bytes, "Malformed ledger accepted/overwritten.")
	var replaced := store.save_data(valid, true)
	_expect(replaced == OK, "Explicit fixture replacement failed: %s (%s)." % [error_string(replaced), path])
	var bytes := FileAccess.get_file_as_bytes(path)
	DirAccess.make_dir_absolute(path + ".tmp")
	var purchased := _hub()
	_buy(purchased, 4)
	_expect(store.save_data(purchased.to_save_data()) != OK and FileAccess.get_file_as_bytes(path) == bytes, "Failed purchase save changed ledger.")
	DirAccess.remove_absolute(path + ".tmp")
	var saved := store.save_data(purchased.to_save_data())
	var reloaded := HubState.from_save_data(store.load_data(), CATALOG)
	_expect(saved == OK and reloaded != null and reloaded.to_save_data() == purchased.to_save_data(), "Purchase retry lost or duplicated bookkeeping: %s." % error_string(saved))


func _envelope(hub: Dictionary, version: int = ProgressStore.SCHEMA_VERSION) -> Dictionary:
	return {"schema_version": version, "content_version": ProgressStore.CONTENT_VERSION, "resume_state": "hub", "hub": hub}


func _write(path: String, value: Dictionary) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(value))
	file.close()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error(message)
