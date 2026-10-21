extends "res://tests/smoke/hub_departure_smoke.gd"

const CATALOG := preload("res://src/data/prototype_item_catalog.tres")
const ECONOMY := preload("res://src/data/prototype_economy.tres")

var _entry: GameEntry
var _hub: HubPanel
var _panel: HubAppraisalPanel
var _list: ItemList
var _directory := ""
var _path := ""
var _store: ProgressStore
var _read_case := false
var _render := false


func _ready() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--appraisal-directory="):
			_directory = argument.trim_prefix("--appraisal-directory=")
	_read_case = "--appraisal-continue" in OS.get_cmdline_user_args()
	_render = "--appraisal-render" in OS.get_cmdline_user_args()
	if _directory.is_empty():
		_directory = OS.get_environment("TEMP").path_join("dungeon-appraisal-%d-%d" % [OS.get_process_id(), Time.get_ticks_usec()])
	_expect(DirAccess.make_dir_recursive_absolute(_directory) == OK, "Cannot create isolated test directory.")
	_path = _directory.path_join("progress.json")
	_store = ProgressStore.new(_path)
	if not _read_case:
		_check_domain()
		_expect(not _store.has_file() and _store.save_data(_fixture()) == OK, "Fixture requires a fresh directory.")
	var before := FileAccess.get_file_as_bytes(_path)
	_entry = MAIN_SCENE.instantiate()
	_entry.configure_progress(_store)
	var settings_store := SettingsStore.new(_directory.path_join("settings.cfg"))
	if not _read_case:
		_expect(settings_store.save_settings(GameSettings.new()) == OK, "Settings fixture failed.")
	var settings_bytes := FileAccess.get_file_as_bytes(_directory.path_join("settings.cfg"))
	_entry.configure_settings(settings_store)
	add_child(_entry)
	await _frames(5)
	_hub = _entry.get_node("Interface/HubPanel")
	_panel = _hub.get_node("AppraisalPanel")
	_list = _panel.get_node("%AppraisalItems")
	_hub.appraisal_requested.emit()
	_expect(not _panel.visible, "Title accepted hidden appraisal request.")
	_click(_entry.get_node("Interface/TitleScreen/%ContinueButton"))
	await _frames(5)
	_expect(GameState.get_current_state() == GameState.State.HUB and FileAccess.get_file_as_bytes(_path) == before, "Continue failed or rewrote old-format progress.")
	if not _read_case:
		await _check_appraisal()
		await _recover_current_items()
		_click(_hub.get_node("%AppraisalButton"))
		await _frames(3)
		_click(_panel.get_node("%SelectAll"))
		_click(_panel.get_node("%ReviewAppraisal"))
		await _frames(3)
		_expect("선택 3개 · 비용 15" in _panel.get_node("%AppraisalStatus").text, "Batch quote did not include retained and newly recovered unknowns.")
		_click(_panel.get_node("%ConfirmAppraisal"))
		_panel.confirmation_requested.emit()
		await _frames(3)
	else:
		_click(_hub.get_node("%AppraisalButton"))
		await _frames(3)
	_check_final_holdings()
	_expect(_panel.get_node("%SelectAll").disabled and _panel.get_node("%ReviewAppraisal").disabled, "No-target controls remained enabled.")
	await _capture_sizes("identified")
	_panel.review_requested.emit(PackedInt32Array())
	_panel.confirmation_requested.emit()
	_check_final_holdings()
	_click(_panel.get_node("%CloseAppraisal"))
	await _frames(3)
	await _empty_departure()
	_check_final_holdings()
	_expect(settings_bytes == FileAccess.get_file_as_bytes(_directory.path_join("settings.cfg")), "Appraisal modified settings.")
	var report := {"passed": _failures.is_empty(), "case": "continue" if _read_case else "write", "final_hub": _store.load_data()}
	var file := FileAccess.open(_directory.path_join("appraisal-continue.json" if _read_case else "appraisal-write.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t") + "\n")
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"hub_appraisal_passed", report.case)
	get_tree().quit(0 if _failures.is_empty() else 1)


func _fixture() -> Dictionary:
	var data := HubState.new().to_save_data()
	data.money = "10"
	data.costs = ExpeditionCosts.new_book(data.money.to_int())
	data.bag_slots = 3
	data.stored_items = [
		{"id": "test_g1_unknown", "identified": false, "risk_hint": "희미한 진동"},
		{"id": "test_g1_unknown", "identified": false, "risk_hint": "희미한 진동"},
		{"id": "test_g1_unknown", "identified": false, "risk_hint": "긁힌 외형"},
	]
	return data


func _check_domain() -> void:
	var hub := HubState.from_save_data(_fixture(), CATALOG)
	var initial := hub.to_save_data()
	for indices in [PackedInt32Array(), PackedInt32Array([-1]), PackedInt32Array([3]), PackedInt32Array([0, 0]), PackedInt32Array([0, 3])]:
		_expect(hub.quote_appraisal(indices, ECONOMY) == null and hub.to_save_data() == initial, "Invalid selection mutated storage.")
	var expensive := hub.quote_appraisal(PackedInt32Array([0, 1, 2]), ECONOMY)
	_expect(expensive != null and not expensive.can_afford() and not hub.apply_appraisal(expensive, ECONOMY) and hub.to_save_data() == initial, "Insufficient batch was partly charged or identified.")
	var quote := hub.quote_appraisal(PackedInt32Array([1]), ECONOMY)
	quote.get_indices()[0] = 0
	var candidate := hub.copy()
	_expect(candidate.apply_appraisal(quote, ECONOMY) and candidate.get_money() == 5, "Single appraisal failed.")
	var items := candidate.get_stored_items()
	_expect(not items[0].is_identified() and items[1].is_identified() and not items[2].is_identified(), "Same-ID selection identified the wrong physical copy.")
	_expect(not candidate.apply_appraisal(quote, ECONOMY) and candidate.get_money() == 5 and hub.to_save_data() == initial, "Quote replay charged twice or copy modified source.")
	hub.select_bag_slots(2)
	_expect(not hub.apply_appraisal(quote, ECONOMY), "Stale quote accepted a changed hub.")
	hub = HubState.from_save_data(initial, CATALOG)
	var changed_rule := ECONOMY.duplicate() as EconomyRule
	changed_rule.appraisal_fee_per_item = 6
	_expect(not hub.apply_appraisal(quote, changed_rule), "Changed fee accepted old quote.")
	changed_rule.appraisal_fee_per_item = -1
	_expect(hub.quote_appraisal(PackedInt32Array([0]), changed_rule) == null, "Negative fee accepted.")
	changed_rule.appraisal_fee_per_item = 9223372036854775807
	_expect(changed_rule.get_appraisal_cost(2) == -1 and changed_rule.get_appraisal_cost(1) == 9223372036854775807, "Fee overflow boundary failed.")
	changed_rule.appraisal_fee_per_item = 0
	_expect(hub.apply_appraisal(hub.quote_appraisal(PackedInt32Array([0, 2]), changed_rule), changed_rule) and hub.get_money() == 10, "Zero-cost batch failed.")
	_expect(hub.quote_appraisal(PackedInt32Array([0]), ECONOMY) == null, "Already identified item offered for payment.")
	hub.begin_expedition()
	_expect(hub.quote_appraisal(PackedInt32Array([1]), ECONOMY) == null, "Active expedition allowed hub appraisal.")
	for category in ItemDefinition.CATEGORY_IDS:
		var catalog := ItemCatalog.new()
		for original in CATALOG.items:
			catalog.items.append(original.duplicate(true) as ItemDefinition)
		var definition: ItemDefinition = catalog.items[3]
		definition.category = category
		definition.sale_protected = category == ItemDefinition.CATEGORY_SCRAP
		var protected_hub := HubState.from_save_data(initial, catalog)
		var hidden := HubAppraisalPanel.format_item(protected_hub.get_stored_items()[0])
		_expect(not "200" in hidden and not "잔재" in hidden and not "보호" in hidden and not "고유" in hidden, "Hidden category/value/protection leaked.")
		_expect(protected_hub.apply_appraisal(protected_hub.quote_appraisal(PackedInt32Array([0, 1]), ECONOMY), ECONOMY), "Multi-item exact-balance appraisal failed.")
		var restored := HubState.from_save_data(protected_hub.to_save_data(), catalog)
		_expect(restored.get_money() == 0 and restored.get_stored_items().size() == 3 and restored.get_stored_items()[0].get_definition().is_protected() == definition.is_protected(), "Appraisal changed protection or sold a retained item.")
		var public_text := HubAppraisalPanel.format_item(restored.get_stored_items()[0])
		if not definition.has_monetary_value():
			_expect("등록·정보 보상" in public_text and not "200" in public_text, "Non-monetary appraisal disclosed a cash value.")
		if definition.is_protected():
			var outcome := ExplorationOutcome.safe_return_inventory_items([restored.get_stored_items()[0]])
			var sale_rule := ECONOMY.duplicate(true) as EconomyRule
			sale_rule.base_prices[&"test_g1_unknown"] = 999
			var settlement := SettlementResult.from_outcome(outcome, sale_rule)
			_expect(settlement.get_total_income() == 0 and settlement.get_retained_items().size() == 1, "Appraisal bypassed sale protection.")
	_expect(CATALOG.items[3].category == ItemDefinition.CATEGORY_RESIDUE and not CATALOG.items[3].sale_protected, "Test catalog mutated product definitions.")


func _check_appraisal() -> void:
	var before := FileAccess.get_file_as_bytes(_path)
	_click(_hub.get_node("%AppraisalButton"))
	await _frames(3)
	_expect(_panel.visible and not _hub.get_node("Center").visible, "Appraisal did not isolate hub controls.")
	_expect(_list.icon_mode == ItemList.ICON_MODE_TOP and _list.max_text_lines >= 3, "Appraisal item details are flattened into one line.")
	# Use actual Ctrl-clicks to select two distinct copies, then deselect with Space.
	_select_row(0)
	_select_row(1, true)
	_expect(_list.get_selected_items() == PackedInt32Array([0, 1]), "Ctrl-click multi-selection failed.")
	_press_key(KEY_SPACE)
	_expect(_list.get_selected_items().size() == 1, "Space selection toggle failed: %s; focus=%s" % [_list.get_selected_items(), _list.has_focus()])
	_hub.departure_requested.emit()
	_hub.bag_slots_selected.emit(2)
	_expect(GameState.get_current_state() == GameState.State.HUB and _entry.get_departure_preview().slot_capacity == 3, "Modal allowed a conflicting operation.")
	_click(_panel.get_node("%SelectAll"))
	_click(_panel.get_node("%ReviewAppraisal"))
	await _frames(3)
	_expect(_panel.get_node("%ConfirmAppraisal").disabled and "5 부족" in _panel.get_node("%AppraisalStatus").text, "Insufficient balance was not explained.")
	_panel.confirmation_requested.emit()
	_expect(FileAccess.get_file_as_bytes(_path) == before and _entry.get_hub_money() == 10, "Insufficient confirm charged money.")
	# Restore the quote explanation after the intentionally forged confirm request.
	_click(_panel.get_node("%CancelAppraisal"))
	_click(_panel.get_node("%ReviewAppraisal"))
	await _frames(3)
	await _capture_sizes("insufficient")
	_press_key(KEY_ESCAPE)
	await _frames(3)
	_expect(_panel.get_node("%ReviewAppraisal").visible, "Esc did not cancel review.")
	_select_row(1)
	_click(_panel.get_node("%ReviewAppraisal"))
	await _frames(3)
	_expect("선택 1개 · 비용 5 · 감정 후 보유금 5" in _panel.get_node("%AppraisalStatus").text, "Single quote selected wrong count or balance.")
	_click(_panel.get_node("%CloseAppraisal"))
	await _frames(3)
	_panel.confirmation_requested.emit()
	_expect(not _panel.visible and FileAccess.get_file_as_bytes(_path) == before, "Cancel committed the quote.")
	_click(_hub.get_node("%AppraisalButton"))
	await _frames(3)
	_expect(_list.get_selected_items().is_empty(), "Reopening retained stale selection.")
	_select_row(1)
	_click(_panel.get_node("%ReviewAppraisal"))
	await _frames(3)
	await _capture_sizes("quote")
	_expect(DirAccess.make_dir_absolute(_path + ".tmp") == OK, "Cannot inject save failure.")
	_click(_panel.get_node("%ConfirmAppraisal"))
	await _frames(3)
	_expect("저장 실패" in _panel.get_node("%AppraisalStatus").text and FileAccess.get_file_as_bytes(_path) == before and _entry.get_hub_money() == 10 and not _entry.get_hub_stored_items()[1].is_identified(), "Failed save mutated memory, file or selection.")
	await _capture_sizes("retry")
	_expect(DirAccess.remove_absolute(_path + ".tmp") == OK, "Cannot clear isolated failure directory.")
	_click(_panel.get_node("%ConfirmAppraisal"))
	_panel.confirmation_requested.emit()
	await _frames(3)
	var items := _entry.get_hub_stored_items()
	_expect(_entry.get_hub_money() == 5 and not items[0].is_identified() and items[1].is_identified() and not items[2].is_identified(), "Retry/duplicate request changed the wrong item or charged twice.")
	_expect("200~280" in _list.get_item_text(1) and not "200" in _list.get_item_text(0), "Appraisal did not reveal only the selected item: %s / %s" % [_list.get_item_text(0), _list.get_item_text(1)])
	_click(_panel.get_node("%CloseAppraisal"))
	await _frames(3)


func _recover_current_items() -> void:
	_click(_hub.get_node("%DepartureButton"))
	await _frames(5)
	var world: PrototypeExploration = _entry.get_node("PrototypeExploration")
	var player: PlayerController = world.get_node("Player")
	for target in [Vector2(-500, -200), Vector2(-275, -200), Vector2(80, -200), Vector2(630, -200), Vector2(630, 220)]:
		await _walk(player, target)
		if target in [Vector2(-275, -200), Vector2(80, -200), Vector2(630, 220)]:
			_press_key(KEY_E)
			_expect(await InteractionTestInput.wait_for_work(player), "Real recovery action failed.")
	_press_key(KEY_E)
	_expect(await InteractionTestInput.wait_for_work(player), "Unknown recovery action failed.")
	for frame in range(240):
		if world.get_node("%GolemContactThreat").is_warning():
			break
		await _frames(1)
	_press_key(KEY_Q)
	await _frames(3)
	for point in [Vector2(630, -200), Vector2(-500, -200), Vector2(-650, 0), Vector2(-720, 0)]:
		await _walk(player, point)
	_press_key(KEY_E)
	await _frames(5)
	_click(_entry.get_node("Interface/Results/NextStep/SettleButton"))
	await _frames(5)
	_expect(_entry.get_hub_money() == 41 and _entry.get_hub_stored_items().size() == 4, "Real recovery/settlement did not retain prior appraisal and new unknown.")


func _empty_departure() -> void:
	_click(_hub.get_node("%DepartureButton"))
	await _frames(5)
	var world: PrototypeExploration = _entry.get_node("PrototypeExploration")
	_panel.confirmation_requested.emit()
	_expect(world.get_node("Player/Inventory").get_used_slots() == 0 and _entry.get_hub_money() == 26, "Fresh expedition carried storage or applied hidden appraisal.")
	await _walk(world.get_node("Player"), Vector2(-720, 0))
	_press_key(KEY_E)
	await _frames(5)
	_click(_entry.get_node("Interface/Results/NextStep/SettleButton"))
	await _frames(5)


func _check_final_holdings() -> void:
	_expect(_entry.get_hub_money() == 26 and _entry.get_hub_stored_items().size() == 4, "Final money/storage incorrect.")
	for item in _entry.get_hub_stored_items():
		_expect(item.is_identified() and item.get_definition().stable_id == &"test_g1_unknown", "Saved appraisal state lost.")
	_expect(_store.load_data().money == "26" and _store.load_data().size() == 16, "Saved money or existing schema changed.")
	for raw_item in _store.load_data().stored_items:
		_expect(raw_item.identified, "File did not preserve identification.")


func _select_row(index: int, control := false) -> void:
	var position := _list.get_global_rect().position + _list.get_item_rect(index).get_center()
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.position = position
		event.pressed = pressed
		event.ctrl_pressed = control
		get_viewport().push_input(event)


func _capture_sizes(label: String) -> void:
	for window_size in [Vector2i(1152, 648), Vector2i(1600, 900)]:
		get_tree().root.size = window_size
		await _frames(4)
		_expect(get_viewport().get_visible_rect().encloses(_panel.get_node("Center/Card").get_global_rect()), "Appraisal card exceeds viewport.")
		if _render and DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
			_expect(get_viewport().get_texture().get_image().save_png(_directory.path_join("%s-%d.png" % [label, window_size.x])) == OK, "Screenshot failed.")
	get_tree().root.size = Vector2i(1152, 648)
	await _frames(4)
