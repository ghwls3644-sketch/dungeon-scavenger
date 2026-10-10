extends "res://tests/smoke/lure_preparation_smoke.gd"


func _ready() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	_directory = OS.get_environment("TEMP").path_join("dungeon-cost-flow-%d-%d" % [OS.get_process_id(), Time.get_ticks_usec()])
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--cost-directory="):
			_directory = argument.trim_prefix("--cost-directory=")
	_render = "--cost-render" in OS.get_cmdline_user_args()
	DirAccess.make_dir_recursive_absolute(_directory)
	_path = _directory.path_join("progress.json")
	_store = ProgressStore.new(_path)
	_expect(_store.save_data(_lure_data(100, 0, 2)) == OK, "Cannot seed cost app.")
	await _open_cost_app()
	await _choose_lures(4)
	_expect(_store.load_data().costs.period.bought_costs == ["5", "5"], "Purchase omitted acquisition costs.")
	await _cost_tab("preparation", "현금 변화 -10")
	# Recreate the app using the saved preparation before any departure.
	_entry.queue_free()
	await _frames(3)
	await _open_cost_app()
	_expect(_entry.get_hub_money() == 90 and _store.load_data().costs.period.bought_costs == ["5", "5"], "Preparation restart lost or recharged purchase.")
	await _cost_run(22, 17)
	await _settle_lures(1, true)
	_expect(_entry.get_hub_money() == 117 and _store.load_data().costs.last.period.bought_costs == ["5", "5"], "Settlement used profit as wallet credit.")
	await _cost_tab("saved-first", "현금 변화 +17")
	_entry.queue_free()
	await _frames(3)
	await _open_cost_app()
	await _cost_tab("restored-first", "현금 변화 +17")
	await _choose_lures(3)
	await _cost_run(22, 27)
	await _settle_lures(0)
	_expect(_entry.get_hub_money() == 144, "Old stock use changed cash twice.")
	await _cost_tab("saved-second", "현금 변화 +27")
	# Explicitly prepared display boundaries, separate from the actual two-run route above.
	await _cost_display_boundary("negative", 100, ["5"], true)
	await _cost_display_boundary("unknown", 100, [""], true)
	await _cost_display_boundary("long-money", 9223372036854775807, [], false)
	await _cost_display_boundary("long-negative", 100, ["9223372036854775807"], true)
	_write_json(_directory.path_join("cost-flow.json"), {"passed": _failures.is_empty(), "actual_runs": 2, "final_money": _entry.get_hub_money(), "failures": _failures})
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"cost_flow_passed", _directory)
	get_tree().quit(0 if _failures.is_empty() else 1)


func _open_cost_app() -> void:
	# Recreated app fixture also needs the process-global boot state reset.
	GameState._current_state = GameState.State.BOOT
	var settings := SettingsStore.new(_directory.path_join("settings.cfg"))
	_expect(settings.save_settings(GameSettings.new()) == OK, "Cannot save cost settings.")
	_entry = ENTRY.instantiate()
	_entry.configure_progress(_store)
	_entry.configure_settings(settings)
	add_child(_entry)
	await _frames(5)
	_hub = _entry.get_node("Interface/HubPanel")
	_lures = _hub.get_node("LurePanel")
	_results = _entry.get_node("Interface/Results")
	_click(_entry.get_node("Interface/TitleScreen/%ContinueButton"))
	await _frames(5)


func _cost_tab(label: String, expected: String) -> void:
	var tabs: TabContainer = _hub.get_node("%CostTabs")
	var bar := tabs.get_tab_bar()
	var point := bar.global_position + bar.get_tab_rect(1).get_center()
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.position = point
		event.pressed = pressed
		get_viewport().push_input(event, true)
	await _frames(3)
	var details: RichTextLabel = _hub.get_node("%CostDetails")
	_expect(tabs.current_tab == 1 and expected in details.text, "Cost tab did not show actual cash interval.")
	await _capture_wear(label, _hub.get_node("Center/Card"))
	details.grab_focus()
	_tap(KEY_END)
	await _frames(3)
	await _capture_wear(label + "-end", _hub.get_node("Center/Card"))
	_tap(KEY_HOME)


func _cost_run(profit: int, cash: int) -> void:
	_click(_hub.get_node("%DepartureButton"))
	await _frames(5)
	var world: PrototypeExploration = _entry.get_node("PrototypeExploration")
	var player: PlayerController = world.get_node("Player")
	await _aim_lure(world, player.position + Vector2(120, -80))
	for index in 3:
		_tap(KEY_F)
		await _frames(30)
	for point in [Vector2(-500, -200), Vector2(-275, -200), Vector2(80, -200)]:
		await _walk(player, point)
	_tap(KEY_E)
	_expect(await InteractionTestInput.wait_for_work(player), "Heavy pickup failed.")
	for point in [Vector2(-500, -200), Vector2(-650, 0), Vector2(-720, 0)]:
		await _walk(player, point)
	_tap(KEY_E)
	await _frames(5)
	_expect(_entry.get_pending_outcome() != null, "Cost run did not reach result.")
	_expect(_results.get_node("NextStep/NetIncome").text == "이번 준비·탐험 손익\n%+d" % profit, "Actual result profit incorrect.")
	_expect("현금 변화 %+d" % cash in _results.get_node("NextStep/Totals").text, "Actual result cash incorrect.")
	await _cost_result_capture("actual-%d" % cash)


func _cost_display_boundary(label: String, money: int, stock: Array, failure: bool) -> void:
	var data := _lure_data(money, stock.size(), 2 + stock.size())
	data.costs = ExpeditionCosts.new_book(money, stock)
	if label == "long-money":
		data.costs.period.opening_money = "0"
		data.costs.period.storage_income = str(money)
		data.costs.period.tax_legacy_income = str(money)
	var hub := HubState.from_save_data(data, CATALOG)
	var id := hub.reserve_departure()
	_expect(hub.mark_departure_started(id), "Display boundary cannot start.")
	var outcome := ExplorationOutcome.failure(0) if failure else ExplorationOutcome.safe_return_inventory_items([])
	outcome.record_lure_usage(2 + stock.size(), 0)
	_expect(hub.prepare_settlement(id, outcome, ECONOMY), "Display boundary cannot prepare.")
	_hub.hide()
	_results.show()
	_results.present_result(outcome, hub.get_pending_settlement())
	if label == "negative":
		_expect("-5" in _results.get_node("NextStep/NetIncome").text, "Negative profit hidden.")
	if label == "unknown":
		_expect("손익 계산 보류" in _results.get_node("NextStep/NetIncome").text, "Unknown cost invented a numeric profit.")
	await _cost_result_capture(label)
	if label == "long-money":
		_results.set_status("저장하지 못했습니다. 정산 내역을 유지했습니다. 다시 시도하거나 종료할 수 있습니다.")
		await _cost_result_capture("long-money-retry")


func _cost_result_capture(label: String) -> void:
	await _capture_wear(label, _results.get_node("NextStep"))
	var items: RichTextLabel = _results.get_node("NextStep/Items")
	items.grab_focus()
	_tap(KEY_END)
	await _frames(3)
	await _capture_wear(label + "-end", _results.get_node("NextStep"))
	_tap(KEY_HOME)
