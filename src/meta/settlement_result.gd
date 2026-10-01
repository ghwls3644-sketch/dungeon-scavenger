class_name SettlementResult
extends RefCounted

var _sales: Array[Dictionary] = []
var _retained_items: Array[InventoryItem] = []
var _total_income := 0
var _total_cost := 0
var _failure := false
var _lost_count := 0
var _equipment_damage: Dictionary = {}
var _full_repair_estimate := -1


static func from_outcome(
	outcome: ExplorationOutcome, rule: EconomyRule,
	wear_rule: EquipmentWearRule = null, durability: int = 0
) -> SettlementResult:
	if outcome == null or rule == null or not rule.is_valid():
		return null
	var result := SettlementResult.new()
	result._failure = outcome.is_failure()
	result._lost_count = outcome.get_lost_item_count()
	if wear_rule != null:
		if not wear_rule.is_valid() or durability < 0 or durability > wear_rule.max_durability:
			return null
		var damage := mini(durability, wear_rule.get_damage(result._failure))
		result._equipment_damage = {
			"before": durability, "after": durability - damage,
			"damage": damage, "maximum": wear_rule.max_durability,
		}
		result._full_repair_estimate = rule.get_repair_cost(wear_rule.max_durability - (durability - damage))
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
	# Wear is not a repair payment. Do not charge an unconfirmed service here.
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


func get_equipment_damage() -> Dictionary:
	return _equipment_damage.duplicate()


func get_full_repair_estimate() -> int:
	return _full_repair_estimate
