class_name MapRegionDefinition
extends ContentDefinition

@export var bounds: Rect2


func get_validation_errors() -> PackedStringArray:
	var errors := super.get_validation_errors()
	if not bounds.position.is_finite() or not bounds.size.is_finite() or bounds.size.x <= 0.0 or bounds.size.y <= 0.0:
		errors.append("Map region bounds must be finite and positive.")
	return errors
