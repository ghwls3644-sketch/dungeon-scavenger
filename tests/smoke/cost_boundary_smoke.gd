extends "res://tests/smoke/expedition_costs_smoke.gd"

const BOUNDARY_STORE := preload("res://tests/fixtures/lure_boundary_store.gd")
const ACTIONS := ["purchase", "appraisal", "sale", "repair", "upgrade", "reserve", "start", "settle", "recover_reserved", "recover_started"]


func _ready() -> void:
	var mode := "retry"
	var action := "purchase"
	var after := false
	_directory = OS.get_environment("TEMP").path_join("dungeon-cost-boundary-%d-%d" % [OS.get_process_id(), Time.get_ticks_usec()])
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--cost-directory="):
			_directory = argument.trim_prefix("--cost-directory=")
		if argument.begins_with("--boundary-mode="):
			mode = argument.trim_prefix("--boundary-mode=")
		if argument.begins_with("--action="):
			action = argument.trim_prefix("--action=")
	after = "--boundary-after" in OS.get_cmdline_user_args()
	DirAccess.make_dir_recursive_absolute(_directory)
	var path := _directory.path_join("progress.json")
	if mode == "verify":
		_verify(path, action, after)
	elif mode == "stop":
		var hub := _seed(path, action)
		var store := BOUNDARY_STORE.new(path)
		store.directory = _directory
		store.stop_call = 1
		store.stop_after = after
		_expect(_act(hub, action), "Boundary transaction failed.")
		store.save_data(hub.to_progress_data())
		_expect(false, "Supervisor did not interrupt boundary.")
	else:
		for current in ACTIONS:
			var case_path := _directory.path_join(current + ".json")
			var hub := _seed(case_path, current)
			var store := BOUNDARY_STORE.new(case_path)
			var before := FileAccess.get_file_as_bytes(case_path)
			var candidate := hub.copy()
			_expect(_act(candidate, current), "Retry transaction failed: " + current)
			store.failures = [1, 2]
			for attempt in 2:
				_expect(store.save_data(candidate.to_progress_data()) != OK and FileAccess.get_file_as_bytes(case_path) == before, "Failed write partially changed costs: " + current)
			_expect(store.save_data(candidate.to_progress_data()) == OK, "Retry failed: " + current)
			_verify(case_path, current, true)
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"cost_boundary_passed", mode + " " + action)
	get_tree().quit(0 if _failures.is_empty() else 1)


func _seed(path: String, action: String) -> HubState:
	var stocked := action in ["reserve", "start", "settle", "recover_reserved", "recover_started"]
	var hub := _hub(100, ["5", "7"] if stocked else [], 2 if action == "repair" else 3)
	if action in ["appraisal", "sale"]:
		var data := hub.to_save_data()
		data.stored_items = [{"id": "test_g1_known", "identified": action == "sale", "risk_hint": ""}]
		hub = HubState.from_save_data(data, CATALOG)
	if stocked:
		_buy(hub, 4)
	if action in ["start", "settle", "recover_reserved", "recover_started"]:
		hub.reserve_departure()
	if action in ["settle", "recover_started"]:
		hub.mark_departure_started(1)
	_expect(ProgressStore.new(path).save_data(hub.to_progress_data()) == OK, "Cannot seed save boundary.")
	return hub


func _act(hub: HubState, action: String) -> bool:
	match action:
		"purchase": return hub.apply_lures(hub.quote_lures(4))
		"appraisal": return hub.apply_appraisal(hub.quote_appraisal(PackedInt32Array([0]), ECONOMY), ECONOMY)
		"sale": return hub.apply_sale(hub.quote_sale(PackedInt32Array([0]), ECONOMY), ECONOMY)
		"repair": return hub.apply_repair(hub.quote_repair(1, ECONOMY), ECONOMY)
		"upgrade": return hub.apply_harness_upgrade(hub.quote_harness_upgrade(HarnessUpgradeRule.OBSERVATION, UPGRADES), UPGRADES)
		"reserve": return hub.reserve_departure() == 1
		"start": return hub.mark_departure_started(1)
		"recover_reserved", "recover_started": return hub.recover_departure()
		"settle":
			var items: Array[InventoryItem] = [InventoryItem.from_definition(CATALOG.find_item(&"test_g1_heavy"), true)]
			var outcome := ExplorationOutcome.safe_return_inventory_items(items)
			outcome.record_lure_usage(4, 3)
			return hub.prepare_settlement(1, outcome, ECONOMY) and hub.apply_settlement(1)
	return false


func _verify(path: String, action: String, after: bool) -> void:
	var bytes := FileAccess.get_file_as_bytes(path)
	var store := ProgressStore.new(path)
	var data := store.load_data()
	var hub := HubState.from_save_data(data, CATALOG)
	_expect(hub != null and bytes == FileAccess.get_file_as_bytes(path), "Restart read invalid/modified saved bytes.")
	if hub == null:
		return
	var money: int = {"purchase": 90, "appraisal": 95, "sale": 172, "repair": 95, "upgrade": 40, "settle": 127}.get(action, 100) if after else 100
	_expect(hub.get_money() == money, "Restart wallet mismatch: " + action)
	var costs: Dictionary = data.costs
	var phase := ""
	if action in ["start", "recover_reserved"]:
		phase = "reserved"
	if action in ["settle", "recover_started"]:
		phase = "started"
	if after:
		if action == "reserve": phase = "reserved"
		if action == "start": phase = "started"
		if action in ["settle", "recover_reserved", "recover_started"]: phase = ""
	_expect(data.pending_departure.get("phase", "") == phase, "Restart journal mismatch: " + action)
	var stock: Array = ["5", "7"] if action in ["reserve", "start", "settle", "recover_reserved", "recover_started"] else []
	if after and action == "purchase": stock = ["5", "5"]
	if after and action == "settle": stock = ["7"]
	if after and action == "recover_started": stock = []
	_expect(costs.stock + costs.carried == stock and costs.carried == (stock if not phase.is_empty() else []), "Restart acquisition costs lost/duplicated: " + action)
	var key: String = {"appraisal": "appraisal_paid", "repair": "repair_paid", "upgrade": "upgrade_paid", "sale": "storage_income"}.get(action, "")
	if not key.is_empty():
		var amount: int = {"appraisal": 5, "repair": 5, "upgrade": 60, "sale": 80}[action]
		_expect(costs.period[key] == str(amount if after else 0), "Restart service counter incorrect: " + action)
	if action == "purchase":
		_expect(costs.period.bought_costs == (["5", "5"] if after else []), "Restart purchase counter incorrect.")
	if after and action in ["settle", "recover_started"]:
		var last := hub.get_last_costs()
		_expect(last.get("profit") == (22 if action == "settle" else -12) and last.get("cash_change") == (27 if action == "settle" else 0), "Restart last report mismatch.")
		_expect(costs.period.opening_money == str(money) and costs.period.opening_stock == stock, "Next period not committed with report.")
		if action == "recover_started":
			_expect(last.get("paid_used") == -1 and last.get("lost_count") == 2, "Interrupted report guessed use count.")
	else:
		_expect(costs.last.is_empty(), "Report committed before settlement/recovery.")
	# A second independent restore must leave the report and original bytes intact.
	_expect(HubState.from_save_data(store.load_data(), CATALOG).to_progress_data() == hub.to_progress_data() and bytes == FileAccess.get_file_as_bytes(path), "Repeated restore changed costs.")
