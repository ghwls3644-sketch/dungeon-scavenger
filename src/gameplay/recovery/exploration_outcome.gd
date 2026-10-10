class_name ExplorationOutcome
extends RefCounted

const SUPPLY := preload("res://src/data/prototype_lure_supply.tres")

enum Result {
	SAFE_RETURN,
	FAILURE,
}

var _lure_usage: Dictionary = {}
var _appraisal_usage: Dictionary = {}
var _result: Result = Result.FAILURE
var _recovery_result: RecoveryResult
var _lost_item_count := 0
var _failure_cause: StringName = &""
var _return_method: StringName = &""
var _harness_upgrades: Array[String] = []


static func safe_return(recovered_items: Array[ItemDefinition]) -> ExplorationOutcome:
	var outcome := ExplorationOutcome.new()
	outcome._result = Result.SAFE_RETURN
	outcome._return_method = &"entrance"
	outcome._recovery_result = RecoveryResult.from_recovered_items(recovered_items)
	return outcome


static func safe_return_inventory_items(
	recovered_items: Array[InventoryItem], return_method: StringName = &"entrance", upgrades: Array[String] = []
) -> ExplorationOutcome:
	if not HarnessUpgradeRule.is_valid_owned(upgrades):
		return null
	var outcome := ExplorationOutcome.new()
	outcome._harness_upgrades = upgrades.duplicate()
	outcome._result = Result.SAFE_RETURN
	outcome._return_method = return_method
	outcome._recovery_result = RecoveryResult.from_recovered_inventory_items(recovered_items)
	return outcome


static func failure(lost_item_count: int, cause: StringName = &"") -> ExplorationOutcome:
	var outcome := ExplorationOutcome.new()
	outcome._result = Result.FAILURE
	outcome._lost_item_count = maxi(lost_item_count, 0)
	outcome._failure_cause = cause
	return outcome


func get_result() -> Result:
	return _result


func is_safe_return() -> bool:
	return _result == Result.SAFE_RETURN


func is_failure() -> bool:
	return _result == Result.FAILURE


func get_recovery_result() -> RecoveryResult:
	return _recovery_result


func get_lost_item_count() -> int:
	return _lost_item_count


func get_failure_cause() -> StringName:
	return _failure_cause


func get_return_method() -> StringName:
	return _return_method


func get_harness_upgrades() -> Array[String]:
	return _harness_upgrades.duplicate() if is_safe_return() else []


func record_lure_usage(capacity: int, used: int) -> bool:
	if not _lure_usage.is_empty() or not LureSupplyRule.is_count(capacity, SUPPLY.maximum_count) or not LureSupplyRule.is_count(used, capacity):
		return false
	_lure_usage = {"capacity": capacity, "used": used}
	return true


func get_lure_usage() -> Dictionary:
	return _lure_usage.duplicate()


func get_lure_summary() -> Dictionary:
	if _lure_usage.is_empty():
		return {}
	var free := mini(int(_lure_usage.capacity), SUPPLY.free_count)
	var paid := int(_lure_usage.capacity) - free
	var used_paid := mini(paid, maxi(int(_lure_usage.used) - free, 0))
	return {"free_used": int(_lure_usage.used) - used_paid, "paid_used": used_paid,
		"returned": paid - used_paid if is_safe_return() else 0, "lost": paid if is_failure() else 0}


func record_appraisal_usage(capacity: int, used: int) -> bool:
	if not _appraisal_usage.is_empty() or not LureSupplyRule.is_count(capacity, 100) or not LureSupplyRule.is_count(used, capacity):
		return false
	_appraisal_usage = {"capacity": capacity, "used": used}
	return true


func get_appraisal_usage() -> Dictionary:
	return _appraisal_usage.duplicate()
