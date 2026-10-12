extends Node

const WORLD := preload("res://src/app/prototype_exploration.tscn")
const RULE := preload("res://src/data/prototype_noise_lure.tres")

var _failures := PackedStringArray()
var _landings: Array[Vector2] = []


func _ready() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	_check_rule()
	await _check_throwing()
	await _check_gate()
	await _check_hearing()
	await _check_endings()
	_key(KEY_F, false)
	get_tree().paused = false
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"noise_lure_passed")
	get_tree().quit(0 if _failures.is_empty() else 1)


func _check_rule() -> void:
	_expect(RULE.is_valid(), "Prototype lure rule invalid.")
	for row in [["starting_uses", 0], ["minimum_distance", 0.0], ["maximum_distance", 24.0], ["maximum_distance", INF], ["wall_clearance", 0.0], ["wall_clearance", 24.0], ["flight_duration", NAN], ["hearing_radius", -1.0], ["marker_duration", 0.0]]:
		var invalid := RULE.duplicate() as NoiseLureRule
		invalid.set(row[0], row[1])
		_expect(not invalid.is_valid(), "Invalid lure rule accepted: %s." % row[0])


func _new_world(start := true) -> PrototypeExploration:
	var world: PrototypeExploration = WORLD.instantiate()
	add_child(world)
	await _frames(3)
	world.get_node("%NoiseLureController").lure_landed.connect(func(position: Vector2, _radius: float): _landings.append(position))
	if start:
		_expect(world.prepare_departure(_loadout()) and world.start_exploration(), "Departure failed.")
		await _frames(3)
	return world


func _loadout() -> ExpeditionLoadout:
	var loadout := ExpeditionLoadout.new()
	loadout.slot_capacity = 3
	loadout.burden_weight = 2.5
	loadout.overload_weight = 4.0
	loadout.charge_capacity = 3
	loadout.starting_charge = 3
	return loadout


func _check_throwing() -> void:
	var world := await _new_world(false)
	var tool: NoiseLureController = world.get_node("%NoiseLureController")
	var player: PlayerController = world.get_node("Player")
	var golem: BrokenGuardGolem = world.get_node("%BrokenGuardGolem")
	_landings.clear()
	_tap(KEY_F)
	await _frames(25)
	_expect(tool.get_remaining_uses() == 0 and _landings.is_empty(), "Tool active before departure.")
	_key(KEY_F, true)
	_expect(world.prepare_departure(_loadout()) and world.start_exploration(), "Held-key departure failed.")
	player.position = Vector2(50, -200)
	golem.position = Vector2(500, -200)
	golem.patrol_speed = 0.0
	await _aim(world, Vector2(200, -200))
	_key(KEY_F, true, true)
	await _frames(3)
	_expect(tool.get_remaining_uses() == 2 and not tool.is_in_flight(), "Held departure key threw a lure.")
	_key(KEY_F, false)
	await _aim(world, player.position)
	_tap(KEY_F)
	await _frames(4)
	_expect(tool.get_remaining_uses() == 2 and not tool.is_in_flight(), "Too-close target consumed a lure.")
	player.position = Vector2(50, -42)
	await _aim(world, Vector2(50, 200))
	_tap(KEY_F)
	await _frames(4)
	_expect(tool.get_remaining_uses() == 2 and not tool.is_in_flight(), "Wall immediately ahead consumed a lure.")
	player.position = Vector2(50, -200)
	await _aim(world, Vector2(50, 200))
	_key(KEY_F, true)
	await _frames(3)
	_expect(tool.is_in_flight() and tool.get_remaining_uses() == 1 and _landings.is_empty(), "Launch did not consume once before landing.")
	_expect(tool.get_landing_position().distance_to(Vector2(50, -28)) < 0.1, "Throw crossed central wall.")
	_key(KEY_F, true, true)
	_key(KEY_F, true)
	_key(KEY_F, false)
	_tap(KEY_F)
	await _frames(2)
	_expect(tool.get_remaining_uses() == 1, "Repeat or concurrent throw consumed extra stock.")
	for menu in [KEY_TAB, KEY_M]:
		_tap(menu)
		await _frames(3)
		_key(KEY_F, true)
		await _frames(30)
		_expect(get_tree().paused and tool.is_in_flight() and _landings.is_empty() and tool.get_remaining_uses() == 1, "Menu failed to pause throw/input.")
		_tap(menu)
		await _frames(3)
		_key(KEY_F, true, true)
		_key(KEY_F, false)
	await _frames(24)
	_expect(_landings.size() == 1 and golem.get_state() == BrokenGuardGolem.State.PATROL, "Distant landing incorrectly lured golem.")
	await _aim(world, Vector2(650, -200))
	_key(KEY_F, true)
	await _frames(5)
	_expect(tool.is_in_flight() and tool.get_remaining_uses() == 0, "Second throw failed.")
	_expect(tool.get_landing_position().distance_to(Vector2(350, -200)) < 0.1, "Maximum throw range incorrect.")
	await _capture("lure-flight.png")
	_key(KEY_F, true, true)
	_key(KEY_F, false)
	Input.action_press(InputActions.MOVE_LEFT)
	await _frames(24)
	Input.action_release(InputActions.MOVE_LEFT)
	await _frames(2)
	_expect(_landings.size() == 2 and _landings.back().distance_to(Vector2(350, -200)) < 0.1, "Moving thrower altered destination or duplicated landing.")
	_expect(golem.get_state() == BrokenGuardGolem.State.SUSPICIOUS and golem.get_last_known_position() == _landings.back(), "Landing did not lure toward snapshot position.")
	_expect(world.get_node("%ChoiceStatus").text.contains("소리 쪽으로 움직입니다"), "Lure feedback missing.")
	_expect(world.get_node("%ToolStatus").text.contains("0/2"), "Remaining stock missing from HUD.")
	await _capture("lure-heard.png")
	var before := golem.position
	await _frames(30)
	_expect(golem.position.x < before.x and golem.get_last_known_position() == _landings.back(), "Golem did not move toward lure or tracked thrower.")
	_tap(KEY_F)
	await _frames(25)
	_expect(tool.get_remaining_uses() == 0 and _landings.size() == 2 and world.get_node("%ChoiceStatus").text.contains("없습니다"), "Exhausted tool could be used.")
	_expect(world.get_node("Player/Inventory").get_used_slots() == 0 and world.get_node("Player/HarnessController").get_current_charge() == 3, "Lure consumed recovery slots or harness charge.")
	await _capture("lure-empty.png")
	world.queue_free()
	await _frames(3)


func _check_gate() -> void:
	var world := await _new_world()
	var tool: NoiseLureController = world.get_node("%NoiseLureController")
	var player: PlayerController = world.get_node("Player")
	player.position = Vector2(100, -300)
	await _aim(world, Vector2(100, -450))
	_tap(KEY_F)
	await _frames(3)
	_expect(tool.get_landing_position().distance_to(Vector2(100, -348)) < 0.1, "Throw crossed closed remaining-zone entrance.")
	await _frames(24)
	_tap(KEY_Q)
	await _frames(4)
	_expect(world.get_node("%RemainingZoneEntrance").is_open(), "Could not stabilize gate for throw test.")
	await _aim(world, Vector2(100, -450))
	_tap(KEY_F)
	await _frames(3)
	_expect(tool.get_landing_position().distance_to(Vector2(100, -450)) < 0.1, "Throw still blocked by open gate.")
	await _frames(24)
	_expect(world.get_map_state().get_discovered_region_count() == 0, "Throw disclosed an unvisited region.")
	world.queue_free()
	await _frames(3)


func _check_hearing() -> void:
	var world := await _new_world()
	var player: PlayerController = world.get_node("Player")
	var golem: BrokenGuardGolem = world.get_node("%BrokenGuardGolem")
	var hearing: GolemHearing = world.get_node("%GolemHearing")
	var emitter: MovementNoiseEmitter = world.get_node("%MovementNoiseEmitter")
	player.position = Vector2(-650, -200)
	golem.position = Vector2(400, -200)
	golem.patrol_speed = 0.0
	golem.suspicious_speed = 0.0
	golem.chase_speed = 0.0
	golem.search_speed = 0.0
	golem.suspicion_duration = 0.15
	golem.search_duration = 0.2
	golem.discharge_duration = 0.15
	await _frames(3)
	_expect(not hearing.hear_lure(Vector2(720.1, -200), 320.0), "Out-of-range lure heard.")
	_expect(not hearing.hear_lure(Vector2(NAN, 0), 320.0) and not hearing.hear_lure(Vector2(600, -200), INF), "Invalid lure heard.")
	_expect(hearing.hear_lure(Vector2(720, -200), 320.0), "Boundary lure not heard.")
	await _frames(12)
	_expect(golem.get_state() == BrokenGuardGolem.State.SEARCH, "Single lure escalated to chase.")
	# This deliberately immobile golem now gives up at the lure stall bound,
	# rather than spending the ordinary search timer while travelling.
	await _frames(72)
	_expect(golem.get_state() == BrokenGuardGolem.State.PATROL, "Blocked lure did not return to patrol.")
	emitter.noise_emitted.emit(Vector2(600, -200), 260.0, true)
	emitter.noise_emitted.emit(Vector2(600, -200), 260.0, true)
	_expect(hearing.get_loud_noise_count() == 2 and hearing.hear_lure(Vector2(650, -200), 320.0), "Could not lure suspicious golem.")
	_expect(hearing.get_loud_noise_count() == 2, "Lure altered movement alarm history.")
	emitter.noise_emitted.emit(Vector2(600, -200), 260.0, true)
	_expect(not hearing.hear_lure(Vector2(650, -200), 320.0), "Lure erased pending alarm.")
	await _frames(12)
	_expect(golem.get_state() == BrokenGuardGolem.State.CHASE, "Lure prevented existing noise alarm.")
	_expect(hearing.hear_lure(Vector2(650, -200), 320.0) and golem.get_state() == BrokenGuardGolem.State.SUSPICIOUS, "Sound-only chase could not be redirected.")
	_expect(golem.get_last_known_position() == Vector2(650, -200), "Lure did not replace sound-only chase destination.")
	_expect(golem.emergency_discharge(), "Discharge failed.")
	_expect(not hearing.hear_lure(Vector2(650, -200), 320.0), "Disabled golem followed lure.")
	await _frames(30)
	player.position = Vector2(500, -200)
	await _frames(4)
	var visual := golem.get_last_known_position()
	_expect(not hearing.hear_lure(Vector2(650, -200), 320.0) and golem.get_last_known_position() == visual, "Lure replaced visual target.")
	get_tree().paused = true
	_expect(not hearing.hear_lure(Vector2(650, -200), 320.0), "Paused golem heard lure.")
	get_tree().paused = false
	hearing.set_active(false)
	_expect(not hearing.hear_lure(Vector2(650, -200), 320.0), "Inactive golem heard lure.")
	world.queue_free()
	await _frames(3)


func _check_endings() -> void:
	for safe in [true, false]:
		var world := await _new_world()
		var tool: NoiseLureController = world.get_node("%NoiseLureController")
		var player: PlayerController = world.get_node("Player")
		_expect(tool.get_remaining_uses() == 2, "New departure did not reset test stock.")
		player.position = Vector2(-650, -200)
		await _aim(world, Vector2(-450, -200))
		# A queued input is cancelled by menu opening/focus loss before physics.
		_key(KEY_F, true)
		_tap(KEY_TAB)
		await _frames(3)
		_key(KEY_F, false)
		_tap(KEY_TAB)
		await _frames(3)
		_expect(tool.get_remaining_uses() == 2 and not tool.is_in_flight(), "Queued throw survived menu opening.")
		_key(KEY_F, true)
		tool.notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
		_key(KEY_F, false)
		await _frames(3)
		_expect(tool.get_remaining_uses() == 2, "Queued throw survived focus loss.")
		await _aim(world, Vector2(-450, -200))
		_tap(KEY_F)
		await _frames(4)
		_expect(tool.is_in_flight() and tool.get_remaining_uses() == 1, "End test did not start a throw.")
		var count := _landings.size()
		var run: ExplorationRun = world.get_node("%ExplorationRun")
		if safe:
			run.complete_safe_return()
		else:
			run.complete_failure()
		await _frames(30)
		_tap(KEY_F)
		await _frames(5)
		_expect(not tool.is_in_flight() and _landings.size() == count and tool.get_remaining_uses() == 1, "End did not cancel flight and block use.")
		world.queue_free()
		await _frames(3)


func _aim(world: Node2D, position: Vector2) -> void:
	await _frames(3)
	var event := InputEventMouseMotion.new()
	event.position = world.get_canvas_transform() * position
	Input.parse_input_event(event)
	Input.flush_buffered_events()
	await _frames(2)


func _key(key: Key, pressed: bool, echo := false) -> void:
	var event := InputEventKey.new()
	event.keycode = key
	event.physical_keycode = key
	event.pressed = pressed
	event.echo = echo
	Input.parse_input_event(event)
	Input.flush_buffered_events()


func _tap(key: Key) -> void:
	_key(key, true)
	_key(key, false)


func _capture(filename: String) -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--lure-render-directory="):
			var directory := argument.trim_prefix("--lure-render-directory=")
			DirAccess.make_dir_recursive_absolute(directory)
			await RenderingServer.frame_post_draw
			_expect(get_viewport().get_texture().get_image().save_png(directory.path_join(filename)) == OK, "Lure screenshot failed.")


func _frames(count: int) -> void:
	for index in range(count):
		await get_tree().physics_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		GameLog.error(&"SmokeTest", &"noise_lure_failed", message)
