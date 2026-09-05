class_name InventoryItem
extends RefCounted

var _definition: ItemDefinition
var _identified := true
var _risk_hint := ""


static func from_definition(
	definition: ItemDefinition,
	starts_identified := true,
	known_risk_hint := ""
) -> InventoryItem:
	var item := InventoryItem.new()
	item._definition = definition
	item._identified = starts_identified
	item._risk_hint = known_risk_hint
	return item


func get_definition() -> ItemDefinition:
	return _definition


func is_identified() -> bool:
	return _identified


func get_risk_hint() -> String:
	return _risk_hint


func copy() -> InventoryItem:
	var definition_copy := _definition.duplicate(true) as ItemDefinition if _definition != null else null
	return from_definition(definition_copy, _identified, _risk_hint)


func identify() -> bool:
	if _identified:
		return false
	_identified = true
	return true


func is_valid() -> bool:
	return _definition != null and _definition.get_validation_errors().is_empty()
