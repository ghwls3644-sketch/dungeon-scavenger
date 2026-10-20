class_name RepairQuote
extends RefCounted

var _source: Dictionary
var _amount: int
var _cost: int
var _unit_cost: int
var _minimum: int
var _maximum: int
var _supported: bool


func _init(source: Dictionary, amount: int, cost: int, rule: EconomyRule, maximum: int, supported: bool) -> void:
	_source = source.duplicate(true)
	_amount = amount
	_cost = cost
	_unit_cost = rule.repair_cost_per_durability
	_minimum = rule.minimum_recovery_durability
	_maximum = maximum
	_supported = supported


func get_amount() -> int:
	return _amount


func get_cost() -> int:
	return _cost


func get_durability_before() -> int:
	return int(_source.harness_durability)


func get_durability_after() -> int:
	return get_durability_before() + _amount


func get_maximum() -> int:
	return _maximum


func is_supported() -> bool:
	return _supported


func can_afford() -> bool:
	return _source.money.to_int() >= _cost


func get_money_after() -> int:
	return _source.money.to_int() - _cost


func matches(source: Dictionary, checked: RepairQuote) -> bool:
	return not source.is_empty() and _source == source and checked != null \
		and _amount == checked._amount and _cost == checked._cost \
		and _unit_cost == checked._unit_cost and _minimum == checked._minimum \
		and _maximum == checked._maximum and _supported == checked._supported
