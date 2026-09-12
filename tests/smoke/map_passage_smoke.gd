extends Node

const WORLD := preload("res://src/app/prototype_exploration.tscn")
const MAP := preload("res://src/data/prototype_exploration_map.tres")
const UPPER: StringName = &"prototype_upper_link"
const CENTER: StringName = &"prototype_central_link"
const BYPASS: StringName = &"prototype_bypass_link"
const MOVE_ACTIONS := [InputActions.MOVE_LEFT, InputActions.MOVE_RIGHT, InputActions.MOVE_UP, InputActions.MOVE_DOWN]

var _failures := PackedStringArray()


func _ready() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	_check_state_boundary()
	var world: PrototypeExploration = WORLD.instantiate()
	add_child(world)
	await _frames(4)
	var state := world.get_map_state()
	var player: PlayerController = world.get_node("Player")
	var panel: ExplorationMapPanel = world.get_node("%ExplorationMapPanel")
	_expect(state.get_observed_passage_count() == 0, "Survey recorded a passage before departure.")
	_expect(world.prepare_departure(_loadout()) and world.start_exploration(), "Could not start survey exploration.")
	await _frames(3)
	_expect(state.get_observed_passage_count() == 0, "Distant passages were known on departure.")
	_press_key(KEY_M)
	await _frames(3)
	_expect(panel.get_passage_summary_text().contains("0 / 3"), "Unobserved summary is incorrect.")
	await _capture("passages-unknown.png")
	_press_key(KEY_M)
	await _walk(player, Vector2(-500, -200))
	_expect(state.get_passage_status(UPPER) == ExplorationMapState.PassageStatus.OPEN, "Nearby open crossing was not observed.")
	_expect(state.get_passage_status(CENTER) == ExplorationMapState.PassageStatus.UNKNOWN, "Central wall was revealed remotely.")
	await _walk(player, Vector2(60, -200))
	await _walk(player, Vector2(60, -150))
	_expect(state.get_passage_status(CENTER) == ExplorationMapState.PassageStatus.BLOCKED, "Actual central wall was not marked blocked.")
	Input.action_press(InputActions.MOVE_DOWN)
	await _frames(45)
	Input.action_release(InputActions.MOVE_DOWN)
	_expect(player.position.y <= -33.0, "Map's blocked central crossing did not match actual collision.")
	_press_key(KEY_M)
	await _frames(3)
	_expect(panel.get_passage_summary_text().contains("열림 1") and panel.get_passage_summary_text().contains("막힘 1"), "Observed counts do not match map states.")
	await _capture("passages-observed.png")
	_press_key(KEY_ESCAPE)
	await _walk(player, Vector2(60, -200))
	await _walk(player, Vector2(630, -200))
	_expect(state.get_passage_status(BYPASS) == ExplorationMapState.PassageStatus.UNKNOWN, "Bypass was observed outside the configured range.")
	await _walk(player, Vector2(630, -145))
	_expect(state.get_passage_status(BYPASS) == ExplorationMapState.PassageStatus.OPEN, "Open bypass was not observed.")
	await _walk(player, Vector2(630, -220))
	# Only tests create barriers: the playable prototype keeps its original layout.
	var barrier := _block(world, Vector2(630, 0), Vector2(320, 24))
	await _frames(4)
	_expect(state.get_passage_status(BYPASS) == ExplorationMapState.PassageStatus.OPEN, "A remote change leaked into last observed map state.")
	_press_key(KEY_M)
	await _frames(3)
	_expect(panel.get_passage_summary_text().contains("열림 2"), "Opening map queried remote live geometry.")
	_press_key(KEY_ESCAPE)
	# A nearby endpoint behind another wall is not a valid observation point.
	var occluder := _block(world, Vector2(630, -110), Vector2(60, 12))
	await _frames(3)
	await _walk(player, Vector2(630, -145))
	_expect(state.get_passage_status(BYPASS) == ExplorationMapState.PassageStatus.OPEN, "Survey observed a changed passage through an occluding wall.")
	occluder.queue_free()
	await _frames(4)
	_expect(state.get_passage_status(BYPASS) == ExplorationMapState.PassageStatus.BLOCKED, "Re-observation did not update the changed crossing.")
	Input.action_press(InputActions.MOVE_DOWN)
	await _frames(45)
	Input.action_release(InputActions.MOVE_DOWN)
	_expect(player.position.y <= -25.0, "Blocked bypass did not block actual movement.")
	_press_key(KEY_M)
	await _frames(3)
	barrier.queue_free()
	await _frames(5)
	_expect(state.get_passage_status(BYPASS) == ExplorationMapState.PassageStatus.BLOCKED, "Survey ran while the map paused exploration.")
	_press_key(KEY_ESCAPE)
	await _frames(4)
	_expect(state.get_passage_status(BYPASS) == ExplorationMapState.PassageStatus.OPEN, "Survey did not resume after map close.")
	await _walk(player, Vector2(630, -145))
	# The center ray is clear, but the player's 14 px footprint cannot fit.
	var side_blocker := _block(world, Vector2(642, 0), Vector2(8, 20))
	await _frames(4)
	_expect(state.get_passage_status(BYPASS) == ExplorationMapState.PassageStatus.BLOCKED, "Survey ignored the travel footprint beside its center line.")
	_press_key(KEY_M)
	await _frames(3)
	world.get_node("%ExplorationRun").complete_failure()
	await _frames(3)
	side_blocker.queue_free()
	await _frames(4)
	_expect(not get_tree().paused and not panel.visible, "Run end left an open or paused map.")
	_expect(state.get_passage_status(BYPASS) == ExplorationMapState.PassageStatus.BLOCKED, "Finished exploration continued observing.")
	world.queue_free()
	await _frames(3)
	var next_world: PrototypeExploration = WORLD.instantiate()
	add_child(next_world)
	await _frames(3)
	_expect(next_world.prepare_departure(_loadout()) and next_world.start_exploration(), "Second departure failed.")
	await _frames(3)
	_expect(next_world.get_map_state().get_observed_passage_count() == 0, "Passage observations leaked into a new visit.")
	next_world.queue_free()
	await _frames(3)
	_release_movement()
	get_tree().paused = false
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"map_passage_passed")
	get_tree().quit(0 if _failures.is_empty() else 1)


func _check_state_boundary() -> void:
	var definition := MAP.duplicate(true) as ExplorationMapDefinition
	var state := ExplorationMapState.new()
	_expect(state.configure(definition), "Map with passage definitions rejected.")
	definition.passages[0].start = Vector2.ZERO
	var copy := state.get_definition()
	copy.passages[0].end = Vector2.ZERO
	_expect(state.get_definition().passages[0].start != Vector2.ZERO and state.get_definition().passages[0].end != Vector2.ZERO, "Map shared mutable passage definitions.")
	_expect(not state.observe_passage(&"missing", ExplorationMapState.PassageStatus.OPEN), "Unknown passage ID accepted.")
	_expect(not state.observe_passage(UPPER, ExplorationMapState.PassageStatus.UNKNOWN), "Unknown status was recorded as an observation.")
	_expect(state.observe_passage(UPPER, ExplorationMapState.PassageStatus.OPEN), "First passage observation rejected.")
	state.observe_passage(UPPER, ExplorationMapState.PassageStatus.OPEN)
	_expect(state.get_observed_passage_count() == 1, "Repeated observations inflated the count.")
	state.observe_passage(UPPER, ExplorationMapState.PassageStatus.BLOCKED)
	_expect(state.get_passage_count_by_status(ExplorationMapState.PassageStatus.BLOCKED) == 1 and state.get_visited_count() == 0, "Passage update altered visit state or lost its status.")
	var duplicate := MAP.duplicate(true) as ExplorationMapDefinition
	duplicate.passages[1].stable_id = duplicate.passages[0].stable_id
	_expect(not ExplorationMapState.new().configure(duplicate), "Duplicate passage ID accepted.")
	var invalid := MAP.duplicate(true) as ExplorationMapDefinition
	invalid.passages[0].end = invalid.passages[0].start
	_expect(not ExplorationMapState.new().configure(invalid), "Zero-length crossing accepted.")
	invalid = MAP.duplicate(true) as ExplorationMapDefinition
	invalid.passages[0].clearance_radius = 0.0
	_expect(not ExplorationMapState.new().configure(invalid), "Zero travel clearance accepted.")
	invalid = MAP.duplicate(true) as ExplorationMapDefinition
	invalid.passages[0].end = Vector2(9000, 0)
	_expect(not ExplorationMapState.new().configure(invalid), "Crossing outside map bounds accepted.")


func _block(world: Node2D, position: Vector2, dimensions: Vector2) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.position = position
	body.collision_layer = 8
	body.collision_mask = 0
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = dimensions
	collision.shape = shape
	body.add_child(collision)
	world.add_child(body)
	return body


func _loadout() -> ExpeditionLoadout:
	var loadout := ExpeditionLoadout.new()
	loadout.slot_capacity = 2
	loadout.burden_weight = 2.5
	loadout.overload_weight = 4.0
	loadout.charge_capacity = 3
	loadout.starting_charge = 3
	return loadout


func _capture(filename: String) -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--passage-render-directory="):
			var directory := argument.trim_prefix("--passage-render-directory=")
			DirAccess.make_dir_recursive_absolute(directory)
			await RenderingServer.frame_post_draw
			_expect(get_viewport().get_texture().get_image().save_png(directory.path_join(filename)) == OK, "Passage capture failed.")


func _walk(player: PlayerController, destination: Vector2) -> void:
	for frame in range(720):
		var offset := destination - player.global_position
		if offset.length() < 7.0:
			_release_movement()
			await _frames(3)
			return
		_release_movement()
		if absf(offset.x) > 3.0:
			Input.action_press(InputActions.MOVE_RIGHT if offset.x > 0.0 else InputActions.MOVE_LEFT)
		if absf(offset.y) > 3.0:
			Input.action_press(InputActions.MOVE_DOWN if offset.y > 0.0 else InputActions.MOVE_UP)
		await get_tree().physics_frame
	_release_movement()
	_expect(false, "Route blocked before %s." % destination)


func _release_movement() -> void:
	for action in MOVE_ACTIONS:
		Input.action_release(action)


func _press_key(key: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = key
	event.physical_keycode = key
	event.pressed = true
	get_viewport().push_input(event)
	var release := event.duplicate() as InputEventKey
	release.pressed = false
	get_viewport().push_input(release)


func _frames(count: int) -> void:
	for index in range(count):
		await get_tree().physics_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		GameLog.error(&"SmokeTest", &"map_passage_failed", message)
