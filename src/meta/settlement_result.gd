class_name SettlementResult
extends RefCounted

var _sales: Array[Dictionary] = []
var _retained_items: Array[InventoryItem] = []
var _total_income := 0
var _total_cost := 0
var _failure := false
var _lost_count := 0


static func from_outcome(outcome: ExplorationOutcome, rule: EconomyRule) -> SettlementResult:
	if outcome == null or rule == null or not rule.is_valid():
		return null
	var result := SettlementResult.new()
	result._failure = outcome.is_failure()
	result._lost_count = outcome.get_lost_item_count()
	if result._failure:
		return result
	var recovery := outcome.get_recovery_result()
	if recovery == null:
		return null
	for item in recovery.get_recovered_inventory_items():
		var definition := item.get_definition()
		if not item.is_identified() or definition.is_protected() or not rule.has_price(definition.stable_id):
			result._retained_items.append(item)
			continue
		var price := rule.get_price(definition.stable_id)
		if price > 9223372036854775807 - result._total_income:
			return null
		result._sales.append({"item_id": definition.stable_id, "name": definition.display_name, "amount": price})
		result._total_income += price
	# Hub appraisal is charged/saved separately when explicitly confirmed.
	# Do not charge it again in an expedition settlement; other costs remain future work.
	return result


func get_sales() -> Array[Dictionary]:
	return _sales.duplicate(true)


func get_retained_items() -> Array[InventoryItem]:
	var copies: Array[InventoryItem] = []
	for item in _retained_items:
		copies.append(item.copy())
	return copies


func get_total_income() -> int:
	return _total_income


func get_total_cost() -> int:
	return _total_cost


func get_net_income() -> int:
	return _total_income - _total_cost


func is_failure() -> bool:
	return _failure


func get_lost_count() -> int:
	return _lost_count
