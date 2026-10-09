class_name ExpeditionObjective
extends RefCounted

const RULE := preload("res://src/data/prototype_expedition_objective.tres")


static func valid_offer(value: Variant) -> bool:
	if not RULE.is_valid() or typeof(value) != TYPE_DICTIONARY:
		return false
	if value.is_empty():
		return true
	if value.size() != 4 or not value.has_all(["id", "version", "required", "reward"]) \
			or typeof(value.id) != TYPE_STRING or typeof(value.reward) != TYPE_STRING \
			or not LurePreparation.is_count(value.version, RULE.version) \
			or not LurePreparation.is_count(value.required, 3):
		return false
	# Each supported version has a fixed promise. Unknown/changed definitions are not repriced.
	return value.id == String(RULE.stable_id) and value.version == RULE.version \
		and value.required == RULE.required_count and value.reward == str(RULE.reward)


static func eligible_count(items: Array[InventoryItem]) -> int:
	var count := 0
	for item in items:
		if item == null or not item.is_identified():
			continue
		var definition := item.get_definition()
		if definition != null and definition.category == ItemDefinition.CATEGORY_SCRAP and not definition.is_protected():
			count += 1
	return count


static func result(offer: Dictionary, count: int = 0) -> Dictionary:
	return {"offer": offer.duplicate(true), "count": 0 if offer.is_empty() else count}


static func summary(value: Variant, outcome: String) -> Dictionary:
	if typeof(value) != TYPE_DICTIONARY or value.size() != 2 or not value.has_all(["offer", "count"]) \
			or not valid_offer(value.offer) or not LurePreparation.is_count(value.count, 3) \
			or outcome not in ["safe", "failure", "interrupted"]:
		return {}
	if (value.offer.is_empty() or outcome != "safe") and value.count != 0:
		return {}
	if value.offer.is_empty():
		return {"selected": false, "count": 0, "required": 0, "reward": 0, "status": "free"}
	var achieved: bool = outcome == "safe" and value.count >= value.offer.required
	return {"selected": true, "count": int(value.count), "required": int(value.offer.required),
		"reward": value.offer.reward.to_int() if achieved else 0,
		"status": ("achieved" if achieved else "missed") if outcome == "safe" else outcome}


static func migrate_legacy(hub: Dictionary) -> bool:
	if hub.size() != 12 or hub.has("objective") or typeof(hub.get("costs")) != TYPE_DICTIONARY \
			or typeof(hub.costs.get("last")) != TYPE_DICTIONARY:
		return false
	if not hub.costs.last.is_empty():
		if hub.costs.last.size() != 7 or hub.costs.last.has("objective"):
			return false
		hub.costs.last["objective"] = result({})
	hub["objective"] = {}
	return true
