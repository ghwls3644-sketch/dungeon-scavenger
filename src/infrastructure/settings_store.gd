class_name SettingsStore
extends RefCounted

const SCHEMA_VERSION := 1

var _path: String
var _settings := GameSettings.new()
var _writable := true


func _init(path: String = "user://settings.cfg") -> void:
	_path = path


func get_settings() -> GameSettings:
	return _settings.copy()


func is_writable() -> bool:
	return _writable


func load_settings() -> Error:
	_settings = GameSettings.new()
	_writable = true
	if not FileAccess.file_exists(_path):
		return OK
	var config := ConfigFile.new()
	var error := config.load(_path)
	if error != OK:
		return error
	if not config.has_section_key("settings", "schema_version"):
		return ERR_INVALID_DATA
	var version: Variant = config.get_value("settings", "schema_version")
	if typeof(version) != TYPE_INT:
		return ERR_INVALID_DATA
	if version != SCHEMA_VERSION:
		_writable = false
		return ERR_UNAVAILABLE
	if not config.has_section_key("display", "screen_mode") \
			or not config.has_section_key("display", "window_size_index") \
			or not config.has_section_key("audio", "master_volume"):
		return ERR_INVALID_DATA
	var mode: Variant = config.get_value("display", "screen_mode")
	var size_index: Variant = config.get_value("display", "window_size_index")
	var volume: Variant = config.get_value("audio", "master_volume")
	if typeof(mode) != TYPE_STRING or typeof(size_index) != TYPE_INT or typeof(volume) != TYPE_INT:
		return ERR_INVALID_DATA
	var candidate := GameSettings.new()
	candidate.screen_mode = mode
	candidate.window_size_index = size_index
	candidate.master_volume = volume
	if not candidate.is_valid():
		return ERR_INVALID_DATA
	_settings = candidate
	return OK


func save_settings(candidate: GameSettings) -> Error:
	if not _writable:
		return ERR_UNAVAILABLE
	if candidate == null or not candidate.is_valid():
		return ERR_INVALID_DATA
	var config := ConfigFile.new()
	config.set_value("settings", "schema_version", SCHEMA_VERSION)
	config.set_value("display", "screen_mode", candidate.screen_mode)
	config.set_value("display", "window_size_index", candidate.window_size_index)
	config.set_value("audio", "master_volume", candidate.master_volume)
	# Replace only after the complete new file has been written beside the old one.
	var temporary_path := _path + ".tmp"
	var error := config.save(temporary_path)
	if error != OK:
		return error
	error = DirAccess.rename_absolute(temporary_path, _path)
	if error != OK:
		DirAccess.remove_absolute(temporary_path)
		return error
	_settings = candidate.copy()
	return OK
