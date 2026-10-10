extends "res://tests/smoke/cost_flow_smoke.gd"


func _click(button: Button) -> void:
	var viewport := button.get_viewport()
	var point := button.get_global_rect().get_center()
	if viewport != get_viewport() and viewport is Window:
		point += Vector2(viewport.position)
		viewport = get_viewport()
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.position = point
		event.pressed = pressed
		viewport.push_input(event, true)


func _ready() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	_directory = OS.get_environment("TEMP").path_join("dungeon-objective-flow-%d-%d" % [OS.get_process_id(), Time.get_ticks_usec()])
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--objective-directory="):
			_directory = argument.trim_prefix("--objective-directory=")
	_render = "--objective-render" in OS.get_cmdline_user_args()
	DirAccess.make_dir_recursive_absolute(_directory)
	_path = _directory.path_join("progress.json")
	_store = ProgressStore.new(_path)
	_expect(_store.save_data(_lure_data(100, 0, 2)) == OK, "Cannot seed objective app.")
	await _open_cost_app()
	await _choose_objective(true, true)
	await _choose_objective(false)
	await _choose_objective(true)
	await _choose_lures(4)
	var before := FileAccess.get_file_as_bytes(_path)
	_click(_hub.get_node("%LureButton"))
	await _frames(3)
	_hub.objective_selected.emit({}, _store.load_data())
	_expect(FileAccess.get_file_as_bytes(_path) == before, "Modal allowed changing objective.")
	_tap(KEY_ESCAPE)
	await _frames(3)
	_tap(KEY_ESCAPE)
	await _frames(3)
	_hub.objective_selected.emit({}, _store.load_data())
	_expect(FileAccess.get_file_as_bytes(_path) == before, "Pause allowed changing objective.")
	_tap(KEY_ESCAPE)
	await _frames(3)
	# Recreate the actual app from the selected-offer save before departure.
	_entry.queue_free()
	await _frames(3)
	await _open_cost_app()
	_expect(_store.load_data().objective == ExpeditionObjective.RULE.offer() and _entry.get_hub_money() == 90, "App reload lost selected conditions or repurchased supply.")
	await _objective_route(false)
	await _check_tax_reconfirmation()
	_expect(_results.get_node("NextStep/NetIncome").text.ends_with("+41") and "현금 변화 +36" in _results.get_node("NextStep/Totals").text, "Bonus included incorrectly in actual cost report.")
	await _settle_lures(1, true)
	_expect(_entry.get_hub_money() == 136 and _store.load_data().objective.is_empty(), "Settlement retry duplicated reward or reselected.")
	_entry.queue_free()
	await _frames(3)
	await _open_cost_app()
	await _cost_tab("restored-reward", "의뢰 달성 2/2 · 추가 보상 10")
	_expect(_entry.get_hub_money() == 136, "Reload credited reward twice.")
	await _choose_lures(2)
	await _choose_objective(true)
	await _objective_route(true)
	_expect("의뢰 미달성 1/2 · 보상 0" in _results.get_node("NextStep/Items").text, "Dropped item still satisfied objective.")
	await _settle_lures(1)
	_expect(_entry.get_hub_money() == 163, "Missed objective suppressed normal sale.")
	await _choose_objective(true)
	await _depart_return_lures(true, 1)
	_expect(_store.load_data().costs.last.objective.count == 0 and _store.load_data().objective.is_empty() and _entry.get_hub_money() == 163, "Failure paid reward or retained selection.")
	await _cost_tab("failed-objective", "의뢰 미달성 · 탐험 실패 · 보상 0")
	# Free exploration remains available after failure and the usual minimum repair.
	await _depart_return_lures(false, 1)
	_expect(_store.load_data().costs.last.objective.offer.is_empty(), "Free exploration silently accepted an objective.")
	_write_json(_directory.path_join("objective-flow.json"), {"passed": _failures.is_empty(), "actual_runs": 4, "failures": _failures})
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"objective_flow_passed", _directory)
	get_tree().quit(0 if _failures.is_empty() else 1)


func _choose_objective(selected: bool, retry := false) -> void:
	var tabs: TabContainer = _hub.get_node("%CostTabs")
	var bar := tabs.get_tab_bar()
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.position = bar.global_position + bar.get_tab_rect(2).get_center()
		event.pressed = pressed
		get_viewport().push_input(event, true)
	await _frames(3)
	var choice: OptionButton = _hub.get_node("%ObjectiveChoice")
	choice.grab_focus()
	_tap(KEY_ENTER)
	await _frames(2)
	_tap(KEY_DOWN if selected else KEY_UP)
	_tap(KEY_ENTER)
	await _frames(3)
	_expect(tabs.current_tab == 2 and choice.selected == (1 if selected else 0), "Objective tab/keyboard choice failed.")
	if retry:
		var before := FileAccess.get_file_as_bytes(_path)
		DirAccess.make_dir_absolute(_path + ".tmp")
		for attempt in 2:
			_click(_hub.get_node("%ObjectiveConfirm"))
			await _frames(3)
			_expect(FileAccess.get_file_as_bytes(_path) == before and _store.load_data().objective.is_empty(), "Failed objective selection changed save.")
		await _capture_wear("selection-retry", _hub.get_node("Center/Card"))
		DirAccess.remove_absolute(_path + ".tmp")
	_hub.get_node("%ObjectiveConfirm").grab_focus()
	_tap(KEY_ENTER)
	await _frames(3)
	_expect(_store.load_data().objective == (ExpeditionObjective.RULE.offer() if selected else {}), "Objective choice not saved.")
	_expect(_hub.get_node("%ObjectiveConfirm").disabled, "Repeated identical selection remained enabled.")
	await _capture_wear("selected" if selected else "free", _hub.get_node("Center/Card"))
	var description: RichTextLabel = _hub.get_node("%ObjectiveDescription")
	description.grab_focus()
	_tap(KEY_END)
	await _frames(3)
	await _capture_wear("selected-end" if selected else "free-end", _hub.get_node("Center/Card"))
	_tap(KEY_HOME)


func _objective_route(drop_light: bool) -> void:
	_click(_hub.get_node("%DepartureButton"))
	await _frames(5)
	var world: PrototypeExploration = _entry.get_node("PrototypeExploration")
	var player: PlayerController = world.get_node("Player")
	var status: Label = world.get_node("%ObjectiveStatus")
	_expect("0/2" in status.text, "New departure retained old progress.")
	var bytes := FileAccess.get_file_as_bytes(_path)
	_hub.objective_selected.emit({}, _store.load_data())
	_expect(FileAccess.get_file_as_bytes(_path) == bytes, "Exploration changed fixed objective.")
	if not drop_light:
		await _aim_lure(world, player.position + Vector2(120, -80))
		for index in 3:
			_tap(KEY_F)
			await _frames(30)
	for point in [Vector2(-500, -200), Vector2(-275, -200)]:
		await _walk(player, point)
	_tap(KEY_E)
	_expect(await InteractionTestInput.wait_for_work(player), "Light pickup failed.")
	_expect("1/2" in status.text, "Light pickup did not advance objective.")
	await _walk(player, Vector2(80, -200))
	_tap(KEY_E)
	_expect(await InteractionTestInput.wait_for_work(player), "Heavy pickup failed.")
	_expect("2/2" in status.text, "Two pickups did not satisfy objective.")
	if drop_light:
		_tap(KEY_TAB)
		await _frames(3)
		var inventory: InventoryPanel = world.get_node("%InventoryPanel")
		var list: ItemList = inventory.get_node("%ItemList")
		for pressed in [true, false]:
			var event := InputEventMouseButton.new()
			event.button_index = MOUSE_BUTTON_LEFT
			event.position = list.global_position + list.get_item_rect(0).get_center()
			event.pressed = pressed
			get_viewport().push_input(event, true)
		await _frames(3)
		_click(inventory.get_node("%DropButton"))
		await _frames(3)
		_click(inventory.get_node("%DropConfirmation").get_ok_button())
		await _frames(3)
		_expect("1/2" in status.text, "Drop retained completed objective.")
		_tap(KEY_TAB)
		await _frames(3)
	_expect(("1/2" if drop_light else "2/2") in status.text, "Current bag progress incorrect.")
	await _capture_wear("progress-missed" if drop_light else "progress-achieved", status)
	for point in [Vector2(-500, -200), Vector2(-650, 0), Vector2(-720, 0)]:
		await _walk(player, point)
	_tap(KEY_E)
	await _frames(5)
	_expect(_entry.get_pending_outcome() != null, "Objective run did not return.")
	await _cost_result_capture("missed" if drop_light else "achieved")


func _check_tax_reconfirmation() -> void:
	var rule := load("res://src/data/prototype_economy.tres") as EconomyRule
	var before := FileAccess.get_file_as_bytes(_path)
	var money := _entry.get_hub_money()
	for percent in [20, 10]:
		rule.recovery_tax_percent = percent
		_click(_results.get_node("NextStep/SettleButton"))
		await _frames(3)
		_expect(GameState.get_current_state() == GameState.State.RESULTS and _entry.get_hub_money() == money and before == FileAccess.get_file_as_bytes(_path), "Changed tax preview committed without new confirmation.")
		_expect("다시 정산" in _results.get_node("NextStep/Notice").text and "회수세 %d" % (8 if percent == 20 else 4) in _results.get_node("NextStep/Items").text, "Refreshed tax notice omitted changed amount.")
		await _cost_result_capture("tax-reconfirm-%d" % percent)
