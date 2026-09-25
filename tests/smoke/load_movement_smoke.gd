extends Node

const PLAYER := preload("res://src/gameplay/player/player.tscn")
const WORLD := preload("res://src/app/prototype_exploration.tscn")
const RULE := preload("res://src/data/prototype_load_movement.tres")
const LIGHT := preload("res://src/data/prototype_light.tres")
const HEAVY := preload("res://src/data/prototype_heavy.tres")
const KNOWN := preload("res://src/data/prototype_known.tres")
const MOVE_ACTIONS := [InputActions.MOVE_LEFT, InputActions.MOVE_RIGHT, InputActions.MOVE_UP, InputActions.MOVE_DOWN]

var _failures := PackedStringArray()


func _ready() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	await _check_movement_boundaries()
	await _check_exploration()
	_release_movement()
	get_tree().paused = false
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"load_movement_passed")
	get_tree().quit(0 if _failures.is_empty() else 1)


func _check_movement_boundaries() -> void:
	_expect(RULE.is_valid(), "Prototype load rule invalid.")
	for pair in [[0.0, 0.0], [1.0, 0.5], [1.2, 0.5], [0.8, 0.0], [0.8, -0.1], [0.8, 0.8], [0.8, 0.9], [NAN, 0.5], [0.8, INF]]:
		var invalid := LoadMovementRule.new()
		invalid.burdened_multiplier = pair[0]
		invalid.overloaded_multiplier = pair[1]
		_expect(not invalid.is_valid(), "Invalid load multipliers accepted.")

	var player: PlayerController = PLAYER.instantiate()
	add_child(player)
	await _frames(3)
	var inventory: PlayerInventory = player.get_node("Inventory")
	inventory.configure_capacity(2, 2.5, 4.0)
	var item := LIGHT.duplicate(true) as ItemDefinition
	item.weight = 4.0
	inventory.try_add_item(item)
	_expect(player.load_movement_rule == null, "Legacy player acquired prototype load balance.")
	await _measure(player, 240.0)
	player.load_movement_rule = RULE
	# Check just below, exactly at, and above both thresholds using real movement.
	for row in [[0.0, 240.0, PlayerInventory.WeightStage.NORMAL], [2.499, 240.0, PlayerInventory.WeightStage.NORMAL], [2.5, 192.0, PlayerInventory.WeightStage.BURDENED], [3.999, 192.0, PlayerInventory.WeightStage.BURDENED], [4.0, 132.0, PlayerInventory.WeightStage.OVERLOADED], [4.001, 132.0, PlayerInventory.WeightStage.OVERLOADED]]:
		inventory.take_all_inventory_items()
		item = LIGHT.duplicate(true) as ItemDefinition
		item.weight = row[0]
		_expect(inventory.try_add_item(item), "Boundary item was rejected.")
		_expect(inventory.get_weight_stage() == int(row[2]), "Wrong stage at a weight boundary.")
		await _measure(player, row[1])
		await _measure(player, row[1], true)
	var invalid_rule := RULE.duplicate(true) as LoadMovementRule
	invalid_rule.overloaded_multiplier = NAN
	player.load_movement_rule = invalid_rule
	await _measure(player, 240.0)
	player.load_movement_rule = null
	await _measure(player, 240.0)
	player.queue_free()
	await _frames(3)
	var no_inventory := PlayerController.new()
	no_inventory.load_movement_rule = RULE
	no_inventory.movement_speed = 240.0
	add_child(no_inventory)
	await _frames(2)
	_expect(no_inventory.get_current_movement_speed() == 240.0, "Missing inventory broke base movement.")
	no_inventory.queue_free()
	await _frames(2)


func _measure(player: PlayerController, expected_speed: float, diagonal := false) -> void:
	player.position = Vector2.ZERO
	await _frames(2)
	var start := player.position
	Input.action_press(InputActions.MOVE_RIGHT)
	if diagonal:
		Input.action_press(InputActions.MOVE_DOWN)
	await _frames(32)
	_expect(is_equal_approx(player.velocity.length(), expected_speed), "Actual velocity does not match load stage.")
	var distance := player.position.distance_to(start)
	_expect(distance >= expected_speed * 30.0 / 60.0 and distance <= expected_speed * 33.0 / 60.0, "Actual displacement does not match load speed.")
	if diagonal:
		_expect(is_equal_approx(player.velocity.x, player.velocity.y), "Diagonal direction lost normalization.")
	_release_movement()
	await _frames(2)
	_expect(player.velocity.is_zero_approx(), "Release did not stop loaded movement.")


func _check_exploration() -> void:
	var world: PrototypeExploration = WORLD.instantiate()
	add_child(world)
	await _frames(3)
	var player: PlayerController = world.get_node("Player")
	var inventory: PlayerInventory = world.get_node("Player/Inventory")
	var panel: InventoryPanel = world.get_node("%InventoryPanel")
	var before := player.position
	Input.action_press(InputActions.MOVE_RIGHT)
	await _frames(10)
	_release_movement()
	_expect(player.position == before, "Movement before departure.")
	_expect(world.prepare_departure(_loadout()) and world.start_exploration(), "Departure failed.")
	await _frames(3)
	_expect(player.get_current_movement_speed() == 240.0, "New departure did not start at normal speed.")
	await _walk(player, Vector2(-650, -200))
	await _walk(player, Vector2(-275, -200))
	_tap(KEY_E)
	_expect(await InteractionTestInput.wait_for_work(player), "Timed action did not finish.")
	await _frames(3)
	_expect(inventory.get_used_slots() == 1 and player.get_current_movement_speed() == 240.0, "Light pickup slowed normal load.")
	await _walk(player, Vector2(80, -200))
	_tap(KEY_E)
	_expect(await InteractionTestInput.wait_for_work(player), "Timed action did not finish.")
	await _frames(3)
	_expect(inventory.get_used_slots() == 2 and player.get_current_movement_speed() == 192.0, "Actual heavy pickup did not slow movement.")
	_expect(world.get_node("%LoadStatus").text.contains("부담 · 이동 80%"), "HUD does not reflect burden.")
	await _capture("load-burdened.png")
	_expect(inventory.try_add_item(KNOWN), "Could not enter overloaded stage.")
	await _frames(2)
	_expect(player.get_current_movement_speed() == 132.0 and world.get_node("%LoadStatus").text.contains("과적 · 이동 55%"), "Overload speed/HUD mismatch.")
	_expect(not inventory.try_add_item(LIGHT) and player.get_current_movement_speed() == 132.0, "Rejected pickup changed movement.")
	var golem: BrokenGuardGolem = world.get_node("%BrokenGuardGolem")
	_expect(player.get_current_movement_speed() < golem.chase_speed and golem.chase_speed < player.movement_speed, "Prototype load does not change pursuit speed disadvantage.")
	before = player.position
	Input.action_press(InputActions.MOVE_RIGHT)
	await _frames(20)
	_expect(is_equal_approx(player.velocity.length(), 132.0) and player.position.x > before.x + 35.0, "Overloaded player cannot move.")
	_release_movement()
	await _frames(2)
	await _capture("load-overloaded.png")

	# Both menus pause loaded movement and the golem.
	for menu_key in [KEY_TAB, KEY_M]:
		_tap(menu_key)
		await _frames(3)
		before = player.position
		var golem_before := golem.position
		Input.action_press(InputActions.MOVE_LEFT)
		await _frames(20)
		_release_movement()
		_expect(get_tree().paused and player.position == before and golem.position == golem_before, "Menu did not pause loaded simulation.")
		_tap(menu_key)
		await _frames(3)
		_expect(not get_tree().paused, "Menu left exploration paused.")

	# Normal confirmation removes the newest heavy item and restores burden speed.
	_tap(KEY_TAB)
	await _frames(3)
	_click(panel.get_node("%DropButton"))
	await _frames(2)
	var dialog: ConfirmationDialog = panel.get_node("%DropConfirmation")
	_expect(dialog.visible and inventory.get_used_slots() == 3, "Normal drop skipped confirmation.")
	dialog.confirmed.emit()
	dialog.hide()
	await _frames(3)
	_expect(inventory.get_used_slots() == 2 and player.get_current_movement_speed() == 192.0, "Normal drop did not restore burden speed.")
	var list: ItemList = panel.get_node("%ItemList")
	_click_at(list.global_position + list.get_item_rect(1).get_center())
	await _frames(2)
	_expect(inventory.get_quick_drop_item() != null and inventory.get_quick_drop_item().get_definition() == HEAVY, "Could not select heavy item after confirmation closed.")
	_tap(KEY_TAB)
	await _frames(2)
	_key(KEY_G, true)
	Input.action_press(InputActions.MOVE_LEFT)
	await _frames(45)
	_expect(is_equal_approx(player.velocity.length(), 240.0), "Quick drop did not restore actual velocity while moving.")
	_key(KEY_G, false)
	_release_movement()
	await _frames(3)
	_expect(inventory.get_used_slots() == 1 and world.get_node("%LoadStatus").text.contains("정상 · 이동 100%"), "Quick drop did not restore normal load/HUD.")
	await _capture("load-restored.png")

	# Keep actual collision and return flow with the new movement calculation.
	await _walk(player, Vector2(-300, -200))
	Input.action_press(InputActions.MOVE_DOWN)
	await _frames(75)
	_release_movement()
	await _frames(2)
	_expect(player.position.y <= -33.0, "Load-aware movement bypassed the central wall.")
	await _walk(player, Vector2(-500, -200))
	await _walk(player, Vector2(-650, -200))
	await _walk(player, Vector2(-680, 0))
	_tap(KEY_E)
	await _frames(4)
	var run: ExplorationRun = world.get_node("%ExplorationRun")
	_expect(run.get_state() == ExplorationRun.State.SAFE_RETURN and run.get_outcome().get_recovery_result().get_item_count() == 1, "Loaded exploration could not return with the remaining item.")
	before = player.position
	Input.action_press(InputActions.MOVE_RIGHT)
	await _frames(10)
	_release_movement()
	_expect(player.position == before, "Movement continued after return.")
	world.queue_free()
	await _frames(3)

	world = WORLD.instantiate()
	add_child(world)
	await _frames(3)
	_expect(world.prepare_departure(_loadout()) and world.start_exploration(), "Fresh departure failed.")
	player = world.get_node("Player")
	inventory = world.get_node("Player/Inventory")
	_expect(inventory.get_used_slots() == 0 and player.get_current_movement_speed() == 240.0, "Previous load leaked into new departure.")
	inventory.try_add_item(HEAVY)
	inventory.try_add_item(KNOWN)
	_expect(player.get_current_movement_speed() == 132.0, "Failure setup not overloaded.")
	world.get_node("%ExplorationRun").complete_failure()
	await _frames(3)
	before = player.position
	Input.action_press(InputActions.MOVE_RIGHT)
	await _frames(10)
	_release_movement()
	_expect(inventory.get_used_slots() == 0 and player.position == before and player.get_current_movement_speed() == 240.0, "Failure retained load or allowed movement.")
	world.queue_free()
	await _frames(3)


func _loadout() -> ExpeditionLoadout:
	var result := ExpeditionLoadout.new()
	result.slot_capacity = 3
	result.burden_weight = 2.5
	result.overload_weight = 4.0
	result.charge_capacity = 3
	result.starting_charge = 3
	return result


func _walk(player: PlayerController, destination: Vector2) -> void:
	for frame in range(900):
		var offset := destination - player.global_position
		_release_movement()
		if offset.length() < 7.0:
			await _frames(3)
			return
		if absf(offset.x) > 3.0:
			Input.action_press(InputActions.MOVE_RIGHT if offset.x > 0.0 else InputActions.MOVE_LEFT)
		if absf(offset.y) > 3.0:
			Input.action_press(InputActions.MOVE_DOWN if offset.y > 0.0 else InputActions.MOVE_UP)
		await get_tree().physics_frame
	_release_movement()
	_expect(false, "Load route blocked: %s." % destination)


func _release_movement() -> void:
	for action in MOVE_ACTIONS:
		Input.action_release(action)


func _key(key: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = key
	event.physical_keycode = key
	event.pressed = pressed
	Input.parse_input_event(event)


func _tap(key: Key) -> void:
	_key(key, true)
	_key(key, false)


func _click(button: Button) -> void:
	_click_at(button.get_global_rect().get_center())


func _click_at(position: Vector2) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = position
	event.pressed = true
	get_viewport().push_input(event)
	event = event.duplicate() as InputEventMouseButton
	event.pressed = false
	get_viewport().push_input(event)


func _capture(filename: String) -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--load-render-directory="):
			var directory := argument.trim_prefix("--load-render-directory=")
			DirAccess.make_dir_recursive_absolute(directory)
			await RenderingServer.frame_post_draw
			_expect(get_viewport().get_texture().get_image().save_png(directory.path_join(filename)) == OK, "Load capture failed.")


func _frames(count: int) -> void:
	for index in range(count):
		await get_tree().physics_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		GameLog.error(&"SmokeTest", &"load_movement_failed", message)
