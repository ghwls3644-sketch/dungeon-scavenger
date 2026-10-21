extends Node

const CATALOG := preload("res://src/data/prototype_item_catalog.tres")
const ECONOMY := preload("res://src/data/prototype_economy.tres")
const BOUNDARY := preload("res://tests/fixtures/lure_boundary_store.gd")
var _checks := 0
var _failures := PackedStringArray()
var _directory: String


func _ready() -> void:
	_directory = OS.get_environment("TEMP").path_join("dungeon-seeds-%d-%d" % [OS.get_process_id(), Time.get_ticks_usec()])
	_expect(DirAccess.make_dir_recursive_absolute(_directory) == OK, "Cannot create isolated directory.")
	_check_lifecycle()
	_check_storage()
	_check_migration()
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"expedition_seed_passed", "checks=%d" % _checks)
	get_tree().quit(0 if _failures.is_empty() else 1)


func _check_lifecycle() -> void:
	_expect(ExpeditionSeed.CONTENT_VERSION == ProgressStore.CONTENT_VERSION, "Content versions drifted.")
	var hub := HubState.new()
	_expect(hub.get_visit_seed().is_empty(), "Unused hub invented a visit.")
	var previous: Dictionary = {}
	for ending in ["cancel", "interrupted", "entrance", "emergency_escape", "failure"]:
		var id := hub.reserve_departure()
		var record := hub.get_visit_seed()
		_expect(id > 0 and record.id == str(id) and record.seed != previous.get("seed"), "New request did not issue a fresh seed.")
		_expect(hub.reserve_departure() == 0 and hub.get_visit_seed() == record, "Duplicate request changed seed.")
		var exposed := hub.get_visit_seed()
		exposed.seed = "0"
		var copied := hub.copy()
		_expect(copied.get_visit_seed() == record and hub.get_visit_seed() == record, "Copy/getter aliased seed state.")
		if ending != "cancel":
			_expect(hub.mark_departure_started(id) and not hub.mark_departure_started(id), "Start marker repeated.")
		if ending in ["cancel", "interrupted"]:
			_expect(hub.recover_departure() and not hub.recover_departure(), "Recovery repeated.")
		else:
			var outcome := ExplorationOutcome.failure(0) if ending == "failure" else ExplorationOutcome.safe_return_inventory_items([], StringName(ending))
			outcome.record_lure_usage(2, 0)
			_expect(hub.prepare_settlement(id, outcome, ECONOMY) and hub.apply_settlement(id) and not hub.apply_settlement(id), "Settlement repeated.")
		_expect(hub.get_visit_seed() == record and ExpeditionSeed.valid_save(hub.to_save_data()), "Closing a request changed/lost seed.")
		previous = record
	# Unsaved requests also get fresh seeds; caller keeps a reserved candidate for retries.
	var first := HubState.new()
	first.reserve_departure()
	var second := HubState.new()
	second.reserve_departure()
	_expect(first.get_visit_seed().seed != second.get_visit_seed().seed, "Unsaved independent requests reused a seed.")
	seed(7)
	var expected := randi()
	seed(7)
	ExpeditionSeed.issue(1, {})
	_expect(randi() == expected, "Issuing a seed consumed global RNG.")
	# The persisted seed/version can be fed into the existing generator unchanged.
	var definition := RepeatVisitFixture.definition()
	definition.content_version = first.get_visit_seed().content_version
	var generator := RepeatVisitGenerator.new()
	var record := first.get_visit_seed()
	var plan := generator.generate(definition, RepeatExplorationProgress.new(), record.seed.to_int(), record.generation_version)
	var again := generator.generate(definition, RepeatExplorationProgress.new(), record.seed.to_int(), record.generation_version)
	_expect(plan != null and again != null and plan.get_placements() == again.get_placements(), "Persisted seed failed generator reproduction.")


func _check_storage() -> void:
	var path := _directory.path_join("retry.json")
	var store := BOUNDARY.new(path)
	var hub := HubState.new()
	_expect(store.save_data(hub.to_save_data()) == OK, "Cannot seed retry save.")
	var before := FileAccess.get_file_as_bytes(path)
	var candidate := hub.copy()
	var id := candidate.reserve_departure()
	var record := candidate.get_visit_seed()
	store.failures.assign([2])
	_expect(store.save_data(candidate.to_progress_data()) != OK and FileAccess.get_file_as_bytes(path) == before, "Reservation failure changed durable state.")
	_expect(store.save_data(candidate.to_progress_data()) == OK and store.seed_attempts[1] == store.seed_attempts[2], "Same reservation retry reissued seed.")
	hub = HubState.from_save_data(store.load_data(), CATALOG)
	_expect(hub.get_visit_seed() == record, "Reload lost reserved seed.")
	candidate = hub.copy()
	candidate.mark_departure_started(id)
	before = FileAccess.get_file_as_bytes(path)
	store.failures.assign([4])
	_expect(store.save_data(candidate.to_progress_data()) != OK and FileAccess.get_file_as_bytes(path) == before, "Start failure changed durable state.")
	_expect(store.save_data(candidate.to_progress_data()) == OK and store.seed_attempts[3] == record and store.seed_attempts[4] == record, "Start retry reissued seed.")
	hub = candidate
	var outcome := ExplorationOutcome.safe_return_inventory_items([])
	outcome.record_lure_usage(2, 0)
	_expect(hub.prepare_settlement(id, outcome, ECONOMY), "Cannot prepare result.")
	candidate = hub.copy()
	_expect(candidate.apply_settlement(id), "Cannot apply result on candidate.")
	before = FileAccess.get_file_as_bytes(path)
	store.failures.assign([6])
	_expect(store.save_data(candidate.to_save_data()) != OK and FileAccess.get_file_as_bytes(path) == before, "Result failure changed durable state.")
	candidate = hub.copy()
	_expect(candidate.apply_settlement(id) and store.save_data(candidate.to_save_data()) == OK, "Result retry failed.")
	_expect(store.seed_attempts[5] == record and store.seed_attempts[6] == record and store.load_data().visit_seed == record, "Result retry changed seed.")
	var valid := candidate.to_save_data()
	for value in ["0", "-1", "9007199254740993", "9223372036854775807", "-9223372036854775808"]:
		var exact := valid.duplicate(true)
		exact.visit_seed.seed = value
		_expect(store.save_data(exact) == OK and store.load_data().visit_seed.seed == value, "Signed int64 seed lost precision: " + value)
	var invalid: Array[Dictionary] = []
	for value in [1, 1.0, true, "", "+1", "01", "-0", "1.5", "9223372036854775808", "-9223372036854775809"]:
		var bad := valid.duplicate(true)
		bad.visit_seed.seed = value
		invalid.append(bad)
	for key in ExpeditionSeed.KEYS:
		var bad := valid.duplicate(true)
		bad.visit_seed.erase(key)
		invalid.append(bad)
	for key in ["content_version", "generation_version", "id"]:
		var bad := valid.duplicate(true)
		bad.visit_seed[key] = "unknown"
		invalid.append(bad)
	var missing := valid.duplicate(true)
	missing.erase("visit_seed")
	invalid.append(missing)
	var mismatch := first_reserved()
	mismatch.visit_seed.id = "2"
	invalid.append(mismatch)
	mismatch = first_reserved()
	mismatch.visit_seed = {}
	invalid.append(mismatch)
	for bad in invalid:
		_write(path, bad, ProgressStore.SCHEMA_VERSION)
		before = FileAccess.get_file_as_bytes(path)
		_expect(HubState.from_save_data(bad, CATALOG) == null and store.load_data().is_empty() and store.save_data(valid) != OK and before == FileAccess.get_file_as_bytes(path), "Malformed seed accepted/overwritten.")


func first_reserved() -> Dictionary:
	var hub := HubState.new()
	hub.reserve_departure()
	return hub.to_progress_data()


func _check_migration() -> void:
	var path := _directory.path_join("legacy10.json")
	var store := ProgressStore.new(path)
	for phase in ["none", "reserved", "started", "settled"]:
		var hub := HubState.new()
		if phase != "none":
			var id := hub.reserve_departure()
			if phase != "reserved":
				hub.mark_departure_started(id)
			if phase == "settled":
				var outcome := ExplorationOutcome.safe_return_inventory_items([])
				outcome.record_lure_usage(2, 0)
				hub.prepare_settlement(id, outcome, ECONOMY)
				hub.apply_settlement(id)
		var old := LegacyProgressFixture.before_seed(hub.to_progress_data())
		_write(path, old, 10)
		var bytes := FileAccess.get_file_as_bytes(path)
		var loaded := store.load_data()
		_expect(not loaded.is_empty() and bytes == FileAccess.get_file_as_bytes(path), "Schema10 load failed/rewrote file.")
		if loaded.is_empty():
			continue
		var restored := HubState.from_save_data(loaded, CATALOG)
		_expect(restored != null, "Migrated state rejected.")
		if restored == null:
			continue
		var stripped := restored.to_progress_data()
		stripped.erase("visit_seed")
		_expect(stripped == old, "Migration changed existing fields.")
		if phase in ["reserved", "started"]:
			_expect(loaded.visit_seed.seed == null and loaded.visit_seed.content_version == "" and loaded.visit_seed.generation_version == "", "Migration invented an old visit seed.")
			_expect(restored.recover_departure() and not restored.recover_departure(), "Legacy seed recovery repeated.")
		else:
			_expect(loaded.visit_seed.is_empty(), "Idle legacy save invented a visit.")
		_expect(store.save_data(restored.to_save_data()) == OK and HubState.from_save_data(store.load_data(), CATALOG).to_save_data() == restored.to_save_data(), "Legacy seed roundtrip failed.")
		_expect(restored.reserve_departure() > 0 and restored.get_visit_seed().seed != null, "Legacy next request did not get a new seed.")
	var hybrid := HubState.new().to_save_data()
	_write(path, hybrid, 10)
	_expect(store.load_data().is_empty(), "Hybrid schema10 accepted.")
	_write(path, hybrid, ProgressStore.SCHEMA_VERSION + 1)
	_expect(store.load_data().is_empty() and store.get_last_error() == ERR_UNAVAILABLE, "Future schema accepted.")


func _write(path: String, hub: Dictionary, version: int) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify({"schema_version": version, "content_version": ProgressStore.CONTENT_VERSION, "resume_state": "hub", "hub": hub}))
	file.close()


func _expect(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(message)
		GameLog.error(&"SmokeTest", &"expedition_seed_failed", message)
