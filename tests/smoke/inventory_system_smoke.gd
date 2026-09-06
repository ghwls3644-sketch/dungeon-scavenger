extends Node

const PLAYER_SCENE := preload("res://src/gameplay/player/player.tscn")
const PICKUP_SCENE := preload("res://src/gameplay/interaction/pickup_interactable.tscn")
const INVENTORY_PANEL_SCENE := preload("res://src/ui/inventory_panel.tscn")

var _failures := PackedStringArray()
var _last_rejection_reason: StringName


func _ready() -> void:
	await _run_inventory_checks()
	await _check_protected_drops()
	await _check_selection_details()
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

	var light_item := _create_test_item(&"test_light_item", "Light test item", 1.0, 10, 20)
	var heavy_item := _create_test_item(&"test_heavy_item", "Heavy test item", 2.5, 30, 40)
	var overflow_item := _create_test_item(&"test_overflow_item", "Overflow test item", 0.5, 100, 200)

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
	_expect(panel.get_displayed_item_text(0).contains("예상 가치 10~20"), "Inventory UI did not show the item value range.")

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
	await _check_keyboard_close(panel)
	panel.queue_free()
	player.queue_free()
	await get_tree().process_frame


func _check_keyboard_close(panel: InventoryPanel) -> void:
	for control_path in ["%ItemList", "%DropButton", "%CloseButton"]:
		_send_inventory_key()
		await get_tree().process_frame
		_expect(panel.visible and get_tree().paused, "Inventory key did not open and pause.")
		(panel.get_node(control_path) as Control).grab_focus()
		_send_inventory_key()
		await get_tree().process_frame
		_expect(not panel.visible, "Tab was consumed by focused inventory control: %s." % control_path)
		_expect(not get_tree().paused, "Keyboard close did not restore running time.")
		panel.close_inventory()

	get_tree().paused = true
	panel.open_inventory()
	(panel.get_node("%ItemList") as Control).grab_focus()
	_send_inventory_key()
	await get_tree().process_frame
	_expect(not panel.visible and get_tree().paused, "Keyboard close lost a pre-existing pause.")
	panel.close_inventory()
	get_tree().paused = false


func _send_inventory_key() -> void:
	var event := InputEventKey.new()
	event.keycode = KEY_TAB
	event.physical_keycode = KEY_TAB
	event.pressed = true
	get_viewport().push_input(event)
	var released := event.duplicate() as InputEventKey
	released.pressed = false
	get_viewport().push_input(released)


func _check_protected_drops() -> void:
	var inventory := PlayerInventory.new()
	add_child(inventory)
	inventory.configure_capacity(3, 4.0, 7.0)
	var panel: InventoryPanel = INVENTORY_PANEL_SCENE.instantiate()
	add_child(panel)
	panel.bind_inventory(inventory)
	var rejections: Array[StringName] = []
	inventory.item_drop_rejected.connect(func(reason: StringName): rejections.append(reason))
	var dropped: Array[ItemDefinition] = []
	inventory.item_dropped.connect(func(item: ItemDefinition): dropped.append(item))

	for category in [ItemDefinition.CATEGORY_UNIQUE_ARTIFACT, ItemDefinition.CATEGORY_CORE_RECORD, ItemDefinition.CATEGORY_SCRAP]:
		for identified in [false, true]:
			var item := _create_test_item(&"test_protected_drop", "Sealed test item", 1.0, 100, 150)
			item.category = category
			# Unique categories must be protected even without the explicit flag.
			item.sale_protected = category == ItemDefinition.CATEGORY_SCRAP
			_expect(inventory.try_add_item(item, identified), "Protected item was rejected at collection.")
			panel.open_inventory()
			(panel.get_node("%DropButton") as Button).pressed.emit()
			var confirmation := panel.get_node("%DropConfirmation") as ConfirmationDialog
			_expect(confirmation.visible, "Ordinary drop did not request confirmation.")
			_expect(inventory.get_used_slots() == 1, "Requesting confirmation already removed an item.")
			confirmation.confirmed.emit()
			confirmation.hide()
			_expect(inventory.get_items().has(item), "Confirmation bypassed protection.")
			_expect(inventory.get_used_slots() == 1 and is_equal_approx(inventory.get_total_weight(), 1.0), "Rejected drop changed capacity or weight.")
			_expect(inventory.get_selected_index() == 0, "Rejected drop changed selection.")
			_expect(panel.get_status_text() == "이 물품은 버릴 수 없습니다.", "Protected drop did not show a neutral rejection.")
			if not identified:
				var text := panel.get_displayed_item_text(0)
				_expect(text.contains("보호 여부 미확인") and not text.contains("100~150"), "Drop rejection revealed hidden item information.")
			panel.close_inventory()
			inventory.take_all_inventory_items()

	_expect(rejections.size() == 6 and dropped.is_empty(), "Protected drops emitted success or missed a rejection.")
	for reason in rejections:
		_expect(reason == PlayerInventory.REJECT_PROTECTED_ITEM, "Protected drop reported the wrong reason.")
	var ordinary := _create_test_item(&"test_ordinary_drop", "Ordinary test item", 1.0, 10, 20)
	_expect(inventory.try_add_item(ordinary, false), "Ordinary unidentified item was rejected.")
	panel.open_inventory()
	(panel.get_node("%DropButton") as Button).pressed.emit()
	var confirmation := panel.get_node("%DropConfirmation") as ConfirmationDialog
	confirmation.hide()
	_expect(inventory.get_items().has(ordinary), "Cancelling a drop removed the item.")
	(panel.get_node("%DropButton") as Button).pressed.emit()
	confirmation.confirmed.emit()
	confirmation.hide()
	_expect(inventory.get_items().is_empty() and dropped.size() == 1, "Confirmation did not drop an ordinary unidentified item.")
	panel.close_inventory()
	panel.queue_free()
	inventory.queue_free()
	await get_tree().process_frame


func _check_selection_details() -> void:
	var inventory := PlayerInventory.new()
	add_child(inventory)
	inventory.configure_capacity(3, 4.0, 7.0)
	var panel: InventoryPanel = INVENTORY_PANEL_SCENE.instantiate()
	add_child(panel)
	panel.bind_inventory(inventory)
	var known := _create_test_item(&"test_details_known", "Known detail item", 1.0, 10, 20)
	var unknown := _create_test_item(&"test_details_unknown", "Unknown detail item", 2.5, 1234, 5678)
	unknown.category = ItemDefinition.CATEGORY_RESIDUE
	unknown.sale_protected = true
	var long_hint := "시험용 긴 위험 안내입니다. ".repeat(40)
	inventory.try_add_item(known)
	inventory.try_add_item(unknown, false, long_hint)
	panel.open_inventory()
	for i in range(5):
		await get_tree().process_frame
	var details := panel.get_selection_details_text()
	_expect(details.contains(unknown.display_name) and details.contains(long_hint), "Selected details lost the full name or long risk hint.")
	_expect(details.contains("무게 2.5") and details.contains("가치 미확인") and details.contains("보호 여부 미확인"), "Selected unknown details omitted a public field.")
	_expect(not details.contains("잔재") and not details.contains("1234") and not details.contains("5678"), "Selected details exposed the unknown category or value.")
	var details_view := panel.get_node("%SelectionDetails") as RichTextLabel
	_expect(details_view.scroll_active and details_view.get_content_height() > details_view.size.y, "Long details cannot be read by scrolling.")
	_expect(panel.get_global_rect().size.y <= 534.0, "Long details expanded the inventory beyond its usable height.")
	inventory.select_item(0)
	details = panel.get_selection_details_text()
	_expect(details.contains(known.display_name) and details.contains("예상 가치 10~20") and details.contains("일반"), "Selection did not refresh known value and protection.")
	_expect(not details.contains(long_hint), "Selection retained the previous item's risk information.")
	inventory.take_all_inventory_items()
	_expect(not panel.get_selection_details_text().contains(known.display_name), "Empty inventory retained stale selected details.")
	panel.close_inventory()
	panel.queue_free()
	inventory.queue_free()
	await get_tree().process_frame


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


func _create_test_item(
	id: StringName,
	display_name: String,
	weight: float,
	value_min: int,
	value_max: int
) -> ItemDefinition:
	var item := ItemDefinition.new()
	item.stable_id = id
	item.display_name = display_name
	item.category = ItemDefinition.CATEGORY_SCRAP
	item.weight = weight
	item.slot_size = 1
	item.value_min = value_min
	item.value_max = value_max
	return item


func _on_item_add_rejected(_item: ItemDefinition, reason: StringName) -> void:
	_last_rejection_reason = reason


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
