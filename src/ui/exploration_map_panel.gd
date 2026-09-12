class_name ExplorationMapPanel
extends Control

signal opening

var _state: ExplorationMapState
var _tree_was_paused := false
var _input_enabled := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	%CloseMapButton.pressed.connect(close_map)
	hide()


func bind_map(state: ExplorationMapState) -> void:
	close_map()
	_state = state


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
	show()
	get_tree().paused = true
	%CloseMapButton.grab_focus()


func close_map() -> void:
	if not visible:
		return
	hide()
	get_tree().paused = _tree_was_paused


func _exit_tree() -> void:
	if visible and get_tree() != null:
		get_tree().paused = _tree_was_paused
