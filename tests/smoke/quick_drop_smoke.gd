extends Node

const WORLD := preload("res://src/app/prototype_exploration.tscn")
const LIGHT := preload("res://src/data/prototype_light.tres")
const HEAVY := preload("res://src/data/prototype_heavy.tres")
const MOVE_ACTIONS := [InputActions.MOVE_LEFT, InputActions.MOVE_RIGHT, InputActions.MOVE_UP, InputActions.MOVE_DOWN]

var _failures := PackedStringArray()


func _ready() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	_check_inventory_boundary()
	var world: PrototypeExploration = WORLD.instantiate()
	add_child(world)
	await _frames(4)
	var inventory: PlayerInventory = world.get_node("Player/Inventory")
	var controller: QuickDropController = world.get_node("%QuickDropController")
	var player: PlayerController = world.get_node("Player")
	var panel: InventoryPanel = world.get_node("%InventoryPanel")
	var list: ItemList = panel.get_node("%ItemList")
	_key(KEY_G, true)
	await _frames(45)
	_expect(not controller.is_holding(), "Quick drop started before departure.")
	_expect(world.prepare_departure(_loadout()) and world.start_exploration(), "Departure failed.")
	await _frames(45)
	_expect(not controller.is_holding(), "Held key crossed departure boundary.")
	_key(KEY_G, false)
	await _walk(player, Vector2(-650, -200))
	await _walk(player, Vector2(-270, -200))
	_tap(KEY_E)
	_expect(await InteractionTestInput.wait_for_work(player), "Timed action did not finish.")
	await _frames(3)
	await _walk(player, Vector2(80, -200))
	_tap(KEY_E)
	_expect(await InteractionTestInput.wait_for_work(player), "Timed action did not finish.")
	await _frames(3)
	_expect(inventory.get_used_slots() == 2 and inventory.get_quick_drop_item() == null, "Acquisition became an explicit quick-drop selection.")
	_key(KEY_G, true)
	await _frames(45)
	_key(KEY_G, false)
	_expect(inventory.get_used_slots() == 2, "No-selection input discarded an item.")

	_tap(KEY_TAB)
	await _frames(3)
	_click_at(list.global_position + list.get_item_rect(1).get_center())
	await _frames(2)
	_expect(inventory.get_quick_drop_item() != null and inventory.get_quick_drop_item().get_definition() == HEAVY, "Click on already highlighted item did not select quick-drop target.")
	_expect(panel.get_node("%QuickDropHint").text.contains(HEAVY.display_name), "Bag does not display target.")
	_expect(Rect2(0, 0, 1152, 648).encloses(panel.get_global_rect()), "Bag hint exceeds viewport.")
	await _capture("quick-drop-bag.png")
	_tap(KEY_TAB)
	await _frames(2)
	_key(KEY_G, true)
	await _frames(10)
	_expect(controller.is_holding() and controller.get_progress() > 0.0 and inventory.get_used_slots() == 2, "Short hold discarded early or did not progress.")
	await _capture("quick-drop-holding.png")
	_key(KEY_G, false)
	await _frames(45)
	_expect(inventory.get_used_slots() == 2 and not controller.is_holding(), "Release failed to cancel.")

	var position_before := player.position
	Input.action_press(InputActions.MOVE_LEFT)
	_key(KEY_G, true)
	await _frames(45)
	Input.action_release(InputActions.MOVE_LEFT)
	_expect(player.position.distance_to(position_before) > 100.0 and not get_tree().paused, "Quick drop paused movement.")
	_expect(inventory.get_used_slots() == 1 and inventory.get_items()[0] == LIGHT, "Quick drop removed the wrong item.")
	_expect(is_equal_approx(inventory.get_total_weight(), LIGHT.weight) and inventory.get_weight_stage() == PlayerInventory.WeightStage.NORMAL, "Drop did not refresh load.")
	_expect(world.get_node("%ChoiceStatus").text.contains(HEAVY.display_name), "Drop feedback missing.")
	await _capture("quick-drop-done.png")
	inventory.try_add_item(HEAVY)
	inventory.select_item(0)
	_key(KEY_G, true, true)
	await _frames(80)
	_expect(inventory.get_used_slots() == 2, "Held key or repeat discarded a second item.")
	_key(KEY_G, false)

	# Menus cancel immediately, including a same-frame open/close.
	for menu_key in [KEY_TAB, KEY_M]:
		_key(KEY_G, true)
		await _frames(10)
		_tap(menu_key)
		await _frames(3)
		_expect(get_tree().paused and not controller.is_holding(), "Menu did not cancel hold.")
		await _frames(45)
		_tap(menu_key)
		await _frames(45)
		_expect(inventory.get_used_slots() == 2, "Menu close resumed a held drop.")
		_key(KEY_G, false)
		_tap(menu_key)
		_key(KEY_G, true)
		await _frames(3)
		_tap(menu_key)
		await _frames(45)
		_expect(inventory.get_used_slots() == 2, "Key first pressed in a menu started after closing.")
		_key(KEY_G, false)
	_key(KEY_G, true)
	await _frames(8)
	panel.open_inventory()
	panel.close_inventory()
	await _frames(45)
	_expect(inventory.get_used_slots() == 2, "Same-frame menu visit retained hold.")
	_key(KEY_G, false)

	_key(KEY_G, true)
	await _frames(8)
	get_tree().paused = true
	await _frames(45)
	get_tree().paused = false
	await _frames(45)
	_expect(inventory.get_used_slots() == 2 and not controller.is_holding(), "Pause resumed a pending drop.")
	_key(KEY_G, false)
	_key(KEY_G, true)
	await _frames(8)
	controller.notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
	await _frames(45)
	_expect(inventory.get_used_slots() == 2, "Focus loss retained hold.")
	_key(KEY_G, false)

	_key(KEY_G, true)
	await _frames(8)
	inventory.select_item(1)
	await _frames(45)
	_expect(inventory.get_used_slots() == 2, "Target switch discarded an unintended item.")
	_key(KEY_G, false)
	for invalid_duration in [0.0, -0.1, NAN, INF]:
		controller.hold_duration = invalid_duration
		_key(KEY_G, true)
		await _frames(45)
		_key(KEY_G, false)
		_expect(inventory.get_used_slots() == 2, "Invalid hold duration discarded an item.")
	controller.hold_duration = 0.6

	# Re-check protection at completion, not just when a hold starts.
	var protected_definition := LIGHT.duplicate(true) as ItemDefinition
	inventory.take_all_inventory_items()
	inventory.try_add_item(protected_definition, false)
	inventory.select_item(0)
	_key(KEY_G, true)
	await _frames(8)
	protected_definition.sale_protected = true
	await _frames(45)
	_expect(inventory.get_used_slots() == 1 and not controller.is_holding(), "Protection change during hold was bypassed.")
	_key(KEY_G, false)
	_expect(not world.get_node("%QuickDropStatus").text.contains("폐품"), "Unidentified category leaked to quick-drop HUD.")

	# A normal drop consumes its selected target; automatic neighbor highlighting is not a new selection.
	inventory.take_all_inventory_items()
	inventory.try_add_item(LIGHT)
	inventory.try_add_item(HEAVY)
	inventory.select_item(1)
	_tap(KEY_TAB)
	await _frames(2)
	_click_at(panel.get_node("%DropButton").get_global_rect().get_center())
	await _frames(2)
	var dialog: ConfirmationDialog = panel.get_node("%DropConfirmation")
	_expect(dialog.visible and inventory.get_used_slots() == 2, "Normal drop lost confirmation.")
	dialog.get_cancel_button().pressed.emit()
	dialog.hide()
	_expect(inventory.get_used_slots() == 2, "Normal drop cancellation removed item.")
	panel.close_inventory()
	inventory.select_item(1)
	_key(KEY_G, true)
	await _frames(8)
	_expect(inventory.drop_selected_item() == HEAVY, "Normal drop could not remove held target.")
	await _frames(45)
	_expect(inventory.get_used_slots() == 1 and inventory.get_quick_drop_item() == null, "Removed target shifted to neighbor.")
	_key(KEY_G, false)
	inventory.select_item(0)
	_key(KEY_G, true)
	await _frames(8)
	_expect(world.get_node("%ExplorationRun").complete_safe_return(), "Return failed during hold.")
	await _frames(45)
	var recovered: RecoveryResult = world.get_node("%ExplorationRun").get_outcome().get_recovery_result()
	_expect(recovered.get_item_count() == 1 and recovered.get_recovered_items()[0].stable_id == LIGHT.stable_id, "Return included dropped item or lost pending item.")
	_expect(inventory.get_quick_drop_item() == null and not controller.is_holding(), "Return retained selection or input.")
	world.queue_free()
	await _frames(3)
	# The old G press remains down through a fresh departure.
	world = WORLD.instantiate()
	add_child(world)
	await _frames(3)
	_expect(world.prepare_departure(_loadout()) and world.start_exploration(), "Second departure failed.")
	inventory = world.get_node("Player/Inventory")
	controller = world.get_node("%QuickDropController")
	_expect(inventory.get_quick_drop_item() == null, "Selection leaked to a fresh exploration.")
	inventory.try_add_item(LIGHT)
	inventory.select_item(0)
	await _frames(45)
	_expect(inventory.get_used_slots() == 1, "Old key press discarded on new departure.")
	_key(KEY_G, false)
	_key(KEY_G, true)
	await _frames(8)
	world.get_node("%ExplorationRun").complete_failure()
	await _frames(45)
	_expect(world.get_node("%ExplorationRun").get_outcome().get_lost_item_count() == 1 and not controller.is_holding(), "Failure raced with pending drop.")
	_key(KEY_G, false)
	world.queue_free()
	await _frames(3)
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"quick_drop_passed")
	get_tree().quit(0 if _failures.is_empty() else 1)


func _check_inventory_boundary() -> void:
	var inventory := PlayerInventory.new()
	inventory.configure_capacity(16, 20.0, 40.0)
	inventory.try_add_item(LIGHT, false, "first copy")
	inventory.select_item(0)
	var first := inventory.get_quick_drop_item()
	inventory.try_add_item(LIGHT, false, "second copy")
	_expect(inventory.get_quick_drop_item() == first, "Pickup replaced explicit target.")
	_expect(inventory.drop_quick_drop_item(first) == LIGHT and inventory.get_inventory_items()[0].get_risk_hint() == "second copy", "Duplicate definition lost wrong carried instance.")
	_expect(inventory.get_quick_drop_item() == null and inventory.drop_quick_drop_item(first) == null, "Consumed target repeated.")
	inventory.select_item(0)
	for category in [ItemDefinition.CATEGORY_UNIQUE_ARTIFACT, ItemDefinition.CATEGORY_CORE_RECORD, ItemDefinition.CATEGORY_RESIDUE]:
		var definition := LIGHT.duplicate(true) as ItemDefinition
		definition.category = category
		definition.sale_protected = category == ItemDefinition.CATEGORY_RESIDUE
		inventory.try_add_item(definition, false)
		inventory.select_item(inventory.get_inventory_items().size() - 1)
		var protected_item := inventory.get_inventory_items().back() as InventoryItem
		_expect(inventory.get_quick_drop_item() == null and inventory.drop_quick_drop_item(protected_item) == null and inventory.drop_selected_item() == null, "Unidentified protected item discarded or fell back to another item.")
	inventory.take_all_inventory_items()
	_expect(inventory.get_quick_drop_item() == null, "Clearing inventory retained quick selection.")
	inventory.try_add_item(LIGHT)
	inventory.try_add_item(HEAVY)
	inventory.select_item(1)
	var target := inventory.get_quick_drop_item()
	inventory.try_add_item(LIGHT)
	_expect(not inventory.select_item(-1) and inventory.get_quick_drop_item() == target, "Invalid selection changed target.")
	inventory.drop_selected_item()
	_expect(inventory.get_quick_drop_item() == target and inventory.drop_quick_drop_item(target) == HEAVY, "Unrelated deletion invalidated correct target.")
	inventory.free()


func _key(key: Key, pressed: bool, echo := false) -> void:
	var event := InputEventKey.new()
	event.keycode = key
	event.physical_keycode = key
	event.pressed = pressed
	event.echo = echo
	Input.parse_input_event(event)


func _tap(key: Key) -> void:
	_key(key, true)
	_key(key, false)


func _click_at(position: Vector2) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = position
	event.pressed = true
	get_viewport().push_input(event)
	event = event.duplicate() as InputEventMouseButton
	event.pressed = false
	get_viewport().push_input(event)


func _walk(player: PlayerController, destination: Vector2) -> void:
	for frame in range(720):
		var offset := destination - player.global_position
		for action in MOVE_ACTIONS:
			Input.action_release(action)
		if offset.length() < 7.0:
			await _frames(3)
			return
		if absf(offset.x) > 3.0:
			Input.action_press(InputActions.MOVE_RIGHT if offset.x > 0.0 else InputActions.MOVE_LEFT)
		if absf(offset.y) > 3.0:
			Input.action_press(InputActions.MOVE_DOWN if offset.y > 0.0 else InputActions.MOVE_UP)
		await get_tree().physics_frame
	for action in MOVE_ACTIONS:
		Input.action_release(action)
	_expect(false, "Route blocked.")


func _loadout() -> ExpeditionLoadout:
	var loadout := ExpeditionLoadout.new()
	loadout.slot_capacity = 2
	loadout.burden_weight = 2.5
	loadout.overload_weight = 4.0
	loadout.charge_capacity = 3
	loadout.starting_charge = 3
	return loadout


func _capture(filename: String) -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--quick-drop-render-directory="):
			var directory := argument.trim_prefix("--quick-drop-render-directory=")
			DirAccess.make_dir_recursive_absolute(directory)
			await RenderingServer.frame_post_draw
			_expect(get_viewport().get_texture().get_image().save_png(directory.path_join(filename)) == OK, "Capture failed.")


func _frames(count: int) -> void:
	for index in range(count):
		await get_tree().physics_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		GameLog.error(&"SmokeTest", &"quick_drop_failed", message)
