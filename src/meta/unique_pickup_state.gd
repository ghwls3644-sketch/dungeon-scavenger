class_name UniquePickupState
extends RefCounted

var _items: Array[InventoryItem] = []


func contains(id: StringName) -> bool:
	for item in _items:
		if item.get_definition().stable_id == id:
			return true
	return false


func register(item: InventoryItem) -> bool:
	if item == null or not item.is_valid() or not item.is_identified():
		return false
	var definition := item.get_definition()
	if not definition.is_original() or contains(definition.stable_id):
		return false
	_items.append(item.copy())
	return true


func get_items() -> Array[InventoryItem]:
	var copies: Array[InventoryItem] = []
	for item in _items:
		copies.append(item.copy())
	return copies


func copy() -> UniquePickupState:
	var result := UniquePickupState.new()
	result._items = get_items()
	return result


func to_save_data() -> Array[Dictionary]:
	var data: Array[Dictionary] = []
	for item in _items:
		data.append({"id": String(item.get_definition().stable_id), "identified": true, "risk_hint": item.get_risk_hint()})
	return data


static func from_save_data(data: Variant, catalog: ItemCatalog) -> UniquePickupState:
	if typeof(data) != TYPE_ARRAY or catalog == null or not catalog.is_valid():
		return null
	var restored := UniquePickupState.new()
	for raw in data:
		if typeof(raw) != TYPE_DICTIONARY or raw.size() != 3 \
				or typeof(raw.get("id")) != TYPE_STRING or typeof(raw.get("identified")) != TYPE_BOOL \
				or not raw.identified or typeof(raw.get("risk_hint")) != TYPE_STRING:
			return null
		var definition := catalog.find_item(StringName(raw.id))
		if definition == null or not restored.register(InventoryItem.from_definition(definition, true, raw.risk_hint)):
			return null
	return restored
