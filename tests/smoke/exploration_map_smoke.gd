extends Node

const WORLD := preload("res://src/app/prototype_exploration.tscn")
const MAP := preload("res://src/data/prototype_exploration_map.tres")
const MOVE_ACTIONS := [InputActions.MOVE_LEFT, InputActions.MOVE_RIGHT, InputActions.MOVE_UP, InputActions.MOVE_DOWN]

var _failures := PackedStringArray()


func _ready() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	_check_state_boundary()
	var world: PrototypeExploration = WORLD.instantiate()
	add_child(world)
	await _frames(4)
	var panel: ExplorationMapPanel = world.get_node("%ExplorationMapPanel")
	var inventory: InventoryPanel = world.get_node("%InventoryPanel")
	var player: PlayerController = world.get_node("Player")
	var golem: BrokenGuardGolem = world.get_node("%BrokenGuardGolem")
	var state := world.get_map_state()
	_press_key(KEY_M)
	panel.open_map()
	await _frames(2)
	_expect(not panel.visible and not get_tree().paused and state.get_visited_count() == 0, "Map opened or recorded visits before departure.")
	_expect(world.prepare_departure(_loadout()) and world.start_exploration(), "Exploration could not start.")
	await _frames(3)
	_expect(state.get_current_region_id() == &"prototype_entry" and state.get_visited_count() == 1, "Entrance was not the only initially visited region.")
	world.get_node("%HarnessStatus/%AnalyzeButton").grab_focus()
	_press_key(KEY_M)
	await _frames(3)
	_expect(panel.visible and get_tree().paused, "M with HUD focus did not pause and open map.")
	_expect(Rect2(0, 0, 1152, 648).encloses(panel.get_node("Center/Card").get_global_rect()), "Map card exceeds base viewport.")
	var player_before := player.position
	var golem_before := golem.position
	Input.action_press(InputActions.MOVE_RIGHT)
	_press_key(KEY_E)
	_press_key(KEY_Q)
	await _frames(30)
	Input.action_release(InputActions.MOVE_RIGHT)
	_expect(player.position.is_equal_approx(player_before) and golem.position.is_equal_approx(golem_before), "Map did not pause player and golem.")
	_expect(state.get_visited_count() == 1, "Map revealed unvisited regions.")
	_expect(world.get_node("Player/HarnessController").get_current_charge() == 3, "Map allowed harness use.")
	await _capture(panel, "map-entry.png")
	_press_key(KEY_M)
	await _frames(3)
	_expect(not panel.visible and not get_tree().paused, "M did not close focused map.")
	await _walk(player, Vector2(-500, -200))
	await _walk(player, Vector2(-230, -200))
	_expect(state.is_visited(&"prototype_north") and not state.is_visited(&"prototype_south"), "Actual movement did not update only the visited region.")
	_expect(state.get_current_region_id() == &"prototype_north", "Current map region did not follow the player.")
	_press_key(KEY_E)
	_expect(await InteractionTestInput.wait_for_work(player), "Timed action did not finish.")
	await _frames(3)
	_press_key(KEY_TAB)
	await _frames(3)
	_expect(inventory.visible and get_tree().paused, "Inventory failed before switching to map.")
	# Opening the map cancels an unconfirmed discard; switching must not lose a pause.
	_click(inventory.get_node("%DropButton"))
	await _frames(3)
	_expect(inventory.get_node("%DropConfirmation").visible, "Discard confirmation did not open.")
	panel.open_map()
	await _frames(3)
	_expect(panel.visible and not inventory.visible and not inventory.get_node("%DropConfirmation").visible and get_tree().paused, "Map failed to close inventory/confirmation safely.")
	_expect(world.get_node("Player/Inventory").get_used_slots() == 1, "Switching screens discarded an item.")
	_press_key(KEY_TAB)
	await _frames(3)
	_expect(inventory.visible and not panel.visible and get_tree().paused, "Tab from map did not switch to inventory.")
	_press_key(KEY_M)
	await _frames(3)
	_expect(panel.visible and not inventory.visible and get_tree().paused, "M from inventory did not switch to map.")
	_press_key(KEY_ESCAPE)
	await _frames(3)
	_expect(not panel.visible and not get_tree().paused, "Esc did not restore exploration after switching.")
	_press_key(KEY_M)
	await _frames(3)
	_click(panel.get_node("%CloseMapButton"))
	await _frames(3)
	_expect(not panel.visible and not get_tree().paused, "Mouse close did not restore exploration.")
	await _walk(player, Vector2(630, -200))
	await _walk(player, Vector2(630, 220))
	await _walk(player, Vector2(440, 220))
	_expect(state.get_visited_count() == 4, "Exploration did not record all four regions.")
	_press_key(KEY_M)
	await _frames(3)
	await _capture(panel, "map-visited.png")
	_press_key(KEY_ESCAPE)
	await _frames(2)
	# A menu that opens over an existing pause must preserve that pause on close.
	get_tree().paused = true
	panel.open_map()
	panel.close_map()
	_expect(get_tree().paused, "Closing map erased a pre-existing pause.")
	get_tree().paused = false
	panel.open_map()
	world.get_node("%ExplorationRun").complete_failure()
	await _frames(3)
	_expect(not panel.visible and not get_tree().paused, "Ending exploration with map open left a hidden pause.")
	_press_key(KEY_M)
	await _frames(2)
	_expect(not panel.visible and not get_tree().paused, "Finished exploration reopened its map.")
	world.queue_free()
	await _frames(3)
	var next_world: PrototypeExploration = WORLD.instantiate()
	add_child(next_world)
	await _frames(3)
	_expect(next_world.prepare_departure(_loadout()) and next_world.start_exploration(), "A fresh departure failed.")
	await _frames(3)
	_expect(next_world.get_map_state().get_visited_count() == 1 and not next_world.get_map_state().is_visited(&"prototype_north"), "Prototype visit state leaked into another departure.")
	var next_panel: ExplorationMapPanel = next_world.get_node("%ExplorationMapPanel")
	next_panel.open_map()
	next_world.queue_free()
	await _frames(3)
	_expect(not get_tree().paused, "Deleting an open map left the tree paused.")
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"exploration_map_passed")
	get_tree().quit(0 if _failures.is_empty() else 1)


func _check_state_boundary() -> void:
	var definition := MAP.duplicate(true) as ExplorationMapDefinition
	var state := ExplorationMapState.new()
	_expect(state.configure(definition), "Valid public map rejected.")
	definition.regions[0].display_name = "changed"
	_expect(state.get_definition().regions[0].display_name == "입구", "External definition mutation changed map state.")
	var copy := state.get_definition()
	copy.regions[0].bounds = Rect2(0, 0, 1, 1)
	_expect(state.get_definition().regions[0].bounds != copy.regions[0].bounds, "Map query returned a shared definition.")
	state.observe_position(Vector2(-650, 0))
	state.observe_position(Vector2(-650, 0))
	state.observe_position(Vector2(NAN, 0))
	_expect(state.get_visited_count() == 1 and state.get_current_region_id() == &"prototype_entry", "Repeated or invalid positions changed visits.")
	_expect(not state.configure(MAP), "Map state was reconfigured during a visit.")
	var invalid := MAP.duplicate(true) as ExplorationMapDefinition
	invalid.regions[1].stable_id = invalid.regions[0].stable_id
	_expect(not ExplorationMapState.new().configure(invalid), "Duplicate region IDs were accepted.")
	_expect(not ExplorationMapState.new().configure(null), "Missing map data was accepted.")


func _loadout() -> ExpeditionLoadout:
	var loadout := ExpeditionLoadout.new()
	loadout.slot_capacity = 2
	loadout.burden_weight = 2.5
	loadout.overload_weight = 4.0
	loadout.charge_capacity = 3
	loadout.starting_charge = 3
	return loadout


func _capture(panel: ExplorationMapPanel, filename: String) -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--map-render-directory="):
			var directory := argument.trim_prefix("--map-render-directory=")
			DirAccess.make_dir_recursive_absolute(directory)
			await RenderingServer.frame_post_draw
			_expect(panel.get_viewport().get_texture().get_image().save_png(directory.path_join(filename)) == OK, "Map capture failed.")


func _walk(player: PlayerController, destination: Vector2) -> void:
	for frame in range(720):
		var offset := destination - player.global_position
		if offset.length() < 7.0:
			_release_movement()
			await _frames(3)
			return
		_release_movement()
		if absf(offset.x) > 3.0:
			Input.action_press(InputActions.MOVE_RIGHT if offset.x > 0.0 else InputActions.MOVE_LEFT)
		if absf(offset.y) > 3.0:
			Input.action_press(InputActions.MOVE_DOWN if offset.y > 0.0 else InputActions.MOVE_UP)
		await get_tree().physics_frame
	_release_movement()
	_expect(false, "Route blocked before %s." % destination)


func _release_movement() -> void:
	for action in MOVE_ACTIONS:
		Input.action_release(action)


func _click(button: Button) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = button.get_global_rect().get_center()
	event.pressed = true
	get_viewport().push_input(event)
	event = event.duplicate() as InputEventMouseButton
	event.pressed = false
	get_viewport().push_input(event)


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
		GameLog.error(&"SmokeTest", &"exploration_map_failed", message)
