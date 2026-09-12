class_name RemainingZoneEntrance
extends StabilizableHazard

signal opened
signal discovered

@export var region_definition: MapRegionDefinition

var _map_state: ExplorationMapState
var _player: PlayerController
var _region: MapRegionDefinition
var _active := false
var _opened := false
var _discovered := false


func configure(map_state: ExplorationMapState, player: PlayerController) -> bool:
	if _map_state != null or map_state == null or not map_state.is_configured() or player == null:
		return false
	if region_definition == null or not region_definition.get_validation_errors().is_empty():
		return false
	_map_state = map_state
	_player = player
	_region = region_definition.duplicate(true) as MapRegionDefinition
	return true


func set_exploration_active(active: bool) -> void:
	_active = active


func is_open() -> bool:
	return _opened


func can_stabilize() -> bool:
	return _active and _map_state != null and not _opened and not get_tree().paused


func stabilize() -> bool:
	if not can_stabilize():
		return false
	_opened = true
	$Barrier/CollisionShape2D.set_deferred("disabled", true)
	queue_redraw()
	opened.emit()
	return true


func get_basic_analysis() -> String:
	if not _active:
		return ""
	return "입구가 안정화되어 지나갈 수 있습니다." if _opened else "틈의 버팀대가 흔들립니다. 안정화하면 지나갈 수 있습니다."


func get_analysis_charge_cost() -> int:
	return 0


func get_precise_analysis() -> String:
	# The free reading already supplies the complete visible information.
	return ""


func _physics_process(_delta: float) -> void:
	if not _active or not _opened or _discovered or get_tree().paused or not is_instance_valid(_player):
		return
	if _map_state.discover_region(_region, _player.position):
		_discovered = true
		queue_redraw()
		discovered.emit()


func _draw() -> void:
	var gate := Rect2(-60, -12, 120, 24)
	if not _opened:
		draw_rect(gate, Color("#9d7550"))
		for offset in range(-48, 49, 24):
			draw_line(Vector2(offset - 8, -10), Vector2(offset + 8, 10), Color("#e8cd89"), 3.0)
		return
	draw_rect(Rect2(-176, -228, 352, 216), Color("#243641"))
	for wall in [Rect2(-200, -252, 400, 24), Rect2(-200, -252, 24, 240), Rect2(176, -252, 24, 240)]:
		draw_rect(wall, Color("#69717d"))
	draw_rect(gate, Color("#345f54"))
	draw_line(Vector2(-54, -10), Vector2(-54, 10), Color("#89dac3"), 4.0)
	draw_line(Vector2(54, -10), Vector2(54, 10), Color("#89dac3"), 4.0)
	if _discovered:
		draw_string(ThemeDB.fallback_font, Vector2(-58, -164), "잔여 구역", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color("#e8cd89"))
