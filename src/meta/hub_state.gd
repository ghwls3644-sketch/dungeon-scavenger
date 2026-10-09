class_name HubState
extends RefCounted

# Existing G1 comparison values, not final equipment or balance.
const PROTOTYPE_BAG_SLOTS := [2, 3]
const EQUIPMENT_WEAR := preload("res://src/data/prototype_equipment_wear.tres")

var _loadout := ExpeditionLoadout.new()
var _money := 0
var _harness_durability: int = EQUIPMENT_WEAR.max_durability
var _stored_items: Array[InventoryItem] = []
var _unique_pickups := UniquePickupState.new()
var _next_expedition_id := 1
var _active_expedition_id := 0
var _pending_settlement: SettlementResult
var _paid_lures := 0
var _selected_lures := 2
var _pending_departure: Dictionary = {}
var _return_paid_lures := 0
var _costs := ExpeditionCosts.new_book(0)
var _objective: Dictionary = {}


func _init() -> void:
	_loadout.slot_capacity = 2
	_loadout.burden_weight = 2.5
	_loadout.overload_weight = 4.0
	_loadout.charge_capacity = 3
	_loadout.starting_charge = 3
	_loadout.harness_modules = HarnessModules.DEFAULT.duplicate()


func select_harness_modules(modules: Array, expected_source: Dictionary) -> bool:
	var source := to_save_data()
	if source.is_empty() or source != expected_source or not HarnessModules.is_valid(modules) \
			or modules == _loadout.harness_modules:
		return false
	_loadout.harness_modules.assign(modules)
	return true


func get_available_bag_slots() -> Array[int]:
	return [2, 3]


func quote_harness_upgrade(id: String, rule: HarnessUpgradeRule) -> HarnessUpgradeQuote:
	var source := to_save_data()
	if source.is_empty() or rule == null or not rule.is_valid() \
			or id not in HarnessUpgradeRule.ALL or id in _loadout.harness_upgrades:
		return null
	return HarnessUpgradeQuote.new(source, id, rule)


func apply_harness_upgrade(quote: HarnessUpgradeQuote, rule: HarnessUpgradeRule) -> bool:
	if quote == null:
		return false
	var checked := quote_harness_upgrade(quote.get_id(), rule)
	if checked == null or not checked.can_afford() or not quote.matches(to_save_data(), checked):
		return false
	var costs := ExpeditionCosts.trade(_costs, "upgrade_paid", checked.get_cost())
	if costs.is_empty():
		return false
	_costs = costs
	_money -= checked.get_cost()
	_loadout.harness_upgrades.append(checked.get_id())
	return true


func select_bag_slots(slots: int) -> bool:
	if has_pending_departure() or slots not in PROTOTYPE_BAG_SLOTS:
		return false
	_loadout.slot_capacity = slots
	return true


func create_departure_loadout() -> ExpeditionLoadout:
	var result := _loadout.copy()
	result.lure_count = _selected_lures
	result.lure_weight = LurePreparation.RULE.unit_weight
	return result


func get_money() -> int:
	return _money


func get_harness_durability() -> int:
	return _harness_durability


func get_harness_max_durability() -> int:
	return EQUIPMENT_WEAR.max_durability


static func is_valid_harness_durability(value: Variant) -> bool:
	return EQUIPMENT_WEAR.is_valid() and typeof(value) in [TYPE_INT, TYPE_FLOAT] \
		and is_finite(float(value)) and value == floor(float(value)) \
		and value >= 0 and value <= EQUIPMENT_WEAR.max_durability


func get_stored_items() -> Array[InventoryItem]:
	var copies: Array[InventoryItem] = []
	for item in _stored_items:
		copies.append(item.copy())
	return copies


func can_depart(rule: EconomyRule) -> bool:
	return rule != null and rule.is_valid() and rule.minimum_departure_durability <= get_harness_max_durability() \
		and _harness_durability >= rule.minimum_departure_durability


func quote_repair(amount: int, rule: EconomyRule, supported: bool = false) -> RepairQuote:
	var source := to_save_data()
	if source.is_empty() or rule == null or not rule.is_valid() \
			or rule.minimum_departure_durability > get_harness_max_durability() \
			or amount <= 0 or amount > get_harness_max_durability() - _harness_durability:
		return null
	var cost := rule.get_repair_cost(amount)
	if cost < 0:
		return null
	if supported:
		if amount != rule.minimum_departure_durability - _harness_durability or _money >= cost:
			return null
		cost = 0
	return RepairQuote.new(source, amount, cost, rule, get_harness_max_durability(), supported)


func get_repair_offers(rule: EconomyRule) -> Array[RepairQuote]:
	var offers: Array[RepairQuote] = []
	if rule == null:
		return offers
	var support := quote_repair(rule.minimum_departure_durability - _harness_durability, rule, true)
	if support != null:
		offers.append(support)
	for amount in range(1, get_harness_max_durability() - _harness_durability + 1):
		var quote := quote_repair(amount, rule)
		if quote != null:
			offers.append(quote)
	return offers


func apply_repair(quote: RepairQuote, rule: EconomyRule) -> bool:
	if quote == null:
		return false
	var checked := quote_repair(quote.get_amount(), rule, quote.is_supported())
	if checked == null or not checked.can_afford() or not quote.matches(to_save_data(), checked):
		return false
	var costs := ExpeditionCosts.trade(_costs, "repair_paid", checked.get_cost())
	if costs.is_empty():
		return false
	_costs = costs
	_money -= checked.get_cost()
	_harness_durability += checked.get_amount()
	return true


func begin_expedition() -> int:
	if has_pending_departure() or _active_expedition_id != 0 or _next_expedition_id >= 9223372036854775807:
		return 0
	_active_expedition_id = _next_expedition_id
	_next_expedition_id += 1
	return _active_expedition_id


func quote_appraisal(indices: PackedInt32Array, rule: EconomyRule) -> AppraisalQuote:
	var source := to_save_data()
	if source.is_empty() or rule == null or indices.is_empty():
		return null
	var selected := indices.duplicate()
	selected.sort()
	var previous := -1
	for index in selected:
		if index < 0 or index >= _stored_items.size() or index == previous:
			return null
		if not _stored_items[index].is_valid() or _stored_items[index].is_identified():
			return null
		previous = index
	var cost := rule.get_appraisal_cost(selected.size())
	if cost < 0:
		return null
	return AppraisalQuote.new(source, selected, cost, _money)


func apply_appraisal(quote: AppraisalQuote, rule: EconomyRule) -> bool:
	if quote == null:
		return false
	var checked := quote_appraisal(quote.get_indices(), rule)
	if checked == null or not checked.can_afford() or not quote.matches(to_save_data(), checked.get_cost()):
		return false
	var costs := ExpeditionCosts.trade(_costs, "appraisal_paid", checked.get_cost())
	if costs.is_empty():
		return false
	_costs = costs
	for index in checked.get_indices():
		_stored_items[index].identify()
	_money -= checked.get_cost()
	return true


func cancel_expedition(expedition_id: int) -> bool:
	if has_pending_departure() or expedition_id <= 0 or expedition_id != _active_expedition_id or _pending_settlement != null:
		return false
	_active_expedition_id = 0
	return true


func get_sale_offers(rule: EconomyRule) -> Array[Dictionary]:
	var offers: Array[Dictionary] = []
	for item in _stored_items:
		var status := SaleQuote.get_item_status(item, rule)
		var price := rule.get_price(item.get_definition().stable_id) if status == SaleQuote.Status.AVAILABLE else -1
		offers.append({"item": item.copy(), "status": status, "price": price})
	return offers


func quote_sale(indices: PackedInt32Array, rule: EconomyRule) -> SaleQuote:
	var source := to_save_data()
	if source.is_empty() or indices.is_empty() or rule == null or not rule.is_valid():
		return null
	var selected := indices.duplicate()
	selected.sort()
	var previous := -1
	var income := 0
	var prices: Array[int] = []
	for index in selected:
		if index < 0 or index >= _stored_items.size() or index == previous:
			return null
		var item := _stored_items[index]
		if SaleQuote.get_item_status(item, rule) != SaleQuote.Status.AVAILABLE:
			return null
		var price := rule.get_price(item.get_definition().stable_id)
		if price > 9223372036854775807 - income:
			return null
		income += price
		prices.append(price)
		previous = index
	if income > 9223372036854775807 - _money or _paid_lures + _return_paid_lures > LurePreparation.RULE.stock_limit:
		return null
	return SaleQuote.new(source, selected, prices, income, _money + income)


func apply_sale(quote: SaleQuote, rule: EconomyRule) -> bool:
	if quote == null:
		return false
	var checked := quote_sale(quote.get_indices(), rule)
	if checked == null or not quote.matches(to_save_data(), checked.get_prices()):
		return false
	var costs := ExpeditionCosts.trade(_costs, "storage_income", checked.get_income())
	if costs.is_empty():
		return false
	_costs = costs
	var selected := checked.get_indices()
	selected.reverse()
	for index in selected:
		_stored_items.remove_at(index)
	_money += checked.get_income()
	return true


func copy() -> HubState:
	var result := HubState.new()
	result._loadout = _loadout.copy()
	result._money = _money
	result._harness_durability = _harness_durability
	result._stored_items = get_stored_items()
	result._unique_pickups = _unique_pickups.copy()
	result._next_expedition_id = _next_expedition_id
	result._active_expedition_id = _active_expedition_id
	result._pending_settlement = _pending_settlement
	result._paid_lures = _paid_lures
	result._selected_lures = _selected_lures
	result._pending_departure = _pending_departure.duplicate(true)
	result._return_paid_lures = _return_paid_lures
	result._costs = _costs.duplicate(true)
	result._objective = _objective.duplicate(true)
	return result


func to_save_data() -> Dictionary:
	if _active_expedition_id != 0 or _pending_settlement != null or has_pending_departure():
		return {}
	return to_progress_data()


# Only the durable hub snapshot and departure journal; never serialize live loot.
func to_progress_data() -> Dictionary:
	if _pending_settlement != null or (_active_expedition_id != 0 and not has_pending_departure()):
		return {}
	var items: Array[Dictionary] = []
	for item in _stored_items:
		items.append({
			"id": String(item.get_definition().stable_id),
			"identified": item.is_identified(),
			"risk_hint": item.get_risk_hint(),
		})
	# Decimal strings preserve the full int64 range through JSON.
	return {
		"money": str(_money),
		"bag_slots": _loadout.slot_capacity,
		"next_expedition_id": str(_next_expedition_id),
		"stored_items": items,
		"registered_items": _unique_pickups.to_save_data(),
		"harness_durability": _harness_durability,
		"harness_modules": _loadout.harness_modules.duplicate(),
		"harness_upgrades": _loadout.harness_upgrades.duplicate(),
		"paid_lures": _paid_lures,
		"selected_lures": _selected_lures,
		"pending_departure": _pending_departure.duplicate(true),
		"costs": _costs.duplicate(true),
		"objective": _objective.duplicate(true),
	}


static func from_save_data(data: Dictionary, catalog: ItemCatalog) -> HubState:
	if catalog == null or not catalog.is_valid() or data.size() != 13 or not ExpeditionObjective.valid_offer(data.get("objective")) or not LurePreparation.valid_save(data) \
			or not ExpeditionCosts.valid_save(data.get("costs"), data) \
			or not HarnessUpgradeRule.is_valid_owned(data.get("harness_upgrades")) \
			or not is_valid_harness_durability(data.get("harness_durability")) \
			or not HarnessModules.is_valid(data.get("harness_modules")):
		return null
	var unique := UniquePickupState.from_save_data(data.get("registered_items"), catalog)
	if unique == null:
		return null
	var money := _read_nonnegative_integer(data.get("money"))
	var next_id := _read_nonnegative_integer(data.get("next_expedition_id"))
	var slots: Variant = data.get("bag_slots")
	var items: Variant = data.get("stored_items")
	if money < 0 or next_id <= 0 or typeof(slots) not in [TYPE_INT, TYPE_FLOAT] \
			or not is_finite(float(slots)) or slots != floor(float(slots)) \
			or int(slots) not in PROTOTYPE_BAG_SLOTS or typeof(items) != TYPE_ARRAY:
		return null
	var restored := HubState.new()
	restored._unique_pickups = unique
	restored._money = money
	restored._harness_durability = int(data.harness_durability)
	restored._loadout.harness_modules.assign(data.harness_modules)
	restored._loadout.harness_upgrades.assign(data.harness_upgrades)
	restored._next_expedition_id = next_id
	restored.select_bag_slots(int(slots))
	restored._paid_lures = int(data.paid_lures)
	restored._selected_lures = int(data.selected_lures)
	restored._pending_departure = data.pending_departure.duplicate(true)
	restored._costs = data.costs.duplicate(true)
	restored._objective = data.objective.duplicate(true)
	if restored.has_pending_departure():
		restored._active_expedition_id = restored._pending_departure.id.to_int()
	for raw_item in items:
		if typeof(raw_item) != TYPE_DICTIONARY or raw_item.size() != 3 \
				or typeof(raw_item.get("id")) != TYPE_STRING \
				or typeof(raw_item.get("identified")) != TYPE_BOOL \
				or typeof(raw_item.get("risk_hint")) != TYPE_STRING:
			return null
		var definition := catalog.find_item(StringName(raw_item.id))
		if definition == null:
			return null
		restored._stored_items.append(InventoryItem.from_definition(definition, raw_item.identified, raw_item.risk_hint))
	return restored


func get_registered_items() -> Array[InventoryItem]:
	return _unique_pickups.get_items()


func get_excluded_original_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for item in _unique_pickups.get_items() + _stored_items:
		var definition := item.get_definition()
		if definition.is_original() and definition.stable_id not in ids:
			ids.append(definition.stable_id)
	return ids


func get_registration_reason(index: int) -> String:
	if index < 0 or index >= _stored_items.size():
		return "물품을 선택하세요."
	var item := _stored_items[index]
	if not item.is_identified():
		return "미확인 · 감정 필요"
	var definition := item.get_definition()
	if not definition.is_original():
		return "원본 등록 대상이 아닙니다."
	if _unique_pickups.contains(definition.stable_id):
		return "이미 등록한 원본입니다."
	if definition.registration_text.strip_edges().is_empty():
		return "등록 안내가 준비되지 않았습니다."
	return ""


func quote_registration(index: int) -> RegistrationQuote:
	var source := to_save_data()
	if source.is_empty() or not get_registration_reason(index).is_empty():
		return null
	return RegistrationQuote.new(source, index)


func apply_registration(quote: RegistrationQuote) -> bool:
	if quote == null or not quote.matches(to_save_data()) or quote_registration(quote.get_index()) == null:
		return false
	if not _unique_pickups.register(_stored_items[quote.get_index()]):
		return false
	_stored_items.remove_at(quote.get_index())
	return true


static func _read_nonnegative_integer(value: Variant) -> int:
	return LurePreparation.read_nonnegative_integer(value)


func prepare_settlement(expedition_id: int, outcome: ExplorationOutcome, rule: EconomyRule) -> bool:
	if expedition_id <= 0 or expedition_id != _active_expedition_id or _pending_settlement != null:
		return false
	var returned := 0
	var free_used := 0
	var paid_used := 0
	if has_pending_departure():
		var tools := outcome.get_lure_usage() if outcome != null else {}
		if _pending_departure.phase != "started" or tools.size() != 2 \
				or tools.get("capacity") != _selected_lures \
				or not LurePreparation.is_count(tools.get("used"), _selected_lures):
			return false
		free_used = mini(int(tools.used), int(_pending_departure.free))
		paid_used = int(tools.used) - free_used
		returned = int(_pending_departure.paid) - paid_used if outcome.is_safe_return() else 0
	var settlement := SettlementResult.from_outcome(outcome, rule, EQUIPMENT_WEAR, _harness_durability)
	if settlement == null:
		return false
	var count := ExpeditionObjective.eligible_count(outcome.get_recovery_result().get_recovered_inventory_items()) if outcome.is_safe_return() else 0
	if not settlement.set_objective(ExpeditionObjective.result(_objective, count)):
		return false
	var report := ExpeditionCosts.make_report(_costs, expedition_id, "failure" if outcome.is_failure() else "safe", settlement.get_sales_income(), free_used, paid_used, settlement.get_objective_result())
	if not settlement.set_cost_report(report):
		return false
	_return_paid_lures = returned
	_pending_settlement = settlement
	return true


func get_pending_settlement() -> SettlementResult:
	return _pending_settlement


func apply_settlement(expedition_id: int) -> bool:
	if expedition_id <= 0 or expedition_id != _active_expedition_id or _pending_settlement == null:
		return false
	var income := _pending_settlement.get_net_income()
	if income > 9223372036854775807 - _money or _paid_lures + _return_paid_lures > LurePreparation.RULE.stock_limit:
		return false
	var costs := ExpeditionCosts.finish(_pending_settlement.get_cost_report())
	if costs.is_empty() or costs.stock.size() != _paid_lures + _return_paid_lures:
		return false
	var retained := _pending_settlement.get_retained_items()
	for id in _pending_settlement.get_harness_upgrades():
		if id not in _loadout.harness_upgrades:
			_loadout.harness_upgrades.append(id)
	_paid_lures += _return_paid_lures
	_return_paid_lures = 0
	_pending_departure.clear()
	_costs = costs
	_objective.clear()
	_money += income
	_stored_items.append_array(retained)
	_harness_durability = _pending_settlement.get_equipment_damage().after
	_pending_settlement = null
	_active_expedition_id = 0
	return true


func get_paid_lures() -> int:
	return _paid_lures


func quote_lures(count: Variant, rule: LureSupplyRule = LurePreparation.RULE) -> LurePreparationQuote:
	var source := to_save_data()
	if source.is_empty() or rule == null or not rule.is_valid() or not LurePreparation.is_count(count, rule.maximum_count):
		return null
	return LurePreparationQuote.new(source, int(count), rule)


func apply_lures(quote: LurePreparationQuote, rule: LureSupplyRule = LurePreparation.RULE) -> bool:
	if quote == null:
		return false
	var checked := quote_lures(quote.get_count(), rule)
	if checked == null or not checked.can_afford() or not quote.matches(to_save_data(), checked):
		return false
	var costs := ExpeditionCosts.purchase(_costs, checked.get_bought_count(), rule.unit_price)
	if costs.is_empty():
		return false
	_costs = costs
	_money -= checked.get_cost()
	_paid_lures += checked.get_bought_count()
	_selected_lures = checked.get_count()
	return true


func has_prepared_lures() -> bool:
	return _paid_lures >= maxi(_selected_lures - LurePreparation.RULE.free_count, 0)


func has_pending_departure() -> bool:
	return not _pending_departure.is_empty()


func reserve_departure() -> int:
	if not has_prepared_lures():
		return 0
	var paid := maxi(_selected_lures - LurePreparation.RULE.free_count, 0)
	var costs := ExpeditionCosts.reserve(_costs, paid)
	if costs.is_empty():
		return 0
	var id := begin_expedition()
	if id == 0:
		return 0
	_costs = costs
	_paid_lures -= paid
	_pending_departure = {"id": str(id), "phase": "reserved", "free": mini(_selected_lures, LurePreparation.RULE.free_count), "paid": paid}
	return id


func mark_departure_started(id: int) -> bool:
	if not has_pending_departure() or _pending_departure.phase != "reserved" or _pending_departure.id != str(id):
		return false
	_pending_departure.phase = "started"
	return true


# Call on a copy, then save successfully before enabling any hub actions.
func recover_departure() -> bool:
	if not has_pending_departure() or _pending_settlement != null:
		return false
	if _pending_departure.phase == "reserved":
		_costs = ExpeditionCosts.cancel_reservation(_costs)
		_paid_lures += int(_pending_departure.paid)
	else:
		var report := ExpeditionCosts.make_report(_costs, int(_pending_departure.id), "interrupted", 0, -1, -1, ExpeditionObjective.result(_objective))
		var costs := ExpeditionCosts.finish(report)
		if costs.is_empty():
			return false
		_costs = costs
		_objective.clear()
	_pending_departure.clear()
	_active_expedition_id = 0
	return true


func get_preparation_costs() -> Dictionary:
	return ExpeditionCosts.preparation_summary(_costs)


func get_last_costs() -> Dictionary:
	return ExpeditionCosts.report_summary(_costs.last) if not _costs.last.is_empty() else {}


func get_objective_offer() -> Dictionary:
	return _objective.duplicate(true)


func select_objective(offer: Dictionary, expected_source: Dictionary) -> bool:
	var source := to_save_data()
	if source.is_empty() or source != expected_source or not ExpeditionObjective.valid_offer(offer) or offer == _objective:
		return false
	_objective = offer.duplicate(true)
	return true
