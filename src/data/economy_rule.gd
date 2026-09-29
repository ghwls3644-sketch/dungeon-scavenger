class_name EconomyRule
extends Resource

# Explicit prices for the temporary settlement, separate from estimated item values.
@export var base_prices: Dictionary[StringName, int] = {}
# Prototype per-item fee. Final pricing/batch discounts remain undecided.
@export var appraisal_fee_per_item: int = 0


func is_valid() -> bool:
	if appraisal_fee_per_item < 0:
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


func get_price(item_id: StringName) -> int:
	return base_prices.get(item_id, 0)
