class_name HubState
extends RefCounted

# Existing G1 comparison values, not final equipment or balance.
const PROTOTYPE_BAG_SLOTS := [2, 3]

var _loadout := ExpeditionLoadout.new()
var _money := 0
var _stored_items: Array[InventoryItem] = []
var _next_expedition_id := 1
var _active_expedition_id := 0
var _pending_settlement: SettlementResult


func _init() -> void:
	_loadout.slot_capacity = 2
	_loadout.burden_weight = 2.5
	_loadout.overload_weight = 4.0
	_loadout.charge_capacity = 3
	_loadout.starting_charge = 3


func get_available_bag_slots() -> Array[int]:
	return [2, 3]


func select_bag_slots(slots: int) -> bool:
	if slots not in PROTOTYPE_BAG_SLOTS:
		return false
	_loadout.slot_capacity = slots
	return true


func create_departure_loadout() -> ExpeditionLoadout:
	return _loadout.copy()


func get_money() -> int:
	return _money


func get_stored_items() -> Array[InventoryItem]:
	var copies: Array[InventoryItem] = []
	for item in _stored_items:
		copies.append(item.copy())
	return copies


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
	result._stored_items = get_stored_items()
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
	}


static func from_save_data(data: Dictionary, catalog: ItemCatalog) -> HubState:
	if catalog == null or not catalog.is_valid() or data.size() != 4:
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
	restored._money = money
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


static func _read_nonnegative_integer(value: Variant) -> int:
	if typeof(value) != TYPE_STRING or not value.is_valid_int():
		return -1
	var number: int = value.to_int()
	return number if number >= 0 and str(number) == value else -1


func prepare_settlement(expedition_id: int, outcome: ExplorationOutcome, rule: EconomyRule) -> bool:
	if expedition_id <= 0 or expedition_id != _active_expedition_id or _pending_settlement != null:
		return false
	_pending_settlement = SettlementResult.from_outcome(outcome, rule)
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
	_money += income
	_stored_items.append_array(retained)
	_pending_settlement = null
	_active_expedition_id = 0
	return true
