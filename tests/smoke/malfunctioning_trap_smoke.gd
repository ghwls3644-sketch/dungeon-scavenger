extends Node

const WORLD := preload("res://src/app/prototype_exploration.tscn")
const TRAP := preload("res://src/gameplay/hazards/malfunctioning_trap.tscn")
const RULE := preload("res://src/data/prototype_trap_cycle.tres")
const LIGHT := preload("res://src/data/prototype_light.tres")
const MOVE_ACTIONS := [InputActions.MOVE_LEFT, InputActions.MOVE_RIGHT, InputActions.MOVE_UP, InputActions.MOVE_DOWN]

var _failures := PackedStringArray()
var _catches := 0


func _ready() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	_check_rule()
	await _check_cycle()
	await _check_passage_and_stabilization()
	await _check_failure(false)
	await _check_failure(true)
	_release_movement()
	get_tree().paused = false
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"malfunctioning_trap_passed")
	get_tree().quit(0 if _failures.is_empty() else 1)


func _check_rule() -> void:
	_expect(RULE.is_valid(), "Prototype rule invalid.")
	for row in [["quiet_durations", PackedFloat32Array()], ["quiet_durations", PackedFloat32Array([0.0])], ["quiet_durations", PackedFloat32Array([INF])], ["warning_duration", 0.0], ["warning_duration", NAN], ["active_duration", -1.0], ["stabilization_duration", INF], ["stabilization_cost", 0]]:
		var invalid := RULE.duplicate(true) as TrapCycleRule
		invalid.set(row[0], row[1])
		_expect(not invalid.is_valid(), "Invalid trap rule accepted: %s." % row[0])


func _check_cycle() -> void:
	var trap: MalfunctioningTrap = TRAP.instantiate()
	trap.cycle_rule = RULE.duplicate(true)
	add_child(trap)
	trap.cycle_rule.warning_duration = 0.01
	_expect(not trap.visible and not trap.can_stabilize() and trap.get_basic_analysis().is_empty(), "Dormant trap disclosed information or acted.")
	trap.set_exploration_active(true)
	_expect(trap.get_phase() == MalfunctioningTrap.Phase.QUIET and trap.get_remaining_time() > 1.7, "Trap did not start in quiet phase.")
	await _wait_phase(trap, MalfunctioningTrap.Phase.WARNING)
	_expect(trap.get_remaining_time() > 1.1, "Rule snapshot mutated or warning skipped.")
	var remaining := trap.get_remaining_time()
	await _frames(30)
	_expect(trap.get_phase() == MalfunctioningTrap.Phase.WARNING and trap.get_remaining_time() < remaining, "Warning duration not preserved.")
	await _wait_phase(trap, MalfunctioningTrap.Phase.ACTIVE)
	await _wait_phase(trap, MalfunctioningTrap.Phase.QUIET)
	_expect(trap.get_remaining_time() > 2.5, "Second quiet interval did not differ from the first.")
	await _wait_phase(trap, MalfunctioningTrap.Phase.ACTIVE)
	await _wait_phase(trap, MalfunctioningTrap.Phase.QUIET)
	_expect(trap.get_remaining_time() > 1.7 and trap.get_remaining_time() < 1.9, "Quiet interval sequence did not repeat.")
	# A long tick cannot skip directly through the warning into damage.
	trap._physics_process(30.0)
	_expect(trap.get_phase() == MalfunctioningTrap.Phase.WARNING and trap.get_remaining_time() > 1.1, "Long frame skipped advance warning.")
	trap.set_exploration_active(false)
	remaining = trap.get_remaining_time()
	await _frames(90)
	_expect(trap.get_remaining_time() == remaining and not trap.stabilize(), "Stopped trap advanced or stabilized.")
	trap.queue_free()
	await _frames(3)
	var invalid_trap: MalfunctioningTrap = TRAP.instantiate()
	invalid_trap.cycle_rule = TrapCycleRule.new()
	add_child(invalid_trap)
	invalid_trap.set_exploration_active(true)
	await _frames(3)
	_expect(not invalid_trap.visible and not invalid_trap.stabilize(), "Invalid configuration activated trap.")
	invalid_trap.queue_free()
	await _frames(3)


func _new_world() -> PrototypeExploration:
	var world: PrototypeExploration = WORLD.instantiate()
	add_child(world)
	await _frames(4)
	var trap: MalfunctioningTrap = world.get_node("%MalfunctioningTrap")
	trap.body_caught.connect(func(_body: Node2D): _catches += 1)
	_catches = 0
	await _frames(15)
	_expect(trap.get_phase() == MalfunctioningTrap.Phase.DORMANT and not trap.stabilize(), "Trap advanced before departure.")
	var loadout := ExpeditionLoadout.new()
	loadout.slot_capacity = 3
	loadout.burden_weight = 2.5
	loadout.overload_weight = 4.0
	loadout.charge_capacity = 3
	loadout.starting_charge = 3
	_expect(world.prepare_departure(loadout) and world.start_exploration(), "Departure failed.")
	await _frames(4)
	_expect(not trap.visible and trap.collision_layer == 0 and trap.get_basic_analysis().is_empty(), "Undiscovered trap disclosed information.")
	return world


func _enter_room(world: PrototypeExploration) -> void:
	var player: PlayerController = world.get_node("Player")
	var trap: MalfunctioningTrap = world.get_node("%MalfunctioningTrap")
	await _walk(player, Vector2(-650, -200))
	await _walk(player, Vector2(100, -200))
	await _walk(player, Vector2(100, -325))
	_tap(KEY_Q)
	await _frames(4)
	_expect(world.get_node("%RemainingZoneEntrance").is_open() and not trap.visible, "Gate opening itself disclosed trap.")
	await _walk(player, Vector2(100, -440))
	_expect(world.get_map_state().get_discovered_region_count() == 1 and trap.visible, "Room entry did not activate visible trap.")
	await _walk(player, Vector2(110, -520))
	_expect(_catches == 0 and world.get_node("%ExplorationRun").is_active(), "Safe route into room crossed trap.")


func _check_passage_and_stabilization() -> void:
	var world := await _new_world()
	await _enter_room(world)
	var trap: MalfunctioningTrap = world.get_node("%MalfunctioningTrap")
	var player: PlayerController = world.get_node("Player")
	var harness: HarnessController = world.get_node("Player/HarnessController")
	_expect(harness.get_basic_analysis().contains("작동 범위") and harness.get_analysis_charge_cost() == 0, "Free trap analysis missing.")
	await _wait_phase(trap, MalfunctioningTrap.Phase.ACTIVE)
	await _wait_phase(trap, MalfunctioningTrap.Phase.QUIET)
	_expect(world.get_node("%HarnessStatus").get_analysis_text().contains(trap.get_status_text()), "Free quiet reading did not refresh.")
	await _capture("trap-quiet.png")
	# Cross and return using actual movement, without spending charge on the trap.
	await _walk(player, Vector2(260, -520))
	await _walk(player, Vector2(110, -520))
	_expect(_catches == 0 and harness.get_current_charge() == 2, "Quiet passage failed or consumed charge.")
	await _wait_phase(trap, MalfunctioningTrap.Phase.WARNING)
	_expect(world.get_node("%HarnessStatus").get_analysis_text().contains(trap.get_status_text()), "Free warning reading did not refresh.")
	await _capture("trap-warning.png")
	_tap(KEY_Q)
	await _frames(4)
	_expect(trap.get_phase() == MalfunctioningTrap.Phase.STABILIZED and harness.get_current_charge() == 1, "Q failed to stop trap with one shared charge.")
	_expect(world.get_node("%ChoiceStatus").text.contains("잠시 멈췄습니다"), "Stabilization feedback missing.")
	_tap(KEY_Q)
	await _frames(3)
	_expect(harness.get_current_charge() == 1 and not trap.stabilize(), "Repeated stabilization consumed charge or extended stop.")
	await _capture("trap-stabilized.png")
	for key in [KEY_TAB, KEY_M]:
		_tap(key)
		await _frames(3)
		var remaining := trap.get_remaining_time()
		_tap(KEY_Q)
		await _frames(90)
		_expect(get_tree().paused and trap.get_remaining_time() == remaining and not trap.stabilize() and harness.get_current_charge() == 1, "Menu allowed trap time/action.")
		_tap(key)
		await _frames(3)
	await _wait_phase(trap, MalfunctioningTrap.Phase.WARNING)
	_expect(trap.get_remaining_time() > 1.1, "Stabilization expiry skipped full warning.")
	harness.configure_charge(3, 0)
	_tap(KEY_Q)
	await _frames(3)
	_expect(trap.get_phase() == MalfunctioningTrap.Phase.WARNING and harness.get_current_charge() == 0, "Empty harness stopped trap.")
	await _wait_phase(trap, MalfunctioningTrap.Phase.ACTIVE)
	_expect(world.get_node("%HarnessStatus").get_analysis_text().contains(trap.get_status_text()), "Free active reading did not refresh.")
	await _capture("trap-active.png")
	# Left-hand path remains free even while the trap is firing.
	await _walk(player, Vector2(100, -440))
	await _walk(player, Vector2(100, -300))
	await _walk(player, Vector2(-650, -200))
	await _walk(player, Vector2(-680, 0))
	_tap(KEY_E)
	await _frames(4)
	_expect(world.get_node("%ExplorationRun").get_state() == ExplorationRun.State.SAFE_RETURN, "Trap route did not return via original entrance.")
	var remaining := trap.get_remaining_time()
	await _frames(90)
	_expect(trap.get_remaining_time() == remaining and not trap.stabilize() and _catches == 0, "Returned expedition left trap running.")
	world.queue_free()
	await _frames(3)


func _check_failure(enter_while_active: bool) -> void:
	var world := await _new_world()
	await _enter_room(world)
	var trap: MalfunctioningTrap = world.get_node("%MalfunctioningTrap")
	var player: PlayerController = world.get_node("Player")
	var run: ExplorationRun = world.get_node("%ExplorationRun")
	var inventory: PlayerInventory = world.get_node("Player/Inventory")
	inventory.try_add_item(LIGHT)
	await _wait_phase(trap, MalfunctioningTrap.Phase.ACTIVE)
	await _wait_phase(trap, MalfunctioningTrap.Phase.QUIET)
	if enter_while_active:
		# Wait just outside the danger square, then enter during its active pulse.
		await _walk(player, Vector2(155, -520))
		await _wait_phase(trap, MalfunctioningTrap.Phase.ACTIVE)
		Input.action_press(InputActions.MOVE_RIGHT)
		await _frames(12)
		_release_movement()
	else:
		await _walk(player, Vector2(210, -520))
		await _wait_phase(trap, MalfunctioningTrap.Phase.ACTIVE)
	await _frames(4)
	var survival: PlayerSurvival = world.get_node("%PlayerSurvival")
	_expect(run.is_active() and _catches == 1 and survival.get_health() == 1 and survival.get_injury_remaining() > 0.0, "First trap hit did not leave an injured survivor: entering=%s." % enter_while_active)
	await _wait_phase(trap, MalfunctioningTrap.Phase.QUIET)
	await _wait_phase(trap, MalfunctioningTrap.Phase.ACTIVE)
	await _frames(4)
	_expect(run.get_state() == ExplorationRun.State.FAILURE and _catches == 2 and survival.get_health() == 0, "Next trap cycle did not deplete health: entering=%s." % enter_while_active)
	if run.get_outcome() != null:
		_expect(run.get_outcome().get_lost_item_count() == 1 and inventory.get_used_slots() == 0, "Trap failure did not use existing recovery loss.")
	var remaining := trap.get_remaining_time()
	await _frames(120)
	_tap(KEY_Q)
	_expect(_catches == 2 and trap.get_remaining_time() == remaining and not trap.stabilize(), "Failed expedition repeated trap hit/action.")
	world.queue_free()
	await _frames(3)


func _wait_phase(trap: MalfunctioningTrap, phase: MalfunctioningTrap.Phase) -> void:
	for index in range(600):
		if trap.get_phase() == phase:
			return
		await _frames(1)
	_expect(false, "Trap never reached phase %d (at %d)." % [phase, trap.get_phase()])


func _walk(player: PlayerController, destination: Vector2) -> void:
	for frame in range(720):
		var offset := destination - player.global_position
		_release_movement()
		if offset.length() < 6.0:
			await _frames(3)
			return
		if absf(offset.x) > 3.0:
			Input.action_press(InputActions.MOVE_RIGHT if offset.x > 0.0 else InputActions.MOVE_LEFT)
		if absf(offset.y) > 3.0:
			Input.action_press(InputActions.MOVE_DOWN if offset.y > 0.0 else InputActions.MOVE_UP)
		await _frames(1)
	_release_movement()
	_expect(false, "Route blocked before %s, at %s." % [destination, player.position])


func _release_movement() -> void:
	for action in MOVE_ACTIONS:
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
		if argument.begins_with("--trap-render-directory="):
			var directory := argument.trim_prefix("--trap-render-directory=")
			DirAccess.make_dir_recursive_absolute(directory)
			await RenderingServer.frame_post_draw
			_expect(get_viewport().get_texture().get_image().save_png(directory.path_join(filename)) == OK, "Trap screenshot failed.")


func _frames(count: int) -> void:
	for index in range(count):
		await get_tree().physics_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		GameLog.error(&"SmokeTest", &"malfunctioning_trap_failed", message)
