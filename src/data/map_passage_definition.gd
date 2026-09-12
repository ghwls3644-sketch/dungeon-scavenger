class_name MapPassageDefinition
extends ContentDefinition

# A short, straight crossing in the public route map; no current obstruction state.
@export var start: Vector2
@export var end: Vector2
@export var clearance_radius := 0.0


func get_validation_errors() -> PackedStringArray:
	var errors := super.get_validation_errors()
	if not start.is_finite() or not end.is_finite() or start.is_equal_approx(end):
		errors.append("Passage endpoints must be finite and distinct.")
	if not is_finite(clearance_radius) or clearance_radius <= 0.0:
		errors.append("Passage clearance must be finite and positive.")
	return errors
