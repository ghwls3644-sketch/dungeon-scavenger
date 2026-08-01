class_name ContentDefinition
extends Resource

@export var stable_id: StringName = &""
@export var display_name: String = ""


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if not StableId.is_valid(stable_id):
		errors.append("stable_id must be non-empty and have no leading or trailing whitespace.")
	if display_name.strip_edges().is_empty():
		errors.append("display_name must be non-empty.")

	return errors
