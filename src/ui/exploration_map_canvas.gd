class_name ExplorationMapCanvas
extends Control

var _state: ExplorationMapState
var _definition: ExplorationMapDefinition


func bind_map(state: ExplorationMapState) -> void:
	_state = state
	_definition = state.get_definition() if state != null else null
	queue_redraw()


func _draw() -> void:
	if _definition == null or _state == null:
		return
	var scale_factor := minf((size.x - 32.0) / _definition.bounds.size.x, (size.y - 32.0) / _definition.bounds.size.y)
	var origin := (size - _definition.bounds.size * scale_factor) * 0.5
	var font := get_theme_default_font()
	for region in _definition.regions:
		var rect := Rect2(_project(region.bounds.position, origin, scale_factor), region.bounds.size * scale_factor)
		var visited := _state.is_visited(region.stable_id)
		var current := region.stable_id == _state.get_current_region_id()
		draw_rect(rect, Color("#233e43") if visited else Color("#19212d"))
		draw_rect(rect, Color("#e8cd89") if current else Color("#637282"), false, 3.0 if current else 1.0)
		draw_string(font, rect.position + Vector2(12, 25), region.display_name, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 24, 18, Color("#f0efe7"))
		var status := "현재 위치" if current else ("방문함" if visited else "미방문")
		draw_string(font, rect.position + Vector2(12, 49), status, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 24, 16, Color("#e8cd89") if current else Color("#b7c4cf"))
	for route in _definition.routes:
		for index in range(route.size() - 1):
			draw_dashed_line(_project(route[index], origin, scale_factor), _project(route[index + 1], origin, scale_factor), Color("#91a3b5"), 2.0, 7.0)
	var entrance := _project(_definition.entrance_position, origin, scale_factor)
	draw_rect(Rect2(entrance - Vector2(7, 7), Vector2(14, 14)), Color("#f0efe7"), false, 2.0)
	draw_string(font, entrance + Vector2(-10, 32), "출구", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#f0efe7"))
	var player := _project(_state.get_player_position(), origin, scale_factor)
	draw_colored_polygon(PackedVector2Array([player + Vector2(0, -9), player + Vector2(8, 7), player + Vector2(-8, 7)]), Color("#e8cd89"))


func _project(point: Vector2, origin: Vector2, scale_factor: float) -> Vector2:
	return origin + (point - _definition.bounds.position) * scale_factor
