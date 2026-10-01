class_name ResearchCatalog
extends Resource

@export var entries: Array[ResearchDefinition] = []


func is_valid(items: ItemCatalog) -> bool:
	if items == null or not items.is_valid():
		return false
	var seen := {}
	for entry in entries:
		if entry == null or not entry.get_validation_errors().is_empty() or seen.has(entry.stable_id):
			return false
		seen[entry.stable_id] = true
		for id in entry.required_registered_ids:
			var item := items.find_item(id)
			if item == null or not item.is_original() or item.registration_text.strip_edges().is_empty():
				return false
	return true
