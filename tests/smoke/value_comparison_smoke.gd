extends Node

const WORLD := preload("res://src/app/prototype_exploration.tscn")
const PANEL := preload("res://src/ui/inventory_panel.tscn")
const LIGHT := preload("res://src/data/prototype_light.tres")
const HEAVY := preload("res://src/data/prototype_heavy.tres")
const ECONOMY := preload("res://src/data/prototype_economy.tres")
const MOVES := [InputActions.MOVE_LEFT, InputActions.MOVE_RIGHT, InputActions.MOVE_UP, InputActions.MOVE_DOWN]

var _failures := PackedStringArray()


func _ready() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	_check_calculations()
	await _check_exploration()
	_release()
	get_tree().paused = false
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"value_comparison_passed")
	get_tree().quit(0 if _failures.is_empty() else 1)


func _check_calculations() -> void:
	for sample in [[2.5, 80, 110, 32.0, 44.0], [0.5, 3, 7, 6.0, 14.0], [3.0, 10, 10, 10.0 / 3.0, 10.0 / 3.0], [1.0, 0, 0, 0.0, 0.0]]:
		var item := _item(sample[0], sample[1], sample[2])
		var result := ItemValueComparison.from_item(item)
		_expect(result.status == ItemValueComparison.Status.AVAILABLE, "Valid comparison unavailable.")
		_expect(is_equal_approx(result.minimum, sample[3]) and is_equal_approx(result.maximum, sample[4]), "Weight/value division incorrect.")
		_expect(item.get_definition().value_min == sample[1] and item.get_definition().value_max == sample[2] and item.is_identified(), "Comparison mutated item values/state.")
	_expect(ItemValueText.format_weight_value(_item(3.0, 10, 10)) == "무게 1당 약 3.3", "Approximate equal-value label incorrect.")
	_expect(ItemValueText.format_weight_value(_item(2.5, 80, 110)) == "무게 1당 약 32.0~44.0", "Estimated range lost an endpoint.")
	_expect(ItemValueComparison.from_item(null).status == ItemValueComparison.Status.UNAVAILABLE, "Null item produced a comparison.")
	_expect(ItemValueComparison.from_item(InventoryItem.new()).status == ItemValueComparison.Status.UNAVAILABLE, "Missing definition produced a comparison.")
	for weight in [-1.0, NAN, INF]:
		var result := ItemValueComparison.from_item(_item(weight, 10, 20))
		_expect(result.status == ItemValueComparison.Status.UNAVAILABLE and result.minimum == 0.0 and result.maximum == 0.0, "Invalid/overflowing weight %s exposed status %s: %s~%s." % [weight, result.status, result.minimum, result.maximum])
	_expect(ItemValueComparison.from_item(_item(1.0e-300, 9000000000000000000, 9000000000000000000)).status == ItemValueComparison.Status.UNAVAILABLE, "Overflowing ratio produced a comparison.")
	_expect(ItemValueComparison.from_item(_item(1.0, 20, 10)).status == ItemValueComparison.Status.UNAVAILABLE, "Invalid value range accepted.")
	_expect(ItemValueText.format_weight_value(_item(0.0, 10, 20)) == "무게 0 · 비교 제외", "Zero weight treated as zero or infinite value.")
	for category in ItemDefinition.CATEGORY_IDS:
		var item := _item(0.5, 6543, 8765)
		item.get_definition().category = category
		item.get_definition().sale_protected = true
		var hidden := InventoryItem.from_definition(item.get_definition(), false, "알려진 위험 징후")
		var hidden_result := ItemValueComparison.from_item(hidden)
		_expect(hidden_result.status == ItemValueComparison.Status.UNIDENTIFIED and hidden_result.minimum == 0.0 and hidden_result.maximum == 0.0, "Unknown comparison disclosed hidden value/category.")
		_expect(ItemValueText.format_weight_value(hidden) == "무게 대비 가치 미확인", "Unknown categories produce distinguishable comparison text.")
		var known := ItemValueComparison.from_item(item)
		var monetary: bool = category in [ItemDefinition.CATEGORY_SCRAP, ItemDefinition.CATEGORY_RESIDUE]
		_expect(known.status == (ItemValueComparison.Status.AVAILABLE if monetary else ItemValueComparison.Status.NON_MONETARY), "Protection/category confused monetary comparison.")
		if not monetary:
			_expect(known.minimum == 0.0 and known.maximum == 0.0 and ItemValueText.format_weight_value(item) == "금전 비교 제외", "Registration reward acquired monetary weight value.")


func _new_world() -> PrototypeExploration:
	var world := WORLD.instantiate() as PrototypeExploration
	add_child(world)
	await _frames(3)
	var loadout := ExpeditionLoadout.new()
	loadout.slot_capacity = 3
	loadout.burden_weight = 2.5
	loadout.overload_weight = 4.0
	loadout.charge_capacity = 3
	loadout.starting_charge = 3
	_expect(world.prepare_departure(loadout) and world.start_exploration(), "Departure failed.")
	await _frames(4)
	return world


func _check_exploration() -> void:
	var legacy := PANEL.instantiate() as InventoryPanel
	add_child(legacy)
	_expect(not legacy.show_value_comparison and not legacy.get_node("%ComparisonHint").visible and legacy.get_node("%ItemList").max_text_lines == 1, "G1 default display changed.")
	legacy.queue_free()
	await _frames(2)
	var world := await _new_world()
	var player: PlayerController = world.get_node("Player")
	var inventory: PlayerInventory = player.get_node("Inventory")
	var panel: InventoryPanel = world.get_node("%InventoryPanel")
	var list: ItemList = panel.get_node("%ItemList")
	await _walk(player, Vector2(-650, -200))
	await _walk(player, Vector2(-270, -200))
	_tap(KEY_E)
	await _frames(3)
	await _walk(player, Vector2(80, -200))
	_tap(KEY_E)
	await _frames(3)
	_expect(inventory.get_items() == [LIGHT, HEAVY], "Actual pickup setup failed.")
	var snapshot := _snapshot(inventory)
	_tap(KEY_TAB)
	await _frames(5)
	_expect(panel.visible and get_tree().paused and snapshot == _snapshot(inventory), "Opening comparison mutated order/selection/value/state.")
	_expect(inventory.get_quick_drop_item() == null, "Viewing comparison selected a quick-drop item.")
	_expect(panel.get_displayed_item_text(0).contains("무게 1당 약 10.0~20.0") and panel.get_displayed_item_text(1).contains("무게 1당 약 15.0~20.0"), "Actual items missing comparable ratios.")
	_expect(panel.get_displayed_item_text(0).contains("예상 가치 10~20") and panel.get_displayed_item_text(1).contains("예상 가치 30~40"), "Comparison replaced full expected values.")
	_check_layout(panel)
	await _capture("value-comparison-known.png")
	var player_before := player.position
	var golem: Node2D = world.get_node("%BrokenGuardGolem")
	var golem_before := golem.position
	Input.action_press(InputActions.MOVE_RIGHT)
	await _frames(20)
	_release()
	_expect(player.position == player_before and golem.position == golem_before, "Comparison menu did not pause the world.")
	list.grab_focus()
	_tap(KEY_UP)
	await _frames(3)
	_expect(inventory.get_selected_index() == 0 and inventory.get_quick_drop_item() == inventory.get_inventory_items()[0], "Keyboard comparison selected wrong physical item.")
	_expect(panel.get_selection_details_text().contains("무게 1당 약 10.0~20.0"), "Selection details did not follow list selection.")
	_tap(KEY_TAB)
	await _frames(3)
	_key(KEY_G, true)
	await _frames(45)
	_key(KEY_G, false)
	_expect(inventory.get_items() == [HEAVY], "Comparison changed quick-drop target identity.")
	_tap(KEY_TAB)
	await _frames(4)
	_expect(panel.get_displayed_item_count() == 1 and panel.get_displayed_item_text(0).contains("15.0~20.0"), "Reopening retained discarded item or stale comparison.")
	panel.get_node("%DropButton").pressed.emit()
	var confirmation: ConfirmationDialog = panel.get_node("%DropConfirmation")
	_expect(confirmation.visible and inventory.get_used_slots() == 1, "Ordinary drop skipped confirmation.")
	confirmation.hide()
	_expect(inventory.get_used_slots() == 1, "Cancel discarded comparison item.")
	panel.get_node("%DropButton").pressed.emit()
	confirmation.confirmed.emit()
	confirmation.hide()
	await _frames(3)
	_expect(panel.get_displayed_item_count() == 0 and not panel.get_selection_details_text().contains("무게 1당"), "Empty inventory retained comparison.")
	_tap(KEY_TAB)
	await _frames(2)
	# Test-only payloads exercise information boundaries without adding game content.
	var hidden := _item(0.5, 6543, 8765)
	hidden.get_definition().category = ItemDefinition.CATEGORY_UNIQUE_ARTIFACT
	var hidden_item := InventoryItem.from_definition(hidden.get_definition(), false, "표면에서 진동이 느껴집니다. ".repeat(12))
	var record := _item(1.0, 9876, 9999)
	record.get_definition().category = ItemDefinition.CATEGORY_CORE_RECORD
	record.get_definition().display_name = "시험용 등록 기록물"
	var zero := _item(0.0, 10, 20)
	zero.get_definition().display_name = "시험용 무게 0 물품"
	for item in [hidden_item, record, zero]:
		_expect(inventory.try_add_inventory_item(item), "Boundary payload rejected.")
	_tap(KEY_TAB)
	await _frames(4)
	_click(list.global_position + list.get_item_rect(0).get_center())
	await _frames(3)
	var hidden_text := panel.get_displayed_item_text(0) + panel.get_selection_details_text() + list.get_item_tooltip(0)
	_expect(hidden_text.contains("무게 대비 가치 미확인") and hidden_text.contains("보호 여부 미확인") and hidden_text.contains("표면에서 진동"), "Unknown item lost allowed public information.")
	for secret in ["6543", "8765", "13086", "17530", "고유 유물", "금전 비교 제외"]:
		_expect(not hidden_text.contains(secret), "Unknown row/details/tooltip leaked: %s" % secret)
	_expect(panel.get_displayed_item_text(1).contains("등록·정보 보상") and panel.get_displayed_item_text(1).contains("금전 비교 제외"), "Record shown as currency.")
	_expect(panel.get_displayed_item_text(2).contains("무게 0 · 비교 제외"), "Zero-weight row assigned a ratio.")
	_expect(inventory.get_quick_drop_item() == null, "Unknown protected item became quick-drop target.")
	panel.get_node("%DropButton").pressed.emit()
	confirmation.confirmed.emit()
	confirmation.hide()
	_expect(inventory.get_used_slots() == 3 and panel.get_status_text() == "이 물품은 버릴 수 없습니다.", "Comparison bypassed protected drop or disclosed category.")
	_check_layout(panel)
	await _capture("value-comparison-unknown.png")
	var details: RichTextLabel = panel.get_node("%SelectionDetails")
	_expect(details.scroll_active and details.get_content_height() > details.size.y, "Long risk details cannot scroll.")
	# Identification remains an owning-system action, simulated only in this test.
	hidden_item.identify()
	inventory.inventory_changed.emit()
	await _frames(3)
	_expect(panel.get_displayed_item_text(0).contains("금전 비교 제외") and panel.get_selection_details_text().contains("고유 유물"), "Identified comparison did not refresh.")
	for window_size in [Vector2i(1600, 900), Vector2i(1152, 648)]:
		get_tree().root.size = window_size
		await _frames(5)
		_check_layout(panel)
		if window_size.x == 1600:
			await _capture("value-comparison-wide.png")
	world.get_node("%ExplorationRun").complete_failure()
	await _frames(4)
	_expect(not panel.visible and not get_tree().paused, "Failure retained comparison menu/pause.")
	world.queue_free()
	await _frames(3)
	var fresh := await _new_world()
	var fresh_panel: InventoryPanel = fresh.get_node("%InventoryPanel")
	_tap(KEY_TAB)
	await _frames(3)
	_expect(fresh_panel.get_displayed_item_count() == 0 and not fresh_panel.get_selection_details_text().contains("무게 1당"), "New visit retained old comparison.")
	await _capture("value-comparison-empty.png")
	_tap(KEY_TAB)
	await _frames(2)
	_tap(KEY_E)
	await _frames(3)
	_expect(not fresh_panel.visible and not get_tree().paused, "Safe return retained menu/pause.")
	fresh.queue_free()
	await _frames(3)


func _check_layout(panel: InventoryPanel) -> void:
	_expect(get_viewport().get_visible_rect().encloses(panel.get_global_rect()), "Comparison panel extends outside viewport.")
	var list: ItemList = panel.get_node("%ItemList")
	var details: Control = panel.get_node("%SelectionDetails")
	_expect(not list.get_global_rect().intersects(details.get_global_rect()), "Comparison rows overlap details.")
	var font := list.get_theme_font("font")
	var font_size := list.get_theme_font_size("font_size")
	for index in list.item_count:
		for line in list.get_item_text(index).split("\n"):
			_expect(font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x < list.size.x - 24.0, "Comparison fields need horizontal scrolling.")
		_expect(list.get_item_rect(index).size.y >= font.get_height(font_size) * 2.0, "ItemList clipped second comparison line.")


func _snapshot(inventory: PlayerInventory) -> Array:
	var items := inventory.get_inventory_items()
	var recovery := RecoveryResult.from_recovered_inventory_items(items)
	return [items, inventory.get_selected_index(), inventory.get_quick_drop_item(), inventory.get_used_slots(), inventory.get_total_weight(), recovery.get_total_value_min(), recovery.get_total_value_max(), ECONOMY.get_price(LIGHT.stable_id), ECONOMY.get_price(HEAVY.stable_id)]


func _item(weight: float, low: int, high: int) -> InventoryItem:
	var definition := LIGHT.duplicate(true) as ItemDefinition
	definition.display_name = "시험용 봉인 물품"
	definition.weight = weight
	definition.value_min = low
	definition.value_max = high
	return InventoryItem.from_definition(definition)


func _walk(player: PlayerController, target: Vector2) -> void:
	for index in range(720):
		var offset := target - player.position
		_release()
		if offset.length() < 6.0:
			await _frames(4)
			return
		if absf(offset.x) > 3.0:
			Input.action_press(InputActions.MOVE_RIGHT if offset.x > 0.0 else InputActions.MOVE_LEFT)
		if absf(offset.y) > 3.0:
			Input.action_press(InputActions.MOVE_DOWN if offset.y > 0.0 else InputActions.MOVE_UP)
		await _frames(1)
	_release()
	_expect(false, "Comparison route blocked at %s." % player.position)


func _release() -> void:
	for action in MOVES:
		Input.action_release(action)


func _key(key: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = key
	event.physical_keycode = key
	event.pressed = pressed
	Input.parse_input_event(event)
	Input.flush_buffered_events()


func _tap(key: Key) -> void:
	_key(key, true)
	_key(key, false)


func _click(position: Vector2) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = position
	motion.global_position = position
	Input.parse_input_event(motion)
	Input.flush_buffered_events()
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = position
		event.global_position = position
		Input.parse_input_event(event)
		Input.flush_buffered_events()


func _capture(filename: String) -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--value-render-directory="):
			var directory := argument.trim_prefix("--value-render-directory=")
			DirAccess.make_dir_recursive_absolute(directory)
			await RenderingServer.frame_post_draw
			_expect(get_viewport().get_texture().get_image().save_png(directory.path_join(filename)) == OK, "Screenshot failed.")


func _frames(count: int) -> void:
	for index in range(count):
		await get_tree().physics_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		GameLog.error(&"SmokeTest", &"value_comparison_failed", message)
