extends Node

const WORLD := preload("res://src/app/prototype_exploration.tscn")
const MAP := preload("res://src/data/prototype_exploration_map.tres")
const CLUE := preload("res://src/data/prototype_map_clue.tres")
const MOVE_ACTIONS := [InputActions.MOVE_LEFT, InputActions.MOVE_RIGHT, InputActions.MOVE_UP, InputActions.MOVE_DOWN]

var _failures := PackedStringArray()


func _ready() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	_check_state_boundary()
	var world: PrototypeExploration = WORLD.instantiate()
	add_child(world)
	await _frames(4)
	var state := world.get_map_state()
	var source: MapClueInteractable = world.get_node("%MapClue")
	var player: PlayerController = world.get_node("Player")
	var panel: ExplorationMapPanel = world.get_node("%ExplorationMapPanel")
	var canvas: ExplorationMapCanvas = panel.get_node("%MapCanvas")
	var clue_button: Button = panel.get_node("%CluesButton")
	var clue_view: Control = panel.get_node("%ClueView")
	var clue_text: RichTextLabel = panel.get_node("%ClueText")
	var inventory_panel: InventoryPanel = world.get_node("%InventoryPanel")
	var inventory: PlayerInventory = world.get_node("Player/Inventory")
	_expect(not source.interact(player) and not source.is_interaction_available(), "Clue readable before departure.")
	_expect(world.prepare_departure(_loadout()) and world.start_exploration(), "Clue exploration could not start.")
	await _frames(3)
	_expect(state.get_clues().is_empty(), "Unread clue recorded on departure.")
	_press_key(KEY_M)
	await _frames(2)
	_expect(clue_button.text.contains("0") and not clue_text.text.contains(CLUE.hint_text), "Unread clue leaked to the map.")
	_click(clue_button)
	await _frames(2)
	_expect(clue_view.visible and not canvas.visible and clue_text.text == "아직 살펴본 단서가 없습니다.", "Empty clue page exposed hidden content.")
	_press_key(KEY_E)
	_expect(state.get_clues().is_empty(), "Paused input acquired a distant clue.")
	await _capture("clues-unread.png")
	_press_key(KEY_ESCAPE)
	await _walk(player, Vector2(-570, 140))
	var controller: InteractionController = world.get_node("Player/InteractionController")
	_expect(controller.get_current_prompt() == "손상된 공략도 살펴보기 · 0.8초", "Nearby clue or its duration was not shown.")
	_expect(state.get_clues().is_empty(), "Proximity alone revealed the clue.")
	_expect(not source.interact(null), "Missing reader acquired a clue.")
	_press_key(KEY_E)
	_expect(await InteractionTestInput.wait_for_work(player), "Timed action did not finish.")
	await _frames(3)
	_expect(state.has_clue(CLUE.stable_id) and state.get_clues().size() == 1, "Actual E input did not record a clue.")
	_expect(world.get_node("%ChoiceStatus").text.contains(CLUE.hint_text), "First observation did not display its short hint.")
	_expect(controller.get_current_prompt() == "단서 다시 읽기 · 0.8초", "Read prompt/duration did not refresh.")
	_expect(not get_tree().paused and inventory.get_used_slots() == 0, "Looking at a clue forced a menu or created a carried item.")
	_expect(state.get_visited_count() == 1 and not state.is_visited(&"prototype_north"), "Clue marked an unseen region as visited.")
	_expect(state.get_observed_passage_count() == 0 and state.get_marker_count() == 0, "Clue supplied a passage answer or exact marker.")
	_expect(state.get_definition().regions.size() == MAP.regions.size(), "Clue added a hidden destination to the public map.")
	await _capture("clue-observed.png")
	_press_key(KEY_E)
	_expect(await InteractionTestInput.wait_for_work(player), "Timed action did not finish.")
	await _frames(2)
	_expect(state.get_clues().size() == 1, "Re-reading duplicated a clue.")
	_press_key(KEY_M)
	await _frames(3)
	_expect(clue_button.text.contains("1"), "Map did not refresh its observed clue count.")
	_click(panel.get_node("%EditMarkersButton"))
	_expect(panel.get_node("%EditMarkersButton").button_pressed, "Could not enter marker mode.")
	_click(clue_button)
	await _frames(2)
	_expect(clue_view.visible and not canvas.visible and get_tree().paused, "Clue page did not replace map under pause.")
	_expect(panel.get_node("%EditMarkersButton").disabled and not panel.get_node("%EditMarkersButton").button_pressed, "Clue page left marker editing active.")
	_expect(clue_text.text == "%s\n%s" % [CLUE.display_name, CLUE.hint_text], "Read page does not match acquired information.")
	_expect(not clue_text.bbcode_enabled, "Clue text can be interpreted as UI markup.")
	canvas.marker_requested.emit(Vector2(600, 200), -1)
	_expect(state.get_marker_count() == 0, "Hidden map edited markers on the clue page.")
	var player_before := player.position
	var golem: Node2D = world.get_node("%BrokenGuardGolem")
	var golem_before := golem.position
	Input.action_press(InputActions.MOVE_RIGHT)
	_press_key(KEY_E)
	_press_key(KEY_Q)
	await _frames(20)
	Input.action_release(InputActions.MOVE_RIGHT)
	_expect(player.position.is_equal_approx(player_before) and golem.position.is_equal_approx(golem_before), "Clue page did not pause gameplay.")
	_expect(not source.interact(player) and world.get_node("Player/HarnessController").get_current_charge() == 3, "Clue page allowed world actions.")
	_expect(Rect2(0, 0, 1152, 648).encloses(panel.get_node("Center/Card").get_global_rect()), "Clue page exceeds base viewport.")
	await _capture("clues-recorded.png")
	_click(clue_button)
	await _frames(2)
	_expect(canvas.visible and not clue_view.visible and get_tree().paused, "Map return lost pause or did not restore map.")
	_click(clue_button)
	_press_key(KEY_TAB)
	await _frames(3)
	_expect(inventory_panel.visible and not panel.visible and get_tree().paused, "Bag did not take over clue-page pause.")
	_press_key(KEY_M)
	await _frames(3)
	_expect(panel.visible and canvas.visible and not clue_view.visible and not inventory_panel.visible, "Reopening map retained a hidden clue view.")
	_click(clue_button)
	await _frames(2)
	_expect(clue_text.text.contains(CLUE.hint_text) and state.get_clues().size() == 1, "Menu switching lost recorded information.")
	get_tree().root.size = Vector2i(1600, 900)
	await _frames(4)
	_expect(Rect2(Vector2.ZERO, get_viewport().get_visible_rect().size).encloses(panel.get_node("Center/Card").get_global_rect()), "Resized clue page exceeds viewport.")
	await _capture("clues-resized.png")
	get_tree().root.size = Vector2i(1152, 648)
	await _frames(3)
	_click(panel.get_node("%CloseMapButton"))
	await _frames(2)
	_expect(not panel.visible and not get_tree().paused, "Close button left clue page paused.")
	get_tree().paused = true
	panel.open_map()
	_click(clue_button)
	panel.close_map()
	_expect(get_tree().paused, "Clue page erased pre-existing pause.")
	get_tree().paused = false
	panel.open_map()
	_click(clue_button)
	world.get_node("%ExplorationRun").complete_failure()
	await _frames(3)
	_expect(not panel.visible and not get_tree().paused and not source.interact(player), "Failure left clue input or hidden pause active.")
	_press_key(KEY_M)
	_expect(not panel.visible, "Ended exploration reopened clue UI.")
	world.queue_free()
	await _frames(3)
	var next_world: PrototypeExploration = WORLD.instantiate()
	add_child(next_world)
	await _frames(3)
	_expect(next_world.get_map_state().get_clues().is_empty(), "Recorded clue leaked into a new departure.")
	_expect(next_world.prepare_departure(_loadout()) and next_world.start_exploration(), "New clue departure could not start.")
	await _frames(3)
	var next_player: PlayerController = next_world.get_node("Player")
	await _walk(next_player, Vector2(-570, 140))
	_press_key(KEY_E)
	_expect(await InteractionTestInput.wait_for_work(next_player), "Timed action did not finish.")
	await _frames(2)
	_expect(next_world.get_map_state().get_clues().size() == 1, "Clue cannot be observed again in a fresh prototype visit.")
	var next_panel: ExplorationMapPanel = next_world.get_node("%ExplorationMapPanel")
	next_panel.open_map()
	_click(next_panel.get_node("%CluesButton"))
	_expect(next_world.get_node("%ExplorationRun").complete_safe_return(), "Safe return failed after clue observation.")
	await _frames(2)
	_expect(not next_panel.visible and not get_tree().paused and not next_world.get_node("%MapClue").interact(next_player), "Safe return retained clue actions or pause.")
	next_world.queue_free()
	await _frames(3)
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"map_clue_passed")
	get_tree().quit(0 if _failures.is_empty() else 1)


func _check_state_boundary() -> void:
	var state := ExplorationMapState.new()
	_expect(not state.record_clue(CLUE), "Unconfigured map accepted clue data.")
	_expect(state.configure(MAP), "Map configuration failed.")
	_expect(not state.record_clue(null) and state.get_clue(&"missing") == null, "Missing clue accepted.")
	var invalid := CLUE.duplicate(true) as MapClueDefinition
	invalid.hint_text = "  "
	_expect(not state.record_clue(invalid), "Empty clue hint accepted.")
	invalid = CLUE.duplicate(true) as MapClueDefinition
	invalid.stable_id = &""
	_expect(not state.record_clue(invalid), "Empty clue ID accepted.")
	invalid = CLUE.duplicate(true) as MapClueDefinition
	invalid.display_name = ""
	_expect(not state.record_clue(invalid), "Empty clue title accepted.")
	var definition := CLUE.duplicate(true) as MapClueDefinition
	_expect(state.record_clue(definition), "Valid clue rejected.")
	definition.hint_text = "changed"
	_expect(state.record_clue(definition) and state.get_clues().size() == 1, "Repeated clue created duplicates.")
	_expect(state.get_clue(CLUE.stable_id).hint_text == CLUE.hint_text, "Definition mutation or duplicate replaced first observation.")
	var copies := state.get_clues()
	copies[0].hint_text = "changed"
	copies.clear()
	var single := state.get_clue(CLUE.stable_id)
	single.display_name = "changed"
	_expect(state.get_clues().size() == 1 and state.get_clue(CLUE.stable_id).hint_text == CLUE.hint_text and state.get_clue(CLUE.stable_id).display_name == CLUE.display_name, "Queries leaked mutable clue records.")
	_expect(state.get_visited_count() == 0 and state.get_observed_passage_count() == 0 and state.get_marker_count() == 0, "Clue record changed map observations.")
	_expect(state.get_definition().regions.size() == MAP.regions.size() and state.get_definition().routes.size() == MAP.routes.size(), "Clue record changed fixed geometry.")


func _click(button: Button) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = button.get_global_rect().get_center()
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
		if argument.begins_with("--clue-render-directory="):
			var directory := argument.trim_prefix("--clue-render-directory=")
			DirAccess.make_dir_recursive_absolute(directory)
			await RenderingServer.frame_post_draw
			_expect(get_viewport().get_texture().get_image().save_png(directory.path_join(filename)) == OK, "Clue capture failed.")


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
		GameLog.error(&"SmokeTest", &"map_clue_failed", message)
