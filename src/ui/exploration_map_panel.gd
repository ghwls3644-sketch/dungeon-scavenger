class_name ExplorationMapPanel
extends Control

signal opening

var _state: ExplorationMapState
var _tree_was_paused := false
var _input_enabled := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	%CloseMapButton.pressed.connect(close_map)
	%EditMarkersButton.toggled.connect(_set_marker_editing)
	%MapCanvas.marker_requested.connect(_on_marker_requested)
	hide()


func bind_map(state: ExplorationMapState) -> void:
	close_map()
	if _state != null and _state.changed.is_connected(_refresh_marker_summary):
		_state.changed.disconnect(_refresh_marker_summary)
	_state = state
	if _state != null:
		_state.changed.connect(_refresh_marker_summary)
	%MapCanvas.bind_map(state)
	_refresh_marker_summary()


func set_input_enabled(enabled: bool) -> void:
	_input_enabled = enabled
	if not enabled:
		close_map()


func _input(event: InputEvent) -> void:
	if not _input_enabled:
		return
	if event.is_action_pressed(InputActions.MAP):
		get_viewport().set_input_as_handled()
		if visible:
			close_map()
		else:
			open_map()
	elif visible and event.is_action_pressed(InputActions.PAUSE):
		get_viewport().set_input_as_handled()
		close_map()


func open_map() -> void:
	if not _input_enabled or visible or _state == null or not _state.is_configured():
		return
	# The app closes another exploration menu before this menu takes over its pause.
	opening.emit()
	_tree_was_paused = get_tree().paused
	%MapCanvas.bind_map(_state)
	%VisitSummary.text = "이번 탐험에서 확인한 곳  %d / %d" % [_state.get_visited_count(), _state.get_definition().regions.size()]
	%PassageSummary.text = "확인한 통로  %d / %d   ·   열림 %d   ·   막힘 %d" % [
		_state.get_observed_passage_count(), _state.get_definition().passages.size(),
		_state.get_passage_count_by_status(ExplorationMapState.PassageStatus.OPEN),
		_state.get_passage_count_by_status(ExplorationMapState.PassageStatus.BLOCKED),
	]
	_refresh_marker_summary()
	show()
	get_tree().paused = true
	%CloseMapButton.grab_focus()


func close_map() -> void:
	if is_node_ready():
		%EditMarkersButton.set_pressed_no_signal(false)
		_set_marker_editing(false)
	if not visible:
		return
	hide()
	get_tree().paused = _tree_was_paused


func _exit_tree() -> void:
	if visible and get_tree() != null:
		get_tree().paused = _tree_was_paused

func get_passage_summary_text() -> String:
	return %PassageSummary.text


func _set_marker_editing(enabled: bool) -> void:
	%MapCanvas.set_editing(enabled and visible and _input_enabled)
	%MarkerHelp.text = "빈 곳 클릭: 추가 · 표식 클릭: 삭제" if enabled else "내 메모를 남기려면 표식 편집을 켜세요."


func _on_marker_requested(position: Vector2, marker_id: int) -> void:
	if not visible or not _input_enabled or _state == null or not %EditMarkersButton.button_pressed:
		return
	if marker_id >= 0:
		_state.remove_marker(marker_id)
	else:
		_state.add_marker(position)


func _refresh_marker_summary() -> void:
	%MarkerSummary.text = "개인 표식  %d개" % (_state.get_marker_count() if _state != null else 0)
