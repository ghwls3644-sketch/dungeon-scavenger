class_name ProgressStore
extends RefCounted

const SCHEMA_VERSION := 5
const CONTENT_VERSION := "g2_prototype_1"
const MAX_FILE_BYTES := 16 * 1024 * 1024

var _path: String
var _last_error: Error = OK
var _legacy_modules := false


func has_legacy_modules() -> bool:
	return _legacy_modules


func _init(path: String = "user://progress.json") -> void:
	_path = path


func has_file() -> bool:
	return FileAccess.file_exists(_path)


func get_last_error() -> Error:
	return _last_error


func load_data() -> Dictionary:
	_last_error = OK
	_legacy_modules = false
	if not has_file():
		_last_error = ERR_FILE_NOT_FOUND
		return {}
	var file := FileAccess.open(_path, FileAccess.READ)
	if file == null:
		_last_error = FileAccess.get_open_error()
		return {}
	if file.get_length() <= 0 or file.get_length() > MAX_FILE_BYTES:
		_last_error = ERR_INVALID_DATA
		return {}
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK or typeof(json.data) != TYPE_DICTIONARY:
		_last_error = ERR_INVALID_DATA
		return {}
	var data: Dictionary = json.data
	var version: Variant = data.get("schema_version")
	if typeof(version) not in [TYPE_INT, TYPE_FLOAT]:
		_last_error = ERR_INVALID_DATA
		return {}
	# JSON numbers are floats; Array.has() does not coerce int/float variants.
	if (version != 1 and version != 2 and version != 3 and version != 4 and version != SCHEMA_VERSION) or data.get("content_version") != CONTENT_VERSION:
		_last_error = ERR_UNAVAILABLE
		return {}
	if data.size() != 4 or data.get("resume_state") != "hub" or typeof(data.get("hub")) != TYPE_DICTIONARY:
		_last_error = ERR_INVALID_DATA
		return {}
	var hub: Dictionary = data.hub.duplicate(true)
	if version == 1:
		if hub.size() != 4 or hub.has("registered_items"):
			_last_error = ERR_INVALID_DATA
			return {}
		hub["registered_items"] = []
	if version == 1 or version == 2:
		if hub.size() != 5 or not hub.has("registered_items") or hub.has("harness_durability"):
			_last_error = ERR_INVALID_DATA
			return {}
		# Old records never tracked wear; reading must not charge retroactive damage.
		hub["harness_durability"] = HubState.new().get_harness_max_durability()
	if version <= 3:
		if hub.size() != 6 or hub.has("harness_modules"):
			_last_error = ERR_INVALID_DATA
			return {}
		hub["harness_modules"] = HarnessModules.DEFAULT.duplicate()
		_legacy_modules = true
	if version <= 4:
		if hub.size() != 7 or hub.has("harness_upgrades"):
			_last_error = ERR_INVALID_DATA
			return {}
		hub["harness_upgrades"] = []
	if hub.size() != 8 or not HarnessUpgradeRule.is_valid_owned(hub.get("harness_upgrades")) \
			or not hub.has("registered_items") or not HarnessModules.is_valid(hub.get("harness_modules")) \
			or not HubState.is_valid_harness_durability(hub.get("harness_durability")):
		_last_error = ERR_INVALID_DATA
		return {}
	hub["harness_durability"] = int(hub.harness_durability)
	return hub


func save_data(hub: Dictionary, replace_existing: bool = false) -> Error:
	if hub.size() != 8 or not HarnessUpgradeRule.is_valid_owned(hub.get("harness_upgrades")) \
			or not HubState.is_valid_harness_durability(hub.get("harness_durability")) \
			or not HarnessModules.is_valid(hub.get("harness_modules")):
		return ERR_INVALID_DATA
	if has_file() and not replace_existing:
		load_data()
		if _last_error != OK:
			return _last_error
	var text := JSON.stringify({
		"schema_version": SCHEMA_VERSION,
		"content_version": CONTENT_VERSION,
		"resume_state": "hub",
		"hub": hub,
	}, "\t") + "\n"
	if text.to_utf8_buffer().size() > MAX_FILE_BYTES:
		return ERR_OUT_OF_MEMORY
	var temporary_path := _path + ".tmp"
	var file := FileAccess.open(temporary_path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(text)
	file.flush()
	var error := file.get_error()
	if error == OK and file.get_length() != text.to_utf8_buffer().size():
		error = ERR_FILE_CANT_WRITE
	file.close()
	if error != OK:
		DirAccess.remove_absolute(temporary_path)
		return error
	error = DirAccess.rename_absolute(temporary_path, _path)
	if error != OK:
		DirAccess.remove_absolute(temporary_path)
	return error
