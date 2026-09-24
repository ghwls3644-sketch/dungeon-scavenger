class_name GolemContactRule
extends Resource

@export var contact_distance := 0.0
@export var warning_duration := 0.0


func is_valid() -> bool:
	return is_finite(contact_distance) and contact_distance > 0.0 \
		and is_finite(warning_duration) and warning_duration > 0.0
