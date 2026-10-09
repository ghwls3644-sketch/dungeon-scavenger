extends "res://tests/smoke/expedition_objective_smoke.gd"

const BOUNDARY_STORE := preload("res://tests/fixtures/lure_boundary_store.gd")
const ACTIONS := ["select", "cancel", "reserve", "start", "settle", "recover_reserved", "recover_started"]


func _ready() -> void:
	var mode := "retry"
	var action := "select"
	var after := false
	_directory = OS.get_environment("TEMP").path_join("dungeon-objective-boundary-%d-%d" % [OS.get_process_id(), Time.get_ticks_usec()])
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--objective-directory="):
			_directory = argument.trim_prefix("--objective-directory=")
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
		GameLog.info(&"SmokeTest", &"objective_boundary_passed", mode + " " + action)
	get_tree().quit(0 if _failures.is_empty() else 1)


func _seed(path: String, action: String) -> HubState:
	var hub := _hub(100, ["5", "7"])
	_buy(hub, 4)
	if action != "select": _select(hub)
	if action in ["start", "settle", "recover_reserved", "recover_started"]:
		hub.reserve_departure()
	if action in ["settle", "recover_started"]:
		hub.mark_departure_started(1)
	_expect(ProgressStore.new(path).save_data(hub.to_progress_data()) == OK, "Cannot seed objective boundary.")
	return hub


func _act(hub: HubState, action: String) -> bool:
	match action:
		"select": return hub.select_objective(ExpeditionObjective.RULE.offer(), hub.to_save_data())
		"cancel": return hub.select_objective({}, hub.to_save_data())
		"reserve": return hub.reserve_departure() == 1
		"start": return hub.mark_departure_started(1)
		"recover_reserved", "recover_started": return hub.recover_departure()
		"settle":
			var outcome := ExplorationOutcome.safe_return_inventory_items(_items(2))
			outcome.record_lure_usage(4, 3)
			return hub.prepare_settlement(1, outcome, ECONOMY) and hub.apply_settlement(1)
	return false


func _verify(path: String, action: String, after: bool) -> void:
	var bytes := FileAccess.get_file_as_bytes(path)
	var store := ProgressStore.new(path)
	var data := store.load_data()
	var hub := HubState.from_save_data(data, CATALOG)
	_expect(hub != null and bytes == FileAccess.get_file_as_bytes(path), "Restart read invalid/modified saved bytes.")
	if hub == null: return
	var selected := action != "select"
	if after:
		selected = action not in ["cancel", "settle", "recover_started"]
	_expect(hub.get_objective_offer() == (ExpeditionObjective.RULE.offer() if selected else {}), "Restart selection mismatch: " + action)
	var money := 150 if after and action == "settle" else 100
	_expect(hub.get_money() == money, "Restart reward lost/duplicated: " + action)
	var phase := ""
	if action in ["start", "recover_reserved"]: phase = "reserved"
	if action in ["settle", "recover_started"]: phase = "started"
	if after:
		if action == "reserve": phase = "reserved"
		if action == "start": phase = "started"
		if action in ["settle", "recover_reserved", "recover_started"]: phase = ""
	_expect(data.pending_departure.get("phase", "") == phase, "Restart journal mismatch: " + action)
	var stock: Array = ["5", "7"]
	if after and action == "settle": stock = ["7"]
	if after and action == "recover_started": stock = []
	_expect(data.costs.stock + data.costs.carried == stock and data.costs.carried == (stock if not phase.is_empty() else []), "Restart stock lost/duplicated: " + action)
	if after and action in ["settle", "recover_started"]:
		var last := hub.get_last_costs()
		_expect(last.get("profit") == (45 if action == "settle" else -12) and last.get("cash_change") == (50 if action == "settle" else 0), "Restart last report mismatch.")
		_expect(last.objective.status == ("achieved" if action == "settle" else "interrupted") and last.objective_income == (10 if action == "settle" else 0), "Reward status not saved atomically.")
		_expect(data.costs.period.opening_money == str(money) and data.costs.period.opening_stock == stock, "Next period not committed with report.")
		_expect(not hub.apply_settlement(1) and not hub.recover_departure(), "Restart repeated settled transaction.")
	else:
		_expect(data.costs.last.is_empty(), "Report committed before settlement/recovery.")
	_expect(HubState.from_save_data(store.load_data(), CATALOG).to_progress_data() == hub.to_progress_data() and bytes == FileAccess.get_file_as_bytes(path), "Repeated restore changed objective.")
