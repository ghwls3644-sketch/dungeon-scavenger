# Reuse input, departure and layout helpers; this scene runs only category checks.
extends "res://tests/smoke/value_comparison_smoke.gd"


func _ready() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	_check_icon_boundary()
	await _check_category_panel()
	_release()
	get_tree().paused = false
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"item_category_passed")
	get_tree().quit(0 if _failures.is_empty() else 1)


func _check_icon_boundary() -> void:
	var textures: Array[Texture2D] = [ItemCategoryIcon.UNKNOWN]
	_expect(ItemCategoryIcon.for_item(null) == ItemCategoryIcon.UNKNOWN, "Unbound category did not use neutral icon.")
	for category in ItemDefinition.CATEGORY_IDS:
		for protected in [false, true]:
			var item := _category_item(category, false, protected)
			var definition := item.get_definition()
			var before := [definition.category, definition.value_min, definition.value_max, definition.sale_protected, item.is_identified()]
			_expect(ItemCategoryIcon.for_item(item) == ItemCategoryIcon.UNKNOWN, "Unknown price/protection/category changed its icon.")
			_expect(before == [definition.category, definition.value_min, definition.value_max, definition.sale_protected, item.is_identified()], "Icon lookup mutated hidden state.")
		var known := _category_item(category)
		var texture := ItemCategoryIcon.for_item(known)
		_expect(texture != null and not textures.has(texture), "Known categories share an icon.")
		textures.append(texture)
	# Compare only central white shapes, excluding the colored border.
	var silhouettes: Array[String] = []
	for texture in textures:
		var icon_image := texture.get_image()
		_expect(icon_image != null and icon_image.get_size() == Vector2i(32, 32), "Icon import failed or has unexpected dimensions.")
		if icon_image == null:
			continue
		var silhouette := ""
		for y in range(5, 27):
			for x in range(5, 27):
				var pixel := icon_image.get_pixel(x, y)
				silhouette += "1" if minf(pixel.r, minf(pixel.g, pixel.b)) > 0.8 else "0"
		_expect(silhouette.contains("1") and not silhouettes.has(silhouette), "Category icons differ only by color.")
		silhouettes.append(silhouette)


func _check_category_panel() -> void:
	var world := await _new_world()
	var inventory: PlayerInventory = world.get_node("Player/Inventory")
	var panel: InventoryPanel = world.get_node("%InventoryPanel")
	var list: ItemList = panel.get_node("%ItemList")
	var legacy := PANEL.instantiate() as InventoryPanel
	add_child(legacy)
	legacy.bind_inventory(inventory)
	var unknown := _category_item(ItemDefinition.CATEGORY_UNIQUE_ARTIFACT, false)
	var scrap := _category_item(ItemDefinition.CATEGORY_SCRAP)
	var residue := _category_item(ItemDefinition.CATEGORY_RESIDUE)
	for item in [unknown, scrap, residue]:
		_expect(inventory.try_add_inventory_item(item), "First icon group could not be added.")
	_expect(not legacy.show_category_icons and legacy.get_node("%ItemList").get_item_icon(0) == null, "Legacy/G1 inventory gained icons.")
	legacy.queue_free()
	await _frames(2)
	var before := _snapshot(inventory)
	_tap(KEY_TAB)
	await _frames(5)
	_expect(panel.visible and get_tree().paused and before == _snapshot(inventory), "Opening icons mutated gameplay state.")
	_check_visible_icons(panel, inventory)
	list.grab_focus()
	_tap(KEY_UP)
	_tap(KEY_UP)
	await _frames(3)
	_expect(inventory.get_selected_index() == 0 and inventory.get_quick_drop_item() == null, "Unknown protected icon changed selection/protection.")
	var text := panel.get_displayed_item_text(0) + panel.get_selection_details_text() + list.get_item_tooltip(0)
	_expect(text.contains("미확인 물품") and text.contains("보호 여부 미확인") and text.contains("가치 미확인"), "Unknown category lost neutral text.")
	_expect(not text.contains("고유 유물") and not text.contains("6543") and not text.contains("8765"), "Icon integration leaked category/value.")
	await _capture("category-unknown-scrap-residue.png")
	_tap(KEY_DOWN)
	await _frames(3)
	_expect(inventory.get_selected_index() == 1 and inventory.get_quick_drop_item() == scrap, "Keyboard icon selection changed target identity.")
	_check_layout(panel)
	panel.get_node("%DropButton").pressed.emit()
	var confirmation: ConfirmationDialog = panel.get_node("%DropConfirmation")
	_expect(confirmation.visible, "Icon list bypassed drop confirmation.")
	confirmation.confirmed.emit()
	confirmation.hide()
	await _frames(3)
	_expect(inventory.get_inventory_items() == [unknown, residue] and inventory.get_quick_drop_item() == null, "Icon redraw discarded or selected the wrong item.")
	_check_visible_icons(panel, inventory)
	unknown.identify()
	inventory.inventory_changed.emit()
	await _frames(3)
	_expect(list.get_item_icon(0) == ItemCategoryIcon.for_item(unknown) and list.get_item_icon(0) != ItemCategoryIcon.UNKNOWN and panel.get_displayed_item_text(0).contains("고유 유물"), "Identification did not refresh icon and name together.")
	inventory.take_all_inventory_items()
	_expect(list.item_count == 0, "Empty inventory retained category icons.")
	var artifact := _category_item(ItemDefinition.CATEGORY_UNIQUE_ARTIFACT)
	var record := _category_item(ItemDefinition.CATEGORY_CORE_RECORD)
	var protected_scrap := _category_item(ItemDefinition.CATEGORY_SCRAP, true, true)
	for item in [artifact, record, protected_scrap]:
		_expect(inventory.try_add_inventory_item(item), "Second icon group could not be added.")
	await _frames(3)
	list.grab_focus()
	_tap(KEY_UP)
	_tap(KEY_UP)
	await _frames(3)
	_check_visible_icons(panel, inventory)
	await _capture("category-artifact-record-protected.png")
	panel.get_node("%DropButton").pressed.emit()
	confirmation.confirmed.emit()
	confirmation.hide()
	_expect(inventory.get_used_slots() == 3 and inventory.get_quick_drop_item() == null, "Category icon bypassed artifact protection.")
	for window_size in [Vector2i(1600, 900), Vector2i(1152, 648)]:
		get_tree().root.size = window_size
		await _frames(5)
		_check_layout(panel)
		if window_size.x == 1600:
			await _capture("category-wide.png")
	# Long lists use normal scrolling; category remains attached to the same item.
	inventory.configure_capacity(8, 2.5, 4.0)
	for index in range(5):
		inventory.try_add_inventory_item(_category_item(ItemDefinition.CATEGORY_RESIDUE))
	await _frames(3)
	list.grab_focus()
	for index in range(7):
		_tap(KEY_UP)
	await _frames(3)
	_expect(is_zero_approx(list.get_v_scroll_bar().value), "Selecting first category item did not scroll to top.")
	for index in range(7):
		_tap(KEY_DOWN)
	await _frames(4)
	_expect(inventory.get_selected_index() == 7 and inventory.get_quick_drop_item() == inventory.get_inventory_items()[7], "Scrolling category list lost selection identity.")
	_expect(list.get_v_scroll_bar().value > 0.0, "Selected category item remained below visible list.")
	var scroll := list.get_v_scroll_bar()
	_expect(is_equal_approx(scroll.value, scroll.max_value - scroll.page), "Last category row is clipped after quick-drop hint resized list.")
	_check_visible_icons(panel, inventory)
	_check_layout(panel)
	await _capture("category-scroll.png")
	_tap(KEY_TAB)
	await _frames(3)
	_expect(not panel.visible and not get_tree().paused, "Closing icon menu did not restore time.")
	_tap(KEY_TAB)
	await _frames(3)
	_check_visible_icons(panel, inventory)
	world.get_node("%ExplorationRun").complete_failure()
	await _frames(3)
	_expect(not panel.visible and not get_tree().paused, "Failure retained icon menu.")
	world.queue_free()
	await _frames(3)


func _category_item(category: StringName, identified := true, protected := false) -> InventoryItem:
	var item := _item(1.0, 6543, 8765)
	item.get_definition().category = category
	item.get_definition().sale_protected = protected
	return InventoryItem.from_definition(item.get_definition(), identified, "표면을 살펴볼 수 있습니다.")


func _check_visible_icons(panel: InventoryPanel, inventory: PlayerInventory) -> void:
	var list: ItemList = panel.get_node("%ItemList")
	var items := inventory.get_inventory_items()
	_expect(list.item_count == items.size(), "Icon count differs from inventory.")
	if list.item_count == 3:
		var rows_height := list.get_item_rect(0).size.y * 3.0
		_expect(rows_height + 8.0 <= list.size.y, "Three default inventory rows clip their category or value text.")
	for index in items.size():
		_expect(list.get_item_icon(index) == ItemCategoryIcon.for_item(items[index]), "Icon attached to wrong inventory index.")


func _capture(filename: String) -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--category-render-directory="):
			var directory := argument.trim_prefix("--category-render-directory=")
			DirAccess.make_dir_recursive_absolute(directory)
			await RenderingServer.frame_post_draw
			_expect(get_viewport().get_texture().get_image().save_png(directory.path_join(filename)) == OK, "Screenshot failed.")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		GameLog.error(&"SmokeTest", &"item_category_failed", message)
