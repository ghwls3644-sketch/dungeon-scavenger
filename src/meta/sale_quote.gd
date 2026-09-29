class_name SaleQuote
extends RefCounted

enum Status { AVAILABLE, UNIDENTIFIED, PROTECTED, UNPRICED, UNAVAILABLE }

var _source: Dictionary
var _indices: PackedInt32Array
var _prices: Array[int]
var _income: int
var _money_after: int


func _init(source: Dictionary, indices: PackedInt32Array, prices: Array[int], income: int, money_after: int) -> void:
	_source = source.duplicate(true)
	_indices = indices.duplicate()
	_prices = prices.duplicate()
	_income = income
	_money_after = money_after


static func get_item_status(item: InventoryItem, rule: EconomyRule) -> Status:
	if item == null or not item.is_valid():
		return Status.UNAVAILABLE
	# Hidden protection/category must not be exposed through availability or price.
	if not item.is_identified():
		return Status.UNIDENTIFIED
	if item.get_definition().is_protected() or not item.get_definition().has_monetary_value():
		return Status.PROTECTED
	if rule == null or not rule.is_valid():
		return Status.UNAVAILABLE
	if not rule.has_price(item.get_definition().stable_id):
		return Status.UNPRICED
	return Status.AVAILABLE


func get_indices() -> PackedInt32Array:
	return _indices.duplicate()


func get_prices() -> Array[int]:
	return _prices.duplicate()


func get_count() -> int:
	return _indices.size()


func get_income() -> int:
	return _income


func get_money_after() -> int:
	return _money_after


func matches(source: Dictionary, prices: Array[int]) -> bool:
	return not source.is_empty() and source == _source and prices == _prices
