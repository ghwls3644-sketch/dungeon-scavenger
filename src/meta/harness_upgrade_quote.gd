class_name HarnessUpgradeQuote
extends RefCounted

var _source: Dictionary
var _id: String
var _cost: int
var _rules: Dictionary


func _init(source: Dictionary, id: String, rule: HarnessUpgradeRule) -> void:
	_source = source.duplicate(true)
	_id = id
	_cost = rule.get_cost(id)
	_rules = rule.snapshot()


func get_id() -> String:
	return _id


func get_cost() -> int:
	return _cost


func can_afford() -> bool:
	return _source.money.to_int() >= _cost


func get_money_after() -> int:
	return _source.money.to_int() - _cost


func matches(source: Dictionary, checked: HarnessUpgradeQuote) -> bool:
	return not source.is_empty() and _source == source and checked != null \
		and _id == checked._id and _cost == checked._cost and _rules == checked._rules
