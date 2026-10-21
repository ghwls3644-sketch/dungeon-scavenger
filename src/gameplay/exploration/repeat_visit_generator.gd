class_name RepeatVisitGenerator
extends RefCounted

# Compatibility boundary for ranking, ordering, exclusion and collision handling.
const GENERATION_VERSION := "repeat_plan_sha256_v1"

var _errors := PackedStringArray()


func get_last_errors() -> PackedStringArray:
	return _errors.duplicate()


func generate(definition: RepeatExplorationDefinition, progress: RepeatExplorationProgress, seed_value: Variant, generation_version: String = GENERATION_VERSION) -> RepeatVisitPlan:
	_errors.clear()
	if definition == null or progress == null:
		_errors.append("Definition and progress are required.")
	if typeof(seed_value) != TYPE_INT:
		_errors.append("Seed must be a signed 64-bit integer, not a float or string.")
	if generation_version != GENERATION_VERSION:
		_errors.append("Unsupported generation version.")
	if not _errors.is_empty():
		return null
	_errors.append_array(definition.get_validation_errors())
	if not _errors.is_empty():
		return null
	var fixed := definition.get_snapshot()
	_errors.append_array(progress.get_validation_errors(fixed))
	if not _errors.is_empty():
		return null
	var permanent := progress.get_snapshot()
	var originals: Dictionary = {}
	for item in fixed.items:
		if item.original:
			originals[item.id] = true
	var excluded: Dictionary = {}
	for id in permanent.registered + permanent.stored:
		excluded[id] = true
	var occupied: Dictionary = {}
	var placements: Array[Dictionary] = []
	var counts: Dictionary = {}
	for pool in fixed.pools:
		counts[pool.id] = 0
		if permanent.region_states.get(pool.region_id, "") in [RepeatExplorationProgress.LOST, RepeatExplorationProgress.SEALED]:
			continue
		var ranked: Array[Dictionary] = []
		for candidate in pool.candidates:
			if excluded.has(candidate.item_id) or candidate.id in permanent.removed:
				continue
			# JSON array framing avoids separator ambiguities; only strings enter the hash.
			var rank := JSON.stringify([GENERATION_VERSION, fixed.content_version, str(seed_value), pool.region_id, pool.id, candidate.id]).sha256_text()
			ranked.append({"rank": rank, "candidate": candidate})
		ranked.sort_custom(_by_rank)
		for entry in ranked:
			if counts[pool.id] >= pool.maximum_count:
				break
			var candidate: Dictionary = entry.candidate
			if excluded.has(candidate.item_id) or occupied.has(candidate.position):
				continue
			placements.append({"pool_id": pool.id, "region_id": pool.region_id, "candidate_id": candidate.id, "item_id": candidate.item_id, "position": candidate.position})
			counts[pool.id] += 1
			occupied[candidate.position] = true
			if originals.has(candidate.item_id):
				excluded[candidate.item_id] = true
	return RepeatVisitPlan.new({"seed": str(seed_value), "generation_version": GENERATION_VERSION, "definition": fixed, "progress": permanent}, placements, counts)


static func _by_rank(a: Dictionary, b: Dictionary) -> bool:
	if a.rank == b.rank:
		return a.candidate.id < b.candidate.id
	return a.rank < b.rank
