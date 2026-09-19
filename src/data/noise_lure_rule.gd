class_name NoiseLureRule
extends Resource

@export var starting_uses := 0
@export var minimum_distance := 0.0
@export var maximum_distance := 0.0
@export var wall_clearance := 0.0
@export var flight_duration := 0.0
@export var hearing_radius := 0.0
@export var marker_duration := 0.0


func is_valid() -> bool:
	return (
		starting_uses > 0
		and is_finite(minimum_distance) and minimum_distance > 0.0
		and is_finite(maximum_distance) and maximum_distance > minimum_distance
		and is_finite(wall_clearance) and wall_clearance > 0.0 and wall_clearance < minimum_distance
		and is_finite(flight_duration) and flight_duration > 0.0
		and is_finite(hearing_radius) and hearing_radius > 0.0
		and is_finite(marker_duration) and marker_duration > 0.0
	)
