class_name MapClueDefinition
extends ContentDefinition

# Observed text only: no hidden destination, coordinates, or opening conditions.
@export_multiline var hint_text := ""


func get_validation_errors() -> PackedStringArray:
	var errors := super.get_validation_errors()
	if hint_text.strip_edges().is_empty():
		errors.append("Map clue hint must be non-empty.")
	return errors
