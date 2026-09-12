class_name ExplorationMapState
extends RefCounted

signal changed

var _definition: ExplorationMapDefinition
var _visited: Dictionary = {}
var _current_region: StringName = &""
var _position := Vector2.ZERO


func configure(definition: ExplorationMapDefinition) -> bool:
	if _definition != null or definition == null or not definition.get_validation_errors().is_empty():
		return false
	_definition = definition.duplicate(true) as ExplorationMapDefinition
	return true


func is_configured() -> bool:
	return _definition != null


func get_definition() -> ExplorationMapDefinition:
	return _definition.duplicate(true) as ExplorationMapDefinition if _definition != null else null


func observe_position(position: Vector2) -> void:
	if _definition == null or not position.is_finite():
		return
	_position = position
	var current: StringName = &""
	for region in _definition.regions:
		if region.bounds.has_point(position):
			current = region.stable_id
			break
	var newly_visited := not current.is_empty() and not _visited.has(current)
	if newly_visited:
		_visited[current] = true
	if current != _current_region or newly_visited:
		_current_region = current
		changed.emit()


func is_visited(region_id: StringName) -> bool:
	return _visited.has(region_id)


func get_current_region_id() -> StringName:
	return _current_region


func get_player_position() -> Vector2:
	return _position


func get_visited_count() -> int:
	return _visited.size()
