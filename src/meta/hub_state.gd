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
	if _active_expedition_id != 0:
		return 0
	_active_expedition_id = _next_expedition_id
	_next_expedition_id += 1
	return _active_expedition_id


func cancel_expedition(expedition_id: int) -> bool:
	if expedition_id <= 0 or expedition_id != _active_expedition_id or _pending_settlement != null:
		return false
	_active_expedition_id = 0
	return true


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
