extends Node

const WORLD := preload("res://src/app/prototype_exploration.tscn")
const GOLEM := preload("res://src/gameplay/hazards/broken_guard_golem.tscn")
const LIGHT := preload("res://src/data/prototype_light.tres")
const UPGRADES := preload("res://src/data/prototype_harness_upgrades.tres")
var failures: Array[String] = []
var cases: Array[Dictionary] = []
var directory := ""
var capture := false


func _ready() -> void:
	directory = OS.get_environment("TEMP").path_join("dungeon-golem-review-%d" % OS.get_process_id())
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--response-directory="):
			directory = argument.trim_prefix("--response-directory=")
	capture = "--response-render" in OS.get_cmdline_user_args()
	DirAccess.make_dir_recursive_absolute(directory)
	get_window().size = Vector2i(1152, 648)
	for weight in [0.0, 2.5, 4.0]:
		await _movement_and_escape(weight)
	for mode in ["default", "no_module", "empty", "out_of_range", "wall", "stay", "improved"]:
		await _discharge(mode)
	for distance in [40.0, 160.0, 300.0]:
		await _lure(distance, false)
	await _lure(160.0, true)
	await _visual_lure_and_drop()
	var file := FileAccess.open(directory.path_join("golem-response.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify({"passed": failures.is_empty(), "cases": cases, "failures": failures,
		"method": "Prepared positions/load/initial chase; live current expedition settings, physics and Q/G input. Lanes inject the golem lure API; cover cases use the hearing API. No human play or balance approval."}, "\t") + "\n")
	file.close()
	if failures.is_empty():
		GameLog.info(&"SmokeTest", &"golem_response_review_passed", directory)
	get_tree().quit(0 if failures.is_empty() else 1)


func _world(mode := "default") -> PrototypeExploration:
	var world: PrototypeExploration = WORLD.instantiate()
	add_child(world)
	var loadout := HubState.new().create_departure_loadout()
	if mode == "no_module":
		loadout.harness_modules = [HarnessModules.ANALYSIS, HarnessModules.STABILIZATION]
	if mode == "empty":
		loadout.starting_charge = 0
	if mode == "improved":
		loadout.harness_upgrades = [HarnessUpgradeRule.EMERGENCY]
	_expect(world.prepare_departure(loadout) and world.start_exploration(), "Cannot start actual expedition")
	# Hearing is isolated except in the explicit hearing checks. Live footstep
	# escalation is already covered by movement_noise_smoke and noise_lure_smoke.
	world.get_node("%GolemHearing").set_active(false)
	world.get_node("Player").position = Vector2(-500, -180)
	world.get_node("%BrokenGuardGolem").position = Vector2(-650, -180)
	await _frames(3)
	return world


func _movement_and_escape(weight: float) -> void:
	var world := await _world()
	var player: PlayerController = world.get_node("Player")
	var golem: BrokenGuardGolem = world.get_node("%BrokenGuardGolem")
	var inventory: PlayerInventory = player.get_node("Inventory")
	# Prepare the exact total carried weight, including the default free tools.
	if weight > 0:
		var item := LIGHT.duplicate(true) as ItemDefinition
		item.weight = weight - inventory.get_total_weight()
		_expect(inventory.try_add_item(item), "Cannot prepare load")
	# Seed a chase with the player out of sight, then start with an 80px gap.
	player.position = Vector2(-500, -900)
	await _frames(4)
	golem.raise_alarm(Vector2(-500, -180))
	await _frames(45)
	golem.position = Vector2(-580, -180)
	player.position = Vector2(-500, -180)
	await _frames(2)
	var before := player.position.x - golem.position.x
	Input.action_press(InputActions.MOVE_RIGHT)
	await _frames(45)
	Input.action_release(InputActions.MOVE_RIGHT)
	var after := player.position.x - golem.position.x
	var speed := player.get_current_movement_speed()
	_expect(after > before if weight == 0 else after < before, "Unexpected open-space pursuit gap")
	var row := {"case": "open_chase", "total_weight": inventory.get_total_weight(), "speed": speed,
		"golem_speed": golem.chase_speed, "gap_before": before, "gap_after_45_frames": after}
	# Reposition in the same open space; invoke the real Q action and flee.
	golem.position = Vector2(-580, -180)
	player.position = Vector2(-510, -180)
	await _frames(2)
	_tap(KEY_Q)
	await _frames(2)
	_expect(golem.get_state() == BrokenGuardGolem.State.DISABLED, "Q did not disable in escape case")
	Input.action_press(InputActions.MOVE_RIGHT)
	await _frames(135)
	Input.action_release(InputActions.MOVE_RIGHT)
	_expect(not golem.has_visual_contact(), "Straight escape after Q failed")
	row["after_q_distance"] = player.position.distance_to(golem.position)
	row["after_q_visual_contact"] = golem.has_visual_contact()
	cases.append(row)
	await _dispose(world)


func _discharge(mode: String) -> void:
	var world := await _world(mode)
	var player: PlayerController = world.get_node("Player")
	var golem: BrokenGuardGolem = world.get_node("%BrokenGuardGolem")
	var harness: HarnessController = player.get_node("HarnessController")
	# Only the wall case changes the layout; all use the current action radius.
	golem.position = Vector2(400, -180)
	player.position = Vector2(470 if mode != "out_of_range" else 540, -180)
	if mode == "wall":
		golem.position = Vector2(400, 45)
		player.position = Vector2(400, -45)
	await _frames(3)
	var charge := harness.get_current_charge()
	var row := {"case": "discharge_" + mode, "prompt_before": harness.get_current_prompt(),
		"basic_before": harness.get_basic_analysis(), "charge_before": charge,
		"visual_before": golem.has_visual_contact()}
	await _capture("q-" + mode + "-before")
	_tap(KEY_Q)
	await _frames(2)
	var accepted := golem.get_state() == BrokenGuardGolem.State.DISABLED
	row["accepted"] = accepted
	row["charge_after"] = harness.get_current_charge()
	row["status_after"] = golem.get_status_text()
	row["basic_after"] = harness.get_basic_analysis()
	row["remaining_after_2_frames"] = golem.get_analysis_remaining()
	var should_accept := mode not in ["no_module", "empty", "out_of_range"]
	_expect(accepted == should_accept and harness.get_current_charge() == charge - (1 if accepted else 0), "Q condition/charge mismatch: " + mode)
	if accepted:
		var elapsed := 2
		while golem.get_state() == BrokenGuardGolem.State.DISABLED and elapsed < 240:
			await _frames(1)
			elapsed += 1
		row["disabled_seconds_approx"] = float(elapsed) / 60.0
		row["state_after_restart"] = golem.get_state()
		row["visual_after_restart"] = golem.has_visual_contact()
		_expect(absf(float(elapsed) / 60.0 - (3.0 if mode == "improved" else 2.0)) < 0.1, "Discharge duration changed")
		_expect(golem.has_visual_contact() == (mode != "wall"), "Restart sight mismatch")
	await _capture("q-" + mode + "-after")
	cases.append(row)
	await _dispose(world)


func _lure(distance: float, blocked: bool) -> void:
	# A bare controlled lane uses exactly the current expedition's golem settings.
	# The AI landing is injected to isolate travel/search from throw flight.
	var template: PrototypeExploration = WORLD.instantiate()
	var configured: BrokenGuardGolem = template.get_node("%BrokenGuardGolem")
	var lane := Node2D.new()
	add_child(lane)
	var golem: BrokenGuardGolem = GOLEM.instantiate()
	for property in ["patrol_speed", "suspicious_speed", "chase_speed", "search_speed", "suspicion_duration", "search_duration", "discharge_duration", "use_sight_occlusion"]:
		golem.set(property, configured.get(property))
	template.free()
	golem.patrol_offset = Vector2.ZERO
	lane.add_child(golem)
	if blocked:
		var wall := StaticBody2D.new()
		wall.collision_layer = 8
		wall.position = Vector2(60, 0)
		var collision := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = Vector2(20, 160)
		collision.shape = shape
		wall.add_child(collision)
		lane.add_child(wall)
	await _frames(3)
	_expect(golem.investigate_lure(Vector2(distance, 0)), "Lure was rejected in empty lane")
	var elapsed := 0
	var first_arrival := -1
	var first_search := -1
	while golem.get_state() != BrokenGuardGolem.State.PATROL and elapsed < 540:
		await _frames(1)
		elapsed += 1
		if first_arrival < 0 and golem.position.distance_to(Vector2(distance, 0)) <= 3.0:
			first_arrival = elapsed
		if first_search < 0 and golem.get_state() == BrokenGuardGolem.State.SEARCH:
			first_search = elapsed
	var row := {"case": "lure_lane", "landing_distance": distance, "blocked": blocked,
		"first_search_seconds": float(first_search) / 60.0, "patrol_seconds": float(elapsed) / 60.0,
		"arrival_seconds": float(first_arrival) / 60.0 if first_arrival >= 0 else -1.0,
		"arrival_before_patrol": first_arrival >= 0,
		"distance_short_at_patrol": golem.position.distance_to(Vector2(distance, 0)),
		"hold_after_arrival_seconds": float(elapsed - first_arrival) / 60.0 if first_arrival >= 0 else 0.0}
	_expect(golem.get_state() == BrokenGuardGolem.State.PATROL and float(elapsed) / 60.0 <= 8.1, "Lure did not end within the bounded investigation")
	_expect((first_arrival < 0) == blocked, "Reachable lure destination was abandoned")
	if not blocked:
		_expect(float(elapsed - first_arrival) / 60.0 >= 2.45, "Travel consumed the arrival search window")
	cases.append(row)
	await _dispose(lane)


func _visual_lure_and_drop() -> void:
	var world := await _world()
	var player: PlayerController = world.get_node("Player")
	var golem: BrokenGuardGolem = world.get_node("%BrokenGuardGolem")
	var hearing: GolemHearing = world.get_node("%GolemHearing")
	golem.position = Vector2(400, -180)
	player.position = Vector2(470, -180)
	hearing.set_active(true)
	await _frames(3)
	var visible_accepted := hearing.hear_lure(Vector2(550, -180), 320)
	_expect(golem.has_visual_contact() and not visible_accepted, "Visible player should override lure")
	golem.position = Vector2(400, 60)
	player.position = Vector2(400, -60)
	await _frames(3)
	var hidden_accepted := hearing.hear_lure(Vector2(550, 60), 320)
	_expect(not golem.has_visual_contact() and hidden_accepted, "Covered lure should redirect")
	var inventory: PlayerInventory = player.get_node("Inventory")
	var item := LIGHT.duplicate(true) as ItemDefinition
	item.weight = 3.5
	_expect(inventory.try_add_item(item), "Cannot prepare quick drop load")
	var before := player.get_current_movement_speed()
	_tap(KEY_G)
	await _frames(40)
	_expect(inventory.get_used_slots() == 1, "Unselected quick drop removed cargo")
	_expect(inventory.select_item(0), "Cannot select quick drop item")
	_key(KEY_G, true)
	await _frames(38)
	_key(KEY_G, false)
	_expect(inventory.get_used_slots() == 0 and player.get_current_movement_speed() == 240, "Selected quick drop failed")
	cases.append({"case": "cover_lure_and_quick_drop", "visible_lure_accepted": visible_accepted,
		"hidden_lure_accepted": hidden_accepted, "speed_before_drop": before, "speed_after_drop": player.get_current_movement_speed()})
	await _dispose(world)


func _capture(label: String) -> void:
	if capture and DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(directory.path_join(label + ".png"))


func _frames(count: int) -> void:
	for index in count:
		await get_tree().physics_frame
		await get_tree().process_frame


func _key(key: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = key
	event.physical_keycode = key
	event.pressed = pressed
	get_viewport().push_input(event, true)


func _tap(key: Key) -> void:
	_key(key, true)
	_key(key, false)


func _dispose(node: Node) -> void:
	Input.action_release(InputActions.MOVE_RIGHT)
	node.queue_free()
	await _frames(3)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)
