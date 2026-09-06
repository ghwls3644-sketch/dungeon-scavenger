class_name StabilizableHazard
extends Area2D

@export var stabilization_charge_cost := 1
@export var harness_prompt := "안정화"
@export var analysis_charge_cost := 1


func get_analysis_charge_cost() -> int:
	return analysis_charge_cost


func get_basic_analysis() -> String:
	return ""


func get_precise_analysis() -> String:
	return ""


func get_stabilization_charge_cost() -> int:
	return stabilization_charge_cost


func get_harness_prompt() -> String:
	return harness_prompt


func can_stabilize() -> bool:
	return false


func stabilize() -> bool:
	return false
