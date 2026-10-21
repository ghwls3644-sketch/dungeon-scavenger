class_name ExpeditionSeed
extends RefCounted

# Version of the existing fixed prototype content, not a new candidate pool.
const CONTENT_VERSION := "g2_prototype_1"
const GENERATION_VERSION := RepeatVisitGenerator.GENERATION_VERSION
const KEYS := ["id", "seed", "content_version", "generation_version"]
static var _last_issued: Variant = null


static func issue(id: int, previous: Dictionary) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var seed_value: int = (int(rng.randi()) << 32) | int(rng.randi())
	# Avoid an immediate repeat, including requests discarded before saving.
	var excluded: Array = [_last_issued, previous.get("seed")]
	for offset in range(3):
		var candidate := str(seed_value ^ offset)
		if candidate not in excluded:
			_last_issued = candidate
			return {"id": str(id), "seed": candidate,
				"content_version": CONTENT_VERSION, "generation_version": GENERATION_VERSION}
	return {}


static func unknown(id: String) -> Dictionary:
	# Pre-11 visits never had a seed. Do not invent one on migration.
	return {"id": id, "seed": null, "content_version": "", "generation_version": ""}


static func valid_save(hub: Dictionary) -> bool:
	var record: Variant = hub.get("visit_seed")
	var pending: Variant = hub.get("pending_departure")
	if typeof(record) != TYPE_DICTIONARY or typeof(pending) != TYPE_DICTIONARY:
		return false
	if record.is_empty():
		return pending.is_empty()
	if record.size() != KEYS.size() or not record.has_all(KEYS):
		return false
	var id := LurePreparation.read_nonnegative_integer(record.id)
	var next_id := LurePreparation.read_nonnegative_integer(hub.get("next_expedition_id"))
	if id <= 0 or id >= next_id or (not pending.is_empty() and record.id != pending.get("id")):
		return false
	if record.seed == null:
		return record.content_version == "" and record.generation_version == ""
	if typeof(record.seed) != TYPE_STRING or not record.seed.is_valid_int() or str(record.seed.to_int()) != record.seed:
		return false
	return record.content_version == CONTENT_VERSION and record.generation_version == GENERATION_VERSION


static func migrate_legacy(hub: Dictionary) -> bool:
	if hub.size() != 15 or hub.has("visit_seed") or not LurePreparation.valid_save(hub):
		return false
	hub["visit_seed"] = {} if hub.pending_departure.is_empty() else unknown(hub.pending_departure.id)
	return true
