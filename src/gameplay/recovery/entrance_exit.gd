class_name EntranceExit
extends Interactable

@export var exploration_run_path: NodePath

var _exploration_run: ExplorationRun


func _ready() -> void:
	if _exploration_run == null and not exploration_run_path.is_empty():
		_exploration_run = get_node_or_null(exploration_run_path) as ExplorationRun
	assert(_exploration_run != null, "EntranceExit requires an ExplorationRun.")


func bind_exploration_run(exploration_run: ExplorationRun) -> bool:
	if exploration_run == null:
		return false
	_exploration_run = exploration_run
	return true


func is_interaction_available(interactor: Node = null) -> bool:
	if not super.is_interaction_available(interactor):
		return false
	return _exploration_run != null and _exploration_run.is_active()


func _perform_interaction(_interactor: Node) -> bool:
	return _exploration_run != null and _exploration_run.complete_safe_return()
