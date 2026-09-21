class_name ItemValueComparison
extends RefCounted

enum Status { UNAVAILABLE, UNIDENTIFIED, NON_MONETARY, ZERO_WEIGHT, AVAILABLE }

var status := Status.UNAVAILABLE
var minimum := 0.0
var maximum := 0.0


static func from_item(item: InventoryItem) -> ItemValueComparison:
	var result := ItemValueComparison.new()
	if item == null or not item.is_valid():
		return result
	if not item.is_identified():
		result.status = Status.UNIDENTIFIED
		return result
	var definition := item.get_definition()
	if not definition.has_monetary_value():
		result.status = Status.NON_MONETARY
		return result
	if not is_finite(definition.weight):
		return result
	if definition.weight == 0.0:
		result.status = Status.ZERO_WEIGHT
		return result
	var low := definition.value_min / definition.weight
	var high := definition.value_max / definition.weight
	if not is_finite(low) or not is_finite(high):
		return result
	result.status = Status.AVAILABLE
	result.minimum = low
	result.maximum = high
	return result
