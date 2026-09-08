class_name ExpeditionLoadout
extends RefCounted

var slot_capacity := 0
var burden_weight := 0.0
var overload_weight := 0.0
var charge_capacity := 0
var starting_charge := 0


func is_valid() -> bool:
	return (
		slot_capacity > 0 and is_finite(burden_weight) and is_finite(overload_weight)
		and burden_weight > 0.0 and overload_weight > burden_weight
		and charge_capacity >= 0 and starting_charge >= 0 and starting_charge <= charge_capacity
	)


func copy() -> ExpeditionLoadout:
	var result := ExpeditionLoadout.new()
	result.slot_capacity = slot_capacity
	result.burden_weight = burden_weight
	result.overload_weight = overload_weight
	result.charge_capacity = charge_capacity
	result.starting_charge = starting_charge
	return result
