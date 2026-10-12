extends Node

const WORLD := preload("res://src/app/prototype_exploration.tscn")
const GOLEM := preload("res://src/gameplay/hazards/broken_guard_golem.tscn")
var failures: Array[String] = []
var cases: Array[Dictionary] = []
var directory := ""
var render := false


func _ready() -> void:
	directory = OS.get_environment("TEMP").path_join("dungeon-response-guidance-%d" % OS.get_process_id())
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--guidance-directory="):
			directory = argument.trim_prefix("--guidance-directory=")
	render = "--guidance-render" in OS.get_cmdline_user_args()
	DirAccess.make_dir_recursive_absolute(directory)
	await _bounded_redirects()
	await _normal_search()
	for size in [Vector2i(1152, 648), Vector2i(1600, 900)]:
		get_window().size = size
		await _frames(3)
		for mode in ["ready", "empty", "missing", "far", "precise"]:
			await _guidance(mode, size.x)
		await _lure_feedback(size.x)
	var file := FileAccess.open(directory.path_join("guidance.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify({"passed": failures.is_empty(), "failures": failures, "cases": cases,
		"human_session_completed": false, "rendered": render}, "\t") + "\n")
	file.close()
	if failures.is_empty():
		GameLog.info(&"SmokeTest", &"golem_response_guidance_passed", directory)
	get_tree().quit(0 if failures.is_empty() else 1)


func _bounded_redirects() -> void:
	var golem: BrokenGuardGolem = GOLEM.instantiate()
	golem.use_sight_occlusion = true
	golem.patrol_offset = Vector2.ZERO
	golem.suspicion_duration = 0.7
	golem.search_duration = 2.5
	add_child(golem)
	_expect(golem.investigate_lure(Vector2(300, 0)), "Initial lure rejected")
	await _frames(55)
	_expect(golem.get_analysis_remaining() < 0.0, "Travelling lure exposed a nonexistent search timer")
	var position_before := golem.position
	get_tree().paused = true
	await _frames(100)
	_expect(golem.position == position_before, "Paused lure moved")
	get_tree().paused = false
	var elapsed := 55
	var redirects := 0
	while elapsed < 500 and golem.get_state() != BrokenGuardGolem.State.PATROL:
		if elapsed % 30 == 0:
			_expect(golem.investigate_lure(golem.position + Vector2(150 if redirects % 2 == 0 else -150, 0)), "Redirect rejected")
			redirects += 1
		await _frames(1)
		elapsed += 1
	_expect(elapsed >= 478 and elapsed <= 483, "Repeated lures extended the first-lure cap or pause consumed it")
	_expect(golem.get_state() == BrokenGuardGolem.State.PATROL, "Redirect loop never returned to patrol")
	cases.append({"case": "redirect_cap_and_pause", "active_frames": elapsed, "paused_frames": 100, "redirects": redirects})
	golem.queue_free()
	await _frames(3)


func _normal_search() -> void:
	var golem: BrokenGuardGolem = GOLEM.instantiate()
	golem.use_sight_occlusion = true
	golem.suspicion_duration = 0.7
	golem.search_duration = 2.5
	golem.patrol_offset = Vector2.ZERO
	add_child(golem)
	_expect(golem.investigate_lure(Vector2(300, 0)), "Setup lure failed")
	await _frames(50)
	_expect(golem.investigate_noise(Vector2(1500, 0)), "Ordinary noise did not supersede lure")
	var elapsed := 0
	while elapsed < 250 and golem.get_state() != BrokenGuardGolem.State.PATROL:
		await _frames(1)
		elapsed += 1
	_expect(elapsed >= 191 and elapsed <= 195, "Ordinary noise search inherited lure arrival timing")
	cases.append({"case": "ordinary_noise_supersedes_lure", "active_frames": elapsed})
	golem.queue_free()
	await _frames(3)


func _guidance(mode: String, width: int) -> void:
	var world: PrototypeExploration = WORLD.instantiate()
	add_child(world)
	var loadout := HubState.new().create_departure_loadout()
	if mode == "empty":
		loadout.starting_charge = 0
	if mode == "missing":
		loadout.harness_modules = [HarnessModules.ANALYSIS, HarnessModules.STABILIZATION]
	if mode == "precise":
		loadout.harness_modules = [HarnessModules.ANALYSIS, HarnessModules.EMERGENCY]
		loadout.harness_upgrades = [HarnessUpgradeRule.OBSERVATION]
	_expect(world.prepare_departure(loadout) and world.start_exploration(), "Expedition failed to start")
	world.get_node("%GolemHearing").set_active(false)
	var player: PlayerController = world.get_node("Player")
	var golem: BrokenGuardGolem = world.get_node("%BrokenGuardGolem")
	var harness: HarnessController = player.get_node("HarnessController")
	var status: HarnessStatus = world.get_node("%HarnessStatus")
	golem.position = Vector2(0, -180)
	player.position = Vector2(140 if mode == "far" else 70, -180)
	await _frames(3)
	if mode != "far":
		_expect(harness.get_current_prompt().begins_with("골렘 잠깐 멈추기"), "Effect did not lead the action prompt")
		_expect(status.get_analysis_text().contains("비상 방전"), "Effect guidance lost the module-name connection")
	if mode == "ready":
		_expect(status.get_analysis_text().contains("그동안 멀어지세요"), "Free guidance omitted the effect/action")
	if mode == "empty":
		_expect(status.get_status_text().contains("충전 부족"), "Empty charge looked usable")
	if mode == "missing":
		_expect(status.get_status_text().contains("미장착") and not status.get_status_text().contains("[Q]"), "Missing module showed usable Q")
	if mode == "far":
		_expect(status.get_status_text().contains("대상 없음") and not status.is_prompt_visible(), "Out-of-range guidance was misleading")
	_expect(not status.get_analysis_text().contains("남은 시간"), "Free guidance leaked exact analysis timing")
	await _record_screen(world, "%d-%s-before" % [width, mode])
	var charge := harness.get_current_charge()
	var accepted := harness.use_current_harness_action()
	_expect(accepted == (mode in ["ready", "precise"]), "Q condition did not match guidance")
	if accepted:
		_expect(not harness.use_current_harness_action() and harness.get_current_charge() == charge - 1, "Repeated Q consumed charge or extended disable")
		if mode == "precise":
			_expect(harness.analyze_current_target() and harness.get_precise_analysis().contains("남은 시간"), "Purchased observation timing missing")
		await _frames(3)
		_expect(world.get_node("%ChoiceStatus").text.contains("지금 멀어지세요"), "Q success guidance missing")
		await _record_screen(world, "%d-%s-disabled" % [width, mode])
		# Real inventory and map actions must freeze both the effect and simulation.
		for key in [KEY_TAB, KEY_M]:
			_tap(key)
			await _frames(2)
			var remaining := golem.get_analysis_remaining()
			_expect(get_tree().paused, "Menu failed to pause")
			await _frames(40)
			_expect(is_equal_approx(remaining, golem.get_analysis_remaining()), "Menu consumed discharge time")
			_tap(key)
			await _frames(2)
			_expect(not get_tree().paused, "Menu failed to resume")
		await _frames(125)
		_expect(world.get_node("%ChoiceStatus").text.contains("다시 움직입니다"), "Visible restart not announced")
		await _record_screen(world, "%d-%s-restart" % [width, mode])
		_expect(harness.get_precise_analysis().is_empty(), "Purchased timer survived a state change")
	else:
		_expect(harness.get_current_charge() == charge, "Rejected Q spent charge")
		if mode in ["empty", "missing"]:
			player.position = golem.position + Vector2(20, 0)
			await _frames(44)
			var contact: Label = world.get_node("%ContactStatus")
			_expect(contact.visible and contact.text.contains("충전 부족" if mode == "empty" else "미장착"), "Contact warning advertised unavailable discharge")
			await _record_screen(world, "%d-%s-contact" % [width, mode])
	cases.append({"case": "guidance", "mode": mode, "width": width, "accepted": accepted})
	world.get_node("%ExplorationRun").complete_failure()
	var stopped_position := golem.position
	await _frames(60)
	_expect(golem.position == stopped_position and not world.get_node("Overlay").visible, "Finished expedition kept simulating or showing HUD")
	world.queue_free()
	await _frames(3)


func _lure_feedback(width: int) -> void:
	var world: PrototypeExploration = WORLD.instantiate()
	add_child(world)
	_expect(world.prepare_departure(HubState.new().create_departure_loadout()) and world.start_exploration(), "Lure UI expedition failed")
	var player: PlayerController = world.get_node("Player")
	var golem: BrokenGuardGolem = world.get_node("%BrokenGuardGolem")
	player.position = Vector2(-350, -180)
	golem.position = Vector2(0, -180)
	await _frames(3)
	world._on_lure_landed(Vector2(300, -180), 320.0)
	await _frames(50)
	_expect(golem.get_status_text().contains("이동 중"), "Moving lure status missing")
	await _record_screen(world, "%d-lure-travel" % width)
	await _frames(235)
	_expect(golem.get_status_text().contains("살피는 중"), "Arrival status missing")
	await _record_screen(world, "%d-lure-arrival" % width)
	await _frames(150)
	_expect(world.get_node("%ChoiceStatus").text.contains("다시 순찰"), "Visible patrol return not announced")
	await _record_screen(world, "%d-lure-return" % width)
	world._on_lure_landed(Vector2(2000, 2000), 320.0)
	_expect(world.get_node("%ChoiceStatus").text.contains("반응하지 않았습니다"), "Rejected landing advertised success")
	# A wall-hidden golem cannot reveal its return through the central notice.
	golem.position = Vector2(400, 60)
	player.position = Vector2(400, -60)
	await _frames(3)
	world.get_node("%ChoiceStatus").text = "hidden return sentinel"
	world._on_lure_finished()
	_expect(world.get_node("%ChoiceStatus").text == "hidden return sentinel", "Hidden patrol return leaked through HUD")
	cases.append({"case": "lure_feedback", "width": width})
	world.queue_free()
	await _frames(3)


func _record_screen(world: PrototypeExploration, label: String) -> void:
	await _frames(3)
	var panel: Control = world.get_node("%HarnessStatus")
	var tool: Control = world.get_node("%ToolStatus")
	var choice: Control = world.get_node("%ChoiceStatus")
	var contact: Control = world.get_node("%ContactStatus")
	_expect(panel.get_global_rect().end.y <= tool.get_global_rect().position.y, "Harness/tool panels overlap: " + label)
	_expect(tool.get_global_rect().end.y < get_viewport().get_visible_rect().size.y, "Right HUD clipped: " + label)
	_expect(panel.get_global_rect().position.x > choice.get_global_rect().end.x, "Action/choice panels overlap: " + label)
	_expect(not (choice.visible and contact.visible), "Contact and choice both shown: " + label)
	if render and DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(directory.path_join(label + ".png"))


func _tap(key: Key) -> void:
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.keycode = key
		event.physical_keycode = key
		event.pressed = pressed
		get_viewport().push_input(event, true)


func _frames(count: int) -> void:
	for index in count:
		await get_tree().physics_frame
		await get_tree().process_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)
