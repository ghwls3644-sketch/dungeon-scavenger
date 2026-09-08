class_name HubState
extends RefCounted

# Existing G1 comparison values, not final equipment or balance.
const PROTOTYPE_BAG_SLOTS := [2, 3]

var _loadout := ExpeditionLoadout.new()


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
