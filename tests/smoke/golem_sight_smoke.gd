extends Node

const WORLD := preload("res://src/app/prototype_exploration.tscn")
const DOOR := preload("res://src/gameplay/interaction/door_interactable.tscn")
const GOLEM := preload("res://src/gameplay/hazards/broken_guard_golem.tscn")
const PLAYER := preload("res://src/gameplay/player/player.tscn")

var _failures := PackedStringArray()
var _warnings := 0
var _losses := 0


func _ready() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	var legacy := GOLEM.instantiate() as BrokenGuardGolem
	_expect(not legacy.use_sight_occlusion, "Historical scene detection changed.")
	legacy.free()
	await _check_wall_and_movement()
	await _check_door_and_discharge()
	await _check_removed_target()
	await _check_hearing()
	await _check_lifecycle()
	get_tree().paused = false
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"golem_sight_passed")
	get_tree().quit(0 if _failures.is_empty() else 1)


func _new_world(start := true) -> PrototypeExploration:
	var world: PrototypeExploration = WORLD.instantiate()
	add_child(world)
	var golem: BrokenGuardGolem = world.get_node("%BrokenGuardGolem")
	golem.patrol_speed = 0.0
	golem.suspicious_speed = 0.0
	golem.chase_speed = 0.0
	golem.search_speed = 0.0
	golem.suspicion_duration = 0.5
	golem.search_duration = 1.0
	golem.discharge_duration = 0.2
	golem.warning_started.connect(func(_position: Vector2): _warnings += 1)
	golem.sight_lost.connect(func(_position: Vector2): _losses += 1)
	_warnings = 0
	_losses = 0
	await _frames(3)
	if start:
		_start(world)
		await _frames(3)
	return world


func _start(world: PrototypeExploration) -> void:
	var loadout := ExpeditionLoadout.new()
	loadout.slot_capacity = 3
	loadout.burden_weight = 2.5
	loadout.overload_weight = 4.0
	loadout.charge_capacity = 3
	loadout.starting_charge = 3
	_expect(world.prepare_departure(loadout) and world.start_exploration(), "Departure failed.")
	# Isolate sight during visual checks. Hearing is separately tested below.
	world.get_node("%GolemHearing").set_active(false)


func _check_wall_and_movement() -> void:
	var world := await _new_world()
	var golem: BrokenGuardGolem = world.get_node("%BrokenGuardGolem")
	var player: PlayerController = world.get_node("Player")
	golem.position = Vector2(450, 60)
	player.position = Vector2(450, -60)
	await _frames(5)
	_expect(golem.get_node("DetectionArea").overlaps_body(player), "Wall check was outside the detection range.")
	_expect(golem.use_sight_occlusion and not golem.has_visual_contact() and _warnings == 0, "Central wall failed to block initial sight.")
	_expect(golem.get_basic_analysis().contains("닫힌 문") and golem.get_basic_analysis().contains("발소리"), "Basic analysis omitted cover/hearing guidance.")
	await _capture("sight-hidden.png")
	await _walk(InputActions.MOVE_RIGHT, 27)
	_expect(golem.has_visual_contact() and golem.get_state() == BrokenGuardGolem.State.SUSPICIOUS, "Walking beyond wall failed to start warning.")
	_expect(_warnings == 1, "Continuous visibility restarted the warning.")
	await _capture("sight-warning.png")
	await _frames(34)
	_expect(golem.get_state() == BrokenGuardGolem.State.CHASE and _warnings == 1, "Visible warning never escalated or restarted.")
	await _walk(InputActions.MOVE_LEFT, 27)
	_expect(not golem.has_visual_contact() and golem.get_state() == BrokenGuardGolem.State.SEARCH, "Hiding within range failed to break chase.")
	var last_seen := golem.get_last_known_position()
	_expect(last_seen.x > player.position.x + 20.0 and _losses == 1, "Hidden movement leaked into last visible position.")
	_expect(world.get_node("%ChoiceStatus").text.contains("시야를 벗어났습니다"), "Sight loss feedback missing.")
	await _capture("sight-search.png")
	for key in [KEY_TAB, KEY_M]:
		_tap(key)
		await _frames(3)
		var remaining: float = golem.get_node("SearchTimer").time_left
		await _frames(75)
		_expect(get_tree().paused and is_equal_approx(golem.get_node("SearchTimer").time_left, remaining), "Menu did not pause sight search.")
		_expect(golem.get_last_known_position() == last_seen and _losses == 1, "Paused search changed evidence.")
		_tap(key)
		await _frames(3)
	await _frames(65)
	_expect(golem.get_state() == BrokenGuardGolem.State.PATROL and not golem.has_visual_contact(), "Hidden player prevented return to patrol.")
	await _walk(InputActions.MOVE_RIGHT, 27)
	_expect(golem.get_state() == BrokenGuardGolem.State.SUSPICIOUS and _warnings == 2, "Reappearance skipped new warning.")
	var before_exit := golem.get_last_known_position()
	# Move away beyond the radius and continue moving after losing contact.
	await _walk(InputActions.MOVE_RIGHT, 26)
	_expect(not golem.has_visual_contact() and _losses == 2, "Range exit failed to lose sight once.")
	var exit_seen := golem.get_last_known_position()
	_expect(exit_seen.x >= before_exit.x and exit_seen.x < player.position.x - 20.0, "Range exit tracked hidden position.")
	await _frames(4)
	_expect(golem.get_last_known_position() == exit_seen, "Hidden position kept updating.")
	world.queue_free()
	await _frames(3)


func _check_door_and_discharge() -> void:
	var world := await _new_world()
	var golem: BrokenGuardGolem = world.get_node("%BrokenGuardGolem")
	var player: PlayerController = world.get_node("Player")
	golem.position = Vector2(60, -200)
	player.position = Vector2(-60, -200)
	var door := DOOR.instantiate() as DoorInteractable
	door.position = Vector2(0, -200)
	world.add_child(door)
	await _frames(5)
	_expect(door.is_blocking() and not golem.has_visual_contact(), "Closed door did not block sight.")
	_tap(KEY_E)
	await _frames(5)
	_expect(door.is_open and golem.has_visual_contact() and _warnings == 1, "Opening door inside range did not reacquire.")
	await _frames(8)
	_tap(KEY_E)
	await _frames(5)
	var remembered := golem.get_last_known_position()
	_expect(not door.is_open and golem.get_state() == BrokenGuardGolem.State.SEARCH and _losses == 1, "Closing door failed to cancel warning.")
	await _frames(35)
	_expect(golem.get_state() != BrokenGuardGolem.State.CHASE and golem.get_last_known_position() == remembered, "Cancelled warning chased through door.")
	_tap(KEY_E)
	await _frames(5)
	_expect(golem.has_visual_contact() and _warnings == 2, "Reopening door did not restart warning.")
	await _frames(32)
	_expect(golem.get_state() == BrokenGuardGolem.State.CHASE, "Reopened door failed to escalate after warning.")
	_expect(golem.emergency_discharge(), "Discharge failed.")
	_tap(KEY_E)
	await _frames(20)
	_expect(golem.get_state() == BrokenGuardGolem.State.SEARCH and not golem.has_visual_contact() and _warnings == 2, "Discharge recovery saw through closed door.")
	_tap(KEY_E)
	await _frames(4)
	_expect(golem.has_visual_contact() and _warnings == 3, "Post-discharge reappearance not detected.")
	_expect(golem.emergency_discharge(), "Second discharge failed.")
	await _frames(18)
	_expect(golem.has_visual_contact() and golem.get_state() == BrokenGuardGolem.State.SUSPICIOUS and _warnings == 4, "Visible recovery skipped fresh warning.")
	world.queue_free()
	await _frames(3)


func _check_removed_target() -> void:
	# Isolate target lifetime from the application's always-present player contract.
	var golem: BrokenGuardGolem = GOLEM.instantiate()
	golem.use_sight_occlusion = true
	golem.patrol_speed = 0.0
	add_child(golem)
	var player: PlayerController = PLAYER.instantiate()
	player.position = Vector2(100, 0)
	player.get_node("Camera2D").enabled = false
	add_child(player)
	await _frames(5)
	_expect(golem.has_visual_contact(), "Removal check never acquired target.")
	player.queue_free()
	await _frames(5)
	_expect(not golem.has_visual_contact() and golem.get_state() == BrokenGuardGolem.State.SEARCH, "Removed visual target remained tracked.")
	golem.queue_free()
	await _frames(3)


func _check_hearing() -> void:
	var world := await _new_world()
	var golem: BrokenGuardGolem = world.get_node("%BrokenGuardGolem")
	var player: PlayerController = world.get_node("Player")
	var hearing: GolemHearing = world.get_node("%GolemHearing")
	var emitter: MovementNoiseEmitter = world.get_node("%MovementNoiseEmitter")
	golem.position = Vector2(450, 60)
	player.position = Vector2(450, -60)
	hearing.set_active(true)
	await _frames(5)
	var heard := player.position
	_expect(hearing.hear_lure(heard, 320.0) and not golem.has_visual_contact(), "Wall incorrectly blocked sound or granted sight.")
	player.position.x -= 25.0
	await _frames(5)
	_expect(golem.get_last_known_position() == heard, "Hearing began tracking hidden player.")
	await _frames(32)
	_expect(golem.get_state() == BrokenGuardGolem.State.SEARCH, "Single hidden lure escalated to chase.")
	for index in range(3):
		emitter.noise_emitted.emit(heard, 260.0, true)
	_expect(not hearing.hear_lure(Vector2(520, 60), 320.0), "Lure erased pending noise alarm.")
	await _frames(34)
	_expect(golem.get_state() == BrokenGuardGolem.State.CHASE and not golem.has_visual_contact(), "No sight incorrectly cancelled sound alarm.")
	_expect(hearing.hear_lure(Vector2(520, 60), 320.0), "Sound-only chase could not be lured.")
	player.position = Vector2(540, 60)
	await _frames(5)
	_expect(golem.has_visual_contact() and not hearing.hear_lure(heard, 320.0), "Lure overwrote direct visual contact.")
	var visible := golem.get_last_known_position()
	_expect(not golem.investigate_noise(heard) and golem.raise_alarm(heard) and golem.get_last_known_position() == visible, "External sound overwrote visual evidence.")
	var harness: HarnessController = world.get_node("Player/HarnessController")
	_expect(harness.analyze_current_target(), "Could not inspect visible golem.")
	await _frames(3)
	var harness_panel: HarnessStatus = world.get_node("%HarnessStatus")
	var tool_panel: Label = world.get_node("%ToolStatus")
	_expect(harness_panel.get_analysis_text().contains("닫힌 문"), "Cover guidance missing from analysis panel.")
	_expect(not harness_panel.get_global_rect().intersects(tool_panel.get_global_rect()), "Analysis and tool guidance overlap.")
	await _capture("sight-analysis.png")
	_expect(golem.emergency_discharge() and not hearing.hear_lure(heard, 320.0), "Disabled golem responded to lure.")
	world.queue_free()
	await _frames(3)


func _check_lifecycle() -> void:
	for safe in [true, false]:
		var world := await _new_world(false)
		var golem: BrokenGuardGolem = world.get_node("%BrokenGuardGolem")
		var player: PlayerController = world.get_node("Player")
		golem.position = Vector2(50, -200)
		player.position = Vector2(100, -200)
		await _frames(40)
		_expect(not golem.has_visual_contact() and _warnings == 0, "Visual detection active before departure.")
		_start(world)
		await _frames(5)
		_expect(golem.has_visual_contact() and _warnings == 1, "Starting inside range failed to detect.")
		var run: ExplorationRun = world.get_node("%ExplorationRun")
		if safe:
			run.complete_safe_return()
		else:
			run.complete_failure()
		var last_seen := golem.get_last_known_position()
		var state := golem.get_state()
		player.position = Vector2(450, -60)
		await _frames(70)
		_expect(golem.get_state() == state and golem.get_last_known_position() == last_seen and _warnings == 1, "Finished expedition kept updating sight.")
		world.queue_free()
		await _frames(3)
	var fresh := await _new_world()
	_expect(not fresh.get_node("%BrokenGuardGolem").has_visual_contact() and _warnings == 0, "New departure retained visual target.")
	fresh.queue_free()
	await _frames(3)


func _walk(action: StringName, frames: int) -> void:
	Input.action_press(action)
	await _frames(frames)
	Input.action_release(action)
	await _frames(2)


func _tap(key: Key) -> void:
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.keycode = key
		event.physical_keycode = key
		event.pressed = pressed
		Input.parse_input_event(event)
		Input.flush_buffered_events()


func _capture(filename: String) -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--sight-render-directory="):
			var directory := argument.trim_prefix("--sight-render-directory=")
			DirAccess.make_dir_recursive_absolute(directory)
			await RenderingServer.frame_post_draw
			_expect(get_viewport().get_texture().get_image().save_png(directory.path_join(filename)) == OK, "Sight screenshot failed.")


func _frames(count: int) -> void:
	for index in range(count):
		await get_tree().physics_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		GameLog.error(&"SmokeTest", &"golem_sight_failed", message)
