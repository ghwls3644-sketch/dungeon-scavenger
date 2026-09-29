class_name AppraisalQuote
extends RefCounted

# A transient quote for exact storage positions in an unchanged hub snapshot.
# Stable IDs identify definitions, not individual copies of the same item.
var _source: Dictionary
var _indices: PackedInt32Array
var _cost: int
var _money: int


func _init(source: Dictionary, indices: PackedInt32Array, cost: int, money: int) -> void:
	_source = source.duplicate(true)
	_indices = indices.duplicate()
	_cost = cost
	_money = money


func get_indices() -> PackedInt32Array:
	return _indices.duplicate()


func get_count() -> int:
	return _indices.size()


func get_cost() -> int:
	return _cost


func get_remaining_money() -> int:
	return _money - _cost


func can_afford() -> bool:
	return _cost >= 0 and _money >= _cost


func matches(source: Dictionary, cost: int) -> bool:
	return not source.is_empty() and _source == source and _cost == cost
