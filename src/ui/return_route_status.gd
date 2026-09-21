class_name ReturnRouteStatus
extends PanelContainer

const DIRECTIONS := ["오른쪽", "오른쪽 아래", "아래", "왼쪽 아래", "왼쪽", "왼쪽 위", "위", "오른쪽 위"]

var _state: ExplorationMapState
var _entrance := Vector2.ZERO
var _active := false
var _direction := Vector2.ZERO


func _ready() -> void:
	set_active(false)


func bind_map(state: ExplorationMapState) -> void:
	set_active(false)
	_state = state if state != null and state.is_configured() else null
	_entrance = _state.get_definition().entrance_position if _state != null else Vector2.ZERO


func set_active(active: bool) -> void:
	_active = active and _state != null
	if not _active:
		hide()
		_direction = Vector2.ZERO
		%Direction.text = ""
		%Passages.text = ""
		%Arrow.hide()


func refresh(map_to_screen: Transform2D, can_return: bool, menu_visible := false) -> void:
	if not _active or _state == null:
		return
	if menu_visible:
		hide()
		return
	# Only public map coordinates and recorded observations enter this view.
	var delta := map_to_screen.basis_xform(_entrance - _state.get_player_position())
	_direction = delta.normalized() if delta.is_finite() and delta.length_squared() > 0.0001 else Vector2.ZERO
	%Arrow.visible = not can_return and not _direction.is_zero_approx()
	if can_return:
		%Direction.text = "입구 · E로 귀환 가능"
	elif _direction.is_zero_approx():
		%Direction.text = "입구 위치 · E 안내 확인"
	else:
		var index := posmod(roundi(_direction.angle() / (PI / 4.0)), DIRECTIONS.size())
		%Direction.text = "입구 방향 · %s" % DIRECTIONS[index]
		%Arrow.rotation = _direction.angle()
	%Passages.text = "통로 기록 · 열림 %d · 막힘 %d · 미확인 %d" % [
		_state.get_passage_count_by_status(ExplorationMapState.PassageStatus.OPEN),
		_state.get_passage_count_by_status(ExplorationMapState.PassageStatus.BLOCKED),
		_state.get_passage_count_by_status(ExplorationMapState.PassageStatus.UNKNOWN),
	]
	show()


func get_direction_text() -> String:
	return %Direction.text


func get_passage_text() -> String:
	return %Passages.text


func get_arrow_direction() -> Vector2:
	return _direction
