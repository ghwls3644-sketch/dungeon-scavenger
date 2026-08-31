extends Node

const TEST_SCENE := preload("res://tests/fixtures/inspection_unidentified_test_space.tscn")

var _failures := PackedStringArray()


func _ready() -> void:
	await _run_checks()

	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"inspection_unidentified_passed")
		get_tree().quit(0)
		return

	for failure in _failures:
		GameLog.error(&"SmokeTest", &"inspection_unidentified_failed", failure)
	get_tree().quit(1)


func _run_checks() -> void:
	var space: Node2D = TEST_SCENE.instantiate()
	add_child(space)
	await get_tree().physics_frame

	var player := space.get_node("Player") as PlayerController
	player.movement_speed = 0.0
	var inventory := player.get_node("Inventory") as PlayerInventory
	var controller := player.get_node("InteractionController") as InteractionController
	var detector := player.get_node("InteractionDetector") as InteractionDetector
	var inventory_panel := space.get_node("Overlay/InventoryPanel") as InventoryPanel
	var outcome_panel := space.get_node("Overlay/ExplorationOutcomePanel") as ExplorationOutcomePanel
	var unknown_scrap := space.get_node("UnknownScrapPickup") as InspectablePickupInteractable
	var unknown_residue := space.get_node("UnknownResiduePickup") as InspectablePickupInteractable
	var exploration_run := space.get_node("ExplorationRun") as ExplorationRun

	await _inspect_and_collect(player, detector, controller, unknown_scrap, "특이 위험 없음")
	_expect(inventory.get_items().size() == 1, "First inspected item was not collected.")
	_expect(
		not inventory.get_inventory_items()[0].is_identified(),
		"First inspected item did not retain its unidentified state."
	)
	var first_text := inventory_panel.get_displayed_item_text(0)
	_expect(first_text.contains("봉인된 금속 상자"), "Inventory hid the visible appearance name.")
	_expect(first_text.contains("무게 1.5"), "Inventory hid the visible weight.")
	_expect(first_text.contains("미확인 물품"), "Inventory did not label the item as unidentified.")
	_expect(first_text.contains("가치 미확인"), "Inventory did not hide the value.")
	_expect(not first_text.contains("폐품"), "Inventory leaked the underlying scrap category.")
	_expect(not first_text.contains("15~25"), "Inventory leaked the underlying value range.")

	await _inspect_and_collect(player, detector, controller, unknown_residue, "마력 반응 있음")
	_expect(inventory.get_items().size() == 2, "Second inspected item was not collected.")
	_expect(
		not inventory.get_inventory_items()[1].is_identified(),
		"Second inspected item did not retain its unidentified state."
	)
	var second_text := inventory_panel.get_displayed_item_text(1)
	_expect(second_text.contains("맥동하는 유리 덩어리"), "Inventory hid the second appearance name.")
	_expect(second_text.contains("무게 2.0"), "Inventory hid the second visible weight.")
	_expect(not second_text.contains("잔재"), "Inventory leaked the underlying residue category.")
	_expect(not second_text.contains("90~120"), "Inventory leaked the second value range.")

	var known_item := ItemDefinition.new()
	known_item.stable_id = &"test_known_value"
	known_item.display_name = "확인된 시험 폐품"
	known_item.category = ItemDefinition.CATEGORY_SCRAP
	known_item.weight = 0.5
	known_item.slot_size = 1
	known_item.value_min = 30
	known_item.value_max = 40
	_expect(inventory.try_add_item(known_item), "Known comparison item was rejected.")

	_expect(exploration_run.complete_safe_return(), "Safe return rejected the unidentified items.")
	var outcome := exploration_run.get_outcome()
	var result := outcome.get_recovery_result()
	_expect(outcome.is_safe_return(), "Unidentified-item run did not end in safe return.")
	_expect(result.get_item_count() == 3, "Recovery result lost a carried item.")
	_expect(result.get_unidentified_item_count() == 2, "Recovery result unidentified count was wrong.")
	_expect(result.get_total_value_min() == 30, "Recovery result minimum did not include only known value.")
	_expect(result.get_total_value_max() == 40, "Recovery result maximum did not include only known value.")
	_expect(outcome_panel.get_recovery_summary_text().contains("미확인 물품 2개"), "Result UI omitted the unidentified count.")
	_expect(outcome_panel.get_recovery_summary_text().contains("30~40"), "Result UI did not preserve known value.")
	_expect(outcome_panel.get_recovery_displayed_item_text(0).contains("가치 미확인"), "Result UI leaked the first value.")
	_expect(outcome_panel.get_recovery_displayed_item_text(1).contains("가치 미확인"), "Result UI leaked the second value.")

	space.queue_free()
	await get_tree().process_frame


func _inspect_and_collect(
	player: PlayerController,
	detector: InteractionDetector,
	controller: InteractionController,
	target: InspectablePickupInteractable,
	expected_risk_hint: String
) -> void:
	player.global_position = target.global_position
	await get_tree().physics_frame
	await get_tree().physics_frame
	detector.refresh_current_interactable()
	_expect(detector.get_current_interactable() == target, "Detector did not select the inspectable pickup.")
	_expect(controller.get_current_prompt() == "조사하기", "First prompt was not inspection.")
	_expect(controller.interact_current(), "Inspection interaction failed.")
	_expect(target.is_inspected(), "Inspection did not update the target state.")
	_expect(target.is_inside_tree(), "Inspection collected the item too early.")
	_expect(target.get_inspection_text().contains(expected_risk_hint), "Inspection did not expose the risk hint.")
	_expect(controller.get_current_prompt() == "회수하기", "Prompt did not change from inspection to collection.")
	_expect(controller.interact_current(), "Collection after inspection failed.")
	await get_tree().process_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
