class_name MapClueInteractable
extends Interactable

signal clue_read(clue: MapClueDefinition)

@export var clue_definition: MapClueDefinition

var _map_state: ExplorationMapState
var _clue: MapClueDefinition


func _ready() -> void:
	set_interaction_enabled(false)


func configure(state: ExplorationMapState) -> bool:
	if _map_state != null or state == null or not state.is_configured():
		return false
	if clue_definition == null or not clue_definition.get_validation_errors().is_empty():
		return false
	_map_state = state
	_clue = clue_definition.duplicate(true) as MapClueDefinition
	return true


func get_interaction_prompt() -> String:
	if _map_state != null and _clue != null and _map_state.has_clue(_clue.stable_id):
		return "단서 다시 읽기"
	return "손상된 공략도 살펴보기"


func is_interaction_available(interactor: Node = null) -> bool:
	return super.is_interaction_available(interactor) and _map_state != null and _clue != null and not get_tree().paused


func _perform_interaction(interactor: Node) -> bool:
	if interactor == null or not _map_state.record_clue(_clue):
		return false
	clue_read.emit(_map_state.get_clue(_clue.stable_id))
	return true
