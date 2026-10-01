extends "res://tests/smoke/value_comparison_smoke.gd"

const SURVIVAL_RULE := preload("res://src/data/prototype_survival.tres")
const MAIN := preload("res://src/app/main.tscn")
const UNKNOWN := preload("res://src/data/prototype_unknown.tres")
const CATALOG := preload("res://src/data/prototype_item_catalog.tres")

var _ends := 0
var _hits := 0
var _noises := 0


func _ready() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	await _check_rule_and_lifetime()
	for weight in [0.0, 3.0, 4.0]:
		await _check_motion(weight)
	await _check_pause_drop_expiry()
	await _check_trap_reentry()
	await _check_contact_and_return()
	await _check_app_failure()
	_release()
	get_tree().paused = false
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"player_survival_passed")
	get_tree().quit(0 if _failures.is_empty() else 1)


func _check_rule_and_lifetime() -> void:
	_expect(SURVIVAL_RULE.is_valid() and not SurvivalRule.new().is_valid(), "Default survival data validity incorrect.")
	for row in [["max_health", 0], ["trap_damage", -1], ["injury_duration", 0.0], ["injury_duration", NAN], ["injury_duration", INF], ["injury_movement_multiplier", 0.0], ["injury_movement_multiplier", -0.1], ["injury_movement_multiplier", 1.1], ["injury_movement_multiplier", NAN], ["injury_movement_multiplier", INF]]:
		var invalid := SURVIVAL_RULE.duplicate(true) as SurvivalRule
		invalid.set(row[0], row[1])
		_expect(not invalid.is_valid(), "Invalid survival rule accepted: %s." % row[0])
	var state := PlayerSurvival.new()
	state.process_mode = Node.PROCESS_MODE_PAUSABLE
	state.rule = SURVIVAL_RULE.duplicate(true)
	state.rule.max_health = 3 # Exercise repeated nonfatal injury independently of prototype balance.
	add_child(state)
	_expect(not state.apply_trap_damage() and not state.incapacitate(), "Pre-departure state accepted damage.")
	state.rule.max_health = 99
	state.rule.trap_damage = 99
	state.rule.injury_duration = 99.0
	state.rule.injury_movement_multiplier = 0.01
	_expect(state.start_exploration() and not state.start_exploration(), "Departure was missing or repeatable.")
	_expect(state.get_max_health() == 3 and state.apply_trap_damage() and state.get_health() == 2, "Mutable exported data changed snapshot.")
	await _frames(90)
	var remaining := state.get_injury_remaining()
	_expect(state.apply_trap_damage() and state.get_health() == 1 and state.get_injury_remaining() > remaining and is_equal_approx(state.get_movement_multiplier(), 0.9), "Repeated injury stacked instead of refreshing.")
	get_tree().paused = true
	remaining = state.get_injury_remaining()
	await _frames(30)
	_expect(not state.apply_trap_damage() and not state.incapacitate() and state.get_injury_remaining() == remaining, "Paused state received damage or advanced.")
	get_tree().paused = false
	await _frames(365)
	_expect(state.get_health() == 1 and state.get_injury_remaining() == 0.0 and state.get_movement_multiplier() == 1.0, "Injury expiry healed health or kept penalty.")
	_ends = 0
	state.incapacitated.connect(func(_cause: StringName): _ends += 1)
	_expect(state.apply_trap_damage(), "Lethal damage rejected.")
	_expect(_ends == 1 and not state.incapacitate() and not state.apply_trap_damage() and not state.start_exploration(), "Ended state repeated damage/departure.")
	state.queue_free()
	await _frames(3)
	var world: PrototypeExploration = WORLD.instantiate()
	world.get_node("PlayerSurvival").rule = SurvivalRule.new()
	add_child(world)
	var loadout := ExpeditionLoadout.new()
	loadout.slot_capacity = 3
	loadout.burden_weight = 2.5
	loadout.overload_weight = 4.0
	loadout.charge_capacity = 3
	loadout.starting_charge = 3
	_expect(world.prepare_departure(loadout) and not world.start_exploration() and not world.get_node("Overlay").visible, "Invalid survival data started exploration.")
	world.queue_free()
	await _frames(3)


func _check_motion(weight: float) -> void:
	var world := await _new_world()
	# Isolate movement/noise from pursuit; actual danger integration is tested below.
	world.get_node("%BrokenGuardGolem").process_mode = Node.PROCESS_MODE_DISABLED
	var player: PlayerController = world.get_node("Player")
	var state: PlayerSurvival = world.get_node("%PlayerSurvival")
	var inventory: PlayerInventory = world.get_node("Player/Inventory")
	var item := LIGHT.duplicate(true) as ItemDefinition
	item.weight = weight
	inventory.try_add_item(item)
	var emitter: MovementNoiseEmitter = world.get_node("%MovementNoiseEmitter")
	_noises = 0
	emitter.noise_emitted.connect(func(_position: Vector2, _radius: float, _loud: bool): _noises += 1)
	var radius := emitter.get_noise_radius()
	var speed := player.get_current_movement_speed()
	await _measure_motion(player, speed)
	_noises = 0
	_expect(state.apply_trap_damage(), "Motion test damage rejected.")
	await _frames(4)
	_expect(_noises == 0 and emitter.get_noise_radius() == radius and inventory.get_total_weight() == weight, "Injury emitted noise or changed load.")
	await _measure_motion(player, speed * 0.9)
	_expect(_noises > 0 and emitter.get_noise_radius() == radius, "Injured footsteps lost existing load noise.")
	await _measure_motion(player, speed * 0.9, true)
	world.queue_free()
	await _frames(3)


func _measure_motion(player: PlayerController, speed: float, diagonal := false) -> void:
	player.position = Vector2(-600, -280)
	await _frames(3)
	var start := player.position
	Input.action_press(InputActions.MOVE_RIGHT)
	if diagonal:
		Input.action_press(InputActions.MOVE_DOWN)
	await _frames(32)
	_expect(is_equal_approx(player.velocity.length(), speed), "Actual movement speed differs from load x injury.")
	var distance := player.position.distance_to(start)
	_expect(distance >= speed * 30.0 / 60.0 and distance <= speed * 33.0 / 60.0, "Actual displacement differs from load x injury.")
	_release()
	await _frames(3)


func _check_pause_drop_expiry() -> void:
	var world := await _new_world()
	world.get_node("%BrokenGuardGolem").process_mode = Node.PROCESS_MODE_DISABLED
	var player: PlayerController = world.get_node("Player")
	player.position = Vector2(-300, -200)
	var state: PlayerSurvival = world.get_node("%PlayerSurvival")
	var inventory: PlayerInventory = world.get_node("Player/Inventory")
	inventory.try_add_item(LIGHT)
	inventory.try_add_item(HEAVY)
	state.apply_trap_damage()
	for key in [KEY_TAB, KEY_M]:
		_tap(key)
		await _frames(3)
		var remaining := state.get_injury_remaining()
		var position := player.position
		Input.action_press(InputActions.MOVE_LEFT)
		_tap(KEY_Q)
		await _frames(90)
		_expect(get_tree().paused and remaining == state.get_injury_remaining() and position == player.position and not state.apply_trap_damage(), "Menu advanced injury/movement or accepted damage.")
		_release()
		if key == KEY_TAB:
			var list: ItemList = world.get_node("%InventoryPanel/%ItemList")
			list.grab_focus()
			_tap(KEY_UP)
			_tap(KEY_DOWN)
		_tap(key)
		await _frames(3)
	_expect(inventory.get_quick_drop_item().get_definition() == HEAVY, "Explicit heavy selection failed.")
	_expect(is_equal_approx(player.get_current_movement_speed(), 172.8), "Burdened injury speed incorrect.")
	_check_hud(world)
	await _capture("survival-injured.png")
	Input.action_press(InputActions.MOVE_LEFT)
	_key(KEY_G, true)
	await _frames(44)
	_key(KEY_G, false)
	_release()
	_expect(inventory.get_items() == [LIGHT] and state.get_health() == 1 and state.get_injury_remaining() > 0.0 and is_equal_approx(player.get_current_movement_speed(), 216.0), "Drop changed injury/health instead of only load.")
	await _capture("survival-lightened.png")
	await _frames(365)
	_expect(state.get_health() == 1 and state.get_injury_remaining() == 0.0 and is_equal_approx(player.get_current_movement_speed(), 240.0), "Expiry did not independently restore injury speed.")
	_expect(world.get_node("%SurvivalStatus").text.contains("회복되지"), "Expiry HUD implied healing.")
	_check_hud(world)
	await _capture("survival-expired.png")
	get_tree().root.size = Vector2i(1600, 900)
	await _frames(3)
	_check_hud(world)
	await _capture("survival-expired-wide.png")
	get_tree().root.size = Vector2i(1152, 648)
	world.queue_free()
	await _frames(3)


func _check_trap_reentry() -> void:
	var world := await _new_world()
	var trap: MalfunctioningTrap = world.get_node("%MalfunctioningTrap")
	var player: PlayerController = world.get_node("Player")
	var state: PlayerSurvival = world.get_node("%PlayerSurvival")
	var run: ExplorationRun = world.get_node("%ExplorationRun")
	_hits = 0
	_ends = 0
	trap.body_caught.connect(func(_body: Node2D): _hits += 1)
	run.run_ended.connect(func(_outcome: ExplorationOutcome): _ends += 1)
	player.position = Vector2(155, -520)
	trap.set_exploration_active(true)
	await _wait_phase(trap, MalfunctioningTrap.Phase.ACTIVE)
	Input.action_press(InputActions.MOVE_RIGHT)
	await _frames(6)
	_release()
	_expect(state.get_health() == 1 and _hits == 1 and run.is_active(), "Active trap entry did not cause exactly one nonfatal hit.")
	Input.action_press(InputActions.MOVE_LEFT)
	await _frames(6)
	_release()
	await _frames(2)
	_expect(not trap.overlaps_body(player), "Reentry test never left trap.")
	Input.action_press(InputActions.MOVE_RIGHT)
	await _frames(6)
	_release()
	await _frames(2)
	_expect(trap.overlaps_body(player) and trap.get_phase() == MalfunctioningTrap.Phase.ACTIVE and state.get_health() == 1 and _hits == 1, "Same pulse reentry dealt extra damage.")
	_tap(KEY_Q)
	await _frames(3)
	_expect(trap.get_phase() == MalfunctioningTrap.Phase.STABILIZED and state.get_health() == 1 and state.get_injury_remaining() > 0.0, "Stabilization failed or healed the player.")
	await _capture("survival-trap-stabilized.png")
	await _wait_phase(trap, MalfunctioningTrap.Phase.ACTIVE)
	await _frames(3)
	_expect(state.get_health() == 0 and _hits == 2 and _ends == 1 and run.get_state() == ExplorationRun.State.FAILURE, "Next pulse failed to end run once.")
	var outcome := run.get_outcome()
	world._on_golem_caught(player)
	world._on_body_caught(player)
	world._on_trap_hit(player)
	_expect(not run.complete_safe_return() and not state.start_exploration() and run.get_outcome() == outcome and _ends == 1, "Late outcomes overwrote trap failure.")
	world.queue_free()
	await _frames(3)


func _check_contact_and_return() -> void:
	var world := await _new_world()
	var state: PlayerSurvival = world.get_node("%PlayerSurvival")
	var player: PlayerController = world.get_node("Player")
	state.apply_trap_damage()
	player.position = Vector2(200, 220)
	world.get_node("%BrokenGuardGolem").position = Vector2(230, 220)
	for frame in range(240):
		if world.get_node("%GolemContactThreat").is_warning():
			break
		await _frames(1)
	_expect(world.get_node("%GolemContactThreat").is_warning() and state.get_health() == 1, "Injured player lost normal contact warning.")
	_check_hud(world)
	await _capture("survival-contact-warning.png")
	_tap(KEY_Q)
	await _frames(3)
	_expect(not world.get_node("%GolemContactThreat").is_warning() and state.get_health() == 1 and state.get_injury_remaining() > 0.0, "Discharge healed injury/health.")
	# Simultaneous end requests keep the first accepted result and reject late danger.
	var run: ExplorationRun = world.get_node("%ExplorationRun")
	_expect(run.complete_safe_return(), "Injured player could not return.")
	world._on_trap_hit(player)
	world._on_golem_caught(player)
	world._on_body_caught(player)
	_expect(not state.apply_trap_damage() and not state.incapacitate() and not state.start_exploration() and state.get_health() == 1 and state.get_injury_remaining() == 0.0 and run.get_outcome().is_safe_return(), "Late danger changed safe return or health.")
	world.queue_free()
	await _frames(3)


func _check_app_failure() -> void:
	var hub := HubState.new()
	var first := hub.begin_expedition()
	var cargo: Array[InventoryItem] = [InventoryItem.from_definition(LIGHT), InventoryItem.from_definition(UNKNOWN, false)]
	hub.prepare_settlement(first, ExplorationOutcome.safe_return_inventory_items(cargo), ECONOMY)
	hub.apply_settlement(first)
	var prior_money := hub.get_money()
	var prior_stored := hub.get_stored_items().size()
	var base := OS.get_environment("TEMP").path_join("dungeon-survival-%d-%d" % [OS.get_process_id(), Time.get_ticks_usec()])
	var store := ProgressStore.new(base + ".json")
	_expect(store.save_data(hub.to_save_data()) == OK, "Could not seed prior holdings.")
	var entry: GameEntry = MAIN.instantiate()
	entry.configure_progress(store)
	entry.configure_settings(SettingsStore.new(base + ".cfg"))
	add_child(entry)
	await _frames(5)
	_click(entry.get_node("Interface/TitleScreen/%ContinueButton").get_global_rect().get_center())
	await _frames(5)
	_click(entry.get_node("Interface/HubPanel/%DepartureButton").get_global_rect().get_center())
	await _frames(5)
	var world: PrototypeExploration = entry.get_node("PrototypeExploration")
	var inventory: PlayerInventory = world.get_node("Player/Inventory")
	inventory.try_add_inventory_item(InventoryItem.from_definition(UNKNOWN, false))
	var protected_item := InventoryItem.from_definition(LIGHT.duplicate(true))
	protected_item.get_definition().sale_protected = true
	inventory.try_add_inventory_item(protected_item)
	world.get_node("Player").position = Vector2(210, -520)
	var trap: MalfunctioningTrap = world.get_node("%MalfunctioningTrap")
	trap.set_exploration_active(true)
	await _wait_phase(trap, MalfunctioningTrap.Phase.ACTIVE)
	await _frames(3)
	_expect(world.get_node("%PlayerSurvival").get_health() == 1 and inventory.get_used_slots() == 2 and GameState.get_current_state() == GameState.State.EXPLORATION, "First hit lost cargo or ended app exploration.")
	for frame in range(360):
		if entry.get_pending_outcome() != null:
			break
		await _frames(1)
	await _frames(5)
	var outcome := entry.get_pending_outcome()
	_expect(outcome != null and outcome.is_failure() and outcome.get_failure_cause() == &"trap_damage" and outcome.get_lost_item_count() == 2, "Health depletion lost exact failure/cargo result.")
	_expect(entry.get_node_or_null("PrototypeExploration") == null, "Failed expedition not disposed.")
	var panel: ExplorationOutcomePanel = entry.get_node("Interface/Results/OutcomePanel")
	_expect(panel.get_summary_text().contains("건강이 소진") and not panel.is_recovery_result_visible(), "Failure omitted health cause or showed recovered cargo.")
	await _capture("survival-failure-result.png")
	_click(entry.get_node("Interface/Results/NextStep/SettleButton").get_global_rect().get_center())
	await _frames(5)
	var restored := HubState.from_save_data(store.load_data(), CATALOG)
	_expect(entry.get_hub_money() == prior_money and entry.get_hub_stored_items().size() == prior_stored and restored.get_money() == prior_money and restored.get_stored_items().size() == prior_stored, "Failure settlement/save changed previous holdings.")
	var saved_keys := store.load_data().keys()
	var original_keys := hub.to_save_data().keys()
	saved_keys.sort()
	original_keys.sort()
	_expect(saved_keys == original_keys, "Survival added hub save fields.")
	_expect(HubRepairTestInput.prepare_departure(entry) == 5, "Survival redeparture repair cost changed.")
	_click(entry.get_node("Interface/HubPanel/%DepartureButton").get_global_rect().get_center())
	await _frames(5)
	var fresh: PrototypeExploration = entry.get_node("PrototypeExploration")
	var state: PlayerSurvival = fresh.get_node("%PlayerSurvival")
	_expect(state.get_health() == 2 and state.get_injury_remaining() == 0.0 and fresh.get_node("Player/Inventory").get_used_slots() == 0 and fresh.get_node("Player/HarnessController").get_current_charge() == 3, "Fresh expedition inherited survival state.")
	# Existing collapse still incapacitates from full health after its full warning.
	fresh.get_node("Player").position = Vector2(-170, 200)
	await _frames(15)
	_expect(state.get_health() == 2 and entry.get_pending_outcome() == null, "Collapse skipped advance warning.")
	await _frames(85)
	_expect(entry.get_pending_outcome() != null and entry.get_pending_outcome().is_failure() and entry.get_pending_outcome().get_failure_cause() == &"", "Collapse failed to incapacitate full-health player.")
	entry.queue_free()
	await _frames(3)


func _check_hud(world: PrototypeExploration) -> void:
	var health: Label = world.get_node("%SurvivalStatus")
	var load_status: Label = world.get_node("%LoadStatus")
	var contact: Label = world.get_node("%ContactStatus")
	var drop: Label = world.get_node("%QuickDropStatus")
	_expect(health.is_visible_in_tree() and health.text.contains("건강 1/2"), "Health/injury HUD absent.")
	_expect(health.get_global_rect().end.y <= contact.get_global_rect().position.y and contact.get_global_rect().end.y <= load_status.get_global_rect().position.y and load_status.get_global_rect().end.y <= drop.get_global_rect().position.y, "Contact/health/load/drop HUD overlap.")
	var font := health.get_theme_font("font")
	_expect(font.get_string_size(health.text, HORIZONTAL_ALIGNMENT_LEFT, -1, health.get_theme_font_size("font_size")).x <= health.size.x, "Health HUD text clipped.")


func _wait_phase(trap: MalfunctioningTrap, phase: MalfunctioningTrap.Phase) -> void:
	for frame in range(600):
		if trap.get_phase() == phase:
			return
		await _frames(1)
	_expect(false, "Trap phase was not reached.")


func _capture(filename: String) -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--survival-render-directory="):
			var directory := argument.trim_prefix("--survival-render-directory=")
			DirAccess.make_dir_recursive_absolute(directory)
			await RenderingServer.frame_post_draw
			_expect(get_viewport().get_texture().get_image().save_png(directory.path_join(filename)) == OK, "Survival screenshot failed.")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		GameLog.error(&"SmokeTest", &"player_survival_failed", message)
