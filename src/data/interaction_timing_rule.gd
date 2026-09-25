class_name InteractionTimingRule
extends Resource

@export var inspection_duration := 0.0
@export var recovery_duration := 0.0


func is_valid() -> bool:
	return is_finite(inspection_duration) and inspection_duration > 0.0 \
		and is_finite(recovery_duration) and recovery_duration > 0.0
