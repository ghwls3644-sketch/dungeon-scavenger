extends Node

signal transition_started(from_state: int, to_state: int)
signal state_changed(previous_state: int, current_state: int)
signal transition_rejected(current_state: int, requested_state: int, reason: StringName)

enum State {
	BOOT,
	TITLE,
	HUB,
	EXPLORATION,
	RESULTS,
}

const STATE_NAMES := [
	"Boot",
	"Title",
	"Hub",
	"Exploration",
	"Results",
]

const ALLOWED_TRANSITIONS := {
	State.BOOT: [State.TITLE],
	State.TITLE: [State.HUB],
	State.HUB: [State.EXPLORATION],
	State.EXPLORATION: [State.RESULTS],
	State.RESULTS: [State.HUB],
}

const DEBUG_NEXT_STATE := {
	State.BOOT: State.TITLE,
	State.TITLE: State.HUB,
	State.HUB: State.EXPLORATION,
	State.EXPLORATION: State.RESULTS,
	State.RESULTS: State.HUB,
}

const REASON_ALREADY_CURRENT := &"already_current"
const REASON_INVALID_STATE := &"invalid_state"
const REASON_NOT_ALLOWED := &"transition_not_allowed"
const REASON_TRANSITION_IN_PROGRESS := &"transition_in_progress"

var _current_state: State = State.BOOT
var _transition_in_progress := false


func request_transition(target_state: int) -> bool:
	if not _is_valid_state(target_state):
		return _reject_transition(target_state, REASON_INVALID_STATE)

	if _transition_in_progress:
		return _reject_transition(target_state, REASON_TRANSITION_IN_PROGRESS)

	if target_state == _current_state:
		return _reject_transition(target_state, REASON_ALREADY_CURRENT)

	var allowed_targets: Array = ALLOWED_TRANSITIONS.get(_current_state, [])
	if target_state not in allowed_targets:
		return _reject_transition(target_state, REASON_NOT_ALLOWED)

	_transition_in_progress = true
	GameLog.info(
		&"GameState",
		&"transition_started",
		"from=%s to=%s" % [get_state_name(_current_state), get_state_name(target_state)]
	)
	transition_started.emit(_current_state, target_state)
	_complete_transition.call_deferred(target_state)
	return true


func request_next_debug_state() -> bool:
	return request_transition(get_next_debug_state())


func get_next_debug_state() -> State:
	return DEBUG_NEXT_STATE[_current_state]


func get_current_state() -> State:
	return _current_state


func is_transition_in_progress() -> bool:
	return _transition_in_progress


func get_state_name(state: int) -> String:
	if not _is_valid_state(state):
		return "Unknown"
	return STATE_NAMES[state]


func _complete_transition(target_state: State) -> void:
	var previous_state := _current_state
	_current_state = target_state
	_transition_in_progress = false
	GameLog.info(
		&"GameState",
		&"transition_completed",
		"from=%s to=%s" % [get_state_name(previous_state), get_state_name(_current_state)]
	)
	state_changed.emit(previous_state, _current_state)


func _reject_transition(target_state: int, reason: StringName) -> bool:
	GameLog.warning(
		&"GameState",
		&"transition_rejected",
		"current=%s requested=%s reason=%s" % [
			get_state_name(_current_state),
			get_state_name(target_state),
			reason,
		]
	)
	transition_rejected.emit(_current_state, target_state, reason)
	return false


func _is_valid_state(state: int) -> bool:
	return state >= State.BOOT and state <= State.RESULTS
