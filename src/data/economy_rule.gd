class_name EconomyRule
extends Resource

# Explicit prices for the temporary settlement, separate from estimated item values.
@export var base_prices: Dictionary[StringName, int] = {}


func is_valid() -> bool:
	for item_id in base_prices:
		if not StableId.is_valid(item_id) or base_prices[item_id] < 0:
			return false
	return true


func has_price(item_id: StringName) -> bool:
	return base_prices.has(item_id)


func get_price(item_id: StringName) -> int:
	return base_prices.get(item_id, 0)
