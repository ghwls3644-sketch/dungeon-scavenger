class_name LoadMovementRule
extends Resource

@export var burdened_multiplier := 0.0
@export var overloaded_multiplier := 0.0


func is_valid() -> bool:
	return (
		is_finite(burdened_multiplier) and is_finite(overloaded_multiplier)
		and overloaded_multiplier > 0.0
		and overloaded_multiplier < burdened_multiplier
		and burdened_multiplier < 1.0
	)
