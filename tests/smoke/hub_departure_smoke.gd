extends Node

const MAIN_SCENE := preload("res://src/app/main.tscn")
const WORLD_SCENE := preload("res://src/app/prototype_exploration.tscn")
const MOVE_ACTIONS := [InputActions.MOVE_LEFT, InputActions.MOVE_RIGHT, InputActions.MOVE_UP, InputActions.MOVE_DOWN]

var _failures := PackedStringArray()
var _departure_count := 0


func _ready() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	await _check_loadout_boundary()
	GameState.state_changed.connect(func(_from: int, to: int):
		if to == GameState.State.EXPLORATION:
			_departure_count += 1
	)
	var entry: GameEntry = MAIN_SCENE.instantiate()
	add_child(entry)
	await _frames(5)
	var hub: HubPanel = entry.get_node("Interface/HubPanel")
	hub.departure_requested.emit()
	_expect(entry.get_node_or_null("PrototypeExploration") == null, "Title allowed departure.")
	_click(entry.get_node("Interface/TitleScreen/%NewGameButton"))
	await _frames(5)
	_expect(GameState.get_current_state() == GameState.State.HUB and hub.visible, "New game did not open preparation.")
	_expect(entry.get_node_or_null("PrototypeExploration") == null, "Hub started a dungeon before departure.")
	var slots := 3 if "--departure-case=three" in OS.get_cmdline_user_args() else 2
	var failure_case := "--departure-case=failure" in OS.get_cmdline_user_args()
	var choice: OptionButton = hub.get_node("%BagChoice")
	choice.select(choice.get_item_index(slots))
	choice.item_selected.emit(choice.selected)
	hub.bag_slots_selected.emit(99)
	_expect(entry.get_departure_preview().slot_capacity == slots, "Hub ignored the choice or accepted an invalid capacity.")
	var preview := entry.get_departure_preview()
	preview.slot_capacity = 99
	_expect(entry.get_departure_preview().slot_capacity == slots, "Preview mutation changed the hub.")
	_press_key(KEY_TAB)
	await _frames(3)
	_expect(not get_tree().paused, "Hub Tab opened an exploration inventory.")
	_expect(Rect2(0, 0, 1152, 648).encloses(hub.get_node("Center/Card").get_global_rect()), "Preparation card exceeds the viewport.")
	var departure_button: Button = hub.get_node("%DepartureButton")
	_click(departure_button)
	_click(departure_button)
	await _frames(6)
	var world := entry.get_node_or_null("PrototypeExploration") as PrototypeExploration
	_expect(world != null and _departure_count == 1, "Departure did not create exactly one exploration.")
	if world == null:
		_finish()
		return
	_expect(GameState.get_current_state() == GameState.State.EXPLORATION and not hub.visible, "Departure did not switch screens and state.")
	var inventory: PlayerInventory = world.get_node("Player/Inventory")
	var harness: HarnessController = world.get_node("Player/HarnessController")
	var player: PlayerController = world.get_node("Player")
	_expect(inventory.slot_capacity == slots and inventory.burden_weight == 2.5 and inventory.overload_weight == 4.0, "Hub inventory configuration was not applied.")
	_expect(harness.get_current_charge() == 3 and harness.get_charge_capacity() == 3, "Hub harness configuration was not applied.")
	hub.bag_slots_selected.emit(2 if slots == 3 else 3)
	hub.departure_requested.emit()
	_expect(entry.get_departure_preview().slot_capacity == slots and _departure_count == 1, "Hidden hub changed an active departure.")
	await _walk(player, Vector2(-500, -200))
	await _walk(player, Vector2(-275, -200))
	_press_key(KEY_E)
	await _frames(4)
	_expect(inventory.get_used_slots() == 1, "Started exploration could not collect its first item.")
	await _check_inventory_pause(world, player)
	if failure_case:
		for point in [Vector2(-500, -200), Vector2(-500, 200), Vector2(-170, 200)]:
			await _walk(player, point)
		await _frames(100)
	else:
		await _walk(player, Vector2(80, -200))
		_press_key(KEY_E)
		await _frames(3)
		for point in [Vector2(630, -200), Vector2(630, 220)]:
			await _walk(player, point)
		_press_key(KEY_E)
		await _frames(3)
		_press_key(KEY_E)
		await _frames(3)
		_expect(inventory.get_used_slots() == slots, "Prepared capacity did not govern actual pickup acceptance.")
		for point in [Vector2(630, -200), Vector2(-500, -200), Vector2(-500, 200), Vector2(-220, 200)]:
			await _walk(player, point)
		_press_key(KEY_Q)
		await _frames(3)
		_expect(harness.get_current_charge() == 2, "Prepared harness could not stabilize the return route.")
		_expect(entry.get_departure_preview().starting_charge == 3 and world.get_start_loadout().starting_charge == 3, "Run consumption changed hub or departure data.")
		for point in [Vector2(-500, 200), Vector2(-650, 0), Vector2(-720, 0)]:
			await _walk(player, point)
		_press_key(KEY_E)
		await _frames(5)
	var outcome := entry.get_pending_outcome()
	_expect(outcome != null and GameState.get_current_state() == GameState.State.RESULTS, "Exploration did not preserve its result in the app.")
	if outcome != null:
		if failure_case:
			_expect(outcome.is_failure() and outcome.get_lost_item_count() == 1 and outcome.get_recovery_result() == null, "Failure did not preserve its exact loss.")
		else:
			_expect(outcome.is_safe_return() and outcome.get_recovery_result().get_recovered_items().size() == slots, "Safe return lost its collected items.")
	_expect(entry.get_node_or_null("PrototypeExploration") == null, "Ended exploration remained active in the tree.")
	var results: Control = entry.get_node("Interface/Results")
	_expect(results.visible and not hub.visible, "End did not show the results screen.")
	var result_panel: Control = results.get_node("OutcomePanel")
	_expect(Rect2(0, 0, 1152, 648).encloses(result_panel.get_global_rect()), "Outcome panel exceeds the viewport.")
	_expect(not result_panel.get_global_rect().intersects(results.get_node("NextStep").get_global_rect()), "Outcome overlaps the next-step notice.")
	_press_key(KEY_TAB)
	_press_key(KEY_Q)
	_press_key(KEY_E)
	hub.departure_requested.emit()
	await _frames(4)
	_expect(not get_tree().paused and entry.get_pending_outcome() == outcome and _departure_count == 1, "Ended exploration accepted input or replaced the pending result.")
	_finish()


func _check_loadout_boundary() -> void:
	var hub := HubState.new()
	_expect(hub.select_bag_slots(3) and not hub.select_bag_slots(0), "Hub capacity validation failed.")
	var data := hub.create_departure_loadout()
	data.starting_charge = 1
	var world: PrototypeExploration = WORLD_SCENE.instantiate()
	add_child(world)
	await _frames(3)
	var player: PlayerController = world.get_node("Player")
	var position_before := player.position
	Input.action_press(InputActions.MOVE_RIGHT)
	_press_key(KEY_TAB)
	await _frames(6)
	_release_movement()
	_expect(player.position == position_before and not get_tree().paused and not world.start_exploration(), "Unprepared exploration processed input or started.")
	var invalid := data.copy()
	invalid.burden_weight = NAN
	_expect(not world.prepare_departure(invalid), "Non-finite loadout was accepted.")
	invalid = data.copy()
	invalid.starting_charge = invalid.charge_capacity + 1
	_expect(not world.prepare_departure(invalid), "Invalid charge was silently clamped.")
	_expect(world.prepare_departure(data) and not world.prepare_departure(data), "Preparation was not applied exactly once.")
	data.slot_capacity = 77
	var returned_copy := world.get_start_loadout()
	returned_copy.starting_charge = 77
	_expect(world.get_start_loadout().slot_capacity == 3 and world.get_start_loadout().starting_charge == 1, "Departure data is shared with input or output copies.")
	_expect(world.get_node("Player/HarnessController").get_current_charge() == 1, "Non-full starting charge was not applied.")
	_expect(hub.create_departure_loadout().starting_charge == 3, "Preparing exploration modified hub state.")
	world.queue_free()
	await _frames(3)


func _check_inventory_pause(world: PrototypeExploration, player: PlayerController) -> void:
	var inventory_panel: InventoryPanel = world.get_node("%InventoryPanel")
	_press_key(KEY_TAB)
	await _frames(3)
	_expect(inventory_panel.visible and get_tree().paused, "Active exploration inventory did not pause.")
	var before := player.position
	Input.action_press(InputActions.MOVE_RIGHT)
	await _frames(6)
	_release_movement()
	_expect(player.position == before, "Player moved while checking the inventory.")
	_press_key(KEY_TAB)
	await _frames(3)
	_expect(not inventory_panel.visible and not get_tree().paused, "Inventory did not restore exploration.")


func _walk(player: PlayerController, destination: Vector2) -> void:
	for frame in range(720):
		if not is_instance_valid(player):
			_release_movement()
			_expect(false, "Exploration ended before reaching %s." % destination)
			return
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
	var release := event.duplicate() as InputEventMouseButton
	release.pressed = false
	get_viewport().push_input(release)


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
	for i in range(count):
		await get_tree().physics_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		GameLog.error(&"SmokeTest", &"hub_departure_failed", message)


func _finish() -> void:
	_release_movement()
	get_tree().paused = false
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"hub_departure_passed")
	get_tree().quit(0 if _failures.is_empty() else 1)
