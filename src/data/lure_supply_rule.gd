class_name LureSupplyRule
extends Resource

@export var free_count := 2
@export var maximum_count := 4
@export var stock_limit := 2
@export var unit_price := 5
@export var unit_weight := 0.25


func is_valid() -> bool:
	return free_count >= 0 and maximum_count > free_count and maximum_count <= 100 \
		and stock_limit == maximum_count - free_count and unit_price > 0 \
		and unit_price <= 9223372036854775807 / stock_limit \
		and is_finite(unit_weight) and unit_weight > 0.0 and is_finite(unit_weight * maximum_count)


func snapshot() -> Dictionary:
	return {"free": free_count, "maximum": maximum_count, "stock": stock_limit, "price": unit_price, "weight": unit_weight}


static func is_count(value: Variant, maximum: int) -> bool:
	return typeof(value) in [TYPE_INT, TYPE_FLOAT] and is_finite(float(value)) \
		and value == floor(float(value)) and value >= 0 and value <= maximum
