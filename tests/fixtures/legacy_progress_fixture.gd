class_name LegacyProgressFixture
extends RefCounted


static func before_seed(hub: Dictionary) -> Dictionary:
	var result := hub.duplicate(true)
	result.erase("visit_seed")
	return result


# Build authentic pre-10 fixtures without changing the requested older-version fields.
static func before_appraisal(hub: Dictionary) -> Dictionary:
	var result := hub.duplicate(true)
	result.erase("visit_seed")
	result.erase("paid_appraisals")
	result.erase("selected_appraisals")
	if typeof(result.get("pending_departure")) == TYPE_DICTIONARY:
		result.pending_departure.erase("appraisals")
	if typeof(result.get("costs")) == TYPE_DICTIONARY:
		result.costs.erase("appraisal_stock")
		result.costs.erase("appraisal_carried")
		var periods: Array = [result.costs.get("period")]
		if typeof(result.costs.get("last")) == TYPE_DICTIONARY and not result.costs.last.is_empty():
			result.costs.last.erase("appraisal_count")
			result.costs.last.erase("appraisal_used")
			periods.append(result.costs.last.get("period"))
		for period in periods:
			if typeof(period) == TYPE_DICTIONARY:
				period.erase("appraisal_opening_stock")
				period.erase("appraisal_bought_costs")
	return result
