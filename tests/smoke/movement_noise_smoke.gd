extends Node

const PLAYER := preload("res://src/gameplay/player/player.tscn")
const GOLEM := preload("res://src/gameplay/hazards/broken_guard_golem.tscn")
const WORLD := preload("res://src/app/prototype_exploration.tscn")
const RULE := preload("res://src/data/prototype_load_noise.tres")
const MOVEMENT := preload("res://src/data/prototype_load_movement.tres")
const LIGHT := preload("res://src/data/prototype_light.tres")
const HEAVY := preload("res://src/data/prototype_heavy.tres")
const KNOWN := preload("res://src/data/prototype_known.tres")

var _failures := PackedStringArray()
var _emissions: Array[Dictionary] = []
var _heard: Array[bool] = []


func _ready() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	await _check_emitter()
	await _check_hearing()
	await _check_exploration()
	_release()
	get_tree().paused = false
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"movement_noise_passed")
	get_tree().quit(0 if _failures.is_empty() else 1)


func _fixture() -> Node2D:
	var fixture := Node2D.new()
	var player: PlayerController = PLAYER.instantiate()
	player.name = "Player"
	player.collision_mask = 8
	player.position = Vector2(-1000, 0)
	player.load_movement_rule = MOVEMENT
	fixture.add_child(player)
	var golem: BrokenGuardGolem = GOLEM.instantiate()
	golem.name = "Golem"
	# Isolate sound from sight and movement; integration below uses real steps.
	golem.patrol_speed = 0.0
	golem.suspicious_speed = 0.0
	golem.chase_speed = 0.0
	golem.search_speed = 0.0
	golem.suspicion_duration = 0.2
	golem.search_duration = 0.3
	golem.discharge_duration = 0.2
	fixture.add_child(golem)
	var emitter := MovementNoiseEmitter.new()
	emitter.name = "Emitter"
	emitter.player_path = NodePath("../Player")
	emitter.inventory_path = NodePath("../Player/Inventory")
	emitter.noise_rule = RULE
	emitter.noise_emitted.connect(_record_noise)
	fixture.add_child(emitter)
	var hearing := GolemHearing.new()
	hearing.name = "Hearing"
	hearing.source_path = NodePath("../Emitter")
	hearing.golem_path = NodePath("../Golem")
	hearing.noise_heard.connect(func(escalated: bool): _heard.append(escalated))
	fixture.add_child(hearing)
	add_child(fixture)
	player.get_node("Inventory").configure_capacity(3, 2.5, 4.0)
	return fixture


func _check_emitter() -> void:
	_expect(RULE.is_valid(), "Invalid prototype noise rule.")
	for row in [["step_distance", 0.0], ["step_distance", INF], ["normal_radius", NAN], ["normal_radius", -1.0], ["burdened_radius", 96.0], ["overloaded_radius", 180.0], ["overloaded_radius", INF], ["loud_noise_count", 1], ["loud_noise_window", 0.0], ["loud_noise_window", NAN]]:
		var invalid := RULE.duplicate() as LoadNoiseRule
		invalid.set(row[0], row[1])
		_expect(not invalid.is_valid(), "Invalid noise rule accepted: %s." % row[0])
	var fixture := _fixture()
	var player: PlayerController = fixture.get_node("Player")
	var inventory: PlayerInventory = player.get_node("Inventory")
	var emitter: MovementNoiseEmitter = fixture.get_node("Emitter")
	await _frames(3)
	_emissions.clear()
	Input.action_press(InputActions.MOVE_RIGHT)
	await _frames(30)
	_release()
	_expect(_emissions.is_empty(), "Inactive emitter made noise.")
	emitter.set_active(true)
	for row in [[0.0, 96.0, false], [2.5, 180.0, false], [4.0, 260.0, true]]:
		inventory.take_all_inventory_items()
		var item := LIGHT.duplicate(true) as ItemDefinition
		item.weight = row[0]
		inventory.try_add_item(item)
		for diagonal in [false, true]:
			await _frames(3)
			_emissions.clear()
			var before := player.position
			Input.action_press(InputActions.MOVE_RIGHT)
			if diagonal:
				Input.action_press(InputActions.MOVE_DOWN)
			await _frames(34)
			_release()
			await _frames(2)
			var distance := before.distance_to(player.position)
			_expect(_emissions.size() == floori(distance / RULE.step_distance), "Footsteps did not match actual travel distance.")
			for emission in _emissions:
				_expect(emission.radius == row[1] and emission.loud == row[2], "Footstep load strength mismatch.")
	_emissions.clear()
	player.position += Vector2(0, 500)
	await _frames(30)
	_expect(_emissions.is_empty(), "Stationary player or teleport made noise.")
	get_tree().paused = true
	Input.action_press(InputActions.MOVE_RIGHT)
	await _frames(30)
	_release()
	_expect(_emissions.is_empty(), "Paused player made noise.")
	get_tree().paused = false
	var wall := StaticBody2D.new()
	wall.collision_layer = 8
	wall.position = player.position + Vector2(40, 0)
	var collision := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(24, 200)
	collision.shape = rectangle
	wall.add_child(collision)
	fixture.add_child(wall)
	await _frames(3)
	Input.action_press(InputActions.MOVE_RIGHT)
	await _frames(40)
	_emissions.clear()
	var blocked_position := player.position
	await _frames(40)
	_release()
	_expect(player.position.distance_to(blocked_position) < 0.01 and _emissions.is_empty(), "Blocked input produced footsteps.")
	fixture.queue_free()
	await _frames(3)


func _check_hearing() -> void:
	var fixture := _fixture()
	var emitter: MovementNoiseEmitter = fixture.get_node("Emitter")
	var hearing: GolemHearing = fixture.get_node("Hearing")
	var golem: BrokenGuardGolem = fixture.get_node("Golem")
	var player: PlayerController = fixture.get_node("Player")
	await _frames(3)
	_heard.clear()
	emitter.noise_emitted.emit(Vector2(200, 0), 260.0, true)
	_expect(_heard.is_empty(), "Inactive hearing reacted.")
	hearing.set_active(true)
	for radius in [96.0, 180.0]:
		emitter.noise_emitted.emit(Vector2(200, 0), radius, false)
	emitter.noise_emitted.emit(Vector2(260.01, 0), 260.0, true)
	emitter.noise_emitted.emit(Vector2(NAN, 0), 260.0, true)
	emitter.noise_emitted.emit(Vector2(200, 0), INF, true)
	_expect(_heard.is_empty(), "Out-of-range or invalid sound heard.")
	emitter.noise_emitted.emit(Vector2(260, 0), 260.0, true)
	_expect(_heard == [false] and golem.get_last_known_position() == Vector2(260, 0), "Boundary sound not investigated.")
	await _frames(16)
	_expect(golem.get_state() == BrokenGuardGolem.State.SEARCH, "Single sound escalated to chase.")
	await _frames(25)
	_expect(golem.get_state() == BrokenGuardGolem.State.PATROL and hearing.get_loud_noise_count() == 0, "Single sound did not return to patrol.")
	_heard.clear()
	for index in range(3):
		emitter.noise_emitted.emit(Vector2(220 + index, 0), 260.0, true)
		await _frames(2)
	_expect(_heard == [false, false, true] and golem.get_state() == BrokenGuardGolem.State.SUSPICIOUS, "Loud repetition skipped alarm warning.")
	var last_heard := golem.get_last_known_position()
	# Further steps cannot postpone an already raised alarm or overwrite its target.
	for index in range(16):
		emitter.noise_emitted.emit(Vector2(-220, 0), 260.0, index % 2 == 0)
		await _frames(1)
	_expect(golem.get_state() == BrokenGuardGolem.State.CHASE and golem.get_last_known_position() == last_heard, "Later footsteps reset alarm/chase.")
	player.position = Vector2(-900, 400)
	await _frames(3)
	_expect(golem.get_last_known_position() == last_heard, "Sound acquired a live player target.")
	_expect(golem.emergency_discharge(), "Discharge failed.")
	_expect(hearing.get_loud_noise_count() == 0, "Discharge retained loud history.")
	emitter.noise_emitted.emit(Vector2(220, 0), 260.0, true)
	_expect(_heard.size() == 3, "Disabled golem heard sound.")
	await _frames(40)
	_heard.clear()
	golem.search_duration = 5.0
	emitter.noise_emitted.emit(Vector2(220, 0), 260.0, true)
	await _frames(130)
	_expect(hearing.get_loud_noise_count() == 0, "Old loud sound did not expire.")
	emitter.noise_emitted.emit(Vector2(220, 0), 260.0, true)
	get_tree().paused = true
	await _frames(130)
	emitter.noise_emitted.emit(Vector2(220, 0), 260.0, true)
	_expect(hearing.get_loud_noise_count() == 1, "Pause advanced or accepted sound history.")
	get_tree().paused = false
	emitter.noise_emitted.emit(Vector2(220, 0), 260.0, true)
	_expect(hearing.get_loud_noise_count() == 2 and not _heard.back(), "Pause lost unexpired history.")
	hearing.set_active(false)
	_expect(hearing.get_loud_noise_count() == 0, "Deactivation retained history.")
	hearing.set_active(true)
	_expect(golem.raise_alarm(Vector2(-240, 0)), "External alarm rejected.")
	_expect(not golem.investigate_noise(Vector2(240, 0)), "Weak noise replaced external alarm.")
	await _frames(16)
	_expect(golem.get_state() == BrokenGuardGolem.State.CHASE and golem.get_last_known_position() == Vector2(-240, 0), "External alarm was downgraded.")
	golem.emergency_discharge()
	await _frames(16)
	player.position = Vector2(100, 0)
	await _frames(4)
	var visual_position := golem.get_last_known_position()
	_expect(not golem.can_investigate_noise(), "Visual detection did not take priority.")
	emitter.noise_emitted.emit(Vector2(-220, 0), 260.0, true)
	_expect(golem.get_last_known_position() == visual_position, "Noise replaced visible target.")
	fixture.queue_free()
	await _frames(3)


func _check_exploration() -> void:
	var world: PrototypeExploration = WORLD.instantiate()
	add_child(world)
	await _frames(3)
	var player: PlayerController = world.get_node("Player")
	var inventory: PlayerInventory = player.get_node("Inventory")
	var emitter: MovementNoiseEmitter = world.get_node("%MovementNoiseEmitter")
	var hearing: GolemHearing = world.get_node("%GolemHearing")
	var golem: BrokenGuardGolem = world.get_node("%BrokenGuardGolem")
	emitter.noise_emitted.connect(_record_noise)
	_emissions.clear()
	Input.action_press(InputActions.MOVE_RIGHT)
	await _frames(20)
	_release()
	_expect(_emissions.is_empty(), "Departure gate emitted noise.")
	var loadout := ExpeditionLoadout.new()
	loadout.slot_capacity = 3
	loadout.burden_weight = 2.5
	loadout.overload_weight = 4.0
	loadout.charge_capacity = 3
	loadout.starting_charge = 3
	_expect(world.prepare_departure(loadout) and world.start_exploration(), "Departure failed.")
	inventory.try_add_item(HEAVY)
	inventory.try_add_item(KNOWN)
	# Keep the golem outside vision but inside overloaded hearing throughout walking.
	player.position = Vector2(540, -150)
	golem.position = Vector2(300, -150)
	golem.patrol_speed = 0.0
	golem.suspicious_speed = 0.0
	golem.chase_speed = 0.0
	golem.search_speed = 0.0
	await _frames(3)
	Input.action_press(InputActions.MOVE_UP)
	await _frames(24)
	_release()
	await _frames(2)
	_expect(golem.get_state() == BrokenGuardGolem.State.SUSPICIOUS and world.get_node("%ChoiceStatus").text.contains("이동 소음에"), "Real overloaded steps did not trigger hearing feedback.")
	_expect(world.get_node("%LoadStatus").text.contains("소음 매우 큼"), "Overload noise missing from HUD.")
	await _capture("noise-heard.png")
	# Menu pauses both motion and sound accumulation.
	for key in [KEY_TAB, KEY_M]:
		_tap(key)
		await _frames(3)
		var count := _emissions.size()
		var history := hearing.get_loud_noise_count()
		Input.action_press(InputActions.MOVE_DOWN)
		await _frames(20)
		_release()
		_expect(get_tree().paused and _emissions.size() == count and hearing.get_loud_noise_count() == history, "Menu did not pause noise.")
		_tap(key)
		await _frames(3)
	Input.action_press(InputActions.MOVE_DOWN)
	await _frames(46)
	_release()
	await _frames(2)
	_expect(world.get_node("%ChoiceStatus").text.contains(" 경보가 높아졌습니다"), "Real repeated loud steps did not raise alarm.")
	await _capture("noise-alarm.png")
	await _frames(48)
	_expect(golem.get_state() == BrokenGuardGolem.State.CHASE, "Real noise alarm did not chase.")
	inventory.select_item(1)
	_key(KEY_G, true)
	await _frames(45)
	_key(KEY_G, false)
	await _frames(3)
	_expect(inventory.get_used_slots() == 1 and emitter.get_noise_radius() == 96.0 and world.get_node("%LoadStatus").text.contains("소음 작음"), "Quick drop did not reduce noise.")
	await _capture("noise-reduced.png")
	world.get_node("%ExplorationRun").complete_failure()
	await _frames(3)
	_emissions.clear()
	Input.action_press(InputActions.MOVE_RIGHT)
	await _frames(30)
	_release()
	_expect(_emissions.is_empty() and hearing.get_loud_noise_count() == 0, "Exploration end retained noise.")
	world.queue_free()
	await _frames(3)
	world = WORLD.instantiate()
	add_child(world)
	await _frames(3)
	_expect(world.prepare_departure(loadout) and world.start_exploration(), "Fresh departure failed.")
	emitter = world.get_node("%MovementNoiseEmitter")
	hearing = world.get_node("%GolemHearing")
	_expect(emitter.get_noise_radius() == 96.0 and hearing.get_loud_noise_count() == 0, "Previous noise leaked into fresh departure.")
	emitter.noise_emitted.connect(_record_noise)
	world.get_node("%ExplorationRun").complete_safe_return()
	await _frames(3)
	_emissions.clear()
	Input.action_press(InputActions.MOVE_RIGHT)
	await _frames(30)
	_release()
	_expect(_emissions.is_empty() and hearing.get_loud_noise_count() == 0, "Safe return retained noise.")
	world.queue_free()
	await _frames(3)


func _record_noise(position: Vector2, radius: float, loud: bool) -> void:
	_emissions.append({"position": position, "radius": radius, "loud": loud})


func _release() -> void:
	for action in [InputActions.MOVE_LEFT, InputActions.MOVE_RIGHT, InputActions.MOVE_UP, InputActions.MOVE_DOWN]:
		Input.action_release(action)


func _key(key: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = key
	event.physical_keycode = key
	event.pressed = pressed
	Input.parse_input_event(event)


func _tap(key: Key) -> void:
	_key(key, true)
	_key(key, false)


func _capture(filename: String) -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--noise-render-directory="):
			var directory := argument.trim_prefix("--noise-render-directory=")
			DirAccess.make_dir_recursive_absolute(directory)
			await RenderingServer.frame_post_draw
			_expect(get_viewport().get_texture().get_image().save_png(directory.path_join(filename)) == OK, "Noise screenshot failed.")


func _frames(count: int) -> void:
	for index in range(count):
		await get_tree().physics_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		GameLog.error(&"SmokeTest", &"movement_noise_failed", message)
