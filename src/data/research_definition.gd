class_name ResearchDefinition
extends ContentDefinition

@export var required_registered_ids: Array[StringName] = []
@export_multiline var explanation := ""


func get_validation_errors() -> PackedStringArray:
	var errors := super.get_validation_errors()
	if explanation.strip_edges().is_empty():
		errors.append("Research explanation must be non-empty.")
	if required_registered_ids.is_empty():
		errors.append("Research requires at least one registered original.")
	var seen := {}
	for id in required_registered_ids:
		if not StableId.is_valid(id) or seen.has(id):
			errors.append("Research requirements must contain unique valid IDs.")
		seen[id] = true
	return errors
