extends Node

const WORLD := preload("res://src/app/prototype_exploration.tscn")
const RULE := preload("res://src/data/prototype_door_hold.tres")
const DOOR := preload("res://src/gameplay/interaction/temporary_door.tscn")
const LEGACY_DOOR := preload("res://src/gameplay/interaction/door_interactable.tscn")
const MOVES := [InputActions.MOVE_LEFT, InputActions.MOVE_RIGHT, InputActions.MOVE_UP, InputActions.MOVE_DOWN]

var _failures := PackedStringArray()


func _ready() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	await _check_rule_and_legacy()
	await _check_manual_and_hold()
	await _check_golem(false)
	await _check_golem(true)
	await _check_lifecycle()
	_release()
	get_tree().paused = false
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"door_hold_passed")
	get_tree().quit(0 if _failures.is_empty() else 1)


func _check_rule_and_legacy() -> void:
	_expect(RULE.is_valid(), "Prototype rule invalid.")
	for entry in [["hold_duration", NAN], ["hold_duration", 0.0], ["release_warning_duration", 6.0], ["release_warning_duration", -1.0], ["push_open_duration", INF], ["push_open_duration", 0.0], ["charge_cost", 0]]:
		var rule := RULE.duplicate(true) as DoorHoldRule
		rule.set(entry[0], entry[1])
		_expect(not rule.is_valid(), "Invalid door rule accepted.")
	var legacy := LEGACY_DOOR.instantiate() as DoorInteractable
	add_child(legacy)
	await _frames(3)
	_expect(not legacy.is_open and legacy.interact(self), "Historical door behavior changed.")
	legacy.queue_free()
	var invalid := DOOR.instantiate() as TemporaryDoor
	invalid.hold_rule = DoorHoldRule.new()
	add_child(invalid)
	invalid.set_exploration_active(true)
	_expect(not invalid.can_hold() and not invalid.interact(self), "Invalid data activated door.")
	invalid.queue_free()
	await _frames(3)


func _new_world() -> PrototypeExploration:
	var world := WORLD.instantiate() as PrototypeExploration
	# Mutating the exported rule after ready must not change the live snapshot.
	world.get_node("%RetreatDoor").hold_rule = RULE.duplicate(true)
	add_child(world)
	var door: TemporaryDoor = world.get_node("%RetreatDoor")
	door.hold_rule.hold_duration = 0.01
	var golem: BrokenGuardGolem = world.get_node("%BrokenGuardGolem")
	for property in ["patrol_speed", "suspicious_speed", "chase_speed", "search_speed"]:
		golem.set(property, 0.0)
	await _frames(3)
	_expect(door.is_open and not door.is_blocking() and not door.hold_closed() and not door.interact(self), "Door acted before departure.")
	var loadout := ExpeditionLoadout.new()
	loadout.slot_capacity = 3
	loadout.burden_weight = 2.5
	loadout.overload_weight = 4.0
	loadout.charge_capacity = 3
	loadout.starting_charge = 3
	_expect(world.prepare_departure(loadout) and world.start_exploration(), "Departure failed.")
	# Test door contact independently of movement noise; hearing has its own suite.
	world.get_node("%GolemHearing").set_active(false)
	await _frames(3)
	_expect(door.is_open and not door.is_held() and door.get_push_elapsed() == 0.0, "New expedition kept old door state.")
	return world


func _approach(world: PrototypeExploration) -> void:
	var player: PlayerController = world.get_node("Player")
	await _walk(player, Vector2(-650, -200))
	await _walk(player, Vector2(628, -200))
	await _walk(player, Vector2(628, -70))


func _check_manual_and_hold() -> void:
	var world := await _new_world()
	await _approach(world)
	var door: TemporaryDoor = world.get_node("%RetreatDoor")
	var player: PlayerController = world.get_node("Player")
	var harness: HarnessController = player.get_node("HarnessController")
	var map := world.get_map_state()
	_expect(map.get_passage_status(&"prototype_bypass_link") == ExplorationMapState.PassageStatus.OPEN, "Open door blocked map.")
	_tap(KEY_Q)
	await _frames(3)
	_expect(harness.get_current_charge() == 3 and not door.is_held(), "Open door consumed hold charge.")
	_expect(world.get_node("%HarnessStatus").get_node("%Feedback").visible, "Rejected action lost feedback in unchanged state.")
	await _walk(player, Vector2(628, 0))
	_tap(KEY_E)
	await _frames(3)
	_expect(door.is_open and door.get_status_text().contains("닫을 수 없습니다"), "Door closed on player.")
	await _walk(player, Vector2(628, -70))
	_tap(KEY_E)
	await _frames(5)
	_expect(not door.is_open and door.is_blocking(), "E did not close door.")
	_expect(not world.get_node("%HarnessStatus").get_node("%Feedback").visible, "Old rejection survived changed action context.")
	_expect(map.get_passage_status(&"prototype_bypass_link") == ExplorationMapState.PassageStatus.BLOCKED, "Closed door missing from map observation.")
	_expect(harness.get_analysis_charge_cost() == 0 and harness.get_basic_analysis().contains("문 닫힘"), "Free closed-door analysis missing.")
	await _capture("door-closed.png")
	var mouse := InputEventMouseMotion.new()
	mouse.position = world.get_canvas_transform() * Vector2(628, 160)
	Input.parse_input_event(mouse)
	Input.flush_buffered_events()
	_tap(KEY_F)
	await _frames(4)
	_expect(world.get_node("%NoiseLureController").get_landing_position().y < -12.0, "Lure crossed closed door.")
	Input.action_press(InputActions.MOVE_DOWN)
	await _frames(30)
	_release()
	_expect(player.position.y < -25.0, "Player crossed closed door.")
	_tap(KEY_Q)
	await _frames(4)
	_expect(door.is_held() and door.get_hold_remaining() > 5.8 and harness.get_current_charge() == 2, "Shared charge or rule snapshot wrong.")
	_tap(KEY_Q)
	_tap(KEY_E)
	await _frames(3)
	_expect(not door.is_open and harness.get_current_charge() == 2, "Duplicate Q/E defeated hold.")
	await _capture("door-held.png")
	for key in [KEY_TAB, KEY_M]:
		_tap(key)
		await _frames(3)
		var remaining := door.get_hold_remaining()
		_tap(KEY_E)
		_tap(KEY_Q)
		await _frames(90)
		_expect(get_tree().paused and door.get_hold_remaining() == remaining and not door.interact(player) and not door.hold_closed(), "Menu allowed door time/action.")
		_tap(key)
		await _frames(3)
	await _wait_until(func(): return door.get_hold_remaining() <= 0.9, "Release warning never arrived.")
	_expect(door.get_status_text().contains("해제 임박"), "Release warning absent.")
	await _capture("door-release-warning.png")
	await _wait_until(func(): return not door.is_held(), "Hold never expired.")
	_expect(not door.is_open, "Expiry opened door without pressure.")
	harness.configure_charge(3, 0)
	_tap(KEY_Q)
	await _frames(3)
	_expect(not door.is_held() and harness.get_current_charge() == 0, "Empty charge held door.")
	_tap(KEY_E)
	await _frames(4)
	_expect(door.is_open and player.get_node("InteractionController").get_current_prompt() == "문 닫기", "Free reopening/prompt failed.")
	await _walk(player, Vector2(628, 100))
	await _walk(player, Vector2(628, -70))
	_expect(map.get_passage_status(&"prototype_bypass_link") == ExplorationMapState.PassageStatus.OPEN, "Reopened map stayed blocked.")
	await _walk(player, Vector2(628, -200))
	await _walk(player, Vector2(-650, -200))
	await _walk(player, Vector2(-680, 0))
	_tap(KEY_E)
	await _frames(4)
	_expect(world.get_node("%ExplorationRun").get_state() == ExplorationRun.State.SAFE_RETURN, "Door route failed to return.")
	world.queue_free()
	await _frames(3)


func _check_golem(with_hold: bool) -> void:
	var world := await _new_world()
	var player: PlayerController = world.get_node("Player")
	var golem: BrokenGuardGolem = world.get_node("%BrokenGuardGolem")
	var door: TemporaryDoor = world.get_node("%RetreatDoor")
	player.position = Vector2(628, -70)
	await _frames(4)
	_tap(KEY_E)
	await _frames(4)
	if with_hold:
		_tap(KEY_Q)
		await _frames(4)
		_expect(door.is_held(), "Encounter hold failed.")
	golem.position = Vector2(628, 90)
	golem.suspicious_speed = 90.0
	golem.chase_speed = 90.0
	golem.search_speed = 90.0
	golem.raise_alarm(Vector2(628, -140))
	await _frames(55)
	_expect(not door.is_open and golem.position.y > 31.0 and not golem.has_visual_contact(), "Door failed physical/sight block.")
	if with_hold:
		await _frames(100)
		_expect(door.is_held() and not door.is_open and golem.position.y > 31.0 and door.get_push_elapsed() == 0.0, "Golem forced held door open.")
		await _capture("door-golem-held.png")
		await _wait_until(func(): return not door.is_held(), "Encounter hold never expired.")
		await _frames(3)
		_expect(not door.is_open and door.get_push_elapsed() < 0.1, "Expiry skipped opening warning.")
	else:
		_expect(door.get_push_elapsed() > 0.0, "Golem contact did not warn.")
		golem.raise_alarm(Vector2(628, 160))
		await _frames(20)
		_expect(door.get_push_elapsed() == 0.0 and not door.is_open, "Leaving contact kept opening progress.")
		golem.raise_alarm(Vector2(628, -140))
		await _wait_until(func(): return door.get_push_elapsed() > 0.0, "Returning golem failed to restart warning.")
		golem.discharge_duration = 0.6
		golem.emergency_discharge()
		await _frames(5)
		_expect(door.get_push_elapsed() == 0.0 and not door.is_open, "Discharged golem kept pushing.")
		await _frames(40)
		golem.raise_alarm(Vector2(628, -140))
	await _wait_until(func(): return door.get_push_elapsed() > 0.0, "Opening warning missing.")
	await _capture("door-golem-warning.png")
	_tap(KEY_M)
	await _frames(3)
	var elapsed := door.get_push_elapsed()
	await _frames(100)
	_expect(get_tree().paused and door.get_push_elapsed() == elapsed and not door.is_open, "Paused pressure opened door.")
	_tap(KEY_M)
	await _frames(3)
	await _wait_until(func(): return door.is_open, "Unheld door never opened under pressure.")
	await _frames(45)
	_expect(golem.position.y < -12.0 and golem.has_visual_contact() and not golem.can_be_permanently_defeated(), "Golem failed to pass/reacquire after opening.")
	world.queue_free()
	await _frames(3)


func _check_lifecycle() -> void:
	for safe in [true, false]:
		var world := await _new_world()
		var player: PlayerController = world.get_node("Player")
		var golem: BrokenGuardGolem = world.get_node("%BrokenGuardGolem")
		var door: TemporaryDoor = world.get_node("%RetreatDoor")
		player.position = Vector2(628, -70)
		golem.position = Vector2(628, 0)
		await _frames(4)
		_tap(KEY_E)
		await _frames(3)
		_expect(door.is_open, "Door closed through golem.")
		golem.position = Vector2(460, 170)
		await _frames(4)
		_tap(KEY_E)
		await _frames(3)
		_tap(KEY_Q)
		await _frames(3)
		_expect(door.is_held(), "Lifecycle hold setup failed.")
		var run: ExplorationRun = world.get_node("%ExplorationRun")
		if safe:
			run.complete_safe_return()
		else:
			run.complete_failure()
		var remaining := door.get_hold_remaining()
		await _frames(100)
		_tap(KEY_E)
		_tap(KEY_Q)
		_expect(door.get_hold_remaining() == remaining and not door.interact(player) and not door.hold_closed() and door.get_basic_analysis().is_empty(), "Ended expedition left active door.")
		world.queue_free()
		await _frames(3)


func _wait_until(predicate: Callable, message: String) -> void:
	for index in range(600):
		if predicate.call():
			return
		await _frames(1)
	_expect(false, message)


func _walk(player: PlayerController, target: Vector2) -> void:
	for index in range(720):
		var offset := target - player.position
		_release()
		if offset.length() < 6.0:
			await _frames(3)
			return
		if absf(offset.x) > 3.0:
			Input.action_press(InputActions.MOVE_RIGHT if offset.x > 0.0 else InputActions.MOVE_LEFT)
		if absf(offset.y) > 3.0:
			Input.action_press(InputActions.MOVE_DOWN if offset.y > 0.0 else InputActions.MOVE_UP)
		await _frames(1)
	_release()
	_expect(false, "Route blocked at %s before %s." % [player.position, target])


func _release() -> void:
	for action in MOVES:
		Input.action_release(action)


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
		if argument.begins_with("--door-render-directory="):
			var directory := argument.trim_prefix("--door-render-directory=")
			DirAccess.make_dir_recursive_absolute(directory)
			await RenderingServer.frame_post_draw
			_expect(get_viewport().get_texture().get_image().save_png(directory.path_join(filename)) == OK, "Screenshot failed.")


func _frames(count: int) -> void:
	for index in range(count):
		await get_tree().physics_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		GameLog.error(&"SmokeTest", &"door_hold_failed", message)
