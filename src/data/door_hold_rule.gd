class_name DoorHoldRule
extends Resource

@export var hold_duration := 0.0
@export var release_warning_duration := 0.0
@export var push_open_duration := 0.0
@export var charge_cost := 0


func is_valid() -> bool:
	return (
		is_finite(hold_duration) and hold_duration > 0.0
		and is_finite(release_warning_duration) and release_warning_duration > 0.0
		and release_warning_duration < hold_duration
		and is_finite(push_open_duration) and push_open_duration > 0.0
		and charge_cost > 0
	)
