class_name EconomyRule
extends Resource

# Explicit prices for the temporary settlement, separate from estimated item values.
@export var base_prices: Dictionary[StringName, int] = {}
# Prototype per-item fee. Final pricing/batch discounts remain undecided.
@export var appraisal_fee_per_item: int = 0
@export var repair_cost_per_durability: int = 0
@export var minimum_departure_durability: int = 1
# Must be explicit, including intentionally untaxed test fixtures.
@export var recovery_tax_percent: int = -1


func is_valid() -> bool:
	if appraisal_fee_per_item < 0 or repair_cost_per_durability < 0 or minimum_departure_durability <= 0 or recovery_tax_percent < 0 or recovery_tax_percent > 100:
		return false
	for item_id in base_prices:
		if not StableId.is_valid(item_id) or base_prices[item_id] < 0:
			return false
	return true


func get_appraisal_cost(count: int) -> int:
	if count <= 0 or not is_valid():
		return -1
	if appraisal_fee_per_item > 0 and count > 9223372036854775807 / appraisal_fee_per_item:
		return -1
	return count * appraisal_fee_per_item


func has_price(item_id: StringName) -> bool:
	return base_prices.has(item_id)


func get_repair_cost(amount: int) -> int:
	if amount < 0 or not is_valid():
		return -1
	if repair_cost_per_durability > 0 and amount > 9223372036854775807 / repair_cost_per_durability:
		return -1
	return amount * repair_cost_per_durability


func get_price(item_id: StringName) -> int:
	return base_prices.get(item_id, 0)
