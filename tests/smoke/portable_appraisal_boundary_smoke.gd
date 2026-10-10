extends "res://tests/smoke/portable_appraisal_smoke.gd"

const BOUNDARY_STORE := preload("res://tests/fixtures/lure_boundary_store.gd")
const ACTIONS := ["purchase", "selection", "reserve", "start", "settle", "failure", "recover_reserved", "recover_started"]


func _ready() -> void:
	var mode := "retry"
	var action := "purchase"
	var after := "--boundary-after" in OS.get_cmdline_user_args()
	_directory = OS.get_environment("TEMP").path_join("dungeon-portable-boundary-%d-%d" % [OS.get_process_id(), Time.get_ticks_usec()])
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--cost-directory="):
			_directory = argument.trim_prefix("--cost-directory=")
		if argument.begins_with("--boundary-mode="):
			mode = argument.trim_prefix("--boundary-mode=")
		if argument.begins_with("--action="):
			action = argument.trim_prefix("--action=")
	DirAccess.make_dir_recursive_absolute(_directory)
	var path := _directory.path_join("progress.json")
	if mode == "verify":
		_verify_portable(path, action, after)
	elif mode == "stop":
		var hub := _seed_portable(path, action)
		var store := BOUNDARY_STORE.new(path)
		store.directory = _directory
		store.stop_call = 1
		store.stop_after = after
		_expect(_act_portable(hub, action), "Boundary transaction failed.")
		store.save_data(hub.to_progress_data())
		_expect(false, "Supervisor did not stop portable boundary.")
	else:
		for current in ACTIONS:
			var case_path := _directory.path_join(current + ".json")
			var hub := _seed_portable(case_path, current)
			var original := hub.to_progress_data()
			var candidate := hub.copy()
			_expect(_act_portable(candidate, current), "Cannot prepare boundary candidate.")
			var store := BOUNDARY_STORE.new(case_path)
			store.failures = [1, 2]
			var bytes := FileAccess.get_file_as_bytes(case_path)
			for attempt in 2:
				_expect(store.save_data(candidate.to_progress_data()) != OK and bytes == FileAccess.get_file_as_bytes(case_path) and hub.to_progress_data() == original, "Save failure changed live/saved state.")
			_expect(store.save_data(candidate.to_progress_data()) == OK, "Portable retry failed.")
			_verify_portable(case_path, current, true)
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"portable_appraisal_boundary_passed", mode + " " + action)
	get_tree().quit(0 if _failures.is_empty() else 1)


func _seed_portable(path: String, action: String) -> HubState:
	var stocked := action != "purchase"
	var hub := _portable_hub(["8", "10"] if stocked else [], 100, ["5", "7"] if stocked else [])
	if stocked:
		_prepare(hub, 2)
		_buy(hub, 4)
	if action in ["start", "settle", "failure", "recover_reserved", "recover_started"]:
		hub.reserve_departure()
	if action in ["settle", "failure", "recover_started"]:
		hub.mark_departure_started(1)
	_expect(ProgressStore.new(path).save_data(hub.to_progress_data(), true) == OK, "Cannot seed portable boundary.")
	return hub


func _act_portable(hub: HubState, action: String) -> bool:
	match action:
		"purchase": return hub.apply_portable_appraisals(hub.quote_portable_appraisals(2))
		"selection": return hub.apply_portable_appraisals(hub.quote_portable_appraisals(0))
		"reserve": return hub.reserve_departure() == 1
		"start": return hub.mark_departure_started(1)
		"recover_reserved", "recover_started": return hub.recover_departure()
		"settle", "failure":
			var items: Array[InventoryItem] = [InventoryItem.from_definition(CATALOG.find_item(&"test_g1_heavy"), true), InventoryItem.from_definition(CATALOG.find_item(&"test_g1_light"), true)]
			var outcome := ExplorationOutcome.failure(2) if action == "failure" else ExplorationOutcome.safe_return_inventory_items(items)
			outcome.record_lure_usage(4, 3)
			outcome.record_appraisal_usage(2, 1)
			return hub.prepare_settlement(1, outcome, ECONOMY) and hub.apply_settlement(1)
	return false


func _verify_portable(path: String, action: String, after: bool) -> void:
	var bytes := FileAccess.get_file_as_bytes(path)
	var store := ProgressStore.new(path)
	var hub := HubState.from_save_data(store.load_data(), CATALOG)
	_expect(hub != null and bytes == FileAccess.get_file_as_bytes(path), "Restart rejected/rewrote portable record.")
	if hub == null:
		return
	var data := hub.to_progress_data()
	var money := (80 if action == "purchase" else 136 if action == "settle" else 100) if after else 100
	_expect(hub.get_money() == money, "Portable boundary wallet mismatch.")
	var phase := ""
	if action in ["start", "recover_reserved"]:
		phase = "reserved"
	if action in ["settle", "failure", "recover_started"]:
		phase = "started"
	if after:
		if action == "reserve": phase = "reserved"
		if action == "start": phase = "started"
		if action in ["settle", "failure", "recover_reserved", "recover_started"]: phase = ""
	_expect(data.pending_departure.get("phase", "") == phase, "Portable journal split from inventory.")
	var appraisals: Array = [] if action == "purchase" else ["8", "10"]
	var lures: Array = [] if action == "purchase" else ["5", "7"]
	if after:
		if action == "purchase": appraisals = ["10", "10"]
		if action == "settle":
			appraisals = ["10"]
			lures = ["7"]
		if action in ["failure", "recover_started"]:
			appraisals = []
			lures = []
	_expect(data.costs.appraisal_carried + data.costs.appraisal_stock == appraisals and data.costs.carried + data.costs.stock == lures, "Portable/lure acquisition order or return wrong.")
	_expect(data.costs.appraisal_carried == (appraisals if not phase.is_empty() else []) and data.paid_appraisals == (0 if not phase.is_empty() else appraisals.size()), "Portable carried/owned counts disagree.")
	_expect(data.selected_appraisals == (0 if action == "selection" and after or action == "purchase" and not after else 2), "Selected portable count not durable.")
	if after and action in ["settle", "failure", "recover_started"]:
		var last := hub.get_last_costs()
		_expect(last.profit == (23 if action == "settle" else -30) and last.cash_change == (36 if action == "settle" else 0), "Portable boundary profit/cash mismatch.")
		_expect(last.appraisal_used == (-1 if action == "recover_started" else 1) and last.appraisal_lost_cost == (18 if action == "recover_started" else 10 if action == "failure" else 0), "Portable boundary guessed usage/double-counted loss.")
		_expect(data.costs.period.appraisal_opening_stock == appraisals and data.costs.period.opening_stock == lures, "Next period did not match returned inventory.")
	else:
		_expect(data.costs.last.is_empty(), "Portable report written too early.")
	_expect(HubState.from_save_data(store.load_data(), CATALOG).to_progress_data() == data and bytes == FileAccess.get_file_as_bytes(path), "Repeated read altered portable record.")
