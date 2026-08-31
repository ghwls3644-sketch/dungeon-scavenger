class_name InventoryItem
extends RefCounted

var _definition: ItemDefinition
var _identified := true


static func from_definition(
	definition: ItemDefinition,
	starts_identified := true
) -> InventoryItem:
	var item := InventoryItem.new()
	item._definition = definition
	item._identified = starts_identified
	return item


func get_definition() -> ItemDefinition:
	return _definition


func is_identified() -> bool:
	return _identified


func identify() -> bool:
	if _identified:
		return false
	_identified = true
	return true


func is_valid() -> bool:
	return _definition != null and _definition.get_validation_errors().is_empty()
