extends "res://tests/smoke/hub_appraisal_smoke.gd"

var _sale_panel: HubSalePanel
var _sale_list: ItemList


func _ready() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--sale-directory="):
			_directory = argument.trim_prefix("--sale-directory=")
	_read_case = "--sale-continue" in OS.get_cmdline_user_args()
	_render = "--sale-render" in OS.get_cmdline_user_args()
	if _directory.is_empty():
		_directory = OS.get_environment("TEMP").path_join("dungeon-sale-%d-%d" % [OS.get_process_id(), Time.get_ticks_usec()])
	_expect(DirAccess.make_dir_recursive_absolute(_directory) == OK, "Cannot create isolated sale directory.")
	_path = _directory.path_join("progress.json")
	_store = ProgressStore.new(_path)
	if not _read_case:
		_check_sale_domain()
		_expect(not _store.has_file() and _store.save_data(_sale_fixture()) == OK, "Sale fixture requires a fresh directory.")
	var settings_store := SettingsStore.new(_directory.path_join("settings.cfg"))
	if not _read_case:
		_expect(settings_store.save_settings(GameSettings.new()) == OK, "Cannot prepare settings.")
	var settings_before := FileAccess.get_file_as_bytes(_directory.path_join("settings.cfg"))
	var before := FileAccess.get_file_as_bytes(_path)
	_entry = MAIN_SCENE.instantiate()
	_entry.configure_progress(_store)
	_entry.configure_settings(settings_store)
	add_child(_entry)
	await _frames(5)
	_hub = _entry.get_node("Interface/HubPanel")
	_panel = _hub.get_node("AppraisalPanel")
	_list = _panel.get_node("%AppraisalItems")
	_sale_panel = _hub.get_node("SalePanel")
	_sale_list = _sale_panel.get_node("%SaleItems")
	_hub.sale_requested.emit()
	_sale_panel.confirmation_requested.emit()
	_expect(not _sale_panel.visible, "Title allowed sale operations.")
	_click(_entry.get_node("Interface/TitleScreen/%ContinueButton"))
	await _frames(5)
	_expect(GameState.get_current_state() == GameState.State.HUB and before == FileAccess.get_file_as_bytes(_path), "Continue failed or rewrote the existing save.")
	if not _read_case:
		await _check_sale_ui()
		await _appraise_and_sell(415, 615)
		await _recover_for_sale()
		await _appraise_and_sell(620, 820)
		await _check_failure_preserves_sale()
	else:
		_expect_sale_holdings(820, 0)
		await _empty_return_after_sale()
	_expect_sale_holdings(815 if _read_case else 820, 0)
	_click(_hub.get_node("%SaleButton"))
	await _frames(3)
	_expect(_sale_list.item_count == 0 and _sale_panel.get_node("%ReviewSale").disabled and "판매 가능한" in _sale_panel.get_node("%SaleStatus").text, "Empty storage offered a sale.")
	await _capture_sale("empty")
	_sale_panel.review_requested.emit(PackedInt32Array())
	_sale_panel.confirmation_requested.emit()
	_expect_sale_holdings(815 if _read_case else 820, 0)
	_expect(settings_before == FileAccess.get_file_as_bytes(_directory.path_join("settings.cfg")), "Selling changed settings.")
	var report := {"passed": _failures.is_empty(), "case": "continue" if _read_case else "write", "final_hub": _store.load_data()}
	var file := FileAccess.open(_directory.path_join("sale-continue.json" if _read_case else "sale-write.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t") + "\n")
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"hub_sale_passed", report.case)
	get_tree().quit(0 if _failures.is_empty() else 1)


func _sale_fixture() -> Dictionary:
	var data := HubState.new().to_save_data()
	data.money = "10"
	data.costs = ExpeditionCosts.new_book(data.money.to_int())
	data.bag_slots = 3
	data.stored_items = [
		{"id": "test_g1_unknown", "identified": false, "risk_hint": "표면의 진동"},
		{"id": "test_g1_unknown", "identified": true, "risk_hint": "첫 번째 감정품"},
		{"id": "test_g1_unknown", "identified": true, "risk_hint": "두 번째 감정품"},
		{"id": "test_g1_light", "identified": true, "risk_hint": "가벼운 외형"},
	]
	return data


func _check_sale_domain() -> void:
	var initial := _sale_fixture()
	var hub := HubState.from_save_data(initial, CATALOG)
	for indices in [PackedInt32Array(), PackedInt32Array([-1]), PackedInt32Array([4]), PackedInt32Array([1, 1]), PackedInt32Array([0]), PackedInt32Array([0, 1])]:
		_expect(hub.quote_sale(indices, ECONOMY) == null and hub.to_save_data() == initial, "Invalid/unknown selection partially sold storage.")
	var quote := hub.quote_sale(PackedInt32Array([3, 1]), ECONOMY)
	_expect(quote != null and quote.get_prices() == [200, 10] and quote.get_income() == 210 and quote.get_money_after() == 220, "Quote differs from economic prices or incorrectly reapplied appraisal fees.")
	quote.get_indices()[0] = 0
	quote.get_prices()[0] = 999
	var candidate := hub.copy()
	_expect(candidate.apply_sale(quote, ECONOMY) and candidate.get_money() == 220, "Noncontiguous sale failed.")
	var retained := candidate.get_stored_items()
	_expect(retained.size() == 2 and not retained[0].is_identified() and retained[1].get_risk_hint() == "두 번째 감정품", "Sale removed the wrong identical copy or reordered retained items.")
	_expect(not candidate.apply_sale(quote, ECONOMY) and candidate.get_money() == 220 and hub.to_save_data() == initial, "Quote replay or candidate mutation changed money twice/source state.")
	var offers := hub.get_sale_offers(ECONOMY)
	offers[1].price = 999
	offers[1].item.get_definition().value_min = 1
	_expect(hub.get_sale_offers(ECONOMY)[1].price == 200 and hub.get_stored_items()[1].get_definition().value_min == 200, "Offer view is mutable hub/economy state.")
	var changed_rule := ECONOMY.duplicate(true) as EconomyRule
	changed_rule.base_prices[&"test_g1_unknown"] = 190
	changed_rule.base_prices[&"test_g1_light"] = 20
	_expect(not hub.apply_sale(quote, changed_rule), "Per-item prices changed with same total but old quote was accepted.")
	hub.select_bag_slots(2)
	_expect(not hub.apply_sale(quote, ECONOMY), "Stale hub quote accepted.")
	hub = HubState.from_save_data(initial, CATALOG)
	var appraisal := hub.quote_appraisal(PackedInt32Array([0]), ECONOMY)
	_expect(hub.apply_appraisal(appraisal, ECONOMY) and not hub.apply_sale(quote, ECONOMY), "Appraisal did not invalidate an earlier sale quote.")
	hub.begin_expedition()
	_expect(hub.quote_sale(PackedInt32Array([1]), ECONOMY) == null, "Active expedition allowed selling.")
	hub = HubState.from_save_data(initial, CATALOG)
	changed_rule.base_prices.erase(&"test_g1_unknown")
	_expect(hub.get_sale_offers(changed_rule)[1].status == SaleQuote.Status.UNPRICED and hub.quote_sale(PackedInt32Array([1, 3]), changed_rule) == null, "Unpriced item became a free or partial sale.")
	changed_rule.base_prices[&"test_g1_unknown"] = -1
	_expect(hub.quote_sale(PackedInt32Array([1]), changed_rule) == null, "Negative price accepted.")
	changed_rule.base_prices[&"test_g1_unknown"] = 0
	_expect(hub.apply_sale(hub.quote_sale(PackedInt32Array([1]), changed_rule), changed_rule) and hub.get_money() == 10 and hub.get_stored_items().size() == 3, "Explicit zero price failed.")
	var boundary := initial.duplicate(true)
	boundary.money = "9223372036854775607"
	boundary.costs = ExpeditionCosts.new_book(boundary.money.to_int())
	hub = HubState.from_save_data(boundary, CATALOG)
	_expect(hub.apply_sale(hub.quote_sale(PackedInt32Array([1]), ECONOMY), ECONOMY) and hub.get_money() == 9223372036854775807, "Exact int64 balance lost precision.")
	_expect(hub.quote_sale(PackedInt32Array([1]), ECONOMY) == null, "Balance overflow accepted.")
	changed_rule.base_prices[&"test_g1_unknown"] = 9223372036854775807
	hub = HubState.from_save_data(initial, CATALOG)
	_expect(hub.quote_sale(PackedInt32Array([1, 2]), changed_rule) == null, "Batch sum overflow accepted.")
	for category in ItemDefinition.CATEGORY_IDS:
		var catalog := ItemCatalog.new()
		for original in CATALOG.items:
			catalog.items.append(original.duplicate(true) as ItemDefinition)
		catalog.items[3].category = category
		catalog.items[3].sale_protected = category == ItemDefinition.CATEGORY_SCRAP
		var protected_hub := HubState.from_save_data(initial, catalog)
		var protected_offers := protected_hub.get_sale_offers(ECONOMY)
		_expect(protected_offers[0].status == SaleQuote.Status.UNIDENTIFIED and protected_offers[0].price == -1, "Unknown eligibility leaked protected classification/price.")
		if category != ItemDefinition.CATEGORY_RESIDUE:
			_expect(protected_offers[1].status == SaleQuote.Status.PROTECTED and protected_offers[1].price == -1 and protected_hub.quote_sale(PackedInt32Array([1]), ECONOMY) == null, "Protected/non-monetary item sold despite explicit price.")
			_expect("판매 불가" in HubSalePanel.format_availability(protected_offers[1]), "Protected item lacked a reason.")
	_expect(ECONOMY.get_price(&"test_g1_unknown") == 200 and CATALOG.items[3].category == ItemDefinition.CATEGORY_RESIDUE, "Fixtures changed product resources.")


func _check_sale_ui() -> void:
	var before := FileAccess.get_file_as_bytes(_path)
	_click(_hub.get_node("%SaleButton"))
	await _frames(4)
	_expect(_sale_panel.visible and not _hub.get_node("Center").visible, "Sale did not isolate hub controls.")
	_expect(not _sale_list.is_item_selectable(0) and "감정 대기" in _sale_list.get_item_text(0) and not "200" in _sale_list.get_item_text(0), "Unknown sale row exposed price or allowed selection.")
	_hub.appraisal_requested.emit()
	_hub.departure_requested.emit()
	_hub.bag_slots_selected.emit(2)
	_expect(not _panel.visible and GameState.get_current_state() == GameState.State.HUB and _entry.get_departure_preview().slot_capacity == 3, "Sale allowed appraisal/departure/preparation changes.")
	_sale_panel.review_requested.emit(PackedInt32Array([0, 1]))
	_sale_panel.confirmation_requested.emit()
	_expect_sale_holdings(10, 4)
	await _choose_sale_row(1)
	_click(_sale_panel.get_node("%ReviewSale"))
	await _frames(3)
	_expect("판매 수입 +200 · 판매 후 보유금 210" in _sale_panel.get_node("%SaleStatus").text, "Single sale quote wrong.")
	await _capture_sale("quote")
	_press_key(KEY_ESCAPE)
	await _frames(3)
	_expect(_sale_panel.get_node("%ReviewSale").visible and before == FileAccess.get_file_as_bytes(_path), "Esc cancelled by selling.")
	_click(_sale_panel.get_node("%ReviewSale"))
	await _frames(3)
	_click(_sale_panel.get_node("%CloseSale"))
	await _frames(3)
	_sale_panel.confirmation_requested.emit()
	_expect(not _sale_panel.visible and before == FileAccess.get_file_as_bytes(_path), "Closed quote sold items.")
	_click(_hub.get_node("%SaleButton"))
	await _frames(3)
	_expect(_sale_list.get_selected_items().is_empty(), "Reopen retained stale selection.")
	await _choose_sale_row(1)
	_click(_sale_panel.get_node("%ReviewSale"))
	await _frames(3)
	_expect(DirAccess.make_dir_absolute(_path + ".tmp") == OK, "Cannot inject save failure.")
	_click(_sale_panel.get_node("%ConfirmSale"))
	await _frames(3)
	_expect_sale_holdings(10, 4)
	_expect(before == FileAccess.get_file_as_bytes(_path) and "저장 실패" in _sale_panel.get_node("%SaleStatus").text, "Failed save removed storage/paid money/changed old file.")
	await _capture_sale("retry")
	_expect(DirAccess.remove_absolute(_path + ".tmp") == OK, "Cannot clear isolated save-failure fixture.")
	_click(_sale_panel.get_node("%ConfirmSale"))
	_sale_panel.confirmation_requested.emit()
	await _frames(3)
	_expect_sale_holdings(210, 3)
	_expect(_entry.get_hub_stored_items()[1].get_risk_hint() == "두 번째 감정품", "Retry sold the other identical item.")
	await _choose_sale_row(1)
	await _choose_sale_row(2, true)
	_expect(_sale_list.get_selected_items() == PackedInt32Array([1, 2]), "Scrolled Ctrl-click selected wrong items.")
	_click(_sale_panel.get_node("%ReviewSale"))
	await _frames(3)
	_expect("선택 2개 · 판매 수입 +210 · 판매 후 보유금 420" in _sale_panel.get_node("%SaleStatus").text, "Batch quote incorrect.")
	_click(_sale_panel.get_node("%ConfirmSale"))
	_sale_panel.confirmation_requested.emit()
	await _frames(3)
	_expect_sale_holdings(420, 1)
	_expect(not _entry.get_hub_stored_items()[0].is_identified(), "Batch removed the unselected unknown.")
	await _capture_sale("sold")
	_click(_sale_panel.get_node("%CloseSale"))
	await _frames(3)


func _appraise_and_sell(appraised_money: int, sold_money: int) -> void:
	_click(_hub.get_node("%AppraisalButton"))
	await _frames(3)
	_hub.sale_requested.emit()
	_expect(not _sale_panel.visible, "Appraisal allowed overlapping sale.")
	_click(_panel.get_node("%SelectAll"))
	_click(_panel.get_node("%ReviewAppraisal"))
	await _frames(3)
	_click(_panel.get_node("%ConfirmAppraisal"))
	await _frames(3)
	_expect_sale_holdings(appraised_money, 1)
	_expect(_entry.get_hub_stored_items()[0].is_identified(), "Appraisal failed before sale.")
	_click(_panel.get_node("%CloseAppraisal"))
	await _frames(3)
	_click(_hub.get_node("%SaleButton"))
	await _frames(3)
	_sale_list.grab_focus()
	_press_key(KEY_DOWN)
	_press_key(KEY_SPACE)
	_expect(_sale_list.get_selected_items() == PackedInt32Array([0]), "Arrow and Space could not select the first sale item.")
	_press_key(KEY_SPACE)
	_expect(_sale_list.get_selected_items().is_empty(), "Space did not deselect the focused sale item.")
	_press_key(KEY_SPACE)
	_expect(_sale_list.get_selected_items() == PackedInt32Array([0]), "Keyboard could not select appraised item.")
	_click(_sale_panel.get_node("%ReviewSale"))
	await _frames(3)
	_click(_sale_panel.get_node("%ConfirmSale"))
	_sale_panel.confirmation_requested.emit()
	await _frames(3)
	_expect_sale_holdings(sold_money, 0)
	_click(_sale_panel.get_node("%CloseSale"))
	await _frames(3)


func _recover_for_sale() -> void:
	_click(_hub.get_node("%DepartureButton"))
	await _frames(5)
	var world: PrototypeExploration = _entry.get_node("PrototypeExploration")
	var player: PlayerController = world.get_node("Player")
	_sale_panel.confirmation_requested.emit()
	_hub.sale_requested.emit()
	_expect(not _sale_panel.visible and _entry.get_hub_money() == 615, "Exploration accepted hidden sale.")
	for target in [Vector2(-500, -200), Vector2(-275, -200), Vector2(630, -200), Vector2(630, 220)]:
		await _walk(player, target)
		if target in [Vector2(-275, -200), Vector2(630, 220)]:
			_press_key(KEY_E)
			_expect(await InteractionTestInput.wait_for_work(player), "Actual pickup/inspection failed.")
	_press_key(KEY_E)
	_expect(await InteractionTestInput.wait_for_work(player), "Unknown recovery failed.")
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
	_expect_sale_holdings(625, 1)
	_expect(not _entry.get_hub_stored_items()[0].is_identified(), "New unknown was automatically sold or identified.")


func _check_failure_preserves_sale() -> void:
	_click(_hub.get_node("%DepartureButton"))
	await _frames(5)
	var player: PlayerController = _entry.get_node("PrototypeExploration/Player")
	for point in [Vector2(-500, -200), Vector2(-275, -200)]:
		await _walk(player, point)
	_press_key(KEY_E)
	_expect(await InteractionTestInput.wait_for_work(player), "Failure run could not collect item.")
	for point in [Vector2(-500, -200), Vector2(-500, 200), Vector2(-170, 200)]:
		await _walk(player, point)
	await _frames(100)
	_expect(_entry.get_pending_outcome() != null and _entry.get_pending_outcome().is_failure(), "Expected collapse failure missing.")
	_click(_entry.get_node("Interface/Results/NextStep/SettleButton"))
	await _frames(5)
	_expect_sale_holdings(815 if _read_case else 820, 0)


func _empty_return_after_sale() -> void:
	_expect(HubRepairTestInput.prepare_departure(_entry) == 5, "Sale continuation repair cost changed.")
	_click(_hub.get_node("%DepartureButton"))
	await _frames(5)
	var world: PrototypeExploration = _entry.get_node("PrototypeExploration")
	_expect(world.get_node("Player/Inventory").get_used_slots() == 0, "Sold storage returned in a new expedition.")
	await _walk(world.get_node("Player"), Vector2(-720, 0))
	_press_key(KEY_E)
	await _frames(5)
	_click(_entry.get_node("Interface/Results/NextStep/SettleButton"))
	await _frames(5)


func _expect_sale_holdings(money: int, count: int) -> void:
	_expect(_entry.get_hub_money() == money and _entry.get_hub_stored_items().size() == count, "Live sale holdings mismatch: expected %d/%d, got %d/%d." % [money, count, _entry.get_hub_money(), _entry.get_hub_stored_items().size()])
	var saved := _store.load_data()
	_expect(saved.money == str(money) and saved.stored_items.size() == count and saved.size() == 12, "Saved sale holdings/schema mismatch.")


func _choose_sale_row(index: int, control := false) -> void:
	var rect := _sale_list.get_item_rect(index)
	_sale_list.get_v_scroll_bar().value = rect.position.y
	await _frames(3)
	var position := _sale_list.global_position + rect.get_center() - Vector2(0, _sale_list.get_v_scroll_bar().value)
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.position = position
		event.pressed = pressed
		event.ctrl_pressed = control
		get_viewport().push_input(event)
	await _frames(2)


func _capture_sale(label: String) -> void:
	for window_size in [Vector2i(1152, 648), Vector2i(1600, 900)]:
		get_tree().root.size = window_size
		await _frames(4)
		_expect(get_viewport().get_visible_rect().encloses(_sale_panel.get_node("Center/Card").get_global_rect()), "Sale card exceeds viewport.")
		if _render and DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
			_expect(get_viewport().get_texture().get_image().save_png(_directory.path_join("%s-%d.png" % [label, window_size.x])) == OK, "Sale screenshot failed.")
	get_tree().root.size = Vector2i(1152, 648)
	await _frames(4)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		GameLog.error(&"SmokeTest", &"hub_sale_failed", message)
