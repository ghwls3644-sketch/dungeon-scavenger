class_name ExplorationMapPanel
extends Control

signal opening

var _state: ExplorationMapState
var _tree_was_paused := false
var _input_enabled := false
var _showing_clues := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	%CloseMapButton.pressed.connect(close_map)
	%CluesButton.pressed.connect(func(): _set_clue_view(not _showing_clues))
	%EditMarkersButton.toggled.connect(_set_marker_editing)
	%MapCanvas.marker_requested.connect(_on_marker_requested)
	hide()


func bind_map(state: ExplorationMapState) -> void:
	close_map()
	if _state != null and _state.changed.is_connected(_refresh_notes):
		_state.changed.disconnect(_refresh_notes)
	_state = state
	if _state != null:
		_state.changed.connect(_refresh_notes)
	%MapCanvas.bind_map(state)
	_refresh_notes()


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
	var discovered := _state.get_discovered_region_count()
	%VisitSummary.text = "기본 구역  %d / %d" % [_state.get_visited_count() - discovered, _state.get_definition().regions.size()]
	if discovered > 0:
		%VisitSummary.text += " · 잔여 구역 발견 %d" % discovered
	%PassageSummary.text = "확인한 통로  %d / %d   ·   열림 %d   ·   막힘 %d" % [
		_state.get_observed_passage_count(), _state.get_definition().passages.size(),
		_state.get_passage_count_by_status(ExplorationMapState.PassageStatus.OPEN),
		_state.get_passage_count_by_status(ExplorationMapState.PassageStatus.BLOCKED),
	]
	_refresh_notes()
	show()
	get_tree().paused = true
	%CloseMapButton.grab_focus()


func close_map() -> void:
	if is_node_ready():
		_set_clue_view(false)
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
	%MapCanvas.set_editing(enabled and visible and _input_enabled and not _showing_clues)
	%MarkerHelp.text = "빈 곳 클릭: 추가 · 표식 클릭: 삭제" if enabled else "내 메모를 남기려면 표식 편집을 켜세요."


func _on_marker_requested(position: Vector2, marker_id: int) -> void:
	if not visible or not _input_enabled or _showing_clues or _state == null or not %EditMarkersButton.button_pressed:
		return
	if marker_id >= 0:
		_state.remove_marker(marker_id)
	else:
		_state.add_marker(position)


func _refresh_notes() -> void:
	%MarkerSummary.text = "개인 표식  %d개" % (_state.get_marker_count() if _state != null else 0)
	%CluesButton.text = "지도 보기" if _showing_clues else "단서 보기 · %d" % (_state.get_clues().size() if _state != null else 0)
	var entries := PackedStringArray()
	if _state != null:
		for clue in _state.get_clues():
			entries.append("%s\n%s" % [clue.display_name, clue.hint_text])
	%ClueText.text = "\n\n".join(entries) if not entries.is_empty() else "아직 살펴본 단서가 없습니다."


func _set_clue_view(show_clues: bool) -> void:
	_showing_clues = show_clues
	%MapCanvas.visible = not show_clues
	%ClueView.visible = show_clues
	%Legend.visible = not show_clues
	%MarkerTools.visible = not show_clues
	%Description.visible = not show_clues
	%PassageSummary.visible = not show_clues
	%EditMarkersButton.disabled = show_clues
	%EditMarkersButton.set_pressed_no_signal(false)
	_set_marker_editing(false)
	_refresh_notes()
