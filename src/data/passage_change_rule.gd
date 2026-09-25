class_name PassageChangeRule
extends Resource

@export var warning_duration := 0.0


func is_valid() -> bool:
	return is_finite(warning_duration) and warning_duration > 0.0
