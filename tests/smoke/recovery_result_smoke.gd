extends Node

const RESULT_PANEL_SCENE := preload("res://src/ui/recovery_result_panel.tscn")

var _failures := PackedStringArray()


func _ready() -> void:
	_run_recovery_result_checks()

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
	var result_items := result.get_recovered_items()
	_expect(result.get_item_count() == 3, "Recovery result item count did not match carried items.")
	_expect(result_items.has(low_value_item), "First carried item was missing from recovery result.")
	_expect(result_items.has(high_value_item), "Second carried item was missing from recovery result.")
	_expect(result_items.has(unique_item), "Non-monetary carried item was missing from recovery result.")
	_expect(not result_items.has(dropped_item), "Dropped item was included in recovery result.")
	_expect(not result_items.has(rejected_item), "Rejected item was included in recovery result.")
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
