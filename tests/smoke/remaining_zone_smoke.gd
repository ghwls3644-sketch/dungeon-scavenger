extends Node

const WORLD := preload("res://src/app/prototype_exploration.tscn")
const MAP := preload("res://src/data/prototype_exploration_map.tres")
const CLUE := preload("res://src/data/prototype_map_clue.tres")
const REGION := preload("res://src/data/prototype_remaining_region.tres")
const MOVE_ACTIONS := [InputActions.MOVE_LEFT, InputActions.MOVE_RIGHT, InputActions.MOVE_UP, InputActions.MOVE_DOWN]

var _failures := PackedStringArray()
var _opened_count := 0
var _discovered_count := 0


func _ready() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	_check_state_boundary()
	var world: PrototypeExploration = WORLD.instantiate()
	add_child(world)
	await _frames(4)
	var gate: RemainingZoneEntrance = world.get_node("%RemainingZoneEntrance")
	var player: PlayerController = world.get_node("Player")
	var state := world.get_map_state()
	var harness: HarnessController = world.get_node("Player/HarnessController")
	var panel: ExplorationMapPanel = world.get_node("%ExplorationMapPanel")
	var canvas: ExplorationMapCanvas = panel.get_node("%MapCanvas")
	gate.opened.connect(func(): _opened_count += 1)
	gate.discovered.connect(func(): _discovered_count += 1)
	_expect(not gate.stabilize(), "Gate opened before departure.")
	_expect(world.prepare_departure(_loadout()) and world.start_exploration(), "Departure failed.")
	await _frames(3)
	_press_key(KEY_Q)
	_expect(not gate.is_open() and harness.get_current_charge() == 3, "Distant action opened a gate.")
	await _walk(player, Vector2(-570, 140))
	_press_key(KEY_E)
	await _frames(2)
	_expect(state.has_clue(CLUE.stable_id), "Clue setup did not acquire the hint.")
	_expect(state.get_known_bounds() == MAP.bounds and state.get_discovered_region_count() == 0 and not gate.is_open(), "Clue revealed or opened a region.")
	await _approach_gate(player)
	_expect(harness.get_current_prompt().contains("입구 안정화"), "Nearby entrance was not actionable.")
	_expect(not harness.get_basic_analysis().is_empty() and not harness.can_analyze_current_target(), "Free gate information missing or sold again.")
	_press_key(KEY_M)
	await _frames(3)
	_expect(state.get_known_regions().size() == 4 and not panel.get_node("%VisitSummary").text.contains("잔여"), "Unvisited room leaked through map data or totals.")
	var player_before := player.position
	_press_key(KEY_Q)
	Input.action_press(InputActions.MOVE_UP)
	await _frames(20)
	_release_movement()
	_expect(not gate.stabilize() and not gate.is_open() and player.position.is_equal_approx(player_before) and harness.get_current_charge() == 3, "Paused map allowed movement or opening.")
	await _capture("zone-undiscovered-map.png")
	_press_key(KEY_TAB)
	await _frames(3)
	_press_key(KEY_Q)
	_expect(not gate.is_open() and get_tree().paused, "Inventory allowed entrance action.")
	_press_key(KEY_TAB)
	await _frames(3)
	Input.action_press(InputActions.MOVE_UP)
	await _frames(45)
	_release_movement()
	await _frames(3)
	_expect(player.position.y >= -343.0 and state.get_discovered_region_count() == 0, "Closed entrance did not physically block entry.")
	harness.configure_charge(3, 0)
	_press_key(KEY_Q)
	await _frames(3)
	_expect(not gate.is_open() and harness.get_current_charge() == 0, "Empty charge opened the gate.")
	await _capture("zone-closed.png")
	harness.configure_charge(3, 3)
	_press_key(KEY_Q)
	await _frames(4)
	_expect(gate.is_open() and harness.get_current_charge() == 2 and _opened_count == 1, "Q did not open the gate with one charge.")
	_expect(state.get_discovered_region_count() == 0 and state.get_known_bounds() == MAP.bounds, "Opening alone revealed the room.")
	_press_key(KEY_Q)
	await _frames(3)
	_expect(not gate.stabilize() and harness.get_current_charge() == 2 and _opened_count == 1, "Repeated action charged or opened again.")
	await _walk(player, Vector2(100, -490))
	_expect(state.get_discovered_region_count() == 1 and _discovered_count == 1 and state.is_visited(REGION.stable_id), "Actual entry did not discover exactly once.")
	_expect(state.get_current_region_id() == REGION.stable_id and state.get_visited_count() == 3, "Region entry lost current position or visit count.")
	_expect(state.get_definition().regions.size() == 4 and state.get_definition().bounds == MAP.bounds, "Discovery changed the official map.")
	_expect(world.get_node("%ChoiceStatus").text.contains("잔여 구역 발견"), "Discovery notice missing.")
	_expect(world.get_node("%ExplorationRun").is_active(), "Hidden room became an exit.")
	await _capture("zone-entered.png")
	_press_key(KEY_M)
	await _frames(3)
	_expect(panel.get_node("%VisitSummary").text.contains("기본 구역  2 / 4") and panel.get_node("%VisitSummary").text.contains("잔여 구역 발견 1"), "Map totals mix fixed and discovered rooms.")
	_expect(state.get_known_bounds().has_point(player.position), "Discovered position lies outside the map.")
	var note_position := Vector2(220, -450)
	_click(panel.get_node("%EditMarkersButton"))
	_click_at(canvas.global_position + canvas.world_to_map(note_position))
	await _frames(3)
	_expect(state.get_marker_count() == 1 and (state.get_markers().values()[0] as Vector2).distance_to(note_position) < 1.0, "Expanded map click did not project to the discovered room.")
	await _capture("zone-discovered-map.png")
	get_tree().root.size = Vector2i(1600, 900)
	await _frames(4)
	_expect(Rect2(Vector2.ZERO, get_viewport().get_visible_rect().size).encloses(panel.get_node("Center/Card").get_global_rect()), "Resized map exceeds viewport.")
	_click_at(canvas.global_position + canvas.world_to_map(note_position))
	await _frames(3)
	_expect(state.get_marker_count() == 0, "Resized map could not remove the same marker.")
	await _capture("zone-discovered-resized.png")
	get_tree().root.size = Vector2i(1152, 648)
	await _frames(3)
	_press_key(KEY_M)
	await _walk(player, Vector2(100, -260))
	_expect(state.get_discovered_region_count() == 1 and state.get_current_region_id() == &"prototype_north", "Leaving lost discovery or current region.")
	await _walk(player, Vector2(100, -490))
	_expect(_discovered_count == 1 and harness.get_current_charge() == 2, "Reentry duplicated discovery or cost.")
	await _walk(player, Vector2(100, -220))
	await _walk(player, Vector2(-650, -220))
	await _walk(player, Vector2(-680, 0))
	_press_key(KEY_E)
	await _frames(4)
	_expect(not world.get_node("%ExplorationRun").is_active() and not gate.stabilize(), "Original entrance did not end the run.")
	_press_key(KEY_M)
	_press_key(KEY_Q)
	_expect(not panel.visible and not get_tree().paused and harness.get_current_charge() == 2, "End of run left input or pause active.")
	world.queue_free()
	await _frames(4)
	await _check_fresh_visit(false)
	await _check_fresh_visit(true)
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"remaining_zone_passed")
	get_tree().quit(0 if _failures.is_empty() else 1)


func _check_fresh_visit(empty_charge: bool) -> void:
	var world: PrototypeExploration = WORLD.instantiate()
	add_child(world)
	await _frames(3)
	var state := world.get_map_state()
	var gate: RemainingZoneEntrance = world.get_node("%RemainingZoneEntrance")
	var player: PlayerController = world.get_node("Player")
	var harness: HarnessController = world.get_node("Player/HarnessController")
	var loadout := _loadout()
	if empty_charge:
		loadout.starting_charge = 0
	_expect(not gate.is_open() and state.get_discovered_region_count() == 0 and state.get_known_bounds() == MAP.bounds, "New visit retained opening or discovery.")
	_expect(world.prepare_departure(loadout) and world.start_exploration(), "Fresh visit failed.")
	await _approach_gate(player)
	if empty_charge:
		_press_key(KEY_Q)
		await _frames(3)
		_expect(not gate.is_open() and harness.get_current_charge() == 0, "Empty departure opened a region.")
		await _walk(player, Vector2(100, -220))
		await _walk(player, Vector2(-650, -220))
		await _walk(player, Vector2(-680, 0))
		_press_key(KEY_E)
		await _frames(3)
		_expect(not world.get_node("%ExplorationRun").is_active(), "Unable to return without spending charge.")
	else:
		_expect(state.get_clues().is_empty(), "Fresh departure retained a clue.")
		_press_key(KEY_Q)
		await _frames(3)
		_expect(gate.is_open() and state.get_discovered_region_count() == 0, "Clue incorrectly required as a key, or opening revealed room.")
		var panel: ExplorationMapPanel = world.get_node("%ExplorationMapPanel")
		panel.open_map()
		world.get_node("%ExplorationRun").complete_failure()
		await _frames(3)
		# Relocation is only for the ended-run boundary; playable paths above use movement.
		player.position = REGION.bounds.get_center()
		await _frames(4)
		_expect(state.get_discovered_region_count() == 0 and not panel.visible and not get_tree().paused, "Failure allowed later discovery or retained pause.")
	world.queue_free()
	await _frames(4)


func _approach_gate(player: PlayerController) -> void:
	await _walk(player, Vector2(-570, -220))
	await _walk(player, Vector2(100, -220))
	await _walk(player, Vector2(100, -310))


func _check_state_boundary() -> void:
	var state := ExplorationMapState.new()
	var center := REGION.bounds.get_center()
	_expect(not state.discover_region(REGION, center), "Unconfigured map accepted discovery.")
	_expect(state.configure(MAP), "Map configuration failed.")
	_expect(not state.discover_region(null, center) and not state.discover_region(REGION, Vector2.INF), "Invalid discovery accepted.")
	state.observe_position(center)
	_expect(state.get_discovered_region_count() == 0 and state.get_known_bounds() == MAP.bounds, "Position alone revealed an unknown region.")
	_expect(not state.discover_region(REGION, Vector2.ZERO), "Remote entry accepted.")
	var invalid := REGION.duplicate(true) as MapRegionDefinition
	invalid.stable_id = &""
	_expect(not state.discover_region(invalid, center), "Empty region ID accepted.")
	invalid = REGION.duplicate(true) as MapRegionDefinition
	invalid.bounds.size.x = 0
	_expect(not state.discover_region(invalid, center), "Empty region bounds accepted.")
	invalid = REGION.duplicate(true) as MapRegionDefinition
	invalid.bounds = MAP.regions[0].bounds
	_expect(not state.discover_region(invalid, invalid.bounds.get_center()), "Discovery overlapped the official map.")
	invalid = REGION.duplicate(true) as MapRegionDefinition
	invalid.stable_id = MAP.regions[0].stable_id
	_expect(not state.discover_region(invalid, center), "Discovery replaced a public ID.")
	_expect(state.add_marker(center) == -1 and state.get_known_regions().size() == 4, "Hidden geometry exposed before discovery.")
	var definition := REGION.duplicate(true) as MapRegionDefinition
	_expect(state.discover_region(definition, center), "Valid entry rejected.")
	definition.display_name = "changed"
	_expect(state.discover_region(definition, center) and state.get_discovered_region_count() == 1, "Reentry duplicated a room.")
	var copies := state.get_known_regions()
	copies.back().display_name = "changed again"
	copies.back().bounds.size.x = 1
	copies.clear()
	_expect(state.get_known_regions().back().display_name == REGION.display_name and state.get_known_regions().back().bounds == REGION.bounds, "Discovery leaked mutable data or allowed duplicate overwrite.")
	invalid = REGION.duplicate(true) as MapRegionDefinition
	invalid.stable_id = &"overlap"
	_expect(not state.discover_region(invalid, center), "Overlapping discovery accepted.")
	_expect(state.get_definition().bounds == MAP.bounds and state.get_definition().regions.size() == 4 and state.get_known_bounds() == MAP.bounds.merge(REGION.bounds), "Known bounds changed fixed geometry.")
	_expect(state.get_visited_count() == 1 and state.get_clues().is_empty() and state.get_observed_passage_count() == 0 and state.get_marker_count() == 0, "Discovery changed unrelated knowledge.")
	_expect(state.add_marker(center) > 0, "Discovered room rejected a note.")


func _click_at(point: Vector2) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = point
	event.pressed = true
	get_viewport().push_input(event)
	event = event.duplicate() as InputEventMouseButton
	event.pressed = false
	get_viewport().push_input(event)

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
		if argument.begins_with("--zone-render-directory="):
			var directory := argument.trim_prefix("--zone-render-directory=")
			DirAccess.make_dir_recursive_absolute(directory)
			await RenderingServer.frame_post_draw
			var capture := get_viewport().get_texture().get_image()
			if filename == "zone-entered.png":
				var player: PlayerController = get_node("PrototypeExploration/Player")
				var point := player.get_global_transform_with_canvas().origin
				var pixel := capture.get_pixel(int(point.x), int(point.y))
				_expect(pixel.b > 0.7 and pixel.g > 0.6 and pixel.r < 0.5, "Room floor obscured the player.")
			_expect(capture.save_png(directory.path_join(filename)) == OK, "Zone capture failed.")


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
		GameLog.error(&"SmokeTest", &"remaining_zone_failed", message)
