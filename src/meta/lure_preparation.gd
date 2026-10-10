class_name LurePreparation
extends RefCounted

# DEV-0413 trial values; separate from the throwing behavior resource.
const RULE := preload("res://src/data/prototype_lure_supply.tres")


static func is_count(value: Variant, maximum: int) -> bool:
	return LureSupplyRule.is_count(value, maximum)


static func valid_save(data: Dictionary, legacy: bool = false) -> bool:
	if not RULE.is_valid() or not is_count(data.get("paid_lures"), RULE.stock_limit) or not is_count(data.get("selected_lures"), RULE.maximum_count):
		return false
	var pending: Variant = data.get("pending_departure")
	if typeof(pending) != TYPE_DICTIONARY:
		return false
	if pending.is_empty():
		return true
	if pending.size() != (4 if legacy else 5) or (not legacy and not pending.has("appraisals")) or pending.get("phase") not in ["reserved", "started"] \
			or not is_count(pending.get("free"), RULE.free_count) or not is_count(pending.get("paid"), RULE.stock_limit):
		return false
	var id := read_nonnegative_integer(pending.get("id"))
	var next_id := read_nonnegative_integer(data.get("next_expedition_id"))
	return id > 0 and id < 9223372036854775807 and next_id == id + 1 \
		and pending.free == mini(int(data.selected_lures), RULE.free_count) \
		and pending.paid == maxi(int(data.selected_lures) - RULE.free_count, 0) \
		and data.paid_lures + pending.paid <= RULE.stock_limit


static func read_nonnegative_integer(value: Variant) -> int:
	if typeof(value) != TYPE_STRING or not value.is_valid_int():
		return -1
	var number: int = value.to_int()
	return number if number >= 0 and str(number) == value else -1
