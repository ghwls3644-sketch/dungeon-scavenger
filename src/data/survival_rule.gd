class_name SurvivalRule
extends Resource

@export var max_health := 0
@export var trap_damage := 0
@export var injury_duration := 0.0
@export var injury_movement_multiplier := 0.0


func is_valid() -> bool:
	return max_health > 0 and trap_damage > 0 \
		and is_finite(injury_duration) and injury_duration > 0.0 \
		and is_finite(injury_movement_multiplier) \
		and injury_movement_multiplier > 0.0 and injury_movement_multiplier <= 1.0
