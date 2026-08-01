extends Node

var _failures := PackedStringArray()


func _ready() -> void:
	await _run_state_flow()

	if _failures.is_empty():
		GameLog.info(
			&"SmokeTest",
			&"state_flow_passed",
			"final=%s" % GameState.get_state_name(GameState.get_current_state())
		)
		get_tree().quit(0)
		return

	for failure in _failures:
		GameLog.error(&"SmokeTest", &"state_flow_failed", failure)
	get_tree().quit(1)


func _run_state_flow() -> void:
	var expected_flow := [
		GameState.State.BOOT,
		GameState.State.TITLE,
		GameState.State.HUB,
		GameState.State.EXPLORATION,
		GameState.State.RESULTS,
		GameState.State.HUB,
	]

	_expect(
		GameState.get_current_state() == expected_flow[0],
		"Expected initial state Boot."
	)

	for index in range(1, expected_flow.size()):
		var previous_state: int = expected_flow[index - 1]
		var target_state: int = expected_flow[index]
		var accepted := GameState.request_transition(target_state)

		_expect(
			accepted,
			"Transition request was rejected: %s -> %s." % [
				GameState.get_state_name(previous_state),
				GameState.get_state_name(target_state),
			]
		)
		if not accepted:
			return

		var transition: Array = await GameState.state_changed
		_expect(
			transition[0] == previous_state and transition[1] == target_state,
			"Unexpected state_changed payload for %s -> %s." % [
				GameState.get_state_name(previous_state),
				GameState.get_state_name(target_state),
			]
		)
		_expect(
			GameState.get_current_state() == target_state,
			"Current state did not update to %s." % GameState.get_state_name(target_state)
		)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
