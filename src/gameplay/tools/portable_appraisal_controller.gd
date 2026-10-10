class_name PortableAppraisalController
extends Node

signal status_changed
signal confirmation_canceled

var _inventory: PlayerInventory
var _allowed := Callable()
var _configured := false
var _active := false
var _capacity := 0
var _remaining := 0
var _token := 0
var _pending_item: InventoryItem
var _pending_definition: Dictionary = {}


func configure(inventory: PlayerInventory, count: int, allowed: Callable) -> bool:
	if _configured or inventory == null or count < 0 or count > 100 or not allowed.is_valid():
		return false
	_configured = true
	_inventory = inventory
	_capacity = count
	_remaining = count
	_allowed = allowed
	_inventory.inventory_changed.connect(cancel_pending)
	return true


func set_active(active: bool) -> void:
	_active = active and _configured
	if not _active:
		cancel_pending()


func get_capacity() -> int:
	return _capacity


func get_remaining_uses() -> int:
	return _remaining


func can_appraise_selected() -> bool:
	return _selected_item() != null


func _selected_item() -> InventoryItem:
	if not _active or _remaining <= 0 or not _allowed.is_valid() or not _allowed.call():
		return null
	var index := _inventory.get_selected_index()
	var items := _inventory.get_inventory_items()
	if index < 0 or index >= items.size():
		return null
	var item := items[index]
	return item if item.is_valid() and not item.is_identified() and is_finite(item.get_definition().weight) else null


func request_selected() -> Dictionary:
	cancel_pending()
	var item := _selected_item()
	if item == null:
		return {}
	_pending_item = item
	_pending_definition = _definition_snapshot(item)
	return {"token": _token, "name": item.get_definition().display_name, "remaining_after": _remaining - 1}


func confirm(token: int) -> bool:
	var item := _selected_item()
	if _pending_item == null or item != _pending_item or token != _token or _definition_snapshot(item) != _pending_definition:
		cancel_pending()
		return false
	cancel_pending()
	if not _inventory.identify_selected_item(item, false):
		return false
	_remaining -= 1
	# Both state changes precede any observer, including weight, quest progress and UI.
	status_changed.emit()
	_inventory.inventory_changed.emit()
	return true


func cancel_pending() -> void:
	_token += 1
	_pending_item = null
	_pending_definition.clear()
	confirmation_canceled.emit()


func _definition_snapshot(item: InventoryItem) -> Dictionary:
	var snapshot := {}
	for property in item.get_definition().get_property_list():
		if property.usage & PROPERTY_USAGE_STORAGE:
			snapshot[property.name] = item.get_definition().get(property.name)
	return snapshot
