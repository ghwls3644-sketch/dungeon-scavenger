extends Node

const PLAYER_SCENE := preload("res://src/gameplay/player/player.tscn")
const PICKUP_SCENE := preload("res://src/gameplay/interaction/pickup_interactable.tscn")
const INVENTORY_PANEL_SCENE := preload("res://src/ui/inventory_panel.tscn")

var _failures := PackedStringArray()
var _last_rejection_reason: StringName


func _ready() -> void:
	await _run_inventory_checks()
	get_tree().paused = false

	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"inventory_system_passed")
		get_tree().quit(0)
		return

	for failure in _failures:
		GameLog.error(&"SmokeTest", &"inventory_system_failed", failure)
	get_tree().quit(1)


func _run_inventory_checks() -> void:
	var player: PlayerController = PLAYER_SCENE.instantiate()
	player.movement_speed = 0.0
	add_child(player)
	var inventory := player.get_node("Inventory") as PlayerInventory
	inventory.configure_capacity(2, 2.0, 3.0)
	inventory.item_add_rejected.connect(_on_item_add_rejected)

	var panel: InventoryPanel = INVENTORY_PANEL_SCENE.instantiate()
	add_child(panel)
	panel.bind_inventory(inventory)

	var light_item := _create_test_item(&"test_light_item", "Light test item", 1.0)
	var heavy_item := _create_test_item(&"test_heavy_item", "Heavy test item", 2.5)
	var overflow_item := _create_test_item(&"test_overflow_item", "Overflow test item", 0.5)

	await _collect_with_pickup(player, light_item, true)
	_expect(inventory.get_used_slots() == 1, "First pickup did not use one slot.")
	_expect(is_equal_approx(inventory.get_total_weight(), 1.0), "First pickup weight was incorrect.")
	_expect(inventory.get_weight_stage() == PlayerInventory.WeightStage.NORMAL, "First pickup should be normal weight.")

	await _collect_with_pickup(player, heavy_item, true)
	_expect(inventory.get_used_slots() == 2, "Second pickup did not fill the slot limit.")
	_expect(is_equal_approx(inventory.get_total_weight(), 3.5), "Combined item weight was incorrect.")
	_expect(inventory.get_weight_stage() == PlayerInventory.WeightStage.OVERLOADED, "Weight stage did not become overloaded.")
	_expect(panel.get_displayed_item_count() == 2, "Inventory UI item count did not match inventory state.")
	_expect(panel.get_summary_text().contains("슬롯 2/2"), "Inventory UI slot summary was incorrect.")
	_expect(panel.get_summary_text().contains("무게 3.5"), "Inventory UI weight summary was incorrect.")
	_expect(panel.get_summary_text().contains("과적"), "Inventory UI weight stage was incorrect.")

	await _collect_with_pickup(player, overflow_item, false)
	_expect(_last_rejection_reason == PlayerInventory.REJECT_SLOT_LIMIT, "Slot overflow did not report the slot-limit reason.")
	_expect(inventory.get_items().size() == 2, "Rejected pickup changed the inventory item count.")
	_expect(panel.get_status_text().contains("슬롯 한도"), "Inventory UI did not show the slot-limit rejection.")

	panel.open_inventory()
	_expect(get_tree().paused, "Opening the inventory did not pause the scene tree.")
	inventory.select_item(0)
	var dropped_item := inventory.drop_selected_item()
	_expect(dropped_item == light_item, "Dropping the selected item removed the wrong item.")
	_expect(inventory.get_used_slots() == 1, "Dropping did not release the selected item's slot.")
	_expect(is_equal_approx(inventory.get_total_weight(), 2.5), "Dropping did not update total weight.")
	_expect(inventory.get_weight_stage() == PlayerInventory.WeightStage.BURDENED, "Weight stage did not update after dropping.")
	_expect(panel.get_summary_text().contains("슬롯 1/2"), "UI slot summary did not update after dropping.")
	_expect(panel.get_summary_text().contains("부담"), "UI weight stage did not update after dropping.")
	panel.close_inventory()
	_expect(not get_tree().paused, "Closing the inventory did not resume the scene tree.")


func _collect_with_pickup(player: PlayerController, item: ItemDefinition, should_succeed: bool) -> void:
	var pickup: PickupInteractable = PICKUP_SCENE.instantiate()
	pickup.item_definition = item
	pickup.global_position = player.global_position + Vector2(40.0, 0.0)
	add_child(pickup)
	await get_tree().physics_frame
	await get_tree().physics_frame

	var controller := player.get_node("InteractionController") as InteractionController
	_expect(controller.interact_current() == should_succeed, "Pickup interaction result did not match capacity state.")
	await get_tree().process_frame
	_expect(is_instance_valid(pickup) != should_succeed, "Pickup lifetime did not match interaction result.")
	if is_instance_valid(pickup):
		pickup.queue_free()
		await get_tree().process_frame


func _create_test_item(id: StringName, display_name: String, weight: float) -> ItemDefinition:
	var item := ItemDefinition.new()
	item.stable_id = id
	item.display_name = display_name
	item.category = ItemDefinition.CATEGORY_SCRAP
	item.weight = weight
	item.slot_size = 1
	return item


func _on_item_add_rejected(_item: ItemDefinition, reason: StringName) -> void:
	_last_rejection_reason = reason


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
