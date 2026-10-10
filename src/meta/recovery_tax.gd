class_name RecoveryTax
extends RefCounted

const LIMIT := 9223372036854775807


static func valid_rate(value: Variant) -> bool:
	return typeof(value) in [TYPE_INT, TYPE_FLOAT] and is_finite(float(value)) and value == floor(float(value)) and value >= 0 and value <= 100


static func amount(gross: int, rate: int) -> int:
	if gross < 0 or not valid_rate(rate):
		return -1
	# Decompose before multiplying to retain the full int64 range.
	@warning_ignore("integer_division")
	return (gross / 100) * rate + ((gross % 100) * rate) / 100


static func receipt(gross: int, rate: int) -> Dictionary:
	var paid := amount(gross, rate)
	return {} if paid < 0 else {"gross": str(gross), "rate": rate, "paid": str(paid)}


static func legacy_receipt(gross: String) -> Dictionary:
	return {"gross": gross, "rate": -1, "paid": "0"}


static func valid_receipt(value: Variant, allow_legacy: bool = false) -> bool:
	if typeof(value) != TYPE_DICTIONARY or value.size() != 3 or not value.has_all(["gross", "rate", "paid"]):
		return false
	var gross := LurePreparation.read_nonnegative_integer(value.gross)
	var paid := LurePreparation.read_nonnegative_integer(value.paid)
	if gross < 0 or paid < 0:
		return false
	if allow_legacy and typeof(value.rate) in [TYPE_INT, TYPE_FLOAT] and value.rate == -1:
		return paid == 0
	return valid_rate(value.rate) and amount(gross, int(value.rate)) == paid


static func sales_summary(receipts: Variant, legacy_income: Variant) -> Dictionary:
	var gross := LurePreparation.read_nonnegative_integer(legacy_income)
	if gross < 0 or typeof(receipts) != TYPE_ARRAY:
		return {}
	var paid := 0
	for sale in receipts:
		if not valid_receipt(sale):
			return {}
		var subtotal := LurePreparation.read_nonnegative_integer(sale.gross)
		var tax := LurePreparation.read_nonnegative_integer(sale.paid)
		if subtotal <= 0 or subtotal > LIMIT - gross or tax > LIMIT - paid:
			return {}
		gross += subtotal
		paid += tax
	return {"gross": gross, "paid": paid}


static func migrate_legacy(hub: Dictionary) -> bool:
	if typeof(hub.get("costs")) != TYPE_DICTIONARY or not hub.costs.has_all(["period", "last"]) or typeof(hub.costs.last) != TYPE_DICTIONARY:
		return false
	var periods: Array = [hub.costs.period]
	if not hub.costs.last.is_empty():
		var last: Dictionary = hub.costs.last
		if last.size() != 8 or not last.has_all(["period", "id", "outcome", "loot_income", "free_used", "paid_count", "paid_used", "objective"]):
			return false
		periods.append(last.period)
	for period in periods:
		if typeof(period) != TYPE_DICTIONARY or period.size() != 8 or not period.has_all(["opening_money", "opening_stock", "storage_income", "appraisal_paid", "repair_paid", "upgrade_paid", "bought_costs", "partial"]):
			return false
	for period in periods:
		period["tax_sales"] = []
		period["tax_legacy_income"] = period.storage_income
	if not hub.costs.last.is_empty():
		if LurePreparation.read_nonnegative_integer(hub.costs.last.loot_income) < 0:
			return false
		hub.costs.last["loot_tax"] = legacy_receipt(hub.costs.last.loot_income)
	return true
