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
	_money -= checked.get_cost()
	_loadout.harness_upgrades.append(checked.get_id())
	return true


func select_bag_slots(slots: int) -> bool:
	if slots not in PROTOTYPE_BAG_SLOTS:
		return false
	_loadout.slot_capacity = slots
	return true


func create_departure_loadout() -> ExpeditionLoadout:
	return _loadout.copy()


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
	_money -= checked.get_cost()
	_harness_durability += checked.get_amount()
	return true


func begin_expedition() -> int:
	if _active_expedition_id != 0 or _next_expedition_id >= 9223372036854775807:
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
	for index in checked.get_indices():
		_stored_items[index].identify()
	_money -= checked.get_cost()
	return true


func cancel_expedition(expedition_id: int) -> bool:
	if expedition_id <= 0 or expedition_id != _active_expedition_id or _pending_settlement != null:
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
	if income > 9223372036854775807 - _money:
		return null
	return SaleQuote.new(source, selected, prices, income, _money + income)


func apply_sale(quote: SaleQuote, rule: EconomyRule) -> bool:
	if quote == null:
		return false
	var checked := quote_sale(quote.get_indices(), rule)
	if checked == null or not quote.matches(to_save_data(), checked.get_prices()):
		return false
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
	return result


func to_save_data() -> Dictionary:
	if _active_expedition_id != 0 or _pending_settlement != null:
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
	}


static func from_save_data(data: Dictionary, catalog: ItemCatalog) -> HubState:
	if catalog == null or not catalog.is_valid() or data.size() != 8 \
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
	if typeof(value) != TYPE_STRING or not value.is_valid_int():
		return -1
	var number: int = value.to_int()
	return number if number >= 0 and str(number) == value else -1


func prepare_settlement(expedition_id: int, outcome: ExplorationOutcome, rule: EconomyRule) -> bool:
	if expedition_id <= 0 or expedition_id != _active_expedition_id or _pending_settlement != null:
		return false
	_pending_settlement = SettlementResult.from_outcome(outcome, rule, EQUIPMENT_WEAR, _harness_durability)
	return _pending_settlement != null


func get_pending_settlement() -> SettlementResult:
	return _pending_settlement


func apply_settlement(expedition_id: int) -> bool:
	if expedition_id <= 0 or expedition_id != _active_expedition_id or _pending_settlement == null:
		return false
	var income := _pending_settlement.get_net_income()
	if income > 9223372036854775807 - _money:
		return false
	var retained := _pending_settlement.get_retained_items()
	for id in _pending_settlement.get_harness_upgrades():
		if id not in _loadout.harness_upgrades:
			_loadout.harness_upgrades.append(id)
	_money += income
	_stored_items.append_array(retained)
	_harness_durability = _pending_settlement.get_equipment_damage().after
	_pending_settlement = null
	_active_expedition_id = 0
	return true
