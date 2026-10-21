class_name RepeatExplorationProgress
extends RefCounted

const LOST := "lost"
const SEALED := "sealed"
const REDUCED := "reduced"

var _registered: Array
var _stored: Array
var _region_states: Dictionary
var _removed: Array


# In-memory inputs only. This class neither reads HubState nor writes progress files.
func _init(registered: Array = [], stored: Array = [], region_states: Dictionary = {}, removed: Array = []) -> void:
	_registered = registered.duplicate(true)
	_stored = stored.duplicate(true)
	_region_states = region_states.duplicate(true)
	_removed = removed.duplicate(true)


func get_validation_errors(definition: Dictionary) -> PackedStringArray:
	var errors := PackedStringArray()
	var originals: Dictionary = {}
	for item in definition.items:
		if item.original:
			originals[item.id] = true
	_check_ids(_registered, originals, "registered", errors)
	_check_ids(_stored, originals, "stored", errors)
	var regions: Dictionary = {}
	for region in definition.map.regions:
		regions[region.id] = region.bounds
	var candidates: Dictionary = {}
	for pool in definition.pools:
		for candidate in pool.candidates:
			candidates[candidate.id] = pool.region_id
	_check_ids(_removed, candidates, "removed", errors)
	var seen: Dictionary = {}
	for id in _region_states:
		if not _is_id(id) or not regions.has(String(id)) or seen.has(String(id)):
			errors.append("Region state needs a unique known region ID.")
			continue
		seen[String(id)] = true
		var state: Variant = _region_states[id]
		if typeof(state) != TYPE_STRING or state not in [LOST, SEALED, REDUCED]:
			errors.append("Unknown region state.")
		elif state in [LOST, SEALED] and regions[String(id)].has_point(definition.map.entrance):
			errors.append("Entrance region cannot be lost or sealed.")
	for id in _removed:
		if _is_id(id) and candidates.has(String(id)) and _region_states.get(candidates[String(id)], "") != REDUCED:
			errors.append("Removed candidates must belong to an explicitly reduced region.")
	return errors


func get_snapshot() -> Dictionary:
	var states: Dictionary = {}
	var ids: Array = _region_states.keys()
	ids.sort()
	for id in ids:
		states[String(id)] = _region_states[id]
	return {"registered": _sorted_ids(_registered), "stored": _sorted_ids(_stored), "region_states": states, "removed": _sorted_ids(_removed)}


static func _check_ids(values: Array, known: Dictionary, label: String, errors: PackedStringArray) -> void:
	var seen: Dictionary = {}
	for value in values:
		if not _is_id(value) or not known.has(String(value)) or seen.has(String(value)):
			errors.append("Invalid, unknown or duplicate %s ID." % label)
			continue
		seen[String(value)] = true


static func _is_id(value: Variant) -> bool:
	return typeof(value) in [TYPE_STRING, TYPE_STRING_NAME] and StableId.is_valid(StringName(value))


static func _sorted_ids(values: Array) -> Array[String]:
	var result: Array[String] = []
	for value in values:
		result.append(String(value))
	result.sort()
	return result
