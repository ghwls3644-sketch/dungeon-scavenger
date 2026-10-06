class_name ExpeditionLoadout
extends RefCounted

var slot_capacity := 0
var burden_weight := 0.0
var overload_weight := 0.0
var charge_capacity := 0
var starting_charge := 0
# Standalone historical fixtures use all actions. HubState supplies two explicitly.
var harness_modules: Array[String] = HarnessModules.ALL.duplicate()
var harness_upgrades: Array[String] = []
# Historical standalone fixtures retain two weightless tools; HubState is explicit.
var lure_count := 2
var lure_weight := 0.0


func is_valid() -> bool:
	return (
		slot_capacity > 0 and is_finite(burden_weight) and is_finite(overload_weight)
		and burden_weight > 0.0 and overload_weight > burden_weight
		and charge_capacity >= 0 and starting_charge >= 0 and starting_charge <= charge_capacity
		and harness_modules.size() in [2, 3] and HarnessModules.is_valid(harness_modules, harness_modules.size())
		and HarnessUpgradeRule.is_valid_owned(harness_upgrades)
		and lure_count >= 0 and is_finite(lure_weight) and lure_weight >= 0.0
	)


func copy() -> ExpeditionLoadout:
	var result := ExpeditionLoadout.new()
	result.slot_capacity = slot_capacity
	result.burden_weight = burden_weight
	result.overload_weight = overload_weight
	result.charge_capacity = charge_capacity
	result.starting_charge = starting_charge
	result.harness_modules = harness_modules.duplicate()
	result.harness_upgrades = harness_upgrades.duplicate()
	result.lure_count = lure_count
	result.lure_weight = lure_weight
	return result
