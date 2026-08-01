extends Node

const DEV_STATE_ARGUMENT_PREFIX := "--dev-state="
const INVALID_STATE := -1


func _ready() -> void:
	if not OS.is_debug_build():
		return

	var requested_name := _get_requested_state_name()
	if requested_name.is_empty():
		return

	var target_state := _parse_state_name(requested_name)
	if target_state == INVALID_STATE:
		GameLog.warning(
			&"DevEntry",
			&"invalid_state_argument",
			"value=%s" % requested_name
		)
		return

	await _enter_state(target_state)


func _get_requested_state_name() -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with(DEV_STATE_ARGUMENT_PREFIX):
			return argument.trim_prefix(DEV_STATE_ARGUMENT_PREFIX)
	return ""


func _parse_state_name(state_name: String) -> int:
	match state_name.to_lower():
		"boot":
			return GameState.State.BOOT
		"title":
			return GameState.State.TITLE
		"hub":
			return GameState.State.HUB
		"exploration":
			return GameState.State.EXPLORATION
		"results":
			return GameState.State.RESULTS
		_:
			return INVALID_STATE


func _enter_state(target_state: int) -> void:
	var entry_flow := [
		GameState.State.BOOT,
		GameState.State.TITLE,
		GameState.State.HUB,
		GameState.State.EXPLORATION,
		GameState.State.RESULTS,
	]
	var target_index := entry_flow.find(target_state)

	if GameState.get_current_state() != GameState.State.BOOT or target_index < 0:
		GameLog.error(
			&"DevEntry",
			&"entry_unavailable",
			"current=%s target=%s" % [
				GameState.get_state_name(GameState.get_current_state()),
				GameState.get_state_name(target_state),
			]
		)
		return

	GameLog.info(
		&"DevEntry",
		&"entry_requested",
		"target=%s" % GameState.get_state_name(target_state)
	)

	for index in range(1, target_index + 1):
		var next_state: int = entry_flow[index]
		if not GameState.request_transition(next_state):
			GameLog.error(
				&"DevEntry",
				&"entry_failed",
				"target=%s" % GameState.get_state_name(target_state)
			)
			return
		await GameState.state_changed

	GameLog.info(
		&"DevEntry",
		&"entry_ready",
		"state=%s" % GameState.get_state_name(GameState.get_current_state())
	)
