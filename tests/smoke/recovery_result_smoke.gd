extends Node

const RESULT_PANEL_SCENE := preload("res://src/ui/recovery_result_panel.tscn")

var _failures := PackedStringArray()


func _ready() -> void:
	_run_recovery_result_checks()
	_check_result_snapshot()

	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"recovery_result_passed")
		get_tree().quit(0)
		return

	for failure in _failures:
		GameLog.error(&"SmokeTest", &"recovery_result_failed", failure)
	get_tree().quit(1)


func _run_recovery_result_checks() -> void:
	var inventory := PlayerInventory.new()
	add_child(inventory)
	inventory.configure_capacity(3, 10.0, 20.0)

	var low_value_item := _create_test_item(
		&"test_low_value", "Low value item", ItemDefinition.CATEGORY_SCRAP, 10, 20
	)
	var dropped_item := _create_test_item(
		&"test_dropped", "Dropped item", ItemDefinition.CATEGORY_SCRAP, 100, 200
	)
	var high_value_item := _create_test_item(
		&"test_high_value", "High value item", ItemDefinition.CATEGORY_RESIDUE, 30, 40
	)
	var unique_item := _create_test_item(
		&"test_unique", "Unique item", ItemDefinition.CATEGORY_UNIQUE_ARTIFACT, 900, 900
	)
	var rejected_item := _create_test_item(
		&"test_rejected", "Rejected item", ItemDefinition.CATEGORY_SCRAP, 300, 400
	)

	_expect(inventory.try_add_item(low_value_item), "First recovered item was rejected.")
	_expect(inventory.try_add_item(dropped_item), "Item prepared for dropping was rejected.")
	_expect(inventory.drop_selected_item() == dropped_item, "Selected item was not dropped before result capture.")
	_expect(inventory.try_add_item(high_value_item), "Second recovered item was rejected.")
	_expect(inventory.try_add_item(unique_item), "Non-monetary recovered item was rejected.")
	_expect(not inventory.try_add_item(rejected_item), "Slot overflow item was unexpectedly recovered.")

	var result := RecoveryResult.from_recovered_items(inventory.get_items())
	var result_ids := result.get_recovered_items().map(func(item: ItemDefinition): return item.stable_id)
	_expect(result.get_item_count() == 3, "Recovery result item count did not match carried items.")
	_expect(result_ids.has(low_value_item.stable_id), "First carried item was missing from recovery result.")
	_expect(result_ids.has(high_value_item.stable_id), "Second carried item was missing from recovery result.")
	_expect(result_ids.has(unique_item.stable_id), "Non-monetary carried item was missing from recovery result.")
	_expect(not result_ids.has(dropped_item.stable_id), "Dropped item was included in recovery result.")
	_expect(not result_ids.has(rejected_item.stable_id), "Rejected item was included in recovery result.")
	_expect(result.get_total_value_min() == 40, "Minimum expected value total was incorrect.")
	_expect(result.get_total_value_max() == 60, "Maximum expected value total was incorrect.")
	_expect(result.get_non_monetary_reward_count() == 1, "Non-monetary reward count was incorrect.")

	var panel: RecoveryResultPanel = RESULT_PANEL_SCENE.instantiate()
	add_child(panel)
	panel.bind_result(result)
	_expect(panel.get_displayed_item_count() == 3, "Result UI item count did not match recovery result.")
	_expect(panel.get_summary_text().contains("회수품 3개"), "Result UI did not show the recovered item count.")
	_expect(panel.get_summary_text().contains("40~60"), "Result UI did not show the expected value total.")
	_expect(panel.get_summary_text().contains("등록·정보 보상 1개"), "Result UI did not separate non-monetary rewards.")
	_expect(panel.get_displayed_item_text(0).contains("예상 가치 10~20"), "Result UI did not show the item value range.")
	_expect(panel.get_displayed_item_text(2).contains("등록·정보 보상"), "Result UI showed a price for a unique item.")
	_expect(panel.get_note_text().contains("현재 회수품만 포함"), "Result UI did not explain the recovery scope.")


func _check_result_snapshot() -> void:
	var known_definition := _create_test_item(&"test_snapshot_known", "Known at return", ItemDefinition.CATEGORY_SCRAP, 10, 20)
	var unknown_definition := _create_test_item(&"test_snapshot_unknown", "Unknown at return", ItemDefinition.CATEGORY_RESIDUE, 100, 150)
	var unique_definition := _create_test_item(&"test_snapshot_unique", "Unique at return", ItemDefinition.CATEGORY_UNIQUE_ARTIFACT, 900, 900)
	var unknown := InventoryItem.from_definition(unknown_definition, false, "마력 반응 있음")
	var source: Array[InventoryItem] = [InventoryItem.from_definition(known_definition), unknown, InventoryItem.from_definition(unique_definition)]
	var result := RecoveryResult.from_recovered_inventory_items(source)
	unknown.identify()
	known_definition.display_name = "Changed after return"
	known_definition.value_min = 1000
	known_definition.value_max = 2000
	unknown_definition.category = ItemDefinition.CATEGORY_SCRAP
	unique_definition.category = ItemDefinition.CATEGORY_SCRAP
	source.clear()

	# Both getter paths must return detached copies, including item definitions.
	var exposed := result.get_recovered_inventory_items()
	exposed[1].identify()
	exposed[0].get_definition().display_name = "Changed via getter"
	exposed.clear()
	var exposed_definitions := result.get_recovered_items()
	exposed_definitions[0].value_min = 3000
	exposed_definitions[0].value_max = 4000
	exposed_definitions.clear()

	_expect(result.get_item_count() == 3, "Source or getter mutation changed snapshot membership.")
	_expect(result.get_total_value_min() == 10 and result.get_total_value_max() == 20, "Snapshot totals changed after capture.")
	_expect(result.get_unidentified_item_count() == 1, "Snapshot unidentified count changed after later identification.")
	_expect(result.get_non_monetary_reward_count() == 1, "Snapshot reward count changed after definition mutation.")
	var retained := result.get_recovered_inventory_items()
	_expect(not retained[1].is_identified(), "Snapshot exposed identification performed after return.")
	_expect(retained[1].get_risk_hint() == "마력 반응 있음", "Snapshot lost known risk information.")
	_expect(retained[1].get_definition().category == ItemDefinition.CATEGORY_RESIDUE, "Snapshot shared mutable source definitions.")
	var panel: RecoveryResultPanel = RESULT_PANEL_SCENE.instantiate()
	add_child(panel)
	panel.bind_result(result)
	_expect(panel.get_displayed_item_text(0) == "Known at return | 예상 가치 10~20", "Snapshot item display diverged from its captured totals.")
	_expect(panel.get_displayed_item_text(1).contains("가치 미확인"), "Snapshot UI leaked a later identification.")
	_expect(panel.get_summary_text().contains("10~20") and panel.get_summary_text().contains("미확인 물품 1개"), "Snapshot summary no longer matched item rows.")
	panel.queue_free()


func _create_test_item(
	id: StringName,
	display_name: String,
	category: StringName,
	value_min: int,
	value_max: int
) -> ItemDefinition:
	var item := ItemDefinition.new()
	item.stable_id = id
	item.display_name = display_name
	item.category = category
	item.weight = 1.0
	item.slot_size = 1
	item.value_min = value_min
	item.value_max = value_max
	item.sale_protected = not item.has_monetary_value()
	return item


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
