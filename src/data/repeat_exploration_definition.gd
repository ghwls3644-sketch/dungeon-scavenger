class_name RepeatExplorationDefinition
extends Resource

@export var content_version: String = ""
@export var map_definition: ExplorationMapDefinition
@export var item_catalog: ItemCatalog
@export var pools: Array[VisitPoolDefinition] = []


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if not StableId.is_valid(StringName(content_version)):
		errors.append("Content version must be non-empty and trimmed.")
	if map_definition == null or not map_definition.get_validation_errors().is_empty():
		errors.append("A valid fixed map is required.")
	if item_catalog == null or not item_catalog.is_valid():
		errors.append("A valid item catalog is required.")
	if not errors.is_empty():
		return errors
	var regions: Dictionary = {}
	var entrance_regions := 0
	for region in map_definition.regions:
		regions[region.stable_id] = region
		if region.bounds.has_point(map_definition.entrance_position):
			entrance_regions += 1
	if entrance_regions != 1:
		errors.append("Entrance must belong to exactly one fixed region.")
	var pool_ids: Dictionary = {}
	var candidate_ids: Dictionary = {}
	for pool in pools:
		if pool == null:
			errors.append("Pool must not be null.")
			continue
		if not StableId.is_valid(pool.stable_id) or pool_ids.has(pool.stable_id):
			errors.append("Pool IDs must be valid and unique.")
		pool_ids[pool.stable_id] = true
		if not regions.has(pool.region_id) or pool.maximum_count < 0:
			errors.append("Pool needs a known region and a non-negative upper bound.")
		for candidate in pool.candidates:
			if candidate == null:
				errors.append("Candidate must not be null.")
				continue
			if not StableId.is_valid(candidate.stable_id) or candidate_ids.has(candidate.stable_id):
				errors.append("Candidate IDs must be valid and globally unique.")
			candidate_ids[candidate.stable_id] = true
			if item_catalog.find_item(candidate.item_id) == null:
				errors.append("Candidate item must exist in the catalog.")
			if not candidate.position.is_finite() or (regions.has(pool.region_id) and not regions[pool.region_id].bounds.has_point(candidate.position)):
				errors.append("Candidate position must be finite and inside its region.")
	return errors


# Primitive value snapshot; display labels and mutable Resource references are absent.
# Call only after validation. Ordering is independent of editor array order.
func get_snapshot() -> Dictionary:
	if not get_validation_errors().is_empty():
		return {}
	var regions: Array[Dictionary] = []
	for region in map_definition.regions:
		regions.append({"id": String(region.stable_id), "bounds": region.bounds})
	regions.sort_custom(_by_id)
	var passages: Array[Dictionary] = []
	for passage in map_definition.passages:
		passages.append({"id": String(passage.stable_id), "start": passage.start, "end": passage.end, "clearance_radius": passage.clearance_radius})
	passages.sort_custom(_by_id)
	var items: Array[Dictionary] = []
	for item in item_catalog.items:
		items.append({"id": String(item.stable_id), "original": item.is_original()})
	items.sort_custom(_by_id)
	var pool_values: Array[Dictionary] = []
	for pool in pools:
		var candidates: Array[Dictionary] = []
		for candidate in pool.candidates:
			candidates.append({"id": String(candidate.stable_id), "item_id": String(candidate.item_id), "position": candidate.position})
		candidates.sort_custom(_by_id)
		pool_values.append({"id": String(pool.stable_id), "region_id": String(pool.region_id), "maximum_count": pool.maximum_count, "candidates": candidates})
	pool_values.sort_custom(_by_id)
	return {
		"content_version": content_version,
		"map": {"bounds": map_definition.bounds, "entrance": map_definition.entrance_position, "regions": regions, "passages": passages, "routes": map_definition.routes.duplicate(true)},
		"items": items,
		"pools": pool_values,
	}


static func _by_id(a: Dictionary, b: Dictionary) -> bool:
	return a.id < b.id
