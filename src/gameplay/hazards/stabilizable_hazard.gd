class_name StabilizableHazard
extends Area2D

@export var stabilization_charge_cost := 1
@export var harness_prompt := "안정화"


func get_stabilization_charge_cost() -> int:
	return stabilization_charge_cost


func get_harness_prompt() -> String:
	return harness_prompt


func can_stabilize() -> bool:
	return false


func stabilize() -> bool:
	return false
