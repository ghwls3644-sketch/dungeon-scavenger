extends Node

var _failures := PackedStringArray()


func _ready() -> void:
	var rule := EconomyRule.new()
	rule.base_prices = {&"scrap": 17, &"residue": 23, &"unknown": 999, &"unique": 800, &"record": 900, &"protected": 700}
	var scrap := _item(&"scrap", ItemDefinition.CATEGORY_SCRAP)
	var residue := _item(&"residue", ItemDefinition.CATEGORY_RESIDUE)
	var unknown := _item(&"unknown", ItemDefinition.CATEGORY_RESIDUE, false)
	var unique := _item(&"unique", ItemDefinition.CATEGORY_UNIQUE_ARTIFACT)
	var record := _item(&"record", ItemDefinition.CATEGORY_CORE_RECORD)
	var protected := _item(&"protected", ItemDefinition.CATEGORY_SCRAP)
	protected.get_definition().sale_protected = true
	var unpriced := _item(&"unpriced", ItemDefinition.CATEGORY_SCRAP)
	var unknown_unique := _item(&"unknown_unique", ItemDefinition.CATEGORY_UNIQUE_ARTIFACT, false)
	var outcome := ExplorationOutcome.safe_return_inventory_items([scrap, residue, unknown, unique, record, protected, unpriced, unknown_unique])
	var hub := HubState.new()
	hub.select_bag_slots(3)
	_expect(not hub.prepare_settlement(0, outcome, rule) and not hub.apply_settlement(0), "Settlement succeeded without an expedition.")
	var first := hub.begin_expedition()
	_expect(first > 0 and hub.begin_expedition() == 0, "Overlapping departures were accepted.")
	var invalid := rule.duplicate(true) as EconomyRule
	invalid.base_prices[&"scrap"] = -1
	_expect(not hub.prepare_settlement(first, outcome, invalid), "Negative price was accepted.")
	_expect(hub.get_money() == 0 and hub.get_stored_items().is_empty(), "Rejected settlement changed holdings.")
	_expect(hub.prepare_settlement(first, outcome, rule), "Settlement could not be prepared.")
	var settlement := hub.get_pending_settlement()
	_expect(settlement.get_total_income() == 40 and settlement.get_net_income() == 40 and settlement.get_total_cost() == 0, "Settlement confused actual prices with estimates or charged nonexistent services.")
	_expect(settlement.get_sales().size() == 2 and settlement.get_retained_items().size() == 6, "Unidentified, protected or unpriced items were sold.")
	_expect(hub.get_money() == 0 and hub.get_stored_items().is_empty(), "Preview applied settlement before confirmation.")
	_expect(not hub.prepare_settlement(first, outcome, rule) and not hub.cancel_expedition(first), "Prepared settlement was replaced or canceled.")
	# Price data, recovered input and returned collections cannot alter an offered settlement.
	rule.base_prices[&"scrap"] = 444
	scrap.get_definition().display_name = "changed"
	scrap.get_definition().value_min = 999
	var sales := settlement.get_sales()
	sales[0]["amount"] = 9999
	var retained := settlement.get_retained_items()
	retained[0].identify()
	retained[0].get_definition().display_name = "changed"
	retained.clear()
	_expect(settlement.get_total_income() == 40 and settlement.get_sales()[0].amount == 17, "Preview data was mutable from outside.")
	_expect(hub.apply_settlement(first) and not hub.apply_settlement(first), "Settlement was not applied exactly once.")
	_expect(hub.get_money() == 40 and hub.get_stored_items().size() == 6, "Holdings did not receive the complete settlement.")
	var stored := hub.get_stored_items()
	_expect(not stored[0].is_identified() and stored[0].get_risk_hint() == "시험 위험 정보", "Storage lost identification or risk information.")
	stored[0].identify()
	stored.clear()
	_expect(hub.get_stored_items().size() == 6 and not hub.get_stored_items()[0].is_identified(), "Storage getter exposed mutable state.")
	var second := hub.begin_expedition()
	_expect(second > first and not hub.prepare_settlement(first, outcome, rule), "Old expedition replay was accepted.")
	_expect(hub.prepare_settlement(second, ExplorationOutcome.failure(4), rule), "Failure could not return to the hub.")
	_expect(hub.get_pending_settlement().get_lost_count() == 4 and hub.get_pending_settlement().get_net_income() == 0, "Failure was converted to income.")
	_expect(hub.apply_settlement(second) and hub.get_money() == 40 and hub.get_stored_items().size() == 6, "Failure changed previous holdings.")
	_expect(hub.create_departure_loadout().slot_capacity == 3, "Settlement lost the bag choice.")
	var third := hub.begin_expedition()
	_expect(hub.prepare_settlement(third, ExplorationOutcome.safe_return([]), rule) and hub.apply_settlement(third), "Empty return failed.")
	_expect(hub.get_money() == 40 and hub.get_stored_items().size() == 6 and not hub.apply_settlement(first), "Later expedition enabled an old payout.")
	var fourth := hub.begin_expedition()
	_expect(hub.cancel_expedition(fourth) and not hub.prepare_settlement(fourth, outcome, rule), "Canceled departure accepted settlement.")
	var replacement := hub.begin_expedition()
	_expect(hub.prepare_settlement(replacement, ExplorationOutcome.safe_return_inventory_items([residue]), rule) and hub.apply_settlement(replacement), "A new expedition could not pay out after cancellation.")
	_expect(hub.get_money() == 63 and hub.get_stored_items().size() == 6, "Repeated settlement sold old stored items again.")
	var fresh := HubState.new()
	_expect(fresh.get_money() == 0 and fresh.get_stored_items().is_empty(), "New hub inherited another session's holdings.")
	await _check_display(outcome, settlement)
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"settlement_passed")
	get_tree().quit(0 if _failures.is_empty() else 1)


func _check_display(outcome: ExplorationOutcome, settlement: SettlementResult) -> void:
	get_tree().root.size = Vector2i(1152, 648)
	var screen: ExpeditionResultsScreen = preload("res://src/ui/expedition_results_screen.tscn").instantiate()
	add_child(screen)
	screen.show()
	screen.present_result(outcome, settlement)
	for frame in range(4):
		await get_tree().process_frame
	var text: String = screen.get_node("NextStep/Items").text
	_expect("판매액 17" in text and "미확인 · 감정 대기" in text and "등록·정보 보상 대기" in text, "Settlement display did not separate sales from retained rewards.")
	_expect(not "999" in text and not "800" in text and not "900" in text, "Settlement display leaked hidden or protected prices.")
	_expect(ExpeditionResultsScreen.get_storage_reason(_item(&"hidden", ItemDefinition.CATEGORY_UNIQUE_ARTIFACT, false)) == "미확인 · 감정 대기", "Storage reason disclosed an unidentified category.")
	var net: Label = screen.get_node("NextStep/NetIncome")
	_expect(net.get_theme_font_size("font_size") > screen.get_node("NextStep/Totals").get_theme_font_size("font_size"), "Net income is not emphasized.")
	_expect(Rect2(0, 0, 1152, 648).encloses(screen.get_node("NextStep").get_global_rect()), "Settlement controls exceed the viewport.")
	screen.queue_free()


func _item(item_id: StringName, category: StringName, identified := true) -> InventoryItem:
	var definition := ItemDefinition.new()
	definition.stable_id = item_id
	definition.display_name = "시험 물품 " + item_id
	definition.category = category
	definition.weight = 1.0
	definition.slot_size = 1
	definition.value_min = 1
	definition.value_max = 5
	return InventoryItem.from_definition(definition, identified, "시험 위험 정보")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		GameLog.error(&"SmokeTest", &"settlement_failed", message)
