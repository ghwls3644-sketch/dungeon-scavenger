class_name RepeatVisitPlan
extends RefCounted

var _inputs: Dictionary
var _placements: Array[Dictionary]
var _pool_counts: Dictionary


func _init(inputs: Dictionary = {}, placements: Array[Dictionary] = [], pool_counts: Dictionary = {}) -> void:
	_inputs = inputs.duplicate(true)
	_placements = placements.duplicate(true)
	_pool_counts = pool_counts.duplicate(true)


func get_reproduction_inputs() -> Dictionary:
	return _inputs.duplicate(true)


func get_fixed_map() -> Dictionary:
	return _inputs.definition.map.duplicate(true)


func get_placements() -> Array[Dictionary]:
	return _placements.duplicate(true)


func get_pool_counts() -> Dictionary:
	return _pool_counts.duplicate(true)
