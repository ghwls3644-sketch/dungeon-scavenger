class_name AppraisalPreparationQuote
extends RefCounted

var _source: Dictionary
var _count: int
var _bought: int
var _rules: Dictionary


func _init(source: Dictionary, count: int, rule: AppraisalSupplyRule) -> void:
	_source = source.duplicate(true)
	_count = count
	_rules = rule.snapshot()
	_bought = maxi(count - int(source.paid_appraisals), 0)


func get_count() -> int:
	return _count


func get_bought_count() -> int:
	return _bought


func get_cost() -> int:
	return _bought * int(_rules.price)


func get_money_after() -> int:
	return _source.money.to_int() - get_cost()


func can_afford() -> bool:
	return get_money_after() >= 0


func matches(source: Dictionary, checked: AppraisalPreparationQuote) -> bool:
	return not source.is_empty() and source == _source and checked != null \
		and _count == checked._count and _bought == checked._bought and _rules == checked._rules


func get_start_weight() -> float:
	return _count * float(_rules.weight)


func get_stock_left() -> int:
	return int(_source.paid_appraisals) + _bought - _count
