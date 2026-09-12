class_name ExplorationMapCanvas
extends Control

signal marker_requested(position: Vector2, marker_id: int)

var _editing := false
var _state: ExplorationMapState
var _definition: ExplorationMapDefinition


func bind_map(state: ExplorationMapState) -> void:
	if _state != null and _state.changed.is_connected(queue_redraw):
		_state.changed.disconnect(queue_redraw)
	_state = state
	if _state != null:
		_state.changed.connect(queue_redraw)
	_definition = state.get_definition() if state != null else null
	queue_redraw()


func _draw() -> void:
	if _definition == null or _state == null:
		return
	var scale_factor := _map_scale()
	if scale_factor <= 0.0:
		return
	var origin := _map_origin(scale_factor)
	var font := get_theme_default_font()
	for region in _state.get_known_regions():
		var rect := Rect2(_project(region.bounds.position, origin, scale_factor), region.bounds.size * scale_factor)
		var visited := _state.is_visited(region.stable_id)
		var current := region.stable_id == _state.get_current_region_id()
		draw_rect(rect, Color("#233e43") if visited else Color("#19212d"))
		draw_rect(rect, Color("#e8cd89") if current else Color("#637282"), false, 3.0 if current else 1.0)
		# Small discovered rooms need their labels outside the player/marker area.
		var compact := rect.size.y < 70.0
		var label_origin := Vector2(rect.end.x + 28, rect.position.y) if compact else rect.position + Vector2(8, 0)
		var label_width := 120.0 if compact else rect.size.x - 16.0
		draw_string(font, label_origin + Vector2(0, 23), region.display_name, HORIZONTAL_ALIGNMENT_LEFT, label_width, 16, Color("#f0efe7"))
		var status := "현재 위치" if current else ("방문함" if visited else "미방문")
		draw_string(font, label_origin + Vector2(0, 44), status, HORIZONTAL_ALIGNMENT_LEFT, label_width, 14, Color("#e8cd89") if current else Color("#b7c4cf"))
	for route in _definition.routes:
		for index in range(route.size() - 1):
			draw_dashed_line(_project(route[index], origin, scale_factor), _project(route[index + 1], origin, scale_factor), Color("#91a3b5"), 2.0, 7.0)
	_draw_passages(origin, scale_factor, font)
	var entrance := _project(_definition.entrance_position, origin, scale_factor)
	draw_rect(Rect2(entrance - Vector2(7, 7), Vector2(14, 14)), Color("#f0efe7"), false, 2.0)
	draw_string(font, entrance + Vector2(-10, 32), "출구", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#f0efe7"))
	_draw_markers(origin, scale_factor, font)
	var player := _project(_state.get_player_position(), origin, scale_factor)
	draw_colored_polygon(PackedVector2Array([player + Vector2(0, -9), player + Vector2(8, 7), player + Vector2(-8, 7)]), Color("#e8cd89"))


func _project(point: Vector2, origin: Vector2, scale_factor: float) -> Vector2:
	return origin + (point - _state.get_known_bounds().position) * scale_factor

func _draw_passages(origin: Vector2, scale_factor: float, font: Font) -> void:
	for passage in _definition.passages:
		var start := _project(passage.start, origin, scale_factor)
		var end := _project(passage.end, origin, scale_factor)
		var center := (start + end) * 0.5
		var status := _state.get_passage_status(passage.stable_id)
		var color := Color("#b7c4cf")
		var label := "미확인"
		if status == ExplorationMapState.PassageStatus.UNKNOWN:
			draw_dashed_line(start, end, color, 2.0, 5.0)
		else:
			color = Color("#89dac3") if status == ExplorationMapState.PassageStatus.OPEN else Color("#ef9a91")
			draw_line(start, end, color, 3.0)
			if status == ExplorationMapState.PassageStatus.OPEN:
				label = "열림"
				draw_circle(center, 6.0, color, false, 2.0)
			else:
				label = "막힘"
				draw_line(center - Vector2(6, 6), center + Vector2(6, 6), color, 3.0)
				draw_line(center + Vector2(-6, 6), center + Vector2(6, -6), color, 3.0)
		var text_position := center + (Vector2(12, 24) if absf(end.x - start.x) > absf(end.y - start.y) else Vector2(12, -10))
		draw_rect(Rect2(text_position + Vector2(-3, -17), Vector2(font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x + 6, 23)), Color("#101823"))
		draw_string(font, text_position, label, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, color)


func set_editing(enabled: bool) -> void:
	_editing = enabled
	mouse_default_cursor_shape = Control.CURSOR_CROSS if enabled else Control.CURSOR_ARROW


func world_to_map(position: Vector2) -> Vector2:
	if _definition == null:
		return Vector2.ZERO
	var scale_factor := _map_scale()
	return _project(position, _map_origin(scale_factor), scale_factor)


func _map_scale() -> float:
	return minf((size.x - 32.0) / _state.get_known_bounds().size.x, (size.y - 32.0) / _state.get_known_bounds().size.y)


func _map_origin(scale_factor: float) -> Vector2:
	return (size - _state.get_known_bounds().size * scale_factor) * 0.5


func _gui_input(event: InputEvent) -> void:
	if not _editing or not is_visible_in_tree() or _state == null or _definition == null:
		return
	if not event is InputEventMouseButton or event.button_index != MOUSE_BUTTON_LEFT or not event.pressed:
		return
	var scale_factor := _map_scale()
	if scale_factor <= 0.0:
		return
	var position_on_map: Vector2 = event.position
	var world_position := (position_on_map - _map_origin(scale_factor)) / scale_factor + _state.get_known_bounds().position
	if not _state.get_known_bounds().has_point(world_position):
		return
	# Hit testing uses pixels so selecting a note works at every map size.
	var nearest_id := -1
	var nearest_distance := 14.0
	var markers := _state.get_markers()
	for marker_id: int in markers:
		var distance := position_on_map.distance_to(world_to_map(markers[marker_id]))
		if distance < nearest_distance:
			nearest_id = marker_id
			nearest_distance = distance
	marker_requested.emit(world_position, nearest_id)
	accept_event()


func _draw_markers(origin: Vector2, scale_factor: float, font: Font) -> void:
	var markers := _state.get_markers()
	for marker_id: int in markers:
		var center := _project(markers[marker_id], origin, scale_factor)
		var diamond := PackedVector2Array([center + Vector2(0, -10), center + Vector2(10, 0), center + Vector2(0, 10), center + Vector2(-10, 0), center + Vector2(0, -10)])
		draw_colored_polygon(diamond, Color("#101823"))
		draw_polyline(diamond, Color("#d6b3ff"), 2.0, true)
		var label := str(marker_id)
		var width := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x
		var text_position := center + Vector2(14, -12)
		text_position.x = clampf(text_position.x, 2.0, size.x - width - 4.0)
		text_position.y = maxf(text_position.y, 18.0)
		draw_rect(Rect2(text_position + Vector2(-2, -15), Vector2(width + 4, 20)), Color("#101823"))
		draw_string(font, text_position, label, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#d6b3ff"))
