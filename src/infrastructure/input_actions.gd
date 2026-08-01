class_name InputActions
extends RefCounted

const MOVE_LEFT: StringName = &"move_left"
const MOVE_RIGHT: StringName = &"move_right"
const MOVE_UP: StringName = &"move_up"
const MOVE_DOWN: StringName = &"move_down"
const AIM_LOOK: StringName = &"aim_look"
const INTERACT: StringName = &"interact"
const USE_HARNESS: StringName = &"use_harness"
const USE_TOOL: StringName = &"use_tool"
const INVENTORY: StringName = &"inventory"
const MAP: StringName = &"map"
const QUICK_DROP: StringName = &"quick_drop"
const PAUSE: StringName = &"pause"

const ALL_ACTIONS := [
	MOVE_LEFT,
	MOVE_RIGHT,
	MOVE_UP,
	MOVE_DOWN,
	AIM_LOOK,
	INTERACT,
	USE_HARNESS,
	USE_TOOL,
	INVENTORY,
	MAP,
	QUICK_DROP,
	PAUSE,
]


static func get_move_vector() -> Vector2:
	return Input.get_vector(MOVE_LEFT, MOVE_RIGHT, MOVE_UP, MOVE_DOWN)


static func get_aim_position(viewport: Viewport) -> Vector2:
	return viewport.get_mouse_position()


static func is_pressed(action: StringName) -> bool:
	assert(action in ALL_ACTIONS, "Unknown input action: %s" % action)
	return Input.is_action_pressed(action)


static func is_just_pressed(action: StringName) -> bool:
	assert(action in ALL_ACTIONS, "Unknown input action: %s" % action)
	return Input.is_action_just_pressed(action)


static func is_just_released(action: StringName) -> bool:
	assert(action in ALL_ACTIONS, "Unknown input action: %s" % action)
	return Input.is_action_just_released(action)
