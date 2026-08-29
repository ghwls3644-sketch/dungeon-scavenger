class_name ExplorationRun
extends Node

signal run_ended(outcome: ExplorationOutcome)

enum State {
	ACTIVE,
	SAFE_RETURN,
	FAILURE,
}

@export var inventory_path: NodePath

var _state: State = State.ACTIVE
var _inventory: PlayerInventory
var _outcome: ExplorationOutcome


func _ready() -> void:
	if _inventory == null and not inventory_path.is_empty():
		_inventory = get_node_or_null(inventory_path) as PlayerInventory
	assert(_inventory != null, "ExplorationRun requires a PlayerInventory.")


func bind_inventory(inventory: PlayerInventory) -> bool:
	if not is_active() or inventory == null:
		return false
	_inventory = inventory
	return true


func complete_safe_return() -> bool:
	if not _can_complete():
		return false

	var recovered_items := _inventory.take_all_items()
	_outcome = ExplorationOutcome.safe_return(recovered_items)
	_finish(State.SAFE_RETURN)
	return true


func complete_failure() -> bool:
	if not _can_complete():
		return false

	var lost_item_count := _inventory.take_all_items().size()
	_outcome = ExplorationOutcome.failure(lost_item_count)
	_finish(State.FAILURE)
	return true


func get_state() -> State:
	return _state


func is_active() -> bool:
	return _state == State.ACTIVE


func get_outcome() -> ExplorationOutcome:
	return _outcome


func _can_complete() -> bool:
	return is_active() and _inventory != null


func _finish(next_state: State) -> void:
	_state = next_state
	GameLog.info(
		&"ExplorationRun",
		&"run_ended",
		"result=%s" % ("safe_return" if _state == State.SAFE_RETURN else "failure")
	)
	run_ended.emit(_outcome)
