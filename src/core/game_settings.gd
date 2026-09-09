class_name GameSettings
extends RefCounted

const WINDOW_SIZES := [Vector2i(1152, 648), Vector2i(1280, 720), Vector2i(1600, 900)]

var screen_mode := "windowed"
var window_size_index := 0
var master_volume := 100


func is_valid() -> bool:
	return screen_mode in ["windowed", "fullscreen"] \
		and window_size_index >= 0 and window_size_index < WINDOW_SIZES.size() \
		and master_volume >= 0 and master_volume <= 100


func copy() -> GameSettings:
	var result := GameSettings.new()
	result.screen_mode = screen_mode
	result.window_size_index = window_size_index
	result.master_volume = master_volume
	return result
