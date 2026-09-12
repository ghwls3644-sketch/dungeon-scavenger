class_name ExplorationMapState
extends RefCounted

signal changed

enum PassageStatus { UNKNOWN, OPEN, BLOCKED }

var _definition: ExplorationMapDefinition
var _visited: Dictionary = {}
var _passage_observations: Dictionary = {}
var _current_region: StringName = &""
var _position := Vector2.ZERO
var _markers: Dictionary = {}
var _next_marker_id := 1
var _clues: Dictionary = {}
var _discovered_regions: Dictionary = {}


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
	for region in get_known_regions():
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

func observe_passage(passage_id: StringName, status: PassageStatus) -> bool:
	if _definition == null or status not in [PassageStatus.OPEN, PassageStatus.BLOCKED]:
		return false
	var known_id := false
	for passage in _definition.passages:
		if passage.stable_id == passage_id:
			known_id = true
			break
	if not known_id:
		return false
	if get_passage_status(passage_id) != status:
		_passage_observations[passage_id] = status
		changed.emit()
	return true


func get_passage_status(passage_id: StringName) -> PassageStatus:
	return _passage_observations.get(passage_id, PassageStatus.UNKNOWN)


func get_observed_passage_count() -> int:
	return _passage_observations.size()


func get_passage_count_by_status(status: PassageStatus) -> int:
	var count := 0
	if _definition != null:
		for passage in _definition.passages:
			if get_passage_status(passage.stable_id) == status:
				count += 1
	return count


# Personal notes never change visits, passage observations, or the fixed map.
func add_marker(position: Vector2) -> int:
	if _definition == null or not position.is_finite() or not get_known_bounds().has_point(position):
		return -1
	for marker_id: int in _markers:
		if (_markers[marker_id] as Vector2).is_equal_approx(position):
			return marker_id
	var marker_id := _next_marker_id
	_next_marker_id += 1
	_markers[marker_id] = position
	changed.emit()
	return marker_id


func remove_marker(marker_id: int) -> bool:
	if not _markers.erase(marker_id):
		return false
	changed.emit()
	return true


func get_markers() -> Dictionary:
	return _markers.duplicate()


func get_marker_count() -> int:
	return _markers.size()


func record_clue(clue: MapClueDefinition) -> bool:
	if _definition == null or clue == null or not clue.get_validation_errors().is_empty():
		return false
	# Re-reading never replaces or duplicates the first observation.
	if not _clues.has(clue.stable_id):
		_clues[clue.stable_id] = clue.duplicate(true)
		changed.emit()
	return true


func has_clue(clue_id: StringName) -> bool:
	return _clues.has(clue_id)


func get_clue(clue_id: StringName) -> MapClueDefinition:
	return _clues[clue_id].duplicate(true) as MapClueDefinition if _clues.has(clue_id) else null


func get_clues() -> Array[MapClueDefinition]:
	var copies: Array[MapClueDefinition] = []
	for clue_id: StringName in _clues:
		copies.append(get_clue(clue_id))
	return copies


# Only actual entry publishes a region. The fixed official map stays unchanged.
func discover_region(region: MapRegionDefinition, position: Vector2) -> bool:
	if _definition == null or region == null or not region.get_validation_errors().is_empty():
		return false
	if not position.is_finite() or not region.bounds.has_point(position):
		return false
	for known in _definition.regions:
		if known.stable_id == region.stable_id or known.bounds.intersects(region.bounds):
			return false
	if _discovered_regions.has(region.stable_id):
		return true
	for known: MapRegionDefinition in _discovered_regions.values():
		if known.bounds.intersects(region.bounds):
			return false
	_discovered_regions[region.stable_id] = region.duplicate(true)
	observe_position(position)
	return true


func get_discovered_region_count() -> int:
	return _discovered_regions.size()


func get_known_regions() -> Array[MapRegionDefinition]:
	var copies: Array[MapRegionDefinition] = []
	if _definition != null:
		for region in _definition.regions:
			copies.append(region.duplicate(true) as MapRegionDefinition)
	for region: MapRegionDefinition in _discovered_regions.values():
		copies.append(region.duplicate(true) as MapRegionDefinition)
	return copies


func get_known_bounds() -> Rect2:
	var bounds := _definition.bounds if _definition != null else Rect2()
	for region: MapRegionDefinition in _discovered_regions.values():
		bounds = bounds.merge(region.bounds)
	return bounds
