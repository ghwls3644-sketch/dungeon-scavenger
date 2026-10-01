extends "res://tests/smoke/value_comparison_smoke.gd"

const MAIN := preload("res://src/app/main.tscn")
const UNKNOWN := preload("res://src/data/prototype_unknown.tres")
const CATALOG := preload("res://src/data/prototype_item_catalog.tres")


func _ready() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	_check_rules()
	await _check_warning_and_discharge()
	await _check_blockers_and_lifetime()
	await _check_retreat(false)
	await _check_retreat(true)
	await _check_app_failure()
	_release()
	get_tree().paused = false
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"golem_contact_passed")
	get_tree().quit(0 if _failures.is_empty() else 1)


func _check_rules() -> void:
	var rule := GolemContactRule.new()
	_expect(not rule.is_valid(), "Empty contact data accepted.")
	for value in [-1.0, 0.0, NAN, INF]:
		rule.contact_distance = value
		rule.warning_duration = 1.0
		_expect(not rule.is_valid(), "Invalid distance accepted.")
		rule.contact_distance = 34.0
		rule.warning_duration = value
		_expect(not rule.is_valid(), "Invalid warning accepted.")
	_expect(ExplorationOutcome.failure(2).get_failure_cause() == &"", "Old failure factory changed cause.")


func _check_warning_and_discharge() -> void:
	var world := await _new_world()
	var player: PlayerController = world.get_node("Player")
	var golem: BrokenGuardGolem = world.get_node("%BrokenGuardGolem")
	var threat: GolemContactThreat = world.get_node("%GolemContactThreat")
	var run: ExplorationRun = world.get_node("%ExplorationRun")
	var harness: HarnessController = player.get_node("HarnessController")
	player.position = Vector2(200, 220)
	golem.position = Vector2(230, 220)
	await _frames(5)
	_expect(golem.get_state() == BrokenGuardGolem.State.SUSPICIOUS and not threat.is_warning() and run.is_active(), "Suspicion contact skipped prior warning.")
	await _await_warning(world)
	_expect(threat.get_remaining_time() > 0.95 and run.is_active(), "First contact consumed warning time.")
	var warning: Label = world.get_node("%ContactStatus")
	_expect(warning.visible and not world.get_node("%ChoiceStatus").visible and warning.get_global_rect().end.y <= world.get_node("%LoadStatus").position.y, "Warning overlaps normal guidance/load HUD.")
	await _capture("contact-warning.png")
	for menu in [KEY_TAB, KEY_M]:
		_tap(menu)
		await _frames(3)
		var remaining := threat.get_remaining_time()
		var positions := [player.position, golem.position]
		var charge := harness.get_current_charge()
		_tap(KEY_Q)
		Input.action_press(InputActions.MOVE_RIGHT)
		await _frames(80)
		_release()
		_expect(get_tree().paused and threat.get_remaining_time() == remaining and run.is_active(), "Menu advanced capture timer.")
		_expect(positions == [player.position, golem.position] and harness.get_current_charge() == charge and not world.get_node("%ContactStatus").visible, "Menu accepted evasion or retained warning overlay.")
		_tap(menu)
		await _frames(3)
	await _frames(20)
	_tap(KEY_Q)
	await _frames(3)
	_expect(harness.get_current_charge() == 2 and golem.get_state() == BrokenGuardGolem.State.DISABLED and not threat.is_warning() and run.is_active(), "Paid discharge did not interrupt capture.")
	await _capture("contact-discharge.png")
	await _await_warning(world)
	_expect(threat.get_remaining_time() > 0.95, "Post-discharge contact reused elapsed time.")
	# Isolate distance and current sight cancellation while keeping both bodies processing.
	golem.chase_speed = 0.0
	await _frames(20)
	player.position += Vector2(-80, 0)
	await _frames(3)
	_expect(not threat.is_warning() and run.is_active(), "Distance escape retained capture.")
	player.position = golem.position + Vector2(-25, 0)
	await _await_warning(world)
	_expect(threat.get_remaining_time() > 0.95, "Recontact inherited prior timer.")
	var previous := threat.get_remaining_time()
	var invalid := threat.rule.duplicate(true) as GolemContactRule
	invalid.warning_duration = 0.001
	threat.rule = invalid
	await _frames(5)
	_expect(run.is_active() and threat.get_remaining_time() > previous - 0.2, "Runtime inspector data replaced the snapshot.")
	var count := [0]
	threat.body_caught.connect(func(_body: Node2D): count[0] += 1)
	await _frames(80)
	_expect(run.get_state() == ExplorationRun.State.FAILURE and count[0] == 1 and not threat.is_warning(), "Continuous contact did not finish once.")
	threat.set_active(true)
	await _frames(80)
	_expect(count[0] == 1 and not world.get_node("Overlay").visible, "Finished contact restarted or left its HUD.")
	world.queue_free()
	await _frames(3)


func _check_blockers_and_lifetime() -> void:
	# A deliberately larger test radius isolates LOS from distance across a closed door.
	var world: PrototypeExploration = WORLD.instantiate()
	var threat: GolemContactThreat = world.get_node("GolemContactThreat")
	var rule := threat.rule.duplicate(true) as GolemContactRule
	rule.contact_distance = 160.0
	threat.rule = rule
	add_child(world)
	await _frames(3)
	var player: PlayerController = world.get_node("Player")
	var golem: BrokenGuardGolem = world.get_node("%BrokenGuardGolem")
	var door: TemporaryDoor = world.get_node("%RetreatDoor")
	player.position = Vector2(628, -70)
	golem.position = Vector2(628, 70)
	await _frames(100)
	_expect(not threat.is_warning(), "Undeparted expedition counted contact.")
	var loadout := ExpeditionLoadout.new()
	loadout.slot_capacity = 3
	loadout.burden_weight = 2.5
	loadout.overload_weight = 4.0
	loadout.charge_capacity = 3
	loadout.starting_charge = 3
	_expect(world.prepare_departure(loadout) and world.start_exploration(), "Blocker fixture did not start.")
	golem.patrol_speed = 0.0
	golem.suspicious_speed = 0.0
	golem.chase_speed = 0.0
	golem.search_speed = 0.0
	await _frames(4)
	_tap(KEY_E)
	await _frames(4)
	_expect(not door.is_open, "Blocker test failed to close door.")
	golem.raise_alarm(player.position)
	await _frames(55)
	_expect(golem.get_state() == BrokenGuardGolem.State.CHASE and not golem.is_visually_tracking(player) and not threat.is_warning(), "Sound-only chase captured through closed door.")
	_tap(KEY_E)
	await _await_warning(world)
	await _frames(20)
	_tap(KEY_E)
	await _frames(3)
	_expect(not threat.is_warning() and world.get_node("%ExplorationRun").is_active(), "Closing door did not clear warning.")
	player.position = Vector2(400, -50)
	golem.position = Vector2(400, 50)
	golem.raise_alarm(player.position)
	await _frames(100)
	_expect(not threat.is_warning(), "Static wall allowed contact capture.")
	# A deleted source clears a live warning without retaining a dangling target.
	player.position = Vector2(600, 180)
	golem.position = Vector2(600, 220)
	await _await_warning(world)
	golem.queue_free()
	await _frames(3)
	_expect(not threat.is_warning() and world.get_node("%ExplorationRun").is_active(), "Deleted golem retained warning.")
	world.queue_free()
	await _frames(3)
	var invalid_world: PrototypeExploration = WORLD.instantiate()
	invalid_world.get_node("GolemContactThreat").rule = GolemContactRule.new()
	add_child(invalid_world)
	await _frames(3)
	invalid_world.prepare_departure(loadout)
	invalid_world.start_exploration()
	invalid_world.get_node("Player").position = Vector2(200, 220)
	invalid_world.get_node("%BrokenGuardGolem").position = Vector2(220, 220)
	await _frames(150)
	_expect(invalid_world.get_node("%ExplorationRun").is_active(), "Invalid contact rule caused capture.")
	invalid_world.queue_free()
	await _frames(3)


func _check_retreat(drop: bool) -> void:
	var world := await _new_world()
	var player: PlayerController = world.get_node("Player")
	var inventory: PlayerInventory = player.get_node("Inventory")
	var golem: BrokenGuardGolem = world.get_node("%BrokenGuardGolem")
	var run: ExplorationRun = world.get_node("%ExplorationRun")
	# Real pickups; identical chase start in the long northern corridor.
	await _walk(player, Vector2(-650, -200))
	await _walk(player, Vector2(-275, -200))
	_tap(KEY_E)
	_expect(await InteractionTestInput.wait_for_work(player), "Timed action did not finish.")
	await _frames(3)
	await _walk(player, Vector2(80, -200))
	_tap(KEY_E)
	_expect(await InteractionTestInput.wait_for_work(player), "Timed action did not finish.")
	await _frames(3)
	_tap(KEY_TAB)
	await _frames(3)
	world.get_node("%InventoryPanel/%ItemList").grab_focus()
	_tap(KEY_UP)
	_tap(KEY_DOWN)
	await _frames(3)
	_tap(KEY_TAB)
	await _frames(3)
	var selected := inventory.get_quick_drop_item()
	_expect(inventory.get_items() == [LIGHT, HEAVY] and selected != null and selected.get_definition() == HEAVY, "Retreat setup failed real pickup/selection.")
	golem.position = player.position + Vector2(-90, 0)
	await _await_warning(world)
	Input.action_press(InputActions.MOVE_RIGHT)
	if drop:
		_key(KEY_G, true)
	await _frames(85)
	_key(KEY_G, false)
	if drop:
		_expect(run.is_active() and inventory.get_items() == [LIGHT] and not world.get_node("%GolemContactThreat").is_warning(), "Lighter movement did not escape capture.")
		_expect(player.get_current_movement_speed() > golem.chase_speed and player.position.distance_to(golem.position) > 34.0, "Drop did not create a real separation.")
		await _capture("contact-drop-escape.png")
	else:
		_expect(run.get_state() == ExplorationRun.State.FAILURE and run.get_outcome().get_lost_item_count() == 2, "Keeping the same cargo did not cause capture.")
	_release()
	world.queue_free()
	await _frames(3)


func _check_app_failure() -> void:
	# Seed prior holdings through the existing settlement/save APIs.
	var hub := HubState.new()
	var first := hub.begin_expedition()
	var cargo: Array[InventoryItem] = [InventoryItem.from_definition(LIGHT), InventoryItem.from_definition(UNKNOWN, false)]
	hub.prepare_settlement(first, ExplorationOutcome.safe_return_inventory_items(cargo), ECONOMY)
	hub.apply_settlement(first)
	var prior_money := hub.get_money()
	var prior_stored := hub.get_stored_items().size()
	var base := OS.get_environment("TEMP").path_join("dungeon-contact-%d-%d" % [OS.get_process_id(), Time.get_ticks_usec()])
	var store := ProgressStore.new(base + ".json")
	_expect(store.save_data(hub.to_save_data()) == OK, "Could not seed prior hub holdings.")
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
	var harness: HarnessController = world.get_node("Player/HarnessController")
	harness.configure_charge(3, 0)
	world.get_node("Player").position = Vector2(200, 220)
	world.get_node("%BrokenGuardGolem").position = Vector2(230, 220)
	await _await_warning(world)
	_tap(KEY_Q)
	await _frames(3)
	_expect(world.get_node("%GolemContactThreat").is_warning() and harness.get_current_charge() == 0, "Empty harness canceled contact for free.")
	await _frames(80)
	var outcome := entry.get_pending_outcome()
	_expect(outcome != null and outcome.is_failure() and outcome.get_failure_cause() == &"golem_capture" and outcome.get_lost_item_count() == 2 and outcome.get_recovery_result() == null, "Capture did not preserve exact failure/loss.")
	_expect(GameState.get_current_state() == GameState.State.RESULTS and entry.get_node_or_null("PrototypeExploration") == null, "Capture did not dispose expedition and show results.")
	var panel: ExplorationOutcomePanel = entry.get_node("Interface/Results/OutcomePanel")
	_expect(panel.get_summary_text().contains("골렘") and panel.get_summary_text().contains("2개") and not panel.is_recovery_result_visible(), "Failure screen omitted cause or showed recovered items.")
	await _capture("contact-failure-result.png")
	_click(entry.get_node("Interface/Results/NextStep/SettleButton").get_global_rect().get_center())
	await _frames(5)
	_expect(entry.get_hub_money() == prior_money and entry.get_hub_stored_items().size() == prior_stored, "Capture settlement changed previous holdings.")
	var restored := HubState.from_save_data(store.load_data(), CATALOG)
	_expect(restored != null and restored.get_money() == prior_money and restored.get_stored_items().size() == prior_stored, "Saved failure changed prior holdings.")
	_expect(HubRepairTestInput.prepare_departure(entry) == 5, "Capture redeparture repair cost changed.")
	_click(entry.get_node("Interface/HubPanel/%DepartureButton").get_global_rect().get_center())
	await _frames(5)
	var fresh: PrototypeExploration = entry.get_node("PrototypeExploration")
	_expect(not fresh.get_node("%GolemContactThreat").is_warning() and fresh.get_node("Player/Inventory").get_used_slots() == 0 and fresh.get_node("Player/HarnessController").get_current_charge() == 3, "New departure inherited capture state.")
	fresh.get_node("Player").position = Vector2(200, 220)
	fresh.get_node("%BrokenGuardGolem").position = Vector2(230, 220)
	await _await_warning(fresh)
	_expect(fresh.get_node("%GolemContactThreat").get_remaining_time() > 0.95, "New departure did not restore full warning.")
	_expect(fresh.get_node("%ExplorationRun").complete_safe_return(), "Could not end fresh expedition.")
	await _frames(5)
	_expect(entry.get_pending_outcome().is_safe_return() and entry.get_pending_outcome().get_failure_cause() == &"", "Safe return retained capture cause.")
	entry.queue_free()
	await _frames(3)


func _await_warning(world: PrototypeExploration) -> void:
	for frame in range(240):
		if world.get_node("%GolemContactThreat").is_warning():
			return
		await _frames(1)
	_expect(false, "Visible chase never reached contact warning.")


func _capture(filename: String) -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--contact-render-directory="):
			var directory := argument.trim_prefix("--contact-render-directory=")
			DirAccess.make_dir_recursive_absolute(directory)
			await RenderingServer.frame_post_draw
			_expect(get_viewport().get_texture().get_image().save_png(directory.path_join(filename)) == OK, "Screenshot failed.")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		GameLog.error(&"SmokeTest", &"golem_contact_failed", message)
