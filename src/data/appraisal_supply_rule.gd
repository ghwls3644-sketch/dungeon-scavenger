class_name AppraisalSupplyRule
extends Resource

@export var maximum_count := 2
@export var unit_price := 10
@export var unit_weight := 0.25


func is_valid() -> bool:
	return maximum_count > 0 and maximum_count <= 100 and unit_price > 0 \
		and unit_price <= 9223372036854775807 / maximum_count \
		and is_finite(unit_weight) and unit_weight >= 0.0 and is_finite(unit_weight * maximum_count)


func snapshot() -> Dictionary:
	return {"maximum": maximum_count, "price": unit_price, "weight": unit_weight}
