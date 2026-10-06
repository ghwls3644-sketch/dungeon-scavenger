class_name LurePreparationQuote
extends RefCounted

var _source: Dictionary
var _count: int
var _bought: int
var _rules: Dictionary


func _init(source: Dictionary, count: int, rule: LureSupplyRule) -> void:
	_source = source.duplicate(true)
	_count = count
	_rules = rule.snapshot()
	_bought = maxi(get_paid_count() - int(source.paid_lures), 0)


func get_count() -> int:
	return _count


func get_free_count() -> int:
	return mini(_count, int(_rules.free))


func get_paid_count() -> int:
	return maxi(_count - int(_rules.free), 0)


func get_bought_count() -> int:
	return _bought


func get_cost() -> int:
	return _bought * int(_rules.price)


func get_money_after() -> int:
	return _source.money.to_int() - get_cost()


func can_afford() -> bool:
	return get_money_after() >= 0


func matches(source: Dictionary, checked: LurePreparationQuote) -> bool:
	return not source.is_empty() and _source == source and checked != null \
		and _count == checked._count and _bought == checked._bought and _rules == checked._rules


func get_start_weight() -> float:
	return _count * float(_rules.weight)


func get_stock_left() -> int:
	return int(_source.paid_lures) + _bought - get_paid_count()
