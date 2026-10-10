extends "res://tests/smoke/cost_flow_smoke.gd"

var _portable_panel: HubPortableAppraisalPanel
var _flow_continue := false


func _ready() -> void:
	_directory = OS.get_environment("TEMP").path_join("dungeon-portable-flow-%d-%d" % [OS.get_process_id(), Time.get_ticks_usec()])
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--portable-directory="):
			_directory = argument.trim_prefix("--portable-directory=")
	_flow_continue = "--portable-continue" in OS.get_cmdline_user_args()
	_render = "--portable-render" in OS.get_cmdline_user_args()
	get_tree().root.size = Vector2i(1152, 648)
	DirAccess.make_dir_recursive_absolute(_directory)
	_path = _directory.path_join("progress.json")
	_store = ProgressStore.new(_path)
	if not _flow_continue:
		var data := _lure_data(100, 0, 2)
		data.bag_slots = 3
		_expect(_store.save_data(data) == OK, "Cannot seed portable flow.")
	await _open_cost_app()
	_portable_panel = _hub.get_node("PortablePanel")
	if _flow_continue:
		_check_portable_final()
		await _cost_tab("portable-continued", "감정 도구 1개 사용")
	else:
		await _choose_portable(2, true)
		var purchased := _store.load_data()
		_expect(purchased.money == "80" and purchased.paid_appraisals == 2, "Purchase not saved.")
		_entry.queue_free()
		await _frames(3)
		await _open_cost_app()
		_portable_panel = _hub.get_node("PortablePanel")
		_expect(_entry.get_hub_money() == 80 and _entry.get_departure_preview().appraisal_count == 2, "Purchase restart lost/charged stock.")
		var tabs: TabContainer = _hub.get_node("%CostTabs")
		var bar := tabs.get_tab_bar()
		for pressed in [true, false]:
			var event := InputEventMouseButton.new()
			event.button_index = MOUSE_BUTTON_LEFT
			event.position = bar.global_position + bar.get_tab_rect(2).get_center()
			event.pressed = pressed
			get_viewport().push_input(event, true)
		await _frames(3)
		_hub.get_node("%ObjectiveChoice").grab_focus()
		_tap(KEY_ENTER)
		await _frames(2)
		_tap(KEY_DOWN)
		_tap(KEY_ENTER)
		await _frames(3)
		_click(_hub.get_node("%ObjectiveConfirm"))
		await _frames(3)
		_expect(not _store.load_data().objective.is_empty(), "Actual objective selection failed.")
		await _actual_portable_run()
		_check_portable_final()
		await _cost_tab("portable-saved", "감정 도구 1개 사용")
		# Desired 2 but only 1 owned: departure must open a fresh quote without charging.
		var bytes := FileAccess.get_file_as_bytes(_path)
		_click(_hub.get_node("%DepartureButton"))
		await _frames(3)
		_expect(_portable_panel.visible and _entry.get_hub_money() == 306 and FileAccess.get_file_as_bytes(_path) == bytes, "Departure silently replenished stock.")
		await _capture_wear("portable-shortage", _portable_panel.get_node("Center/Card"))
		_click(_portable_panel.get_node("%ClosePortable"))
		await _frames(2)
	await _portable_display_boundaries()
	var report := {"passed": _failures.is_empty(), "case": "continue" if _flow_continue else "actual_route", "saved": _store.load_data(), "failures": _failures}
	_write_json(_directory.path_join("portable-continue.json" if _flow_continue else "portable-flow.json"), report)
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"portable_appraisal_flow_passed", report.case + " " + _directory)
	get_tree().quit(0 if _failures.is_empty() else 1)


func _choose_portable(count: int, retry: bool = false) -> void:
	_click(_hub.get_node("%PortableButton"))
	await _frames(3)
	var bytes := FileAccess.get_file_as_bytes(_path)
	_hub.lures_requested.emit()
	_hub.departure_requested.emit()
	_hub.appraisal_requested.emit()
	_hub.bag_slots_selected.emit(2)
	_expect(_portable_panel.visible and not _lures.visible and _entry.get_departure_preview().slot_capacity == 3 and bytes == FileAccess.get_file_as_bytes(_path), "Portable preparation allowed conflicting commands.")
	var choice: OptionButton = _portable_panel.get_node("%PortableChoice")
	choice.grab_focus()
	_tap(KEY_ENTER)
	await _frames(2)
	for step in range(absi(count - choice.selected)):
		_tap(KEY_DOWN if count > choice.selected else KEY_UP)
	_tap(KEY_ENTER)
	await _frames(3)
	_click(_portable_panel.get_node("%ReviewPortable"))
	await _frames(3)
	_expect(choice.selected == count and "이번 지불액 20" in _portable_panel.get_node("%PortableStatus").text, "Keyboard purchase quote wrong.")
	await _capture_wear("portable-quote", _portable_panel.get_node("Center/Card"))
	if retry:
		DirAccess.make_dir_absolute(_path + ".tmp")
		_click(_portable_panel.get_node("%ConfirmPortable"))
		await _frames(3)
		_expect(bytes == FileAccess.get_file_as_bytes(_path) and _entry.get_hub_money() == 100 and _entry.get_departure_preview().appraisal_count == 0, "Failed purchase changed memory/file.")
		await _capture_wear("portable-purchase-retry", _portable_panel.get_node("Center/Card"))
		DirAccess.remove_absolute(_path + ".tmp")
	_portable_panel.get_node("%ConfirmPortable").grab_focus()
	_tap(KEY_ENTER)
	await _frames(3)
	_portable_panel.confirmation_requested.emit()
	_expect(_entry.get_hub_money() == 80 and _entry.get_departure_preview().appraisal_count == 2, "Purchase duplicated/failed.")
	_click(_portable_panel.get_node("%ClosePortable"))
	await _frames(3)


func _actual_portable_run() -> void:
	_click(_hub.get_node("%DepartureButton"))
	await _frames(5)
	var world: PrototypeExploration = _entry.get_node("PrototypeExploration")
	var player: PlayerController = world.get_node("Player")
	var inventory: PlayerInventory = player.get_node("Inventory")
	var panel: InventoryPanel = world.get_node("%InventoryPanel")
	var tool: PortableAppraisalController = world.get_node("PortableAppraisalController")
	var lure: NoiseLureController = world.get_node("%NoiseLureController")
	_expect(inventory.get_total_weight() == 1.0 and tool.get_remaining_uses() == 2, "Mixed start weight/stock wrong.")
	await _aim_lure(world, player.position + Vector2(120, -80))
	_tap(KEY_F)
	await _frames(40)
	_expect(lure.get_remaining_uses() == 1 and inventory.get_total_weight() == 0.75, "Lure use overwrote appraisal weight.")
	for target in [Vector2(-500, -200), Vector2(-275, -200), Vector2(80, -200), Vector2(630, -200), Vector2(630, 220)]:
		await _walk(player, target)
		if target in [Vector2(-275, -200), Vector2(80, -200), Vector2(630, 220)]:
			_tap(KEY_E)
			_expect(await InteractionTestInput.wait_for_work(player), "Actual route pickup/inspection failed.")
	_tap(KEY_E)
	_expect(await InteractionTestInput.wait_for_work(player), "Actual unknown recovery failed.")
	var items := inventory.get_inventory_items()
	_expect(items.size() == 3 and not items[2].is_identified(), "Actual route missing unknown item.")
	var weight := inventory.get_total_weight()
	var charge: int = player.get_node("HarnessController").get_current_charge()
	_tap(KEY_TAB)
	await _frames(3)
	_expect(panel.visible and get_tree().paused and not "200" in panel.get_displayed_item_text(2), "Unknown info leaked or menu did not pause.")
	await _capture_wear("portable-before", panel)
	_click(panel.get_node("%PortableAppraisalButton"))
	await _frames(2)
	var confirmation: ConfirmationDialog = panel.get_node("%PortableConfirmation")
	_expect(confirmation.visible and "1개" in confirmation.dialog_text, "Appraisal confirmation missing.")
	confirmation.canceled.emit()
	await _frames(2)
	_expect(not confirmation.visible and tool.get_remaining_uses() == 2 and not items[2].is_identified(), "Cancel consumed tool.")
	_click(panel.get_node("%PortableAppraisalButton"))
	await _frames(2)
	panel.notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
	_expect(not confirmation.visible and tool.get_remaining_uses() == 2, "Focus loss retained confirmation.")
	_click(panel.get_node("%PortableAppraisalButton"))
	await _frames(2)
	confirmation.get_ok_button().grab_focus()
	_tap(KEY_ENTER)
	await _frames(3)
	confirmation.confirmed.emit()
	_expect(items[2].is_identified() and tool.get_remaining_uses() == 1 and inventory.get_total_weight() == weight - 0.25, "Field appraisal did not consume exactly once/update mass.")
	_expect("200~280" in panel.get_displayed_item_text(2) and "잔재" in panel.get_displayed_item_text(2), "Field appraisal did not reveal correct type/range.")
	_expect(player.get_node("HarnessController").get_current_charge() == charge and get_tree().paused and "2/2" in world.get_node("%ObjectiveStatus").text, "Appraisal changed charge/time or counted residue for quest.")
	await _capture_wear("portable-after", panel)
	_tap(KEY_TAB)
	await _frames(2)
	_tap(KEY_TAB)
	await _frames(2)
	_expect(tool.get_remaining_uses() == 1 and panel.get_node("%PortableAppraisalButton").disabled, "Reopen replenished or allowed reappraisal.")
	_tap(KEY_TAB)
	await _frames(2)
	for frame in range(240):
		if world.get_node("%GolemContactThreat").is_warning():
			break
		await _frames(1)
	_tap(KEY_Q)
	await _frames(3)
	for point in [Vector2(630, -200), Vector2(-500, -200), Vector2(-650, 0), Vector2(-720, 0)]:
		await _walk(player, point)
	_tap(KEY_E)
	await _frames(5)
	var outcome := _entry.get_pending_outcome()
	_expect(outcome != null and outcome.is_safe_return() and outcome.get_appraisal_usage() == {"capacity": 2, "used": 1}, "Actual return lost appraisal result.")
	await _capture_wear("portable-results", _results.get_node("NextStep"))
	var bytes := FileAccess.get_file_as_bytes(_path)
	DirAccess.make_dir_absolute(_path + ".tmp")
	_click(_results.get_node("NextStep/SettleButton"))
	await _frames(3)
	_expect(_entry.get_hub_money() == 80 and bytes == FileAccess.get_file_as_bytes(_path), "Failed settlement returned stock/credited income.")
	await _capture_wear("portable-settlement-retry", _results.get_node("NextStep"))
	DirAccess.remove_absolute(_path + ".tmp")
	_click(_results.get_node("NextStep/SettleButton"))
	await _frames(5)
	_results.settlement_requested.emit()


func _check_portable_final() -> void:
	var saved := _store.load_data()
	_expect(_entry.get_hub_money() == 306 and saved.paid_appraisals == 1 and saved.selected_appraisals == 2 and saved.costs.appraisal_stock == ["10"], "Actual return money/stock wrong.")
	var restored := HubState.from_save_data(saved, CATALOG)
	var summary := restored.get_last_costs()
	_expect(summary.profit == 216 and summary.cash_change == 206 and summary.appraisal_used == 1 and summary.appraisal_returned_count == 1 and summary.recovery_tax == 24 and summary.objective_income == 10, "Actual costs/tax/reward wrong.")
	_expect(restored.get_stored_items().is_empty() and restored.get_registered_items().is_empty() and saved.pending_departure.is_empty(), "Field appraisal bypassed sale/registration/journal.")


func _portable_display_boundaries() -> void:
	var bytes := FileAccess.get_file_as_bytes(_path)
	for amount in [0, 9223372036854775807]:
		var state := _lure_data(amount, 0, 2)
		state.selected_appraisals = 2
		var hub := HubState.from_save_data(state, CATALOG)
		_portable_panel.present(hub)
		await _frames(3)
		if amount == 0:
			_expect(_portable_panel.get_node("%ReviewPortable").disabled and "부족" in _portable_panel.get_node("%PortableStatus").text, "Insufficient purchase remained enabled.")
		else:
			_portable_panel.set_review(hub.quote_portable_appraisals(2))
		await _capture_wear("portable-no-money" if amount == 0 else "portable-long-money", _portable_panel.get_node("Center/Card"))
		_portable_panel.hide()
	_expect(FileAccess.get_file_as_bytes(_path) == bytes, "Display boundaries changed saved run.")
