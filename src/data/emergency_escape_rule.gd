class_name EmergencyEscapeRule
extends Resource

@export var time_limit := 0.0
@export var preparation_duration := 0.0
@export var charge_cost := 0


func is_valid() -> bool:
	return is_finite(time_limit) and is_finite(preparation_duration) and preparation_duration > 0.0 and time_limit > preparation_duration and charge_cost > 0
