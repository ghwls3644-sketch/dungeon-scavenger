extends "res://tests/smoke/return_route_smoke.gd"

const ROUTE_WORLD := preload("res://tests/fixtures/retreat_route_test_space.tscn")
const PASSAGE := preload("res://src/gameplay/exploration/changing_passage.tscn")
const RULE := preload("res://src/data/prototype_passage_change.tres")

var _warning_count := 0
var _blocked_count := 0
var _used_discharge := false
var _measurements: Array[Dictionary] = []


func _ready() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	await _check_rule_and_occupants()
	await _check_warning_return_and_pause()
	await _check_detour()
	await _check_failure_and_new_visit()
	_release()
	get_tree().paused = false
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--retreat-report-path="):
			var file := FileAccess.open(argument.trim_prefix("--retreat-report-path="), FileAccess.WRITE)
			file.store_string(JSON.stringify({"passed": _failures.is_empty(), "routes": _measurements}, "\t") + "\n")
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"retreat_route_passed")
	get_tree().quit(0 if _failures.is_empty() else 1)


func _check_rule_and_occupants() -> void:
	_expect(RULE.is_valid() and not PassageChangeRule.new().is_valid(), "Rule defaults wrong.")
	for duration in [0.0, -1.0, NAN, INF]:
		var invalid := RULE.duplicate(true) as PassageChangeRule
		invalid.warning_duration = duration
		_expect(not invalid.is_valid(), "Invalid warning duration accepted.")
		var invalid_passage: ChangingPassage = PASSAGE.instantiate()
		invalid_passage.rule = invalid
		add_child(invalid_passage)
		_expect(not invalid_passage.start_exploration(invalid_passage), "Invalid passage activated.")
		invalid_passage.queue_free()
	await _frames(3)
	for layer in [1, 16]:
		var observer := CharacterBody2D.new()
		observer.collision_layer = layer
		var collision := CollisionShape2D.new()
		var shape := CircleShape2D.new()
		shape.radius = 20.0
		collision.shape = shape
		observer.add_child(collision)
		add_child(observer)
		var passage: ChangingPassage = PASSAGE.instantiate()
		passage.rule = RULE.duplicate(true)
		add_child(passage)
		passage.warning_started.connect(func(): _warning_count += 1)
		passage.passage_blocked.connect(func(): _blocked_count += 1)
		observer.position = Vector2(60, 0)
		await _frames(6)
		_expect(passage.get_phase() == ChangingPassage.Phase.OPEN, "Inactive passage advanced.")
		_expect(passage.start_exploration(observer) and not passage.start_exploration(observer), "Passage started twice.")
		passage.rule.warning_duration = 0.01 # Runtime state must use its validated snapshot.
		await _frames(3)
		_expect(passage.get_phase() == ChangingPassage.Phase.WARNING and passage.get_warning_remaining() > 2.9, "Warning snapshot/entry time wrong.")
		observer.position = Vector2.ZERO
		await _frames(190)
		_expect(passage.get_phase() == ChangingPassage.Phase.WAITING and passage.get_node("Barrier/CollisionShape2D").disabled, "Closure trapped player/golem body.")
		_expect(observer.position == Vector2.ZERO, "Closure displaced an occupant.")
		get_tree().paused = true
		observer.position = Vector2(-100, 0)
		await _frames(10)
		_expect(passage.get_phase() == ChangingPassage.Phase.WAITING, "Paused passage closed.")
		get_tree().paused = false
		await _frames(5)
		_expect(passage.get_phase() == ChangingPassage.Phase.BLOCKED and not passage.get_node("Barrier/CollisionShape2D").disabled, "Empty passage did not physically close.")
		passage.end_exploration()
		_expect(not passage.start_exploration(observer), "Ended passage restarted.")
		observer.queue_free()
		passage.queue_free()
		await _frames(3)
	_expect(_warning_count == 2 and _blocked_count == 2, "Passage emitted duplicate events.")


func _new_world() -> PrototypeExploration:
	var world := ROUTE_WORLD.instantiate() as PrototypeExploration
	world.auto_start = false
	add_child(world)
	await _frames(3)
	_expect(not world.get_node("ChangingPassage").is_active(), "Passage started before departure.")
	var loadout := ExpeditionLoadout.new()
	loadout.slot_capacity = 3
	loadout.burden_weight = 2.5
	loadout.overload_weight = 4.0
	loadout.charge_capacity = 3
	loadout.starting_charge = 3
	_expect(world.prepare_departure(loadout) and world.start_exploration(), "Route departure failed.")
	await _frames(4)
	return world


func _check_warning_return_and_pause() -> void:
	var world := await _new_world()
	var player: PlayerController = world.get_node("Player")
	var passage: ChangingPassage = world.get_node("ChangingPassage")
	await _walk(player, Vector2(-650, -200))
	await _walk(player, Vector2(-500, -200))
	_expect(world.get_map_state().get_passage_status(&"prototype_upper_link") == ExplorationMapState.PassageStatus.OPEN, "Original passage was not observed open.")
	await _capture("retreat-open.png")
	await _walk(player, Vector2(-315, -200))
	_expect(passage.get_phase() == ChangingPassage.Phase.WARNING and passage.get_warning_remaining() > 2.7, "Actual crossing did not start full warning.")
	_expect(world.get_node("%ChoiceStatus").text.contains("붕괴 징후"), "Warning notice missing.")
	_expect(not world.get_node("%ChoiceStatus").get_global_rect().intersects(world.get_node("%LoadStatus").get_global_rect()), "Warning overlaps load HUD.")
	await _capture("retreat-warning.png")
	for key in [KEY_M, KEY_TAB]:
		_tap(key)
		await _frames(4)
		var remaining := passage.get_warning_remaining()
		var position := player.position
		Input.action_press(InputActions.MOVE_RIGHT)
		await _frames(200)
		_release()
		_expect(get_tree().paused and remaining == passage.get_warning_remaining() and player.position == position, "Menu advanced warning or player.")
		_tap(key)
		await _frames(3)
		_expect(not get_tree().paused and passage.get_warning_remaining() < remaining, "Warning failed to resume.")
	await _walk(player, Vector2(-500, -200))
	await _walk(player, Vector2(-680, 0))
	_tap(KEY_E)
	await _frames(4)
	var run: ExplorationRun = world.get_node("%ExplorationRun")
	_expect(run.get_state() == ExplorationRun.State.SAFE_RETURN and not passage.is_active(), "Warning-period retreat failed.")
	var remaining := passage.get_warning_remaining()
	await _frames(220)
	_expect(passage.get_phase() == ChangingPassage.Phase.WARNING and remaining == passage.get_warning_remaining(), "Returned expedition continued passage event.")
	_expect(not world.start_exploration() and not passage.start_exploration(player), "Returned expedition restarted.")
	_measurements.append({"route": "return_during_warning", "safe_return": run.get_state() == ExplorationRun.State.SAFE_RETURN, "remaining_warning": remaining})
	world.queue_free()
	await _frames(4)


func _check_detour() -> void:
	var world := await _new_world()
	var player: PlayerController = world.get_node("Player")
	var passage: ChangingPassage = world.get_node("ChangingPassage")
	var map := world.get_map_state()
	var inventory: PlayerInventory = player.get_node("Inventory")
	var run: ExplorationRun = world.get_node("%ExplorationRun")
	var start_frame := Engine.get_physics_frames()
	await _walk(player, Vector2(-650, -200))
	await _walk(player, Vector2(-275, -200))
	_tap(KEY_E)
	_expect(await InteractionTestInput.wait_for_work(player), "Pickup never completed.")
	await _frames(3)
	_expect(inventory.get_used_slots() == 1, "Real pickup failed.")
	await _walk(player, Vector2(120, -200))
	await _frames(200)
	_expect(passage.get_phase() == ChangingPassage.Phase.BLOCKED and run.is_active(), "Closure incorrectly failed the expedition.")
	_expect(map.get_passage_status(&"prototype_upper_link") == ExplorationMapState.PassageStatus.OPEN, "Unseen closure leaked into map.")
	_expect(not world.get_route_notice().contains("막힘 확인"), "Notice revealed unseen closure.")
	_tap(KEY_M)
	await _frames(4)
	_expect(map.get_passage_status(&"prototype_upper_link") == ExplorationMapState.PassageStatus.OPEN, "Opening map disclosed live passage.")
	await _capture("retreat-stale-map.png")
	_tap(KEY_ESCAPE)
	await _frames(3)
	await _walk(player, Vector2(-325, -200))
	_expect(map.get_passage_status(&"prototype_upper_link") == ExplorationMapState.PassageStatus.BLOCKED, "Re-observation did not record closure.")
	Input.action_press(InputActions.MOVE_LEFT)
	await _frames(55)
	_release()
	_expect(player.position.x > -345.0 and run.is_active() and inventory.get_used_slots() == 1, "Blocked passage allowed crossing or lost cargo.")
	await _capture("retreat-blocked.png")
	get_tree().root.size = Vector2i(1600, 900)
	await _frames(6)
	var notice: Label = world.get_node("%ChoiceStatus")
	_expect(Rect2(Vector2.ZERO, get_viewport().get_visible_rect().size).encloses(notice.get_global_rect()), "Wide notice clipped.")
	_expect(not notice.get_global_rect().intersects(world.get_node("%LoadStatus").get_global_rect()), "Notice overlaps load HUD.")
	await _capture("retreat-wide.png")
	get_tree().root.size = Vector2i(1152, 648)
	await _frames(5)
	await _walk(player, Vector2(628, -200))
	await _walk(player, Vector2(628, -70))
	_tap(KEY_E)
	await _frames(5)
	var door: TemporaryDoor = world.get_node("%RetreatDoor")
	_expect(not door.is_open and run.is_active(), "Closing detour door caused premature route loss.")
	_expect(map.get_passage_status(&"prototype_bypass_link") == ExplorationMapState.PassageStatus.BLOCKED, "Closed detour door not observed.")
	Input.action_press(InputActions.MOVE_DOWN)
	await _frames(35)
	_release()
	_expect(player.position.y < -25.0, "Closed detour door did not block movement.")
	_tap(KEY_E)
	await _frames(5)
	_expect(door.is_open, "Detour door could not reopen.")
	# Existing dangers and their timings stay active. Use a real Q if the golem
	# enters harness reach while walking the long way around the central wall.
	await _walk_detour(world, Vector2(628, 310))
	await _walk_detour(world, Vector2(0, 310))
	await _walk_detour(world, Vector2(0, 200))
	await _walk_detour(world, Vector2(-500, 200))
	await _walk(player, Vector2(-680, 0))
	_expect(run.is_active() and inventory.get_used_slots() == 1, "Actual alternative route lost expedition/cargo.")
	_expect(_used_discharge and player.get_node("HarnessController").get_current_charge() == 2 and world.get_node("%PlayerSurvival").get_health() == 2, "Detour changed danger/resource contract.")
	_tap(KEY_E)
	await _frames(5)
	_expect(run.get_state() == ExplorationRun.State.SAFE_RETURN, "Alternative route did not return to original entrance.")
	var recovered := run.get_outcome().get_recovery_result()
	_expect(recovered != null and recovered.get_item_count() == 1, "Detour recovery result wrong.")
	_expect(not passage.is_active() and not world.get_node("%ReturnRouteStatus").visible, "Ended route kept simulation/HUD active.")
	await _capture("retreat-returned.png")
	_measurements.append({"route": "blocked_upper_detour", "frames": Engine.get_physics_frames() - start_frame, "safe_return": run.get_state() == ExplorationRun.State.SAFE_RETURN, "recovered_items": recovered.get_item_count() if recovered != null else 0, "charge_remaining": player.get_node("HarnessController").get_current_charge(), "used_discharge": _used_discharge})
	world.queue_free()
	await _frames(4)


func _walk_detour(world: PrototypeExploration, target: Vector2) -> void:
	var player: PlayerController = world.get_node("Player")
	for frame in range(720):
		var offset := target - player.position
		_release()
		if offset.length() < 6.0:
			await _frames(3)
			return
		if not _used_discharge and player.get_node("HazardDetector").get_current_harness_target() == world.get_node("%BrokenGuardGolem"):
			_tap(KEY_Q)
			_used_discharge = true
		if absf(offset.x) > 3.0:
			Input.action_press(InputActions.MOVE_RIGHT if offset.x > 0.0 else InputActions.MOVE_LEFT)
		if absf(offset.y) > 3.0:
			Input.action_press(InputActions.MOVE_DOWN if offset.y > 0.0 else InputActions.MOVE_UP)
		await _frames(1)
	_release()
	_expect(false, "Detour blocked at %s before %s." % [player.position, target])


func _check_failure_and_new_visit() -> void:
	var world := await _new_world()
	var passage: ChangingPassage = world.get_node("ChangingPassage")
	_expect(passage.get_phase() == ChangingPassage.Phase.OPEN and world.get_map_state().get_observed_passage_count() == 0, "New visit retained closure or map.")
	await _walk(world.get_node("Player"), Vector2(-650, -200))
	await _walk(world.get_node("Player"), Vector2(-315, -200))
	_tap(KEY_M)
	await _frames(3)
	world.get_node("%ExplorationRun").complete_failure()
	await _frames(3)
	var remaining := passage.get_warning_remaining()
	await _frames(220)
	_expect(not get_tree().paused and not passage.is_active() and remaining == passage.get_warning_remaining(), "Failure failed to stop paused passage event.")
	world.queue_free()
	await _frames(4)


func _capture(filename: String) -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--retreat-render-directory="):
			var directory := argument.trim_prefix("--retreat-render-directory=")
			DirAccess.make_dir_recursive_absolute(directory)
			await RenderingServer.frame_post_draw
			_expect(get_viewport().get_texture().get_image().save_png(directory.path_join(filename)) == OK, "Screenshot failed.")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		GameLog.error(&"SmokeTest", &"retreat_route_failed", message)
