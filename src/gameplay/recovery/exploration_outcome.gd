class_name ExplorationOutcome
extends RefCounted

enum Result {
	SAFE_RETURN,
	FAILURE,
}

var _result: Result = Result.FAILURE
var _recovery_result: RecoveryResult
var _lost_item_count := 0


static func safe_return(recovered_items: Array[ItemDefinition]) -> ExplorationOutcome:
	var outcome := ExplorationOutcome.new()
	outcome._result = Result.SAFE_RETURN
	outcome._recovery_result = RecoveryResult.from_recovered_items(recovered_items)
	return outcome


static func safe_return_inventory_items(
	recovered_items: Array[InventoryItem]
) -> ExplorationOutcome:
	var outcome := ExplorationOutcome.new()
	outcome._result = Result.SAFE_RETURN
	outcome._recovery_result = RecoveryResult.from_recovered_inventory_items(recovered_items)
	return outcome


static func failure(lost_item_count: int) -> ExplorationOutcome:
	var outcome := ExplorationOutcome.new()
	outcome._result = Result.FAILURE
	outcome._lost_item_count = maxi(lost_item_count, 0)
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
