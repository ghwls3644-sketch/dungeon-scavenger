class_name ProgressStore
extends RefCounted

const SCHEMA_VERSION := 10
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
	if (version != 1 and version != 2 and version != 3 and version != 4 and version != 5 and version != 6 and version != 7 and version != 8 and version != 9 and version != SCHEMA_VERSION) or data.get("content_version") != CONTENT_VERSION:
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
	if version <= 5:
		if hub.size() != 8 or hub.has("paid_lures") or hub.has("selected_lures") or hub.has("pending_departure"):
			_last_error = ERR_INVALID_DATA
			return {}
		hub["paid_lures"] = 0
		hub["selected_lures"] = 2
		hub["pending_departure"] = {}
	if version <= 6:
		if hub.size() != 11 or hub.has("costs") or not LurePreparation.valid_save(hub, true) \
				or ExpeditionCosts.number(hub.get("money")) < 0:
			_last_error = ERR_INVALID_DATA
			return {}
		hub["costs"] = ExpeditionCosts.legacy_book(hub, false)
	if version <= 7 and not ExpeditionObjective.migrate_legacy(hub):
		_last_error = ERR_INVALID_DATA
		return {}
	if version <= 8 and not RecoveryTax.migrate_legacy(hub):
		_last_error = ERR_INVALID_DATA
		return {}
	if version <= 9 and not AppraisalPreparation.migrate_legacy(hub):
		_last_error = ERR_INVALID_DATA
		return {}
	if hub.size() != 15 or not AppraisalPreparation.valid_save(hub) or not ExpeditionObjective.valid_offer(hub.get("objective")) or not LurePreparation.valid_save(hub) or not ExpeditionCosts.valid_save(hub.get("costs"), hub) \
			or not HarnessUpgradeRule.is_valid_owned(hub.get("harness_upgrades")) \
			or not hub.has("registered_items") or not HarnessModules.is_valid(hub.get("harness_modules")) \
			or not HubState.is_valid_harness_durability(hub.get("harness_durability")):
		_last_error = ERR_INVALID_DATA
		return {}
	hub["harness_durability"] = int(hub.harness_durability)
	hub["paid_lures"] = int(hub.paid_lures)
	hub["selected_lures"] = int(hub.selected_lures)
	hub["paid_appraisals"] = int(hub.paid_appraisals)
	hub["selected_appraisals"] = int(hub.selected_appraisals)
	for sale in hub.costs.period.tax_sales:
		sale.rate = int(sale.rate)
	if not hub.costs.last.is_empty():
		hub.costs.last.loot_tax.rate = int(hub.costs.last.loot_tax.rate)
		for key in ["free_used", "paid_count", "paid_used", "appraisal_count", "appraisal_used"]:
			hub.costs.last[key] = int(hub.costs.last[key])
		for sale in hub.costs.last.period.tax_sales:
			sale.rate = int(sale.rate)
	# Normalize validated JSON numbers so stale-source checks survive migration/reload.
	if not hub.objective.is_empty():
		hub.objective.version = int(hub.objective.version)
		hub.objective.required = int(hub.objective.required)
	if not hub.costs.last.is_empty():
		hub.costs.last.objective.count = int(hub.costs.last.objective.count)
		if not hub.costs.last.objective.offer.is_empty():
			hub.costs.last.objective.offer.version = int(hub.costs.last.objective.offer.version)
			hub.costs.last.objective.offer.required = int(hub.costs.last.objective.offer.required)
	if not hub.pending_departure.is_empty():
		hub.pending_departure.free = int(hub.pending_departure.free)
		hub.pending_departure.paid = int(hub.pending_departure.paid)
		hub.pending_departure.appraisals = int(hub.pending_departure.appraisals)
	return hub


func save_data(hub: Dictionary, replace_existing: bool = false) -> Error:
	if hub.size() != 15 or not AppraisalPreparation.valid_save(hub) or not ExpeditionObjective.valid_offer(hub.get("objective")) or not LurePreparation.valid_save(hub) or not ExpeditionCosts.valid_save(hub.get("costs"), hub) \
			or not HarnessUpgradeRule.is_valid_owned(hub.get("harness_upgrades")) \
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
