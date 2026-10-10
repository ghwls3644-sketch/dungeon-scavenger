class_name ExpeditionCosts
extends RefCounted

# Reporting never moves money. HubState commits these records with each transaction.
const LIMIT := 9223372036854775807
const PERIOD_KEYS := ["opening_money", "opening_stock", "storage_income", "appraisal_paid", "repair_paid", "upgrade_paid", "bought_costs", "partial", "tax_sales", "tax_legacy_income", "appraisal_opening_stock", "appraisal_bought_costs"]
const REPORT_KEYS := ["period", "id", "outcome", "loot_income", "free_used", "paid_count", "paid_used", "objective", "loot_tax", "appraisal_count", "appraisal_used"]
const PAYMENTS := ["appraisal_paid", "repair_paid", "upgrade_paid"]


static func new_book(money: int, stock: Array = [], partial: bool = false, appraisal_stock: Array = []) -> Dictionary:
	return {"stock": stock.duplicate(), "carried": [], "appraisal_stock": appraisal_stock.duplicate(), "appraisal_carried": [], "period": {
		"opening_money": str(money), "opening_stock": stock.duplicate(),
		"storage_income": "0", "appraisal_paid": "0", "repair_paid": "0",
		"upgrade_paid": "0", "bought_costs": [], "partial": partial,
		"tax_sales": [], "tax_legacy_income": "0",
		"appraisal_opening_stock": appraisal_stock.duplicate(), "appraisal_bought_costs": [],
	}, "last": {}}


static func legacy_book(hub: Dictionary, include_tax: bool = true) -> Dictionary:
	var stock: Array = []
	var carried: Array = []
	for index in int(hub.paid_lures):
		stock.append("")
	if not hub.pending_departure.is_empty():
		for index in int(hub.pending_departure.paid):
			carried.append("")
	var result := new_book(number(hub.money), carried + stock, true)
	result.stock = stock
	result.carried = carried
	if not include_tax:
		result.period.erase("tax_sales")
		result.period.erase("tax_legacy_income")
		result.period.erase("appraisal_opening_stock")
		result.period.erase("appraisal_bought_costs")
		result.erase("appraisal_stock")
		result.erase("appraisal_carried")
	return result


static func number(value: Variant) -> int:
	return LurePreparation.read_nonnegative_integer(value)


static func _keys(value: Variant, keys: Array) -> bool:
	return typeof(value) == TYPE_DICTIONARY and value.size() == keys.size() and value.has_all(keys)


static func _costs(value: Variant, unknown_allowed: bool = true, maximum: int = LurePreparation.RULE.stock_limit) -> bool:
	if typeof(value) != TYPE_ARRAY or value.size() > maximum:
		return false
	for unit in value:
		if not (unknown_allowed and typeof(unit) == TYPE_STRING and unit.is_empty()) and number(unit) < 0:
			return false
	return total(value) >= 0


static func total(values: Array) -> int:
	var amount := 0
	for value in values:
		if typeof(value) == TYPE_STRING and value.is_empty():
			continue
		var unit := number(value)
		if unit < 0 or unit > LIMIT - amount:
			return -1
		amount += unit
	return amount


static func _sum(values: Array) -> int:
	var amount := 0
	for value in values:
		if value < 0 or value > LIMIT - amount:
			return -1
		amount += value
	return amount


static func _valid_period(value: Variant) -> bool:
	if not _keys(value, PERIOD_KEYS) or typeof(value.partial) != TYPE_BOOL \
			or not _costs(value.opening_stock) or not _costs(value.bought_costs, false) \
			or not _costs(value.opening_stock + value.bought_costs):
		return false
	if not _appraisal_costs(value.appraisal_opening_stock) or not _appraisal_costs(value.appraisal_bought_costs) \
			or not _appraisal_costs(value.appraisal_opening_stock + value.appraisal_bought_costs):
		return false
	var sales := RecoveryTax.sales_summary(value.tax_sales, value.tax_legacy_income)
	if sales.is_empty() or sales.gross != number(value.storage_income):
		return false
	for key in ["opening_money", "storage_income"] + PAYMENTS:
		if number(value[key]) < 0:
			return false
	return true


static func _values(period: Dictionary, loot: int = 0, consumed: Array = [], reward: int = 0, loot_tax: Dictionary = {}, appraisal_consumed: Array = []) -> Dictionary:
	if not _valid_period(period) or loot < 0 or reward < 0 or not _costs(consumed) or not _appraisal_costs(appraisal_consumed):
		return {}
	var receipt := RecoveryTax.receipt(0, 0) if loot_tax.is_empty() else loot_tax
	if not RecoveryTax.valid_receipt(receipt, true) or number(receipt.gross) != loot:
		return {}
	var storage_tax: int = RecoveryTax.sales_summary(period.tax_sales, period.tax_legacy_income).paid
	var tax := _sum([storage_tax, number(receipt.paid)])
	var income := _sum([number(period.storage_income), loot, reward])
	var services := _sum([number(period.appraisal_paid), number(period.repair_paid)])
	var investment := number(period.upgrade_paid)
	var purchase := total(period.bought_costs)
	var appraisal_purchase := total(period.appraisal_bought_costs)
	var cash_cost := _sum([services, investment, purchase, appraisal_purchase, tax])
	var operating := _sum([services, total(consumed), total(appraisal_consumed), tax])
	# Reject preparations that could not later report losing all carried stock.
	var maximum_operating := _sum([services, total(period.opening_stock + period.bought_costs), total(period.appraisal_opening_stock + period.appraisal_bought_costs), tax])
	if income < 0 or cash_cost < 0 or operating < 0 or maximum_operating < 0:
		return {}
	var cash := income - cash_cost
	var opening := number(period.opening_money)
	if (cash > 0 and cash > LIMIT - opening) or (cash < 0 and opening < -cash):
		return {}
	return {"income": income, "operating_cost": operating, "profit": income - operating,
		"unknown_count": consumed.count(""), "cash_change": cash, "money_after": opening + cash,
		"opening_money": opening, "storage_income": number(period.storage_income), "loot_income": loot, "objective_income": reward,
		"appraisal_paid": number(period.appraisal_paid), "repair_paid": number(period.repair_paid),
		"upgrade_paid": investment, "lure_bought": purchase, "appraisal_bought": appraisal_purchase, "partial": period.partial,
		"recovery_tax": tax, "storage_tax": storage_tax, "loot_tax_paid": number(receipt.paid),
		"settlement_credit": loot - number(receipt.paid) + reward,
		"tax_legacy": receipt.rate == -1 or number(period.tax_legacy_income) > 0,
		"untaxed_income": number(period.tax_legacy_income) + (loot if receipt.rate == -1 else 0)}


static func valid_save(book: Variant, hub: Dictionary) -> bool:
	if not _keys(book, ["stock", "carried", "period", "last", "appraisal_stock", "appraisal_carried"]) or not _costs(book.stock) \
			or not _costs(book.carried) or not _appraisal_costs(book.appraisal_stock) or not _appraisal_costs(book.appraisal_carried) or not _valid_period(book.period) or typeof(book.last) != TYPE_DICTIONARY:
		return false
	var journal: Dictionary = hub.pending_departure
	var paid := 0 if journal.is_empty() else int(journal.paid)
	if book.stock.size() != int(hub.paid_lures) or book.carried.size() != paid \
			or book.carried + book.stock != book.period.opening_stock + book.period.bought_costs:
		return false
	var appraisal_count := 0 if journal.is_empty() else int(journal.appraisals)
	if book.appraisal_stock.size() != int(hub.paid_appraisals) or book.appraisal_carried.size() != appraisal_count \
			or book.appraisal_carried + book.appraisal_stock != book.period.appraisal_opening_stock + book.period.appraisal_bought_costs:
		return false
	var current := _values(book.period)
	if current.is_empty() or current.money_after != number(hub.get("money")):
		return false
	if not book.last.is_empty():
		var last := report_summary(book.last)
		var next_id := number(hub.get("next_expedition_id"))
		if last.is_empty() or number(book.last.id) >= next_id or (not journal.is_empty() and number(book.last.id) >= number(journal.id)):
			return false
		if last.money_after != number(book.period.opening_money) or last.stock_after != book.period.opening_stock or last.appraisal_stock_after != book.period.appraisal_opening_stock or book.period.partial:
			return false
	return true


static func trade(book: Dictionary, category: String, amount: int) -> Dictionary:
	if category not in PAYMENTS or amount < 0:
		return {}
	var result := book.duplicate(true)
	var old := number(result.period[category])
	if old < 0 or amount > LIMIT - old:
		return {}
	result.period[category] = str(old + amount)
	return {} if _values(result.period).is_empty() else result


static func record_sale(book: Dictionary, receipt: Dictionary) -> Dictionary:
	if not RecoveryTax.valid_receipt(receipt):
		return {}
	var result := book.duplicate(true)
	var gross := number(receipt.gross)
	var old := number(result.period.storage_income)
	if old < 0 or gross > LIMIT - old:
		return {}
	result.period.storage_income = str(old + gross)
	if gross > 0:
		result.period.tax_sales.append(receipt.duplicate(true))
	return {} if _values(result.period).is_empty() else result


static func purchase(book: Dictionary, count: int, unit_cost: int) -> Dictionary:
	if count < 0 or count > LurePreparation.RULE.stock_limit or unit_cost < 0:
		return {}
	var result := book.duplicate(true)
	for index in count:
		result.stock.append(str(unit_cost))
		result.period.bought_costs.append(str(unit_cost))
	return {} if _values(result.period).is_empty() else result


static func reserve(book: Dictionary, count: int, appraisals: int = 0) -> Dictionary:
	if not book.carried.is_empty() or not book.appraisal_carried.is_empty() or count < 0 or count > book.stock.size() or appraisals < 0 or appraisals > book.appraisal_stock.size():
		return {}
	var result := book.duplicate(true)
	result.carried = result.stock.slice(0, count)
	result.stock = result.stock.slice(count)
	result.appraisal_carried = result.appraisal_stock.slice(0, appraisals)
	result.appraisal_stock = result.appraisal_stock.slice(appraisals)
	return result


static func cancel_reservation(book: Dictionary) -> Dictionary:
	var result := book.duplicate(true)
	result.stock = result.carried + result.stock
	result.carried = []
	result.appraisal_stock = result.appraisal_carried + result.appraisal_stock
	result.appraisal_carried = []
	return result


static func make_report(book: Dictionary, id: int, outcome: String, loot: int, free_used: int, paid_used: int, objective: Dictionary = {}, loot_tax: Dictionary = {}, appraisal_used: int = 0) -> Dictionary:
	var result := {"period": book.period.duplicate(true), "id": str(id), "outcome": outcome,
		"appraisal_count": book.appraisal_carried.size(), "appraisal_used": -1 if outcome == "interrupted" else appraisal_used,
		"loot_income": str(loot), "free_used": free_used, "paid_count": book.carried.size(), "paid_used": paid_used,
		"objective": objective.duplicate(true) if not objective.is_empty() else ExpeditionObjective.result({}),
		"loot_tax": loot_tax.duplicate(true) if not loot_tax.is_empty() else RecoveryTax.receipt(0, 0)}
	return {} if report_summary(result).is_empty() else result


static func report_summary(report: Variant) -> Dictionary:
	if not _keys(report, REPORT_KEYS) or not _valid_period(report.period) \
			or number(report.id) <= 0 or number(report.id) >= LIMIT \
			or report.outcome not in ["safe", "failure", "interrupted"] \
			or not LurePreparation.is_count(report.paid_count, LurePreparation.RULE.stock_limit):
		return {}
	if not RecoveryTax.valid_receipt(report.loot_tax, true):
		return {}
	var objective := ExpeditionObjective.summary(report.objective, report.outcome)
	if objective.is_empty():
		return {}
	var loot := number(report.loot_income)
	var paid := int(report.paid_count)
	var all_stock: Array = report.period.opening_stock + report.period.bought_costs
	if paid > all_stock.size() or loot < 0 or (report.outcome != "safe" and loot != 0):
		return {}
	var used: Array = []
	var lost: Array = []
	var returned: Array = []
	if report.outcome == "interrupted":
		if typeof(report.free_used) not in [TYPE_INT, TYPE_FLOAT] or typeof(report.paid_used) not in [TYPE_INT, TYPE_FLOAT] \
				or report.free_used != -1 or report.paid_used != -1:
			return {}
		lost = all_stock.slice(0, paid)
	else:
		if not LurePreparation.is_count(report.free_used, LurePreparation.RULE.free_count) \
				or not LurePreparation.is_count(report.paid_used, paid) \
				or (report.paid_used > 0 and report.free_used != LurePreparation.RULE.free_count):
			return {}
		used = all_stock.slice(0, int(report.paid_used))
		if report.outcome == "safe":
			returned = all_stock.slice(int(report.paid_used), paid)
		else:
			lost = all_stock.slice(int(report.paid_used), paid)
	var appraisal := appraisal_usage_summary(report)
	if appraisal.is_empty():
		return {}
	var result := _values(report.period, loot, used + lost, objective.reward, report.loot_tax, appraisal.consumed)
	if result.is_empty():
		return {}
	result.merge(appraisal)
	result.erase("consumed")
	result.merge({"objective": objective, "id": report.id, "outcome": report.outcome, "free_used": int(report.free_used),
		"paid_used": int(report.paid_used), "used_cost": total(used), "lost_cost": total(lost),
		"used_unknown": used.count(""), "lost_unknown": lost.count(""),
		"lost_count": lost.size(), "returned_count": returned.size(),
		"stock_after": returned + all_stock.slice(paid)})
	return result


static func finish(report: Dictionary) -> Dictionary:
	var summary := report_summary(report)
	if summary.is_empty():
		return {}
	var result := new_book(summary.money_after, summary.stock_after, false, summary.appraisal_stock_after)
	result.last = report.duplicate(true)
	return result


static func preparation_summary(book: Dictionary) -> Dictionary:
	var result := _values(book.period)
	if not result.is_empty():
		result.stock = book.stock.duplicate()
		result.appraisal_stock = book.appraisal_stock.duplicate()
	return result


static func _appraisal_costs(value: Variant) -> bool:
	return _costs(value, false, AppraisalPreparation.RULE.maximum_count)


static func purchase_appraisals(book: Dictionary, count: int, unit_cost: int) -> Dictionary:
	if count < 0 or count > AppraisalPreparation.RULE.maximum_count or unit_cost <= 0:
		return {}
	var result := book.duplicate(true)
	for index in count:
		result.appraisal_stock.append(str(unit_cost))
		result.period.appraisal_bought_costs.append(str(unit_cost))
	return {} if _values(result.period).is_empty() else result


static func appraisal_usage_summary(report: Dictionary) -> Dictionary:
	if not LurePreparation.is_count(report.appraisal_count, AppraisalPreparation.RULE.maximum_count):
		return {}
	var count := int(report.appraisal_count)
	var stock: Array = report.period.appraisal_opening_stock + report.period.appraisal_bought_costs
	if count > stock.size():
		return {}
	var used: Array = []
	var lost: Array = []
	var returned: Array = []
	if report.outcome == "interrupted":
		if typeof(report.appraisal_used) not in [TYPE_INT, TYPE_FLOAT] or report.appraisal_used != -1:
			return {}
		lost = stock.slice(0, count)
	else:
		if not LurePreparation.is_count(report.appraisal_used, count):
			return {}
		used = stock.slice(0, int(report.appraisal_used))
		if report.outcome == "safe":
			returned = stock.slice(int(report.appraisal_used), count)
		else:
			lost = stock.slice(int(report.appraisal_used), count)
	return {"appraisal_used": int(report.appraisal_used), "appraisal_used_cost": total(used),
		"appraisal_lost_cost": total(lost), "appraisal_returned_count": returned.size(),
		"appraisal_lost_count": lost.size(), "appraisal_stock_after": returned + stock.slice(count),
		"consumed": used + lost}
