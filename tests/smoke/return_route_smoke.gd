extends Node

const WORLD := preload("res://src/app/prototype_exploration.tscn")
const PANEL := preload("res://src/ui/return_route_status.tscn")
const MAP := preload("res://src/data/prototype_exploration_map.tres")
const MOVES := [InputActions.MOVE_LEFT, InputActions.MOVE_RIGHT, InputActions.MOVE_UP, InputActions.MOVE_DOWN]

var _failures := PackedStringArray()


func _ready() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	await _check_view_boundary()
	await _check_exploration()
	await _check_new_visit()
	_release()
	get_tree().paused = false
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"return_route_passed")
	get_tree().quit(0 if _failures.is_empty() else 1)


func _check_view_boundary() -> void:
	var panel := PANEL.instantiate() as ReturnRouteStatus
	add_child(panel)
	panel.bind_map(ExplorationMapState.new())
	panel.set_active(true)
	panel.refresh(Transform2D.IDENTITY, false)
	_expect(not panel.visible and panel.get_direction_text().is_empty(), "Unconfigured map displayed a route.")
	var state := ExplorationMapState.new()
	state.configure(MAP)
	panel.bind_map(state)
	panel.set_active(true)
	var directions := [Vector2.RIGHT, Vector2(1, 1), Vector2.DOWN, Vector2(-1, 1), Vector2.LEFT, Vector2(-1, -1), Vector2.UP, Vector2(1, -1)]
	var names := ["오른쪽", "오른쪽 아래", "아래", "왼쪽 아래", "왼쪽", "왼쪽 위", "위", "오른쪽 위"]
	for index in directions.size():
		state.observe_position(MAP.entrance_position - directions[index] * 40.0)
		var before := _signature(state)
		panel.refresh(Transform2D.IDENTITY, false)
		_expect(panel.get_direction_text() == "입구 방향 · %s" % names[index], "Eight-way direction label wrong.")
		_expect(panel.get_arrow_direction().is_equal_approx(directions[index].normalized()), "Arrow disagreed with entrance bearing.")
		_expect(before == _signature(state), "Rendering mutated public map state.")
	state.observe_position(MAP.entrance_position - Vector2.RIGHT * 40.0)
	panel.refresh(Transform2D(PI / 2.0, Vector2(900, -400)), false)
	_expect(panel.get_direction_text() == "입구 방향 · 아래", "Camera rotation/translation was ignored.")
	panel.refresh(Transform2D(Vector2(-2, 0), Vector2(0, 0.5), Vector2.ZERO), false)
	_expect(panel.get_direction_text() == "입구 방향 · 왼쪽", "Mirrored/scaled view gave wrong direction.")
	state.observe_position(MAP.entrance_position)
	panel.refresh(Transform2D.IDENTITY, false)
	_expect(panel.get_arrow_direction() == Vector2.ZERO and not panel.get_node("%Arrow").visible, "Zero direction produced a misleading arrow.")
	_expect(not panel.get_direction_text().contains("귀환 가능"), "Coordinate alone claimed return availability.")
	panel.refresh(Transform2D.IDENTITY, true)
	_expect(panel.get_direction_text().contains("E로 귀환 가능"), "Actual return availability not shown.")
	var other := ExplorationMapState.new()
	other.configure(MAP)
	panel.bind_map(other)
	_expect(not panel.visible and panel.get_passage_text().is_empty(), "Rebinding kept old display.")
	panel.bind_map(null)
	panel.set_active(true)
	panel.refresh(Transform2D.IDENTITY, true)
	_expect(not panel.visible, "Unbound panel displayed return availability.")
	panel.queue_free()
	await _frames(3)


func _new_world() -> PrototypeExploration:
	var world := WORLD.instantiate() as PrototypeExploration
	add_child(world)
	await _frames(3)
	var panel: ReturnRouteStatus = world.get_node("%ReturnRouteStatus")
	_expect(not panel.visible and panel.get_direction_text().is_empty(), "Route displayed before departure.")
	var loadout := ExpeditionLoadout.new()
	loadout.slot_capacity = 3
	loadout.burden_weight = 2.5
	loadout.overload_weight = 4.0
	loadout.charge_capacity = 3
	loadout.starting_charge = 3
	_expect(world.prepare_departure(loadout) and world.start_exploration(), "Departure failed.")
	await _frames(4)
	return world


func _check_exploration() -> void:
	var world := await _new_world()
	var panel: ReturnRouteStatus = world.get_node("%ReturnRouteStatus")
	var player: PlayerController = world.get_node("Player")
	var state := world.get_map_state()
	_expect(panel.visible and panel.get_passage_text().contains("미확인 3"), "Departure disclosed remote passages.")
	_expect(panel.get_direction_text().contains("E로 귀환 가능"), "Nearby exit did not match interaction selection.")
	_expect(not panel.get_global_rect().intersects(_polygon_screen_rect(world.get_node("RiskHazard/WarningGlow"))), "Route panel obscures collapse warning.")
	var risk_label: Label = world.get_node("RiskLabel")
	_expect(not panel.get_global_rect().intersects(risk_label.get_global_transform_with_canvas() * Rect2(Vector2.ZERO, risk_label.size)), "Route panel obscures lower path label.")
	await _capture("return-at-entry.png")
	await _walk(player, Vector2(-500, 200))
	_expect(not panel.get_global_rect().intersects(_polygon_screen_rect(player.get_node("Body"))), "Route panel obscures player on lower path.")
	await _capture("return-lower-path.png")
	await _walk(player, Vector2(-500, -200))
	_expect(panel.get_direction_text() == "입구 방향 · 왼쪽 아래", "Real movement did not update direction.")
	_expect(panel.get_passage_text().contains("열림 1") and panel.get_passage_text().contains("미확인 2"), "Nearby open passage not reflected.")
	for key in [KEY_TAB, KEY_M]:
		_tap(key)
		await _frames(3)
		var before := _signature(state)
		var text := panel.get_direction_text()
		Input.action_press(InputActions.MOVE_RIGHT)
		await _frames(20)
		_release()
		_expect(get_tree().paused and not panel.visible and before == _signature(state) and panel.get_direction_text() == text, "Menu failed to hide/freeze route.")
		_tap(key)
		await _frames(4)
		_expect(panel.visible and not get_tree().paused, "Route did not resume after menu.")
	await _walk(player, Vector2(60, -200))
	await _walk(player, Vector2(60, -145))
	_expect(panel.get_passage_text().contains("막힘 1") and panel.get_passage_text().contains("미확인 1"), "Blocked central passage not recorded.")
	await _walk(player, Vector2(60, -200))
	await _walk(player, Vector2(628, -200))
	await _walk(player, Vector2(628, -70))
	_tap(KEY_E)
	await _frames(5)
	var door: TemporaryDoor = world.get_node("%RetreatDoor")
	_expect(not door.is_open and panel.get_passage_text().contains("막힘 2") and panel.get_passage_text().contains("미확인 0"), "Actual door closing not reflected by observation.")
	await _capture("return-observed-door.png")
	await _walk(player, Vector2(628, -220))
	var recorded := panel.get_passage_text()
	# Test-only remote world change models a door changing outside observation range.
	_expect(door.interact(self), "Remote door test setup failed.")
	await _frames(6)
	_expect(door.is_open and panel.get_passage_text() == recorded, "HUD revealed remote live door state.")
	_tap(KEY_M)
	await _frames(3)
	_expect(world.get_node("%ExplorationMapPanel").get_passage_summary_text().contains("막힘 2"), "HUD/map observation records disagree.")
	_tap(KEY_ESCAPE)
	await _frames(4)
	_expect(panel.get_passage_text() == recorded, "Reopening HUD disclosed remote changes.")
	await _walk(player, Vector2(628, -145))
	_expect(panel.get_passage_text().contains("열림 2") and panel.get_passage_text().contains("막힘 1"), "Re-observation did not refresh route record.")
	await _walk(player, Vector2(628, -200))
	await _walk(player, Vector2(100, -200))
	await _walk(player, Vector2(100, -325))
	var discovered := state.get_discovered_region_count()
	_expect(discovered == 0, "HUD revealed a hidden region.")
	_tap(KEY_Q)
	await _frames(4)
	await _walk(player, Vector2(100, -520))
	_expect(state.get_discovered_region_count() == 1, "Optional room entry failed.")
	_expect(world.get_node("OverviewCamera").position.y < -400.0 and panel.visible, "Camera-follow route disappeared.")
	_expect(panel.get_direction_text() == "입구 방향 · 왼쪽 아래", "Optional room bearing wrong.")
	var expected := (world.get_global_transform_with_canvas().basis_xform(MAP.entrance_position - player.position)).normalized()
	_expect(panel.get_arrow_direction().is_equal_approx(expected), "Arrow ignored current camera transform.")
	await _capture("return-from-remaining-room.png")
	for window_size in [Vector2i(1600, 900), Vector2i(1152, 648)]:
		get_tree().root.size = window_size
		await _frames(5)
		var viewport := Rect2(Vector2.ZERO, get_viewport().get_visible_rect().size)
		_expect(viewport.encloses(panel.get_global_rect()), "Route panel outside viewport.")
		_expect(not panel.get_global_rect().intersects(world.get_node("%InteractionPrompt").get_global_rect()), "Route overlaps interaction prompt.")
		_expect(not panel.get_global_rect().intersects(world.get_node("%QuickDropStatus").get_global_rect()), "Route overlaps inventory hint.")
		if window_size.x == 1600:
			await _capture("return-wide.png")
	_tap(KEY_M)
	await _frames(3)
	world.get_node("%ExplorationRun").complete_failure()
	await _frames(4)
	_expect(not get_tree().paused and not panel.visible and panel.get_direction_text().is_empty() and panel.get_passage_text().is_empty(), "Failed expedition kept route display.")
	world.queue_free()
	await _frames(3)


func _check_new_visit() -> void:
	var world := await _new_world()
	var panel: ReturnRouteStatus = world.get_node("%ReturnRouteStatus")
	_expect(panel.get_passage_text().contains("미확인 3") and world.get_map_state().get_discovered_region_count() == 0, "New visit retained route observations.")
	_tap(KEY_E)
	await _frames(4)
	_expect(world.get_node("%ExplorationRun").get_state() == ExplorationRun.State.SAFE_RETURN, "Return indication did not correspond to actual exit action.")
	_expect(not panel.visible and panel.get_direction_text().is_empty(), "Returned expedition kept route display.")
	world.queue_free()
	await _frames(3)


func _signature(state: ExplorationMapState) -> Array:
	return [state.get_player_position(), state.get_current_region_id(), state.get_visited_count(), state.get_observed_passage_count(), state.get_passage_count_by_status(ExplorationMapState.PassageStatus.OPEN), state.get_passage_count_by_status(ExplorationMapState.PassageStatus.BLOCKED), state.get_markers(), state.get_clues().size(), state.get_discovered_region_count()]


func _polygon_screen_rect(polygon: Polygon2D) -> Rect2:
	var transform := polygon.get_global_transform_with_canvas()
	var bounds := Rect2(transform * polygon.polygon[0], Vector2.ZERO)
	for point in polygon.polygon:
		bounds = bounds.expand(transform * point)
	return bounds


func _walk(player: PlayerController, target: Vector2) -> void:
	for index in range(720):
		var offset := target - player.position
		_release()
		if offset.length() < 6.0:
			await _frames(4)
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
		if argument.begins_with("--return-render-directory="):
			var directory := argument.trim_prefix("--return-render-directory=")
			DirAccess.make_dir_recursive_absolute(directory)
			await RenderingServer.frame_post_draw
			_expect(get_viewport().get_texture().get_image().save_png(directory.path_join(filename)) == OK, "Screenshot failed.")


func _frames(count: int) -> void:
	for index in range(count):
		await get_tree().physics_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		GameLog.error(&"SmokeTest", &"return_route_failed", message)
