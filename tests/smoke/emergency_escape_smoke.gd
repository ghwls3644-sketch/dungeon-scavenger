extends "res://tests/smoke/return_route_smoke.gd"

const ESCAPE_WORLD := preload("res://tests/fixtures/emergency_escape_test_space.tscn")
const ESCAPE_RULE := preload("res://src/data/prototype_emergency_escape.tres")
const ECONOMY := preload("res://src/data/prototype_economy.tres")
const CATALOG := preload("res://src/data/prototype_item_catalog.tres")

var _measurements: Array[Dictionary] = []
var _hub := HubState.new()
var _results := 0
var _charge_events := 0
var _test_catalog: ItemCatalog = CATALOG.duplicate(true)


func _ready() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	# A catalog copy isolates protected-item coverage from the playable content.
	for item in _test_catalog.items:
		if item.stable_id == &"test_g1_known":
			item.sale_protected = true
	_check_rule()
	await _check_available_routes()
	await _check_cancellation_and_success()
	await _check_damage_target_and_resource()
	await _check_timeout_and_new_visit()
	await _check_deadline_priority()
	_release()
	get_tree().paused = false
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--escape-report-path="):
			var file := FileAccess.open(argument.trim_prefix("--escape-report-path="), FileAccess.WRITE)
			file.store_string(JSON.stringify({"passed": _failures.is_empty(), "cases": _measurements}, "\t") + "\n")
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"emergency_escape_passed")
	get_tree().quit(0 if _failures.is_empty() else 1)


func _check_rule() -> void:
	_expect(ESCAPE_RULE.is_valid() and not EmergencyEscapeRule.new().is_valid(), "Rule defaults wrong.")
	for field in ["time_limit", "preparation_duration"]:
		for invalid_value in [0.0, -1.0, NAN, INF]:
			var invalid := ESCAPE_RULE.duplicate(true) as EmergencyEscapeRule
			invalid.set(field, invalid_value)
			_expect(not invalid.is_valid(), "Invalid escape duration accepted.")
	for cost in [0, -1]:
		var invalid := ESCAPE_RULE.duplicate(true) as EmergencyEscapeRule
		invalid.charge_cost = cost
		_expect(not invalid.is_valid(), "Invalid escape cost accepted.")
	var impossible := ESCAPE_RULE.duplicate(true) as EmergencyEscapeRule
	impossible.time_limit = impossible.preparation_duration
	_expect(not impossible.is_valid(), "Impossible deadline accepted.")


func _create_world(charge := 3, both_paths := true) -> PrototypeExploration:
	var world := ESCAPE_WORLD.instantiate() as PrototypeExploration
	world.auto_start = false
	world.get_node("EmergencyEscape").rule = ESCAPE_RULE.duplicate(true)
	if not both_paths:
		# Isolate the one-blocked-connection case in the same physical layout.
		world.get_node("LowerPassage").trigger_bounds = Rect2(10000, 10000, 10, 10)
	add_child(world)
	await _frames(3)
	_expect(world.get_node("EmergencyEscape").is_configured() and not world.get_node("EmergencyEscape").is_route_lost(), "Escape started before departure or configuration failed.")
	var loadout := ExpeditionLoadout.new()
	loadout.slot_capacity = 3
	loadout.burden_weight = 2.5
	loadout.overload_weight = 4.0
	loadout.charge_capacity = 3
	loadout.starting_charge = charge
	_expect(world.prepare_departure(loadout) and world.start_exploration(), "Escape departure failed.")
	await _frames(4)
	return world


func _reach_escape(world: PrototypeExploration, collect := false) -> void:
	var player: PlayerController = world.get_node("Player")
	await _walk(player, Vector2(-650, -200))
	await _walk(player, Vector2(-315, -200))
	_expect(world.get_node("ChangingPassage").get_phase() == ChangingPassage.Phase.WARNING, "Crossing failed to warn.")
	await _capture("escape-warning.png")
	if collect:
		await _walk(player, Vector2(-275, -200))
		_tap(KEY_E)
		_expect(await InteractionTestInput.wait_for_work(player), "Actual cargo pickup failed.")
	await _walk(player, Vector2(40, -280))
	await _frames(190)
	_expect(world.get_node("ChangingPassage").get_phase() == ChangingPassage.Phase.BLOCKED, "Upper connector did not close.")


func _check_available_routes() -> void:
	var world := await _create_world(3, false)
	await _reach_escape(world)
	var escape: EmergencyEscape = world.get_node("EmergencyEscape")
	_expect(world.get_node("ReturnRouteProbe").has_return_route() and not escape.is_route_lost() and escape.get_time_remaining() == 0, "One blocked connector started a deadline.")
	# The reopenable east door is not a permanent loss of the lower way back.
	_expect(world.get_node("RetreatDoor").interact(self), "Door setup failed.")
	await _frames(5)
	_expect(not escape.is_route_lost() and not escape.interact(world.get_node("Player")), "Reopenable door or premature E started escape.")
	world.queue_free()
	await _frames(4)
	world = await _create_world()
	var player: PlayerController = world.get_node("Player")
	await _walk(player, Vector2(-650, -200))
	await _walk(player, Vector2(-315, -200))
	await _walk(player, Vector2(-500, -200))
	await _frames(190)
	escape = world.get_node("EmergencyEscape")
	_expect(world.get_node("LowerPassage").get_phase() == ChangingPassage.Phase.BLOCKED and not escape.is_route_lost(), "Entrance-side player was trapped by remote closures.")
	await _walk(player, Vector2(-680, 0))
	_tap(KEY_E)
	await _frames(4)
	_expect(world.get_node("ExplorationRun").get_outcome().get_return_method() == &"entrance", "Normal return changed meaning.")
	_measurements.append({"case": "one_route_or_entrance_side", "deadline_started": false, "normal_return": true})
	world.queue_free()
	await _frames(4)


func _check_cancellation_and_success() -> void:
	var world := await _create_world()
	await _reach_escape(world, true)
	var escape: EmergencyEscape = world.get_node("EmergencyEscape")
	var player: PlayerController = world.get_node("Player")
	var harness: HarnessController = player.get_node("HarnessController")
	var inventory: PlayerInventory = player.get_node("Inventory")
	var run: ExplorationRun = world.get_node("ExplorationRun")
	_expect(escape.is_route_lost() and escape.get_time_remaining() > 16.0 and escape.get_time_remaining() <= 20.0, "Physical route loss failed to start the deadline.")
	_expect(world.get_map_state().get_passage_status(&"prototype_upper_link") == ExplorationMapState.PassageStatus.OPEN, "Deadline disclosed unseen closure in map records.")
	await _capture("escape-deadline.png")
	# External edits cannot change the validated per-visit duration/cost snapshot.
	escape.rule.preparation_duration = 0.01
	escape.rule.charge_cost = 3
	_tap(KEY_E)
	await _frames(12)
	_expect(escape.is_preparing() and escape.get_preparation_remaining() > 3.7, "Preparation ignored the rule snapshot.")
	_tap(KEY_E)
	await _frames(3)
	_expect(not escape.is_preparing() and harness.get_current_charge() == 3, "E cancellation spent charge.")
	_tap(KEY_E)
	await _frames(3)
	Input.action_press(InputActions.MOVE_RIGHT)
	await _frames(4)
	_release()
	_expect(not escape.is_preparing(), "Movement failed to cancel preparation.")
	for key in [KEY_M, KEY_TAB]:
		_tap(KEY_E)
		await _frames(3)
		_expect(escape.is_preparing(), "Preparation did not restart.")
		_tap(key)
		await _frames(3)
		var remaining := escape.get_time_remaining()
		await _frames(60)
		_expect(get_tree().paused and not escape.is_preparing() and remaining == escape.get_time_remaining(), "Menu failed to cancel preparation or pause the deadline.")
		_tap(key)
		await _frames(3)
		_expect(not escape.is_preparing() and escape.get_time_remaining() < remaining, "Menu auto-resumed preparation or froze the deadline.")
	# State-boundary coverage uses existing catalog items; no content is placed in the scene.
	_expect(inventory.try_add_item(CATALOG.find_item(&"test_g1_unknown"), false, "시험 위험 정보"), "Unknown cargo setup failed.")
	_expect(inventory.try_add_item(_test_catalog.find_item(&"test_g1_known")), "Protected cargo setup failed.")
	run.run_ended.connect(func(_outcome): _results += 1)
	inventory.inventory_changed.connect(func():
		_expect(not run.complete_failure() and not run.complete_emergency_return(), "Inventory notification committed a second outcome.")
		_expect(not harness.commit_charge_action(1, func(): return true), "Inventory notification spent reserved charge.")
	)
	harness.charge_changed.connect(func(_charge, _capacity):
		_charge_events += 1
		_expect(not harness.commit_charge_action(1, func(): return true), "Charge signal allowed nested spending.")
	)
	_tap(KEY_E)
	await _frames(5)
	_expect(escape.get_preparation_remaining() > 3.8, "Canceled progress was retained.")
	_expect(Rect2(Vector2.ZERO, get_viewport().get_visible_rect().size).encloses(world.get_node("%InteractionPrompt").get_global_rect()), "Preparation prompt clipped.")
	await _capture("escape-preparing.png")
	get_tree().root.size = Vector2i(1600, 900)
	await _frames(5)
	var notice: Label = world.get_node("%ChoiceStatus")
	_expect(Rect2(Vector2.ZERO, get_viewport().get_visible_rect().size).encloses(notice.get_global_rect()) and not notice.get_global_rect().intersects(world.get_node("%LoadStatus").get_global_rect()), "Deadline HUD clipped or overlapped load status.")
	_expect(Rect2(Vector2.ZERO, get_viewport().get_visible_rect().size).encloses(world.get_node("%InteractionPrompt").get_global_rect()), "Wide preparation prompt clipped.")
	await _capture("escape-wide.png")
	get_tree().root.size = Vector2i(1152, 648)
	await _frames(240)
	var outcome := run.get_outcome()
	_expect(outcome != null and outcome.is_safe_return() and outcome.get_return_method() == &"emergency_escape", "Emergency return failed.")
	if outcome != null:
		var recovered := outcome.get_recovery_result().get_recovered_inventory_items()
		_expect(recovered.size() == 3 and not recovered[1].is_identified() and recovered[1].get_risk_hint() == "시험 위험 정보" and recovered[2].get_definition().is_protected(), "Emergency return altered cargo state.")
		_settle(outcome)
	_expect(_results == 1 and _charge_events == 1 and harness.get_current_charge() == 2 and inventory.get_used_slots() == 0, "Return duplicated results/charges or kept cargo in the run.")
	_expect(world.get_node("ResultOverlay/Outcome").get_title_text() == "비상 탈출 성공", "Emergency result not distinguished.")
	var remaining := escape.get_time_remaining()
	_tap(KEY_E)
	await _frames(260)
	_expect(remaining == escape.get_time_remaining() and not escape.interact(player) and not world.start_exploration(), "Ended escape advanced or restarted.")
	await _capture("escape-success.png")
	_measurements.append({"case": "canceled_then_success", "charge_before": 3, "charge_after": harness.get_current_charge(), "outcomes": _results, "recovered_items": 3, "hub_money": _hub.get_money(), "stored_items": _hub.get_stored_items().size(), "deadline_remaining": remaining})
	world.queue_free()
	await _frames(4)


func _check_damage_target_and_resource() -> void:
	var world := await _create_world(1)
	await _reach_escape(world)
	var escape: EmergencyEscape = world.get_node("EmergencyEscape")
	var harness: HarnessController = world.get_node("Player/HarnessController")
	_expect(not harness.commit_charge_action(0, func(): return true) and not harness.commit_charge_action(-1, func(): return true) and not harness.commit_charge_action(1, Callable()), "Invalid charge action accepted.")
	_expect(not harness.commit_charge_action(1, func(): return false) and harness.get_current_charge() == 1, "Rejected result failed to refund its reservation.")
	_tap(KEY_E)
	await _frames(3)
	_expect(world.get_node("PlayerSurvival").apply_trap_damage(), "Damage setup failed.")
	await _frames(3)
	_expect(not escape.is_preparing() and harness.get_current_charge() == 1, "Damage failed to cancel without charging.")
	_tap(KEY_E)
	await _frames(3)
	escape.set_interaction_enabled(false)
	await _frames(3)
	_expect(not escape.is_preparing(), "Unavailable target retained preparation.")
	escape.set_interaction_enabled(true)
	await _frames(3)
	_tap(KEY_E)
	await _frames(3)
	var station_position := escape.position
	escape.position += Vector2(0, -200)
	await _frames(3)
	_expect(not escape.is_preparing(), "Out-of-reach target retained preparation.")
	escape.position = station_position
	await _frames(3)
	_tap(KEY_E)
	await _frames(3)
	# Model another consumer using the shared charge during preparation.
	_expect(harness.commit_charge_action(1, func(): return true), "Competing charge setup failed.")
	await _frames(3)
	_expect(not escape.is_preparing() and harness.get_current_charge() == 0, "Charge revalidation failed.")
	_tap(KEY_E)
	await _frames(3)
	_expect(not escape.is_preparing() and world.get_node("ExplorationRun").is_active(), "Insufficient charge ended expedition or started escape.")
	# Test-only restoration of a real connector must reset the route state.
	world.get_node("LowerPassage/Barrier/CollisionShape2D").disabled = true
	await _frames(4)
	_expect(not escape.is_route_lost() and escape.get_time_remaining() == 0, "Restored connection retained deadline.")
	world.get_node("LowerPassage/Barrier/CollisionShape2D").disabled = false
	await _frames(4)
	_expect(escape.is_route_lost() and escape.get_time_remaining() > 19.9, "New route loss inherited old deadline.")
	_tap(KEY_M)
	await _frames(3)
	world.get_node("ExplorationRun").complete_failure(&"golem_capture")
	await _frames(3)
	var remaining := escape.get_time_remaining()
	await _frames(1300)
	_expect(not get_tree().paused and remaining == escape.get_time_remaining() and world.get_node("ExplorationRun").get_outcome().get_failure_cause() == &"golem_capture", "Existing failure was overwritten by timeout.")
	_measurements.append({"case": "damage_target_charge_restore_end", "charge_after": harness.get_current_charge(), "failure_cause": "golem_capture"})
	world.queue_free()
	await _frames(4)


func _check_timeout_and_new_visit() -> void:
	var world := await _create_world(0)
	await _reach_escape(world, true)
	var escape: EmergencyEscape = world.get_node("EmergencyEscape")
	_tap(KEY_E)
	await _frames(3)
	_expect(not escape.is_preparing(), "Zero charge started preparation.")
	await _frames(1250)
	var outcome: ExplorationOutcome = world.get_node("ExplorationRun").get_outcome()
	_expect(outcome != null and outcome.is_failure() and outcome.get_failure_cause() == &"escape_timeout" and outcome.get_lost_item_count() == 1, "Deadline failed to lose only current cargo.")
	if outcome != null:
		_settle(outcome)
	_expect(_hub.get_money() == 10 and _hub.get_stored_items().size() == 2, "Failure damaged previous hub holdings.")
	var restored := HubState.from_save_data(_hub.to_save_data(), _test_catalog)
	_expect(restored != null and restored.get_money() == 10 and restored.get_stored_items().size() == 2 and not restored.get_stored_items()[0].is_identified(), "Save boundary lost emergency return holdings.")
	await _capture("escape-timeout.png")
	_measurements.append({"case": "zero_charge_timeout", "lost_items": 1, "hub_money_preserved": _hub.get_money(), "stored_items_preserved": _hub.get_stored_items().size()})
	world.queue_free()
	await _frames(4)
	world = await _create_world()
	escape = world.get_node("EmergencyEscape")
	_expect(not escape.is_route_lost() and escape.get_time_remaining() == 0 and world.get_node("Player/HarnessController").get_current_charge() == 3 and world.get_node("Player/Inventory").get_used_slots() == 0, "New visit retained route, charge or cargo.")
	world.queue_free()
	await _frames(4)


func _check_deadline_priority() -> void:
	var world := await _create_world()
	await _reach_escape(world)
	var escape: EmergencyEscape = world.get_node("EmergencyEscape")
	# Deterministic scheduler boundary: start normally, then advance one large tick
	# that crosses both deadlines. This avoids depending on input-frame rounding.
	_tap(KEY_E)
	await _frames(3)
	_expect(escape.is_preparing(), "Priority case did not prepare.")
	escape._physics_process(escape.get_time_remaining())
	await _frames(3)
	_expect(world.get_node("ExplorationRun").get_outcome().get_failure_cause() == &"escape_timeout" and world.get_node("Player/HarnessController").get_current_charge() == 3, "Completion beat expiration on the same tick or charged failure.")
	_measurements.append({"case": "deadline_completion_same_tick", "result": "escape_timeout", "charge_spent": 0})
	world.queue_free()
	await _frames(4)


func _settle(outcome: ExplorationOutcome) -> void:
	var expedition := _hub.begin_expedition()
	_expect(_hub.prepare_settlement(expedition, outcome, ECONOMY) and _hub.apply_settlement(expedition) and not _hub.apply_settlement(expedition), "Emergency result failed normal one-time settlement.")


func _capture(filename: String) -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--escape-render-directory="):
			var directory := argument.trim_prefix("--escape-render-directory=")
			DirAccess.make_dir_recursive_absolute(directory)
			await RenderingServer.frame_post_draw
			_expect(get_viewport().get_texture().get_image().save_png(directory.path_join(filename)) == OK, "Screenshot failed.")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		GameLog.error(&"SmokeTest", &"emergency_escape_failed", message)
