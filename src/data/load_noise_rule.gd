class_name LoadNoiseRule
extends Resource

@export var step_distance := 0.0
@export var normal_radius := 0.0
@export var burdened_radius := 0.0
@export var overloaded_radius := 0.0
@export var loud_noise_count := 0
@export var loud_noise_window := 0.0


func is_valid() -> bool:
	return (
		is_finite(step_distance) and step_distance > 0.0
		and is_finite(normal_radius) and normal_radius > 0.0
		and is_finite(burdened_radius) and burdened_radius > normal_radius
		and is_finite(overloaded_radius) and overloaded_radius > burdened_radius
		and loud_noise_count >= 2
		and is_finite(loud_noise_window) and loud_noise_window > 0.0
	)
