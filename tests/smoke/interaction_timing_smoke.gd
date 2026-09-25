extends "res://tests/smoke/value_comparison_smoke.gd"

const TIMING := preload("res://src/data/prototype_interaction_timing.tres")
const SURVIVAL := preload("res://src/data/prototype_survival.tres")
const PLAYER := preload("res://src/gameplay/player/player.tscn")
const PICKUP := preload("res://src/gameplay/interaction/pickup_interactable.tscn")

var _completed := 0
var _reentrant_accepted := false
var _measurements: Array[Dictionary] = []


func _ready() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	await _check_data()
	await _check_durations(false)
	await _check_durations(true)
	await _check_dynamic_efficiency()
	await _check_cancel_boundaries()
	await _check_capacity_and_reentry()
	await _check_immediate_and_end()
	_release()
	get_tree().paused = false
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--timing-report-path="):
			var file := FileAccess.open(argument.trim_prefix("--timing-report-path="), FileAccess.WRITE)
			file.store_string(JSON.stringify({"passed": _failures.is_empty(), "measurements": _measurements}, "\t") + "\n")
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"interaction_timing_passed")
	get_tree().quit(0 if _failures.is_empty() else 1)


func _check_data() -> void:
	_expect(TIMING.is_valid() and not InteractionTimingRule.new().is_valid(), "Timing defaults invalid.")
	for property in ["inspection_duration", "recovery_duration"]:
		for value in [0.0, -1.0, NAN, INF]:
			var invalid := TIMING.duplicate(true) as InteractionTimingRule
			invalid.set(property, value)
			_expect(not invalid.is_valid(), "Invalid timing accepted.")
	for value in [0.0, -0.1, 1.1, NAN, INF]:
		var invalid := SURVIVAL.duplicate(true) as SurvivalRule
		invalid.injury_interaction_multiplier = value
		_expect(not invalid.is_valid(), "Invalid injury efficiency accepted.")
	var state := PlayerSurvival.new()
	state.rule = SURVIVAL
	add_child(state)
	var player: PlayerController = PLAYER.instantiate()
	add_child(player)
	var controller: InteractionController = player.get_node("InteractionController")
	var data := TIMING.duplicate(true) as InteractionTimingRule
	_expect(controller.configure_timing(data, state) and not controller.configure_timing(data, state), "Timing configured twice.")
	data.recovery_duration = 99.0
	var pickup: PickupInteractable = PICKUP.instantiate()
	pickup.item_definition = LIGHT
	add_child(pickup)
	player.get_node("Inventory").configure_capacity(3, 2.5, 4.0)
	await _frames(3)
	_expect(not controller.interact_current(), "Configured work started before activation.")
	state.start_exploration()
	controller.set_active(true)
	_expect(controller.interact_current() and is_equal_approx(controller.get_work_remaining(), 0.4), "Exported data mutated active snapshot.")
	controller.set_active(false)
	await _frames(40)
	_expect(not controller.is_working() and is_instance_valid(pickup), "Deactivation completed pending pickup.")
	player.queue_free()
	pickup.queue_free()
	state.queue_free()
	await _frames(3)
	player = PLAYER.instantiate()
	add_child(player)
	controller = player.get_node("InteractionController")
	_expect(not controller.configure_timing(InteractionTimingRule.new(), null), "Invalid timing accepted.")
	controller.set_active(true)
	_expect(not controller.interact_current(), "Invalid configuration fell back to instant actions.")
	player.queue_free()
	await _frames(3)


func _isolated_world() -> PrototypeExploration:
	var world := await _new_world()
	# Isolate timing/cancellation from pursuit; default integration routes stay active.
	world.get_node("%BrokenGuardGolem").process_mode = Node.PROCESS_MODE_DISABLED
	return world


func _check_durations(injured: bool) -> void:
	var world := await _isolated_world()
	var player: PlayerController = world.get_node("Player")
	var controller: InteractionController = player.get_node("InteractionController")
	var inventory: PlayerInventory = player.get_node("Inventory")
	var unknown: InspectablePickupInteractable = world.get_node("%UnknownPickup")
	player.position = unknown.position
	await _frames(4)
	if injured:
		world.get_node("%PlayerSurvival").apply_trap_damage()
	_completed = 0
	unknown.inspection_completed.connect(func(_summary: String, _hint: String): _completed += 1)
	_tap(KEY_E)
	_expect(controller.is_working() and not unknown.is_inspected() and inventory.get_used_slots() == 0, "Inspection completed on start.")
	var started := Engine.get_physics_frames()
	await _frames(10)
	_expect(not unknown.is_inspected() and _completed == 0, "Partial inspection disclosed completion.")
	_check_prompt(world)
	await _capture("timing-inspection-%s.png" % ("injured" if injured else "normal"))
	if injured:
		get_tree().root.size = Vector2i(1600, 900)
		await _frames(3)
		_check_prompt(world)
		await _capture("timing-inspection-wide.png")
		get_tree().root.size = Vector2i(1152, 648)
	await _finish_work(controller)
	var inspect_frames := Engine.get_physics_frames() - started
	_expect(unknown.is_inspected() and _completed == 1 and inventory.get_used_slots() == 0, "Inspection also recovered item or completed twice.")
	_tap(KEY_E)
	started = Engine.get_physics_frames()
	_expect(controller.is_working() and inventory.get_used_slots() == 0, "Recovery completed on start.")
	await _frames(8)
	_check_prompt(world)
	await _capture("timing-recovery-%s.png" % ("injured" if injured else "normal"))
	await _finish_work(controller)
	var recover_frames := Engine.get_physics_frames() - started
	_expect(inventory.get_used_slots() == 1 and not inventory.get_inventory_items()[0].is_identified() and not is_instance_valid(unknown), "Timed recovery changed identification or retained target.")
	_expect(absi(inspect_frames - (96 if injured else 48)) <= 3 and absi(recover_frames - (48 if injured else 24)) <= 3, "Actual work duration differs from trial data: %d/%d." % [inspect_frames, recover_frames])
	_measurements.append({"injured": injured, "inspection_frames": inspect_frames, "recovery_frames": recover_frames})
	world.queue_free()
	await _frames(3)


func _check_dynamic_efficiency() -> void:
	var world := await _isolated_world()
	var player: PlayerController = world.get_node("Player")
	var state: PlayerSurvival = world.get_node("%PlayerSurvival")
	var controller: InteractionController = player.get_node("InteractionController")
	player.position = world.get_node("%MapClue").position
	await _frames(4)
	_tap(KEY_E)
	await _frames(12)
	var progress := controller.get_work_progress()
	state.apply_trap_damage()
	await _frames(12)
	var slowed_progress := controller.get_work_progress() - progress
	_expect(slowed_progress > 0.09 and slowed_progress < 0.15, "Mid-work injury did not slow remaining work.")
	_expect(world.get_map_state().get_clues().is_empty(), "Incomplete clue work disclosed clue.")
	await _finish_work(controller)
	_expect(world.get_map_state().get_clues().size() == 1, "Completed clue work failed to record clue.")
	# Begin again just before expiry, so efficiency changes during this work.
	while state.get_injury_remaining() > 0.22:
		await _frames(1)
	_tap(KEY_E)
	var started := Engine.get_physics_frames()
	await _frames(20)
	_expect(state.get_interaction_multiplier() == 1.0 and controller.is_working(), "Expiry did not restore work efficiency.")
	await _finish_work(controller)
	var elapsed := Engine.get_physics_frames() - started
	_expect(elapsed > 48 and elapsed < 64 and state.get_health() == 1, "Expiry restarted, healed, or retained injured work duration.")
	world.queue_free()
	await _frames(3)


func _check_cancel_boundaries() -> void:
	var world := await _isolated_world()
	var player: PlayerController = world.get_node("Player")
	var controller: InteractionController = player.get_node("InteractionController")
	var inventory: PlayerInventory = player.get_node("Inventory")
	var pickup: PickupInteractable = world.get_node("%SafeLightPickup")
	player.position = pickup.position + Vector2(-40, 0)
	await _frames(4)
	_tap(KEY_E)
	await _frames(5)
	var echo := InputEventKey.new()
	echo.keycode = KEY_E
	echo.physical_keycode = KEY_E
	echo.pressed = true
	echo.echo = true
	Input.parse_input_event(echo)
	Input.flush_buffered_events()
	_expect(controller.is_working(), "Keyboard echo canceled work.")
	_tap(KEY_E)
	_expect(not controller.is_working() and inventory.get_used_slots() == 0, "Explicit cancel awarded pickup.")
	await _capture("timing-canceled.png")
	for menu in [KEY_TAB, KEY_M]:
		_tap(KEY_E)
		await _frames(6)
		_tap(menu)
		await _frames(60)
		_expect(get_tree().paused and not controller.is_working() and inventory.get_used_slots() == 0 and not controller.interact_current(), "Menu retained/completed work or accepted E.")
		_tap(menu)
		await _frames(4)
		_expect(not controller.is_working(), "Closing menu resumed canceled work.")
	_tap(KEY_E)
	_expect(controller.get_work_progress() == 0.0, "Restart preserved canceled progress.")
	Input.action_press(InputActions.MOVE_LEFT)
	await _frames(16)
	_release()
	_expect(not controller.is_working() and inventory.get_used_slots() == 0, "Actual movement out of reach completed pickup.")
	player.position = pickup.position
	await _frames(4)
	_tap(KEY_E)
	await _frames(5)
	var closer: PickupInteractable = PICKUP.instantiate()
	closer.item_definition = HEAVY
	closer.position = player.position
	pickup.position.x += 45.0
	world.add_child(closer)
	await _frames(4)
	_expect(not controller.is_working() and inventory.get_used_slots() == 0, "Target switch transferred pending progress.")
	_tap(KEY_E)
	await _frames(5)
	closer.queue_free()
	await _frames(4)
	_expect(not controller.is_working() and inventory.get_used_slots() == 0, "Deleted target completed work.")
	_tap(KEY_E)
	await _frames(4)
	pickup.set_interaction_enabled(false)
	await _frames(3)
	_expect(not controller.is_working(), "Disabled target retained work.")
	world.queue_free()
	await _frames(3)


func _check_capacity_and_reentry() -> void:
	var world := await _isolated_world()
	var player: PlayerController = world.get_node("Player")
	var controller: InteractionController = player.get_node("InteractionController")
	var inventory: PlayerInventory = player.get_node("Inventory")
	var unknown: InspectablePickupInteractable = world.get_node("%UnknownPickup")
	player.position = unknown.position
	await _frames(4)
	for index in range(3):
		inventory.try_add_item(LIGHT)
	_tap(KEY_E)
	await _finish_work(controller)
	_expect(unknown.is_inspected(), "Full bag prevented inspection.")
	_tap(KEY_E)
	_expect(not controller.is_working() and world.get_node("%ChoiceStatus").text.contains("공간이 부족"), "Full bag began recovery without feedback.")
	inventory.take_all_items()
	_tap(KEY_E)
	await _frames(10)
	for index in range(3):
		inventory.try_add_item(LIGHT)
	await _frames(20)
	_expect(not controller.is_working() and is_instance_valid(unknown) and inventory.get_items() == [LIGHT, LIGHT, LIGHT], "Capacity change lost target or awarded extra item.")
	inventory.take_all_items()
	_completed = 0
	_reentrant_accepted = false
	inventory.item_added.connect(func(_item: ItemDefinition):
		_completed += 1
		_reentrant_accepted = controller.interact_current() or unknown.interact(player)
	)
	_tap(KEY_E)
	await _finish_work(controller)
	_expect(_completed == 1 and not _reentrant_accepted and inventory.get_used_slots() == 1, "Completion signal reentry duplicated pickup.")
	world.queue_free()
	await _frames(3)
	# A different caller completing inspection must not turn old progress into pickup.
	world = await _isolated_world()
	player = world.get_node("Player")
	controller = player.get_node("InteractionController")
	unknown = world.get_node("%UnknownPickup")
	player.position = unknown.position
	await _frames(4)
	_tap(KEY_E)
	await _frames(8)
	unknown.interact(player)
	await _frames(100)
	_expect(not controller.is_working() and unknown.is_inspected() and player.get_node("Inventory").get_used_slots() == 0, "External stage change converted inspection to recovery.")
	world.queue_free()
	await _frames(3)


func _check_immediate_and_end() -> void:
	var world := await _isolated_world()
	var player: PlayerController = world.get_node("Player")
	var controller: InteractionController = player.get_node("InteractionController")
	world.get_node("%PlayerSurvival").apply_trap_damage()
	player.position = Vector2(628, -70)
	await _frames(4)
	_tap(KEY_E)
	_expect(not world.get_node("%RetreatDoor").is_open and not controller.is_working(), "Injury delayed door action.")
	_tap(KEY_Q)
	await _frames(3)
	_expect(world.get_node("Player/HarnessController").get_current_charge() == 2, "Injury delayed Q.")
	player.position = world.get_node("%SafeLightPickup").position
	await _frames(4)
	_tap(KEY_E)
	await _frames(10)
	world.get_node("%ExplorationRun").complete_failure()
	await _frames(120)
	_expect(not controller.is_working() and not controller.interact_current() and world.get_node("Player/Inventory").get_used_slots() == 0 and is_instance_valid(world.get_node("%SafeLightPickup")), "Failure completed or restarted pending recovery.")
	world.queue_free()
	await _frames(3)
	world = await _new_world()
	player = world.get_node("Player")
	controller = player.get_node("InteractionController")
	_expect(not controller.is_working(), "Fresh departure retained work.")
	world.get_node("%PlayerSurvival").apply_trap_damage()
	_tap(KEY_E)
	_expect(world.get_node("%ExplorationRun").get_outcome().is_safe_return() and not controller.is_working(), "Injury delayed entrance return.")
	controller.set_active(true)
	player.process_mode = Node.PROCESS_MODE_PAUSABLE
	_expect(not controller.interact_current(), "Controller reactivation bypassed finished survival state.")
	world.queue_free()
	await _frames(3)


func _finish_work(controller: InteractionController) -> void:
	for frame in range(240):
		if not controller.is_working():
			return
		await _frames(1)
	_expect(false, "Timed interaction did not finish.")


func _check_prompt(world: PrototypeExploration) -> void:
	var prompt: InteractionPrompt = world.get_node("%InteractionPrompt")
	_expect(prompt.visible and prompt.text.contains("남은") and prompt.text.contains("취소"), "Progress/time/cancel guidance missing.")
	_expect(get_viewport().get_visible_rect().encloses(prompt.get_global_rect()), "Progress prompt exceeds viewport.")
	var font := prompt.get_theme_font("font")
	for line in prompt.text.split("\n"):
		_expect(font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, prompt.get_theme_font_size("font_size")).x <= prompt.size.x, "Progress prompt clipped.")
	var health: Label = world.get_node("%SurvivalStatus")
	_expect(health.get_theme_font("font").get_string_size(health.text, HORIZONTAL_ALIGNMENT_LEFT, -1, health.get_theme_font_size("font_size")).x <= health.size.x, "Injury efficiency HUD clipped.")


func _capture(filename: String) -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--timing-render-directory="):
			var directory := argument.trim_prefix("--timing-render-directory=")
			DirAccess.make_dir_recursive_absolute(directory)
			await RenderingServer.frame_post_draw
			_expect(get_viewport().get_texture().get_image().save_png(directory.path_join(filename)) == OK, "Timing screenshot failed.")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		GameLog.error(&"SmokeTest", &"interaction_timing_failed", message)
