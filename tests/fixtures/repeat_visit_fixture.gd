class_name RepeatVisitFixture
extends RefCounted

const MAP := preload("res://src/data/prototype_exploration_map.tres")
const ITEMS := preload("res://src/data/prototype_item_catalog.tres")


static func definition() -> RepeatExplorationDefinition:
	var result := RepeatExplorationDefinition.new()
	result.content_version = "test_repeat_1"
	result.map_definition = MAP.duplicate(true)
	result.item_catalog = ITEMS.duplicate(true)
	result.pools = [
		pool(&"test_north", &"prototype_north", 2, [
			candidate(&"north_light", &"test_g1_light", Vector2(-250, -200)),
			candidate(&"north_artifact", &"test_g4_artifact", Vector2(-150, -200)),
			candidate(&"north_record", &"test_g4_record", Vector2(0, -200)),
			candidate(&"north_heavy", &"test_g1_heavy", Vector2(150, -200)),
			candidate(&"north_artifact_alt", &"test_g4_artifact", Vector2(250, -200)),
		]),
		pool(&"test_south", &"prototype_south", 2, [
			candidate(&"south_artifact", &"test_g4_artifact", Vector2(-250, 150)),
			candidate(&"south_unknown", &"test_g1_unknown", Vector2(-150, 150)),
			candidate(&"south_light", &"test_g1_light", Vector2(0, 150)),
		]),
		pool(&"test_bypass", &"prototype_bypass", 0, [candidate(&"bypass_record", &"test_g4_record", Vector2(630, 200))]),
		pool(&"test_entry", &"prototype_entry", 1, []),
	]
	return result


static func pool(id: StringName, region: StringName, maximum: int, candidates: Array[VisitCandidateDefinition]) -> VisitPoolDefinition:
	var result := VisitPoolDefinition.new()
	result.stable_id = id
	result.region_id = region
	result.maximum_count = maximum
	result.candidates = candidates
	return result


static func candidate(id: StringName, item: StringName, position: Vector2) -> VisitCandidateDefinition:
	var result := VisitCandidateDefinition.new()
	result.stable_id = id
	result.item_id = item
	result.position = position
	return result
