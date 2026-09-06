extends Node

const PLAYTEST_SCENE := preload("res://tests/fixtures/g1_integration_playtest_space.tscn")
const MOVE_ACTIONS := [InputActions.MOVE_LEFT, InputActions.MOVE_RIGHT, InputActions.MOVE_UP, InputActions.MOVE_DOWN]

var _failures := PackedStringArray()


func _ready() -> void:
	await _check_integrated_risk_route()
	await _check_bypass_capacity(2)
	await _check_bypass_capacity(3)
	await _check_failure_route()
	await _check_inventory_after_analysis_click()
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"g1_integration_playtest_passed")
		get_tree().quit(0)
		return
	for failure in _failures:
		GameLog.error(&"SmokeTest", &"g1_integration_playtest_failed", failure)
	get_tree().quit(1)


func _check_integrated_risk_route() -> void:
	var space = PLAYTEST_SCENE.instantiate()
	add_child(space)
	var player := space.get_node("Player") as PlayerController
	var inventory := player.get_node("Inventory") as PlayerInventory
	var harness := player.get_node("HarnessController") as HarnessController
	var hazard := space.get_node("RiskHazard") as UnstableDebrisHazard
	var golem := space.get_node("BrokenGuardGolem") as BrokenGuardGolem
	var panel := space.get_node("%InventoryPanel") as InventoryPanel
	var original_position := player.position
	Input.action_press(InputActions.MOVE_RIGHT)
	_press_key(KEY_E)
	_press_key(KEY_TAB)
	await _frames(10)
	_release_movement()
	_expect(player.position.is_equal_approx(original_position), "Player moved before choosing a test condition.")
	_expect(not panel.visible and not get_tree().paused, "Inventory opened before choosing a test condition.")
	_expect(space.get_report().outcome == "not_started", "Pre-start input ended the run.")
	_expect(space.start_playtest(2, true), "Two-slot condition did not start.")
	_expect(not space.start_playtest(3, true), "A second start reset an active run.")
	await _frames(3)
	_expect(get_viewport().get_camera_2d() == space.get_node("OverviewCamera"), "Overview camera did not replace the player camera.")

	await _collect_safe_items(space)
	_expect(inventory.get_used_slots() == 2, "Safe items did not fill the two-slot bag.")
	_expect(inventory.get_weight_stage() == PlayerInventory.WeightStage.BURDENED, "Safe load did not enter burdened state.")
	await _walk(player, Vector2(-500, -200))
	await _walk(player, Vector2(-500, 200))
	await _walk(player, Vector2(-275, 200))
	_expect(hazard.get_state() == UnstableDebrisHazard.State.IDLE, "Hazard activated before the approach.")
	var status := space.get_node("%HarnessStatus") as HarnessStatus
	_expect(not status.get_analysis_text().is_empty(), "Free hazard analysis was absent in the integrated map.")
	status.get_node("%AnalyzeButton").pressed.emit()
	_expect(harness.get_current_charge() == 2, "Precise analysis did not share the exploration charge.")
	await _walk(player, Vector2(-220, 200))
	_expect(hazard.get_state() == UnstableDebrisHazard.State.WARNING, "Walking into the choke skipped the warning.")

	_press_key(KEY_TAB)
	_expect(panel.visible and get_tree().paused, "Inventory did not pause the integrated exploration.")
	var before_pause: float = space.get_report().active_seconds
	var hazard_time: float = hazard.get_node("WarningTimer").time_left
	await _frames(15)
	_expect(is_equal_approx(space.get_report().active_seconds, before_pause), "Active play time included the inventory pause.")
	_expect(is_equal_approx(hazard.get_node("WarningTimer").time_left, hazard_time), "Hazard advanced while inspecting the bag.")
	_expect(space.get_report().paused_seconds > 0.0, "Inventory pause time was not recorded separately.")
	_press_key(KEY_TAB)
	_press_key(KEY_Q)
	_expect(hazard.get_state() == UnstableDebrisHazard.State.STABILIZED, "Q did not stabilize the integrated hazard.")
	_expect(harness.get_current_charge() == 1, "Stabilization did not consume the second charge.")
	await _walk(player, Vector2(200, 220))
	_press_key(KEY_E)
	await _frames(2)
	_expect(inventory.get_used_slots() == 2, "Full bag accepted the valuable known item.")
	await _drop_first_through_ui(panel)
	_press_key(KEY_E)
	await _frames(2)
	_expect(inventory.get_items()[1].stable_id == &"test_g1_known", "Value comparison did not replace the light item.")
	_expect(inventory.get_weight_stage() == PlayerInventory.WeightStage.OVERLOADED, "Heavier replacement did not expose overload.")

	await _walk(player, Vector2(365, 220))
	_expect(golem.get_state() == BrokenGuardGolem.State.SUSPICIOUS, "Approaching golem did not show its warning.")
	await _frames(90)
	_expect(golem.get_state() == BrokenGuardGolem.State.CHASE, "Golem never pressured the loaded route.")
	_press_key(KEY_Q)
	_expect(golem.get_state() == BrokenGuardGolem.State.DISABLED, "Last charge did not temporarily stop the golem.")
	_expect(harness.get_current_charge() == 0, "Analysis, stabilization, and discharge did not exhaust three charges.")
	await _walk(player, Vector2(630, 220))
	_press_key(KEY_E)
	await _frames(2)
	_expect(space.get_node("UnknownPickup").is_inspected(), "Unknown item was not investigated.")
	_expect(inventory.get_used_slots() == 2, "Investigation also collected the item.")
	_press_key(KEY_E)
	await _frames(2)
	await _drop_first_through_ui(panel)
	_press_key(KEY_E)
	await _frames(2)
	_expect(inventory.get_inventory_items()[1].get_risk_hint() == "희미한 진동이 느껴집니다.", "Investigation clue was lost during the load choice.")
	_expect(not inventory.get_inventory_items()[1].is_identified(), "Harness activity appraised the unknown item.")

	await _return_by_bypass(space)
	var report: Dictionary = space.get_report()
	_expect(report.outcome == "safe_return", "Integrated risk route did not return through the entrance.")
	_expect(report.counts.inspections == 1 and report.counts.drops == 2, "Investigation and load choices were not recorded.")
	_expect(report.counts.slot_rejections == 2, "Full-bag refusals were not recorded.")
	_expect(report.counts.analyses == 1 and report.counts.stabilizations == 1 and report.counts.discharges == 1, "Charge choices were not recorded separately.")
	_expect(report.counts.bypass_entries == 1 and report.counts.chases >= 1, "Bypass or pursuit evidence was absent.")
	_expect(report.maximum_weight == 5.0 and report.peak_slots == 2, "Peak load measurements were incorrect.")
	_expect(report.burdened_seconds > 0.0 and report.overloaded_seconds > 0.0, "Load exposure times were missing.")
	_expect(report.source == "automated" and not report.movement_slowdown_enabled, "Synthetic run or absent slowdown was misrepresented.")
	var result := (space.get_node("ExplorationRun") as ExplorationRun).get_outcome().get_recovery_result()
	_expect(result.get_total_value_min() == 80 and result.get_total_value_max() == 110, "Unknown value leaked into recovered totals.")
	_expect(result.get_unidentified_item_count() == 1, "Unknown status was lost on return.")
	var outcome_panel := space.get_node("%ExplorationOutcomePanel") as ExplorationOutcomePanel
	var unknown_row := outcome_panel.get_recovery_displayed_item_text(1)
	_expect(unknown_row.contains("희미한 진동") and unknown_row.contains("미확인"), "Result omitted the carried unknown clue.")
	_expect(not unknown_row.contains("잔재") and not unknown_row.contains("200"), "Result exposed unknown category or price.")
	var frozen_report: Dictionary = space.get_report()
	_press_key(KEY_TAB)
	_press_key(KEY_Q)
	await _frames(12)
	_expect(not panel.visible and not get_tree().paused, "Ended run reopened its inventory.")
	_expect(space.get_report() == frozen_report, "Ended run continued to change its measurements.")
	report.counts.drops = 999
	_expect(space.get_report().counts.drops == 2, "Report callers could mutate recorded measurements.")
	space.queue_free()
	await _frames(3)


func _check_bypass_capacity(slots: int) -> void:
	var space = PLAYTEST_SCENE.instantiate()
	add_child(space)
	space.start_playtest(slots, true)
	await _frames(3)
	await _collect_safe_items(space)
	var player := space.get_node("Player") as PlayerController
	await _walk(player, Vector2(630, -200))
	await _walk(player, Vector2(630, 220))
	_press_key(KEY_E)
	await _frames(2)
	_press_key(KEY_E)
	await _frames(2)
	var inventory := player.get_node("Inventory") as PlayerInventory
	if slots == 2:
		_expect(inventory.get_used_slots() == 2, "Two-slot bypass accepted a third item.")
		await _drop_first_through_ui(space.get_node("%InventoryPanel") as InventoryPanel)
		_press_key(KEY_E)
		await _frames(2)
	_expect(inventory.get_used_slots() == slots, "Bypass comparison carried an incorrect load.")
	_expect((space.get_node("RiskHazard") as UnstableDebrisHazard).get_state() == UnstableDebrisHazard.State.IDLE, "Bypass crossed the collapse hazard.")
	await _return_by_bypass(space)
	var report: Dictionary = space.get_report()
	_expect(report.outcome == "safe_return" and report.recovered_count == slots, "Bypass did not recover the expected items.")
	_expect(report.charge_remaining == 3 and report.counts.stabilizations == 0, "Bypass required harness charge.")
	var expected_choices := 1 if slots == 2 else 0
	_expect(report.counts.drops == expected_choices and report.counts.slot_rejections == expected_choices, "Same-route capacity comparison had incorrect choices.")
	_expect(report.maximum_weight == (4.5 if slots == 2 else 5.5) and report.peak_slots == slots, "Capacity comparison lost independent weight pressure.")
	_expect(report.counts.bypass_entries == 2, "Outward and return bypass traversals were not recorded.")
	space.queue_free()
	await _frames(3)


func _check_failure_route() -> void:
	var space = PLAYTEST_SCENE.instantiate()
	add_child(space)
	space.start_playtest(2, true)
	var player := space.get_node("Player") as PlayerController
	await _walk(player, Vector2(-500, -200))
	await _walk(player, Vector2(-230, -200))
	_press_key(KEY_E)
	await _frames(2)
	await _walk(player, Vector2(-500, -200))
	await _walk(player, Vector2(-500, 200))
	await _walk(player, Vector2(-170, 200))
	await _frames(200)
	var outcome := (space.get_node("ExplorationRun") as ExplorationRun).get_outcome()
	_expect(outcome != null and outcome.is_failure(), "Remaining in the collapse did not end the integrated run.")
	_expect(outcome.get_recovery_result() == null and outcome.get_lost_item_count() == 1, "Failure kept current-run loot.")
	var report: Dictionary = space.get_report()
	_expect(report.outcome == "failure" and report.lost_count == 1, "Failure measurements did not match the actual outcome.")
	_expect(report.charge_remaining == 3 and report.counts.stabilizations == 0, "Unanswered risk spent charge.")
	var event_names: Array = report.events.map(func(event: Dictionary): return event.event)
	_expect(event_names.find(&"hazard_warning") < event_names.find(&"hazard_caught"), "Failure log did not preserve warning before impact.")
	space.queue_free()
	await _frames(3)


func _check_inventory_after_analysis_click() -> void:
	# Headless windows default to 64x64; use a playable size for real GUI hit testing.
	var window := get_window()
	var original_size := window.size
	window.size = Vector2i(1152, 648)
	var space = PLAYTEST_SCENE.instantiate()
	add_child(space)
	space.start_playtest(2, true)
	var player := space.get_node("Player") as PlayerController
	var harness := player.get_node("HarnessController") as HarnessController
	var hazard := space.get_node("RiskHazard") as UnstableDebrisHazard
	var panel := space.get_node("%InventoryPanel") as InventoryPanel
	var button := space.get_node("%HarnessStatus").get_node("%AnalyzeButton") as Button
	await _walk(player, Vector2(-500, 200))
	await _walk(player, Vector2(-275, 200))
	_expect(button.is_visible_in_tree() and not button.disabled, "Analysis button was not clickable before the hazard.")
	_click_button(button)
	await _frames(2)
	_expect(harness.get_current_charge() == 2, "Mouse click did not purchase precise analysis.")
	_expect(button.has_focus() and button.disabled, "Analysis click did not retain focus on the completed button.")

	_press_key(KEY_TAB)
	_expect(panel.visible and get_tree().paused, "Focused completed analysis button swallowed inventory opening.")
	var active_before: float = space.get_report().active_seconds
	await _frames(8)
	_expect(is_equal_approx(space.get_report().active_seconds, active_before), "Time advanced in the inventory after an analysis click.")
	_press_key(KEY_TAB)
	_expect(not panel.visible and not get_tree().paused, "Inventory did not close and resume after analysis.")
	panel.close_inventory()

	await _walk(player, Vector2(-220, 200))
	_expect(hazard.get_state() == UnstableDebrisHazard.State.WARNING, "Focus regression route did not reach the warning.")
	_expect(button.has_focus() and not button.disabled, "Warning did not re-enable the focused analysis button.")
	_press_key(KEY_TAB)
	_expect(panel.visible and get_tree().paused, "Focused active analysis button swallowed inventory opening.")
	active_before = space.get_report().active_seconds
	var warning_timer := hazard.get_node("WarningTimer") as Timer
	var warning_before := warning_timer.time_left
	await _frames(8)
	_expect(is_equal_approx(space.get_report().active_seconds, active_before), "Warning-phase inventory did not stop exploration time.")
	_expect(is_equal_approx(warning_timer.time_left, warning_before), "Collapse warning advanced while the inventory was open.")
	_press_key(KEY_TAB)
	_expect(not panel.visible and not get_tree().paused, "Closing the warning-phase inventory did not resume time.")
	panel.close_inventory()
	await _frames(3)
	_expect(warning_timer.time_left < warning_before, "Collapse warning did not resume after closing the inventory.")
	space.queue_free()
	await _frames(3)
	window.size = original_size
	await _frames(3)


func _click_button(button: Button) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = button.get_global_rect().get_center()
	event.global_position = event.position
	event.pressed = true
	get_viewport().push_input(event, true)
	var release := event.duplicate() as InputEventMouseButton
	release.pressed = false
	get_viewport().push_input(release, true)


func _collect_safe_items(space: Node2D) -> void:
	var player := space.get_node("Player") as PlayerController
	await _walk(player, Vector2(-500, -200))
	await _walk(player, Vector2(-230, -200))
	_press_key(KEY_E)
	await _frames(2)
	await _walk(player, Vector2(120, -200))
	_press_key(KEY_E)
	await _frames(2)


func _return_by_bypass(space: Node2D) -> void:
	var player := space.get_node("Player") as PlayerController
	await _walk(player, Vector2(630, -200))
	await _walk(player, Vector2(-500, -200))
	await _walk(player, Vector2(-650, 0))
	await _walk(player, Vector2(-720, 0))
	_press_key(KEY_E)
	await _frames(3)


func _drop_first_through_ui(panel: InventoryPanel) -> void:
	_press_key(KEY_TAB)
	var list := panel.get_node("%ItemList") as ItemList
	list.select(0)
	list.item_selected.emit(0)
	panel.get_node("%DropButton").pressed.emit()
	await _frames(2)
	var confirmation := panel.get_node("%DropConfirmation") as ConfirmationDialog
	_expect(confirmation.visible, "Load choice did not show a confirmation.")
	confirmation.get_ok_button().pressed.emit()
	await _frames(2)
	panel.close_inventory()


func _walk(player: PlayerController, destination: Vector2) -> void:
	for _frame in range(720):
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
	_expect(false, "Physical route blocked before %s; stopped at %s." % [destination, player.global_position])


func _release_movement() -> void:
	for action in MOVE_ACTIONS:
		Input.action_release(action)


func _press_key(code: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = true
	get_viewport().push_input(event)
	var release := InputEventKey.new()
	release.keycode = code
	release.physical_keycode = code
	get_viewport().push_input(release)


func _frames(count: int) -> void:
	for _frame in range(count):
		await get_tree().physics_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
