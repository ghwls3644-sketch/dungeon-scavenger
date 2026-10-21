extends Node

var _failures := PackedStringArray()
var _checks := 0
var _generator := RepeatVisitGenerator.new()


func _ready() -> void:
	_check_reproduction()
	_check_exclusion()
	_check_copy_boundaries()
	_check_invalid_inputs()
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"repeat_visit_passed", "checks=%d; in-memory only" % _checks)
	else:
		for failure in _failures:
			GameLog.error(&"SmokeTest", &"repeat_visit_failed", failure)
	get_tree().quit(0 if _failures.is_empty() else 1)


func _check_reproduction() -> void:
	var definition := RepeatVisitFixture.definition()
	var before := definition.get_snapshot()
	var progress := RepeatExplorationProgress.new()
	# Independently calculated using Python hashlib over compact UTF-8 JSON arrays.
	var golden := {
		0: ["north_light", "north_heavy", "south_light", "south_artifact"],
		42: ["north_artifact_alt", "north_record", "south_unknown", "south_light"],
		-1: ["north_heavy", "north_record", "south_artifact", "south_unknown"],
		-9223372036854775807 - 1: ["north_record", "north_artifact", "south_unknown", "south_light"],
		9223372036854775807: ["north_artifact", "north_light", "south_unknown", "south_light"],
	}
	for seed_value in golden:
		var plan := _generator.generate(definition, progress, seed_value)
		_expect(plan != null, "Golden input rejected: %s" % seed_value)
		if plan == null:
			continue
		_expect(_ids(plan) == golden[seed_value], "Golden output differs: %s" % seed_value)
		_expect(plan.get_reproduction_inputs().seed == str(seed_value), "Seed lost precision.")
	var baseline := _generator.generate(definition, progress, 42)
	if baseline == null:
		return
	seed(7)
	var global_expected := randi()
	seed(7)
	var repeated := _generator.generate(definition, progress, 42)
	_expect(randi() == global_expected, "Generation advanced global RNG.")
	_expect(repeated.get_reproduction_inputs() == baseline.get_reproduction_inputs() and repeated.get_placements() == baseline.get_placements(), "Same inputs differ.")
	for index in range(30):
		randi()
	_expect(_ids(_generator.generate(definition, progress, 42)) == _ids(baseline), "Unrelated RNG changed placements.")
	definition.pools.reverse()
	definition.item_catalog.items.reverse()
	definition.map_definition.regions.reverse()
	definition.map_definition.passages.reverse()
	for pool in definition.pools:
		pool.candidates.reverse()
	for item in definition.item_catalog.items:
		item.display_name = "이름만 변경"
	for region in definition.map_definition.regions:
		region.display_name = "표시 이름 변경"
	var reordered := _generator.generate(definition, progress, 42)
	_expect(reordered.get_reproduction_inputs() == baseline.get_reproduction_inputs() and reordered.get_placements() == baseline.get_placements(), "Editor order or display names changed plan.")
	_expect(definition.get_snapshot() == before, "Generation changed fixed identity.")
	var signatures: Dictionary = {}
	for seed_value in range(-20, 21):
		var plan := _generator.generate(definition, progress, seed_value)
		_expect(plan != null and plan.get_fixed_map() == baseline.get_fixed_map(), "Seed changed fixed map.")
		if plan != null:
			signatures[str(_ids(plan))] = true
			_check_uniqueness(plan)
	_expect(signatures.size() > 1, "Multiple eligible candidates never varied.")
	definition.content_version = "test_repeat_2"
	var versioned := _generator.generate(definition, progress, 42)
	_expect(versioned != null and versioned.get_reproduction_inputs() != baseline.get_reproduction_inputs(), "Content version was lost from reproduction inputs.")


func _check_exclusion() -> void:
	var definition := RepeatVisitFixture.definition()
	for pool in definition.pools:
		pool.maximum_count = 20
	var empty := RepeatExplorationProgress.new()
	var all_plan := _generator.generate(definition, empty, 42)
	_expect(all_plan != null and _item_count(all_plan, "test_g4_artifact") == 1 and _item_count(all_plan, "test_g4_record") == 1, "Original repeated across candidates/pools.")
	var progress := RepeatExplorationProgress.new([&"test_g4_artifact"], ["test_g4_record"])
	var secured := _generator.generate(definition, progress, 42)
	_expect(secured != null and _item_count(secured, "test_g4_artifact") == 0 and _item_count(secured, "test_g4_record") == 0, "Stored/registered original was not excluded.")
	_expect(secured.get_reproduction_inputs().progress.registered == ["test_g4_artifact"] and secured.get_reproduction_inputs().progress.stored == ["test_g4_record"], "Storage was converted to registration.")
	var overlap := _generator.generate(definition, RepeatExplorationProgress.new(["test_g4_artifact"], ["test_g4_artifact"]), 0)
	_expect(overlap != null and _item_count(overlap, "test_g4_artifact") == 0, "Union exclusion failed.")
	for status in [RepeatExplorationProgress.LOST, RepeatExplorationProgress.SEALED]:
		var plan := _generator.generate(definition, RepeatExplorationProgress.new([], [], {"prototype_north": status}), 42)
		_expect(plan != null and plan.get_pool_counts().test_north == 0 and plan.get_pool_counts().test_south > 0, "Lost/sealed region affected wrong pool.")
	var reduced := _generator.generate(definition, RepeatExplorationProgress.new([], [], {&"prototype_north": "reduced"}, ["north_light"]), 42)
	_expect(reduced != null and "north_light" not in _ids(reduced) and "north_heavy" in _ids(reduced), "Reduction removed wrong candidates.")
	var filtered := _generator.generate(definition, RepeatExplorationProgress.new([], [], {"prototype_north": "lost", "prototype_south": "sealed", "prototype_bypass": "lost"}), 42)
	_expect(filtered != null and filtered.get_placements().is_empty(), "All-excluded input did not yield an explicit empty plan.")
	definition.pools[0].candidates[1].position = definition.pools[0].candidates[0].position
	var colliding := _generator.generate(definition, empty, 0)
	_expect(colliding != null, "Alternative candidates sharing a location were rejected.")
	_check_uniqueness(colliding)
	definition.pools.clear()
	var no_pools := _generator.generate(definition, empty, 0)
	_expect(no_pools != null and no_pools.get_pool_counts().is_empty() and no_pools.get_placements().is_empty(), "No optional pools must be valid.")


func _check_copy_boundaries() -> void:
	var definition := RepeatVisitFixture.definition()
	var registered: Array = ["test_g4_artifact"]
	var states: Dictionary = {"prototype_south": "sealed"}
	var removed: Array = []
	var progress := RepeatExplorationProgress.new(registered, [], states, removed)
	registered.clear()
	states.clear()
	removed.append("north_light")
	var plan := _generator.generate(definition, progress, 42)
	_expect(plan != null and _item_count(plan, "test_g4_artifact") == 0 and plan.get_pool_counts().test_south == 0, "Input aliases modified progress.")
	var inputs := plan.get_reproduction_inputs()
	var placements := plan.get_placements()
	plan.get_placements().clear()
	plan.get_reproduction_inputs().progress.registered.clear()
	plan.get_reproduction_inputs().definition.pools[0].candidates.clear()
	plan.get_fixed_map().regions.clear()
	plan.get_fixed_map().routes[0][0] = Vector2(9000, 9000)
	plan.get_pool_counts().clear()
	progress.get_snapshot().region_states.clear()
	_expect(plan.get_reproduction_inputs() == inputs and plan.get_placements() == placements, "Getter aliases modified plan.")
	_expect(_generator.generate(definition, progress, 42).get_reproduction_inputs() == inputs, "Getter aliases modified generation inputs.")
	definition.map_definition.regions[0].bounds = Rect2(0, 0, 1, 1)
	definition.pools[0].candidates.clear()
	definition.item_catalog.items.clear()
	_expect(plan.get_reproduction_inputs() == inputs and plan.get_placements() == placements, "Source edits modified a completed plan.")
	_expect(not RepeatVisitFixture.MAP.get_validation_errors().size() and RepeatVisitFixture.ITEMS.is_valid(), "Fixture mutated shared product definitions.")


func _check_invalid_inputs() -> void:
	var definition := RepeatVisitFixture.definition()
	var progress := RepeatExplorationProgress.new()
	_expect_rejected(null, progress, 0, "Null definition")
	_expect_rejected(definition, null, 0, "Null progress")
	for invalid in [1.0, "1", true, null]:
		_expect_rejected(definition, progress, invalid, "Non-integer seed")
	_expect(_generator.generate(definition, progress, 0, "future") == null and not _generator.get_last_errors().is_empty(), "Unknown generator version accepted.")
	for mutation in [
		func(d): d.content_version = " ",
		func(d): d.map_definition = null,
		func(d): d.item_catalog = null,
		func(d): d.pools.append(null),
		func(d): d.pools[0].stable_id = &" ",
		func(d): d.pools[1].stable_id = d.pools[0].stable_id,
		func(d): d.pools[0].maximum_count = -1,
		func(d): d.pools[0].region_id = &"unknown",
		func(d): d.pools[0].candidates.append(null),
		func(d): d.pools[0].candidates[0].stable_id = &"",
		func(d): d.pools[1].candidates[0].stable_id = d.pools[0].candidates[0].stable_id,
		func(d): d.pools[0].candidates[0].item_id = &"unknown",
		func(d): d.pools[0].candidates[0].position = Vector2(NAN, 0),
		func(d): d.pools[0].candidates[0].position = Vector2(INF, 0),
		func(d): d.pools[0].candidates[0].position = Vector2(0, 200),
		func(d): d.map_definition.entrance_position = Vector2(9000, 0),
		func(d): d.map_definition.regions[0].stable_id = d.map_definition.regions[1].stable_id,
		func(d): d.item_catalog.items.append(d.item_catalog.items[0]),
	]:
		var invalid := RepeatVisitFixture.definition()
		mutation.call(invalid)
		_expect_rejected(invalid, progress, 0, "Invalid fixed definition")
	for invalid_progress in [
		RepeatExplorationProgress.new(["unknown"]),
		RepeatExplorationProgress.new([1]),
		RepeatExplorationProgress.new(["test_g1_light"]),
		RepeatExplorationProgress.new([], ["test_g1_light"]),
		RepeatExplorationProgress.new(["test_g4_record", &"test_g4_record"]),
		RepeatExplorationProgress.new([], ["test_g4_record", "test_g4_record"]),
		RepeatExplorationProgress.new([], [], {"unknown": "lost"}),
		RepeatExplorationProgress.new([], [], {1: "lost"}),
		RepeatExplorationProgress.new([], [], {"prototype_north": "rebuilt"}),
		RepeatExplorationProgress.new([], [], {"prototype_north": 0}),
		RepeatExplorationProgress.new([], [], {"prototype_entry": "lost"}),
		RepeatExplorationProgress.new([], [], {"prototype_entry": "sealed"}),
		RepeatExplorationProgress.new([], [], {}, ["unknown"]),
		RepeatExplorationProgress.new([], [], {}, ["north_light"]),
		RepeatExplorationProgress.new([], [], {"prototype_north": "reduced"}, ["north_light", "north_light"]),
	]:
		_expect_rejected(definition, invalid_progress, 0, "Invalid permanent progress")
	_generator.get_last_errors().clear()
	_expect(not _generator.get_last_errors().is_empty(), "Error getter leaked mutable state.")
	_expect(_generator.generate(definition, progress, 0) != null and _generator.get_last_errors().is_empty(), "Valid retry kept old errors.")


func _expect_rejected(definition: RepeatExplorationDefinition, progress: RepeatExplorationProgress, seed_value: Variant, label: String) -> void:
	_expect(_generator.generate(definition, progress, seed_value) == null and not _generator.get_last_errors().is_empty(), label + " did not fail atomically.")


func _check_uniqueness(plan: RepeatVisitPlan) -> void:
	if plan == null:
		_expect(false, "Missing plan for uniqueness check.")
		return
	var positions: Dictionary = {}
	var ids: Dictionary = {}
	for placement in plan.get_placements():
		_expect(not positions.has(placement.position) and not ids.has(placement.candidate_id), "Duplicate position or candidate.")
		positions[placement.position] = true
		ids[placement.candidate_id] = true
	_expect(_item_count(plan, "test_g4_artifact") <= 1 and _item_count(plan, "test_g4_record") <= 1, "Original selected more than once.")
	for pool in plan.get_reproduction_inputs().definition.pools:
		_expect(plan.get_pool_counts()[pool.id] <= pool.maximum_count, "Pool upper bound exceeded.")


func _ids(plan: RepeatVisitPlan) -> Array:
	var result: Array = []
	if plan != null:
		for placement in plan.get_placements():
			result.append(placement.candidate_id)
	return result


func _item_count(plan: RepeatVisitPlan, item_id: String) -> int:
	var count := 0
	if plan != null:
		for placement in plan.get_placements():
			if placement.item_id == item_id:
				count += 1
	return count


func _expect(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(message)
