class_name AppraisalPreparation
extends RefCounted

const RULE := preload("res://src/data/prototype_appraisal_supply.tres")


static func valid_save(hub: Dictionary) -> bool:
	if not RULE.is_valid() or not LurePreparation.is_count(hub.get("paid_appraisals"), RULE.maximum_count) \
			or not LurePreparation.is_count(hub.get("selected_appraisals"), RULE.maximum_count):
		return false
	var pending: Variant = hub.get("pending_departure")
	if typeof(pending) != TYPE_DICTIONARY:
		return false
	return pending.is_empty() or (LurePreparation.is_count(pending.get("appraisals"), RULE.maximum_count) \
		and pending.appraisals == hub.selected_appraisals and hub.paid_appraisals + pending.appraisals <= RULE.maximum_count)


# Accept only the exact old shape. All other invariants are checked after conversion.
static func migrate_legacy(hub: Dictionary) -> bool:
	if hub.size() != 13 or hub.has("paid_appraisals") or hub.has("selected_appraisals") \
			or not LurePreparation.valid_save(hub, true):
		return false
	var book: Variant = hub.get("costs")
	if not ExpeditionCosts._keys(book, ["stock", "carried", "period", "last"]) or typeof(book.last) != TYPE_DICTIONARY:
		return false
	var periods: Array = [book.period]
	if not book.last.is_empty():
		if not ExpeditionCosts._keys(book.last, ["period", "id", "outcome", "loot_income", "free_used", "paid_count", "paid_used", "objective", "loot_tax"]):
			return false
		periods.append(book.last.period)
	for period in periods:
		if not ExpeditionCosts._keys(period, ["opening_money", "opening_stock", "storage_income", "appraisal_paid", "repair_paid", "upgrade_paid", "bought_costs", "partial", "tax_sales", "tax_legacy_income"]):
			return false
	for period in periods:
		period["appraisal_opening_stock"] = []
		period["appraisal_bought_costs"] = []
	book["appraisal_stock"] = []
	book["appraisal_carried"] = []
	if not book.last.is_empty():
		book.last["appraisal_count"] = 0
		book.last["appraisal_used"] = -1 if book.last.get("outcome") == "interrupted" else 0
	hub["paid_appraisals"] = 0
	hub["selected_appraisals"] = 0
	if not hub.pending_departure.is_empty():
		hub.pending_departure["appraisals"] = 0
	return true
