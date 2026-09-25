# Integrate default production data; do not freeze enemies or grant route resources.
extends "res://tests/smoke/value_comparison_smoke.gd"

var _routes: Array[Dictionary] = []


func _ready() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	await _run_route(false)
	await _run_route(true)
	_release()
	get_tree().paused = false
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--g3-report-path="):
			var file := FileAccess.open(argument.trim_prefix("--g3-report-path="), FileAccess.WRITE)
			_expect(file != null, "Could not write route evidence.")
			if file != null:
				file.store_string(JSON.stringify({"passed": _failures.is_empty(), "routes": _routes}, "\t"))
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"g3_exploration_flow_passed")
	get_tree().quit(0 if _failures.is_empty() else 1)


func _run_route(use_tools: bool) -> void:
	var world := await _new_world()
	var player: PlayerController = world.get_node("Player")
	var inventory: PlayerInventory = player.get_node("Inventory")
	var harness: HarnessController = player.get_node("HarnessController")
	var tool: NoiseLureController = world.get_node("%NoiseLureController")
	var noise: MovementNoiseEmitter = world.get_node("%MovementNoiseEmitter")
	var panel: InventoryPanel = world.get_node("%InventoryPanel")
	var run: ExplorationRun = world.get_node("%ExplorationRun")
	var door: TemporaryDoor = world.get_node("%RetreatDoor")
	var map := world.get_map_state()
	var started_frame := Engine.get_physics_frames()
	_expect(map.get_discovered_region_count() == 0 and not world.get_node("%RemainingZoneEntrance").is_open(), "New expedition retained a discovered/open room.")
	_expect(inventory.get_used_slots() == 0 and harness.get_current_charge() == 3 and tool.get_remaining_uses() == 2, "New expedition retained spent resources or cargo.")
	if use_tools:
		await _walk(player, Vector2(-570, 140))
		_tap(KEY_E)
		_expect(await InteractionTestInput.wait_for_work(player), "Timed action did not finish.")
		await _frames(3)
		_expect(map.has_clue(&"prototype_margin_clue") and map.get_discovered_region_count() == 0, "Reading clue revealed a room or failed to record.")
	await _walk(player, Vector2(-650, -200))
	await _walk(player, Vector2(-275, -200))
	_tap(KEY_E)
	_expect(await InteractionTestInput.wait_for_work(player), "Timed action did not finish.")
	await _frames(3)
	await _walk(player, Vector2(80, -200))
	_tap(KEY_E)
	_expect(await InteractionTestInput.wait_for_work(player), "Timed action did not finish.")
	await _frames(3)
	_expect(inventory.get_items() == [LIGHT, HEAVY] and inventory.get_weight_stage() == PlayerInventory.WeightStage.BURDENED, "Real pickups did not enter burden stage.")
	if use_tools:
		await _explore_optional_room(world)
	await _walk(player, Vector2(628, -200))
	await _walk(player, Vector2(628, -70))
	if use_tools:
		_tap(KEY_E)
		await _frames(4)
		_tap(KEY_Q)
		await _frames(4)
		_expect(door.is_held() and harness.get_current_charge() == 0, "Gate/trap/door did not share the three-charge budget.")
		_expect(map.get_passage_status(&"prototype_bypass_link") == ExplorationMapState.PassageStatus.BLOCKED, "Door action and observed map disagree.")
		var mouse := InputEventMouseMotion.new()
		mouse.position = world.get_canvas_transform() * Vector2(628, -210)
		Input.parse_input_event(mouse)
		Input.flush_buffered_events()
		_tap(KEY_F)
		await _frames(3)
		_expect(tool.is_in_flight() and tool.get_remaining_uses() == 1, "Throw did not use separate tool stock.")
		_tap(KEY_M)
		await _frames(3)
		var held_remaining := door.get_hold_remaining()
		var player_position := player.position
		var golem: BrokenGuardGolem = world.get_node("%BrokenGuardGolem")
		var golem_position := golem.position
		_tap(KEY_Q)
		_tap(KEY_F)
		Input.action_press(InputActions.MOVE_DOWN)
		await _frames(60)
		_release()
		_expect(get_tree().paused and door.get_hold_remaining() == held_remaining and tool.is_in_flight() and tool.get_remaining_uses() == 1 and harness.get_current_charge() == 0, "Map advanced mixed timers or spent resources.")
		_expect(player.position == player_position and golem.position == golem_position, "Map failed to pause actors.")
		await _capture("g3-observed-map.png")
		_tap(KEY_M)
		await _frames(4)
		for frame in range(400):
			if not door.is_held():
				break
			await _frames(1)
		_expect(not door.is_held() and not tool.is_in_flight(), "World timers did not resume after map.")
		if not door.is_open:
			_tap(KEY_E)
			await _frames(4)
		_expect(door.is_open and harness.get_current_charge() == 0, "Empty harness prevented free door opening.")
	# Contact is now dangerous. Approach the reward from the western passage,
	# crossing the collapse warning promptly instead of running into the golem.
	await _walk(player, Vector2(628, -200))
	await _walk(player, Vector2(-500, -200))
	await _walk(player, Vector2(-500, 200))
	await _walk(player, Vector2(160, 220))
	_tap(KEY_E)
	_expect(await InteractionTestInput.wait_for_work(player), "Timed action did not finish.")
	await _frames(3)
	_expect(inventory.get_used_slots() == 3 and inventory.get_weight_stage() == PlayerInventory.WeightStage.OVERLOADED, "Risk-route pickup did not fill/overload cargo.")
	var speed_before := player.get_current_movement_speed()
	var noise_before := noise.get_noise_radius()
	var items := inventory.get_inventory_items()
	_tap(KEY_TAB)
	await _frames(3)
	var list: ItemList = panel.get_node("%ItemList")
	list.grab_focus()
	_tap(KEY_UP)
	await _frames(3)
	_expect(inventory.get_selected_index() == 1 and inventory.get_quick_drop_item() == items[1], "Comparison selected the wrong drop object.")
	_expect(panel.get_selection_details_text().contains("무게 1당") and list.get_item_icon(1) == ItemCategoryIcon.for_item(items[1]), "Category/value comparison disappeared in combined route.")
	if not use_tools:
		await _capture("g3-cargo-choice.png")
	_tap(KEY_TAB)
	await _frames(3)
	_key(KEY_G, true)
	Input.action_press(InputActions.MOVE_LEFT)
	await _frames(45)
	_key(KEY_G, false)
	_release()
	await _frames(3)
	_expect(inventory.get_used_slots() == 2 and not inventory.get_inventory_items().has(items[1]), "Moving quick drop discarded wrong cargo.")
	_expect(player.get_current_movement_speed() > speed_before and noise.get_noise_radius() < noise_before, "Dropping cargo did not improve both speed and noise.")
	var speed_after := player.get_current_movement_speed()
	var noise_after := noise.get_noise_radius()
	_expect(run.is_active(), "Combined route ended before reaching entrance.")
	if not use_tools:
		await _capture("g3-lighter-retreat.png")
	await _walk(player, Vector2(-500, 200))
	await _walk(player, Vector2(-680, 0))
	_expect(world.get_node("%ReturnRouteStatus").get_direction_text().contains("E로 귀환 가능"), "Return HUD did not match actual entrance.")
	_tap(KEY_E)
	await _frames(4)
	_expect(run.get_state() == ExplorationRun.State.SAFE_RETURN and not get_tree().paused, "Combined route failed safe return.")
	var outcome := run.get_outcome()
	var recovered_count := 0
	var expected_value: Array[int] = []
	if outcome != null and outcome.is_safe_return():
		var recovered := outcome.get_recovery_result()
		recovered_count = recovered.get_item_count()
		expected_value = [recovered.get_total_value_min(), recovered.get_total_value_max()]
		_expect(recovered.get_item_count() == 2 and recovered.get_total_value_min() == 90 and recovered.get_total_value_max() == 130, "Return included dropped cargo or changed value.")
	_expect(harness.get_current_charge() == (0 if use_tools else 3), "Route charged for a free action.")
	_expect(tool.get_remaining_uses() == (1 if use_tools else 2), "Route replenished/spent unexpected lure stock.")
	_expect(world.get_node("%RiskHazard").get_state() == UnstableDebrisHazard.State.TRIGGERED, "Route did not clear the timed collapse passage.")
	_routes.append({"route": "limited_tools" if use_tools else "free_lower_passage", "physics_frames": Engine.get_physics_frames() - started_frame, "safe_return": outcome != null and outcome.is_safe_return(), "recovered_items": recovered_count, "expected_value": expected_value, "speed_before_drop": speed_before, "speed_after_drop": speed_after, "noise_before_drop": noise_before, "noise_after_drop": noise_after, "remaining_charge": harness.get_current_charge(), "remaining_lures": tool.get_remaining_uses(), "discovered_regions": map.get_discovered_region_count()})
	GameLog.info(&"G3Flow", &"route_completed", JSON.stringify(_routes.back()))
	world.queue_free()
	await _frames(4)


func _explore_optional_room(world: PrototypeExploration) -> void:
	var player: PlayerController = world.get_node("Player")
	var harness: HarnessController = player.get_node("HarnessController")
	var trap: MalfunctioningTrap = world.get_node("%MalfunctioningTrap")
	await _walk(player, Vector2(100, -325))
	_tap(KEY_Q)
	await _frames(4)
	_expect(harness.get_current_charge() == 2 and not trap.visible, "Opening gate revealed trap or charged incorrectly.")
	await _walk(player, Vector2(100, -440))
	await _walk(player, Vector2(110, -520))
	_expect(world.get_map_state().get_discovered_region_count() == 1 and trap.visible, "Entry failed to reveal optional room.")
	for frame in range(600):
		if trap.get_phase() == MalfunctioningTrap.Phase.WARNING:
			break
		await _frames(1)
	_expect(trap.get_phase() == MalfunctioningTrap.Phase.WARNING and harness.get_basic_analysis().contains("함정 경고"), "Trap warning unavailable.")
	_tap(KEY_Q)
	await _frames(4)
	_expect(trap.get_phase() == MalfunctioningTrap.Phase.STABILIZED and harness.get_current_charge() == 1, "Trap did not share entrance charge budget.")
	await _capture("g3-trap-response.png")
	await _walk(player, Vector2(260, -520))
	await _walk(player, Vector2(110, -520))
	_expect(world.get_node("%ExplorationRun").is_active(), "Stabilized trap could not be crossed with cargo.")
	await _walk(player, Vector2(100, -440))
	await _walk(player, Vector2(100, -200))


func _capture(filename: String) -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--g3-render-directory="):
			var directory := argument.trim_prefix("--g3-render-directory=")
			DirAccess.make_dir_recursive_absolute(directory)
			await RenderingServer.frame_post_draw
			_expect(get_viewport().get_texture().get_image().save_png(directory.path_join(filename)) == OK, "Screenshot failed.")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		GameLog.error(&"SmokeTest", &"g3_exploration_flow_failed", message)
