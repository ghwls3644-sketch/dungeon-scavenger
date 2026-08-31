class_name RecoveryResult
extends RefCounted

var _recovered_items: Array[InventoryItem] = []
var _total_value_min := 0
var _total_value_max := 0
var _non_monetary_reward_count := 0
var _unidentified_item_count := 0


static func from_recovered_items(recovered_items: Array[ItemDefinition]) -> RecoveryResult:
	var result := RecoveryResult.new()
	var inventory_items: Array[InventoryItem] = []
	for item in recovered_items:
		inventory_items.append(InventoryItem.from_definition(item))
	result._capture(inventory_items)
	return result


static func from_recovered_inventory_items(
	recovered_items: Array[InventoryItem]
) -> RecoveryResult:
	var result := RecoveryResult.new()
	result._capture(recovered_items)
	return result


func get_recovered_items() -> Array[ItemDefinition]:
	var definitions: Array[ItemDefinition] = []
	for item in _recovered_items:
		definitions.append(item.get_definition())
	return definitions


func get_recovered_inventory_items() -> Array[InventoryItem]:
	return _recovered_items.duplicate()


func get_item_count() -> int:
	return _recovered_items.size()


func get_total_value_min() -> int:
	return _total_value_min


func get_total_value_max() -> int:
	return _total_value_max


func get_non_monetary_reward_count() -> int:
	return _non_monetary_reward_count


func get_unidentified_item_count() -> int:
	return _unidentified_item_count


func _capture(recovered_items: Array[InventoryItem]) -> void:
	for item in recovered_items:
		if item == null or not item.is_valid():
			continue

		_recovered_items.append(item)
		if not item.is_identified():
			_unidentified_item_count += 1
			continue

		var definition := item.get_definition()
		if definition.has_monetary_value():
			_total_value_min += definition.value_min
			_total_value_max += definition.value_max
		else:
			_non_monetary_reward_count += 1
