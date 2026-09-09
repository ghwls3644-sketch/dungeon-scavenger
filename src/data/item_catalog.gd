class_name ItemCatalog
extends Resource

@export var items: Array[ItemDefinition] = []


func is_valid() -> bool:
	var seen := {}
	for item in items:
		if item == null or not item.get_validation_errors().is_empty() or seen.has(item.stable_id):
			return false
		seen[item.stable_id] = true
	return true


func find_item(id: StringName) -> ItemDefinition:
	for item in items:
		if item != null and item.stable_id == id:
			return item.duplicate(true) as ItemDefinition
	return null
