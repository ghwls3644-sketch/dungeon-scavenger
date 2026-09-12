extends Node

const WORLD := preload("res://src/app/prototype_exploration.tscn")
const MAP := preload("res://src/data/prototype_exploration_map.tres")

var _failures := PackedStringArray()


func _ready() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	_check_state_boundary()
	var world: PrototypeExploration = WORLD.instantiate()
	add_child(world)
	await _frames(4)
	var state := world.get_map_state()
	var panel: ExplorationMapPanel = world.get_node("%ExplorationMapPanel")
	var canvas: ExplorationMapCanvas = panel.get_node("%MapCanvas")
	var edit: Button = panel.get_node("%EditMarkersButton")
	var inventory: InventoryPanel = world.get_node("%InventoryPanel")
	var player: PlayerController = world.get_node("Player")
	var golem: BrokenGuardGolem = world.get_node("%BrokenGuardGolem")
	_press_key(KEY_M)
	_expect(not panel.visible and state.get_marker_count() == 0, "Map accepted editing before departure.")
	_expect(world.prepare_departure(_loadout()) and world.start_exploration(), "Could not start marker exploration.")
	await _frames(3)
	_press_key(KEY_M)
	await _frames(3)
	var target := Vector2(260, 180)
	_click_map(canvas, target)
	_expect(state.get_marker_count() == 0, "Map added a note without entering edit mode.")
	_click_at(edit.get_global_rect().get_center())
	await _frames(2)
	_expect(edit.button_pressed, "Real mouse input did not enable editing.")
	_click_map(canvas, target)
	await _frames(2)
	_expect(state.get_marker_count() == 1, "Real map click did not add a note.")
	var markers := state.get_markers()
	if not markers.is_empty():
		_expect((markers.values()[0] as Vector2).distance_to(target) < 0.1, "Map click used incorrect world coordinates.")
	_expect(panel.get_node("%MarkerSummary").text.contains("1개"), "Marker count did not update while open.")
	_expect(state.get_visited_count() == 1 and not state.is_visited(&"prototype_south") and state.get_observed_passage_count() == 0, "Personal note disclosed visits or passages.")
	_click_at(canvas.global_position + Vector2(1, 1))
	_expect(state.get_marker_count() == 1, "Map margin accepted a note.")
	_click_map(canvas, target, MOUSE_BUTTON_RIGHT)
	_expect(state.get_marker_count() == 1, "Unassigned mouse button edited a note.")
	_click_map(canvas, target + Vector2(10, 0))
	await _frames(2)
	_expect(state.get_marker_count() == 0, "Clicking near the visible note did not delete it.")
	_click_map(canvas, target)
	_click_map(canvas, Vector2(-570, 170))
	_click_map(canvas, Vector2(400, -120))
	await _frames(3)
	_expect(state.get_marker_count() == 3, "Multiple personal notes were not independent.")
	_expect(Rect2(0, 0, 1152, 648).encloses(panel.get_node("Center/Card").get_global_rect()), "Map card exceeds base viewport.")
	var player_before := player.position
	var golem_before := golem.position
	var charge_before: int = world.get_node("Player/HarnessController").get_current_charge()
	Input.action_press(InputActions.MOVE_RIGHT)
	_press_key(KEY_E)
	_press_key(KEY_Q)
	await _frames(20)
	Input.action_release(InputActions.MOVE_RIGHT)
	_expect(get_tree().paused and player.position.is_equal_approx(player_before) and golem.position.is_equal_approx(golem_before), "Marker editing did not pause exploration.")
	_expect(world.get_node("Player/HarnessController").get_current_charge() == charge_before, "Marker editing allowed harness use.")
	await _capture("markers-editing.png")
	_press_key(KEY_M)
	await _frames(2)
	_expect(not panel.visible and not get_tree().paused and not edit.button_pressed, "Closing with M did not exit edit mode and restore time.")
	# Hidden GUI cannot mutate the retained state.
	_click_map(canvas, Vector2(100, 260))
	_expect(state.get_marker_count() == 3, "Hidden map accepted marker input.")
	_press_key(KEY_M)
	await _frames(3)
	_expect(state.get_marker_count() == 3 and not edit.button_pressed, "Reopening lost notes or kept accidental edit mode.")
	_click_map(canvas, Vector2(100, 260))
	_expect(state.get_marker_count() == 3, "Reopened map edited without explicit mode.")
	await _capture("markers-viewing.png")
	_click_at(edit.get_global_rect().get_center())
	_press_key(KEY_TAB)
	await _frames(3)
	_expect(inventory.visible and not panel.visible and get_tree().paused and not edit.button_pressed, "Inventory did not safely take over the editing pause.")
	_press_key(KEY_M)
	await _frames(3)
	_expect(panel.visible and not inventory.visible and state.get_marker_count() == 3, "Returning from inventory lost markers.")
	# Verify projection and picking again after an actual viewport size change.
	get_tree().root.size = Vector2i(1600, 900)
	await _frames(4)
	_click_at(edit.get_global_rect().get_center())
	_click_map(canvas, Vector2(100, 260))
	await _frames(2)
	_expect(state.get_marker_count() == 4, "Resized map did not place a note.")
	_click_map(canvas, Vector2(100, 260))
	await _frames(2)
	_expect(state.get_marker_count() == 3, "Resized map did not remove the chosen note.")
	_expect(Rect2(Vector2.ZERO, get_viewport().get_visible_rect().size).encloses(panel.get_node("Center/Card").get_global_rect()), "Resized map exceeds viewport.")
	await _capture("markers-resized.png")
	get_tree().root.size = Vector2i(1152, 648)
	await _frames(4)
	_press_key(KEY_ESCAPE)
	_expect(not panel.visible and not get_tree().paused, "Esc did not close editing.")
	get_tree().paused = true
	panel.open_map()
	_click_at(edit.get_global_rect().get_center())
	panel.close_map()
	_expect(get_tree().paused, "Marker UI erased an existing pause.")
	get_tree().paused = false
	panel.open_map()
	_click_at(edit.get_global_rect().get_center())
	world.get_node("%ExplorationRun").complete_failure()
	await _frames(3)
	_expect(not panel.visible and not get_tree().paused and not edit.button_pressed, "Failure left editing or a hidden pause active.")
	_press_key(KEY_M)
	_expect(not panel.visible and state.get_marker_count() == 3, "Ended exploration allowed editing.")
	world.queue_free()
	await _frames(3)
	var next_world: PrototypeExploration = WORLD.instantiate()
	add_child(next_world)
	await _frames(3)
	_expect(next_world.prepare_departure(_loadout()) and next_world.start_exploration(), "New departure failed.")
	await _frames(3)
	_expect(next_world.get_map_state().get_marker_count() == 0, "Personal notes leaked into a new departure.")
	var next_panel: ExplorationMapPanel = next_world.get_node("%ExplorationMapPanel")
	next_panel.open_map()
	_click_at(next_panel.get_node("%EditMarkersButton").get_global_rect().get_center())
	next_world.queue_free()
	await _frames(3)
	_expect(not get_tree().paused, "Removing an editing map left a hidden pause.")
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"map_marker_passed")
	get_tree().quit(0 if _failures.is_empty() else 1)


func _check_state_boundary() -> void:
	var state := ExplorationMapState.new()
	_expect(state.add_marker(Vector2.ZERO) == -1 and not state.remove_marker(1), "Unconfigured state accepted notes.")
	_expect(state.configure(MAP), "Map definition rejected.")
	var bounds: Rect2 = MAP.bounds
	_expect(state.add_marker(Vector2(NAN, 0)) == -1 and state.add_marker(Vector2(INF, 0)) == -1, "Non-finite note accepted.")
	_expect(state.add_marker(bounds.position - Vector2.ONE) == -1 and state.add_marker(bounds.end) == -1, "Out-of-map note accepted.")
	var marker_id := state.add_marker(Vector2(100, 200))
	_expect(marker_id > 0 and state.add_marker(Vector2(100, 200)) == marker_id and state.get_marker_count() == 1, "Duplicate note created a second ID.")
	var copy := state.get_markers()
	copy[marker_id] = Vector2.ZERO
	copy.clear()
	_expect(state.get_marker_count() == 1 and state.get_markers()[marker_id] == Vector2(100, 200), "Query leaked mutable marker state.")
	_expect(state.get_visited_count() == 0 and state.get_observed_passage_count() == 0 and state.get_player_position() == Vector2.ZERO, "Adding a note changed observations.")
	_expect(not state.remove_marker(-1) and not state.remove_marker(999) and state.get_marker_count() == 1, "Invalid deletion changed another note.")
	_expect(state.remove_marker(marker_id) and not state.remove_marker(marker_id), "Note deletion was not exact.")
	_expect(state.add_marker(Vector2(200, 200)) > marker_id, "Deleted note ID was reused.")
	_expect(state.add_marker(bounds.position) > 0, "Valid map boundary rejected.")
	_expect(ExplorationMapState.new().get_marker_count() == 0, "Marker state shared between visits.")


func _click_map(canvas: ExplorationMapCanvas, world_position: Vector2, button: MouseButton = MOUSE_BUTTON_LEFT) -> void:
	_click_at(canvas.get_global_transform() * canvas.world_to_map(world_position), button)


func _click_at(position: Vector2, button: MouseButton = MOUSE_BUTTON_LEFT) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = button
	event.position = position
	event.pressed = true
	get_viewport().push_input(event)
	event = event.duplicate() as InputEventMouseButton
	event.pressed = false
	get_viewport().push_input(event)


func _loadout() -> ExpeditionLoadout:
	var loadout := ExpeditionLoadout.new()
	loadout.slot_capacity = 2
	loadout.burden_weight = 2.5
	loadout.overload_weight = 4.0
	loadout.charge_capacity = 3
	loadout.starting_charge = 3
	return loadout


func _capture(filename: String) -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--marker-render-directory="):
			var directory := argument.trim_prefix("--marker-render-directory=")
			DirAccess.make_dir_recursive_absolute(directory)
			await RenderingServer.frame_post_draw
			_expect(get_viewport().get_texture().get_image().save_png(directory.path_join(filename)) == OK, "Marker capture failed.")


func _press_key(key: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = key
	event.physical_keycode = key
	event.pressed = true
	get_viewport().push_input(event)
	var release := event.duplicate() as InputEventKey
	release.pressed = false
	get_viewport().push_input(release)


func _frames(count: int) -> void:
	for index in range(count):
		await get_tree().physics_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		GameLog.error(&"SmokeTest", &"map_marker_failed", message)
