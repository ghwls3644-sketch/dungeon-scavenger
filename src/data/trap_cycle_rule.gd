class_name TrapCycleRule
extends Resource

@export var quiet_durations := PackedFloat32Array()
@export var warning_duration := 0.0
@export var active_duration := 0.0
@export var stabilization_duration := 0.0
@export var stabilization_cost := 0


func is_valid() -> bool:
	if quiet_durations.is_empty() or stabilization_cost <= 0:
		return false
	for duration in quiet_durations:
		if not is_finite(duration) or duration <= 0.0:
			return false
	return (
		is_finite(warning_duration) and warning_duration > 0.0
		and is_finite(active_duration) and active_duration > 0.0
		and is_finite(stabilization_duration) and stabilization_duration > 0.0
	)
