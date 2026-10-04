extends "res://tests/smoke/return_route_smoke.gd"

const ENTRY := preload("res://tests/fixtures/g3_review_entry.tscn")
const ESCAPE_SCENE := preload("res://tests/fixtures/emergency_escape_test_space.tscn")
const CATALOG := preload("res://src/data/prototype_item_catalog.tres")

var _entry: GameEntry
var _store: ProgressStore
var _directory := ""
var _path := ""
var _read_case := false
var _cases: Array[Dictionary] = []
var _charge_on_end := -1
var _health_on_end := -1
var _end_count := 0


func _ready() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--review-progress-directory="):
			_directory = argument.trim_prefix("--review-progress-directory=")
		if argument == "--review-continue":
			_read_case = true
	if _directory.is_empty():
		_directory = OS.get_environment("TEMP").path_join("dungeon-g3-review-%d-%d" % [OS.get_process_id(), Time.get_ticks_usec()])
	_expect(DirAccess.make_dir_recursive_absolute(_directory) == OK, "Cannot create isolated review directory.")
	_path = _directory.path_join("progress.json")
	_store = ProgressStore.new(_path)
	if not _read_case:
		_expect(not _store.has_file(), "Review requires a fresh test directory.")
		# Prior hub holdings are fixture data; every current-run item is picked up.
		var prior := HubState.new().to_save_data()
		prior.money = "40"
		prior.bag_slots = 3
		prior.stored_items = [{"id": "test_g1_unknown", "identified": false, "risk_hint": "희미한 진동이 느껴집니다."}]
		_expect(_store.save_data(prior) == OK, "Cannot seed prior hub holdings.")
	var before_continue := FileAccess.get_file_as_bytes(_path)
	_entry = ENTRY.instantiate() as GameEntry
	_entry.configure_progress(_store)
	_entry.configure_settings(SettingsStore.new(_directory.path_join("settings.cfg")))
	add_child(_entry)
	await _frames(5)
	_click(_entry.get_node("Interface/TitleScreen/%ContinueButton"))
	await _frames(5)
	_expect(GameState.get_current_state() == GameState.State.HUB and FileAccess.get_file_as_bytes(_path) == before_continue, "Continue failed or rewrote saved progress.")
	_check_holdings(85 if _read_case else 40)
	if _read_case:
		await _check_fresh_departure()
		_cases.append({"case": "fresh_process_continue", "money": 80, "stored_unknown": 1, "fresh_departure": true})
	else:
		await _check_injured_recovery()
		await _check_emergency_result(false)
		await _check_emergency_result(true)
		await _check_fresh_departure()
	_release()
	get_tree().paused = false
	var file := FileAccess.open(_directory.path_join("continue-results.json" if _read_case else "flow-results.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify({"passed": _failures.is_empty(), "cases": _cases, "final_hub": _store.load_data()}, "\t") + "\n")
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"g3_survival_flow_passed", "continue" if _read_case else "write")
	get_tree().quit(0 if _failures.is_empty() else 1)


func _depart(emergency := false) -> PrototypeExploration:
	_entry.review_scene = ESCAPE_SCENE if emergency else null
	_click(_entry.get_node("Interface/HubPanel/%DepartureButton"))
	await _frames(5)
	var world: PrototypeExploration = _entry.get_node("EmergencyEscapeTestSpace" if emergency else "PrototypeExploration")
	_expect(GameState.get_current_state() == GameState.State.EXPLORATION and world.get_node("Player/Inventory").get_used_slots() == 0 and world.get_node("PlayerSurvival").get_health() == 2, "App departure failed or retained cargo/health.")
	_charge_on_end = -1
	_health_on_end = -1
	_end_count = 0
	world.exploration_ended.connect(func(_outcome):
		_end_count += 1
		_charge_on_end = world.get_node("Player/HarnessController").get_current_charge()
		_health_on_end = world.get_node("PlayerSurvival").get_health()
	)
	return world


func _check_injured_recovery() -> void:
	var world := await _depart()
	var player: PlayerController = world.get_node("Player")
	var survival: PlayerSurvival = world.get_node("PlayerSurvival")
	var harness: HarnessController = player.get_node("HarnessController")
	await _walk(player, Vector2(-650, -200))
	await _walk(player, Vector2(-275, -200))
	_tap(KEY_E)
	_expect(await InteractionTestInput.wait_for_work(player), "Initial pickup failed.")
	await _walk(player, Vector2(100, -325))
	_tap(KEY_Q)
	await _frames(4)
	await _walk(player, Vector2(100, -440))
	await _walk(player, Vector2(155, -520))
	var trap: MalfunctioningTrap = world.get_node("MalfunctioningTrap")
	for frame in range(600):
		if trap.get_phase() == MalfunctioningTrap.Phase.ACTIVE:
			break
		await _frames(1)
	await _walk(player, Vector2(176, -520))
	_expect(survival.get_health() == 1 and survival.get_injury_remaining() > 5.0, "Actual trap crossing did not injure player.")
	_tap(KEY_Q)
	await _frames(4)
	_expect(trap.get_phase() == MalfunctioningTrap.Phase.STABILIZED and harness.get_current_charge() == 1 and survival.get_health() == 1, "Trap stabilization lost shared charge or healed damage.")
	await _walk(player, Vector2(100, -520))
	await _walk(player, Vector2(100, -240))
	_tap(KEY_E)
	await _frames(3)
	var controller: InteractionController = player.get_node("InteractionController")
	_expect(controller.is_working() and controller.get_work_remaining() > 0.65, "Injured recovery ignored reduced work rate.")
	_tap(KEY_TAB)
	await _frames(3)
	var injury := survival.get_injury_remaining()
	await _frames(60)
	_expect(get_tree().paused and not controller.is_working() and injury == survival.get_injury_remaining(), "Inventory failed to cancel work/freeze injury.")
	_tap(KEY_TAB)
	await _frames(3)
	_tap(KEY_E)
	await _frames(3)
	await _capture("g3-review-injured-recovery.png")
	_expect(await InteractionTestInput.wait_for_work(player), "Injured recovery never finished.")
	_expect(player.get_node("Inventory").get_used_slots() == 2 and survival.get_health() == 1 and is_equal_approx(player.get_current_movement_speed(), 172.8), "Recovery lost injury/load composition.")
	await _walk(player, Vector2(-500, -240))
	await _walk(player, Vector2(-680, 0))
	_tap(KEY_E)
	await _frames(5)
	var outcome := _entry.get_pending_outcome()
	_expect(outcome != null and outcome.is_safe_return() and outcome.get_return_method() == &"entrance" and outcome.get_recovery_result().get_item_count() == 2 and _health_on_end == 1 and _charge_on_end == 1, "Injured entrance return changed cargo/health/resources.")
	await _settle(80)
	_cases.append({"case": "trap_injury_recovery_return", "recovered_items": 2, "health": _health_on_end, "charge": _charge_on_end, "hub_money": 80})


func _check_emergency_result(timeout: bool) -> void:
	var before := FileAccess.get_file_as_bytes(_path)
	var world := await _depart(true)
	var player: PlayerController = world.get_node("Player")
	await _walk(player, Vector2(-650, -200))
	await _walk(player, Vector2(-275, -200))
	_tap(KEY_E)
	_expect(await InteractionTestInput.wait_for_work(player), "Escape cargo pickup failed.")
	await _walk(player, Vector2(40, -280))
	await _frames(190)
	var escape: EmergencyEscape = world.get_node("EmergencyEscape")
	_expect(escape.is_route_lost() and FileAccess.get_file_as_bytes(_path) == before, "Escape did not lose route or wrote an active run.")
	if timeout:
		await _frames(1250)
	else:
		_tap(KEY_E)
		await _frames(10)
		_tap(KEY_M)
		await _frames(3)
		var remaining := escape.get_time_remaining()
		await _frames(60)
		_expect(get_tree().paused and not escape.is_preparing() and remaining == escape.get_time_remaining(), "App menu failed to cancel escape/freeze time.")
		_tap(KEY_M)
		await _frames(3)
		_tap(KEY_E)
		await _frames(250)
	await _frames(5)
	var outcome := _entry.get_pending_outcome()
	_expect(outcome != null and GameState.get_current_state() == GameState.State.RESULTS and _entry.get_node_or_null("EmergencyEscapeTestSpace") == null and _end_count == 1, "Emergency app result or scene disposal failed.")
	_expect(FileAccess.get_file_as_bytes(_path) == before, "Result preview committed progress.")
	var result_panel: ExplorationOutcomePanel = _entry.get_node("Interface/Results/OutcomePanel")
	if timeout:
		_expect(outcome.is_failure() and outcome.get_failure_cause() == &"escape_timeout" and outcome.get_lost_item_count() == 1 and _charge_on_end == 3, "App timeout lost exact cargo/cost contract.")
		_expect(result_panel.get_summary_text().contains("제한 시간") and not result_panel.is_recovery_result_visible(), "App timeout UI omitted cause/loss.")
		await _capture("g3-review-timeout-result.png")
	else:
		_expect(outcome.is_safe_return() and outcome.get_return_method() == &"emergency_escape" and outcome.get_recovery_result().get_item_count() == 1 and _charge_on_end == 2, "App emergency return changed cargo or charge.")
		_expect(result_panel.get_title_text() == "비상 탈출 성공", "App results hid return method.")
		await _capture("g3-review-escape-result.png")
		get_tree().root.size = Vector2i(1600, 900)
		await _frames(5)
		_expect(Rect2(Vector2.ZERO, get_viewport().get_visible_rect().size).encloses(result_panel.get_global_rect()), "Wide result panel clipped.")
		await _capture("g3-review-escape-wide.png")
		get_tree().root.size = Vector2i(1152, 648)
		await _frames(5)
		# A real temporary-path collision rejects the atomic write. The directory
		# is created and removed only inside this run's fresh test directory.
		_expect(DirAccess.make_dir_absolute(_path + ".tmp") == OK, "Cannot create save-failure fixture.")
		_click(_entry.get_node("Interface/Results/NextStep/SettleButton"))
		await _frames(5)
		_expect(GameState.get_current_state() == GameState.State.RESULTS and _entry.get_pending_outcome() == outcome and _entry.get_hub_money() == 80 and FileAccess.get_file_as_bytes(_path) == before, "Rejected emergency settlement changed holdings or discarded retry.")
		await _capture("g3-review-save-retry.png")
		_expect(DirAccess.remove_absolute(_path + ".tmp") == OK, "Cannot remove isolated save-failure fixture.")
	await _settle(90)
	_cases.append({"case": "escape_timeout" if timeout else "emergency_return_save_retry", "charge": _charge_on_end, "outcomes": _end_count, "hub_money": 90, "stored_unknown": 1})


func _settle(expected_money: int) -> void:
	var button: Button = _entry.get_node("Interface/Results/NextStep/SettleButton")
	_click(button)
	_click(button)
	await _frames(5)
	_expect(GameState.get_current_state() == GameState.State.HUB and _entry.get_pending_outcome() == null, "Settlement did not return to hub once.")
	_check_holdings(expected_money)
	var restored := HubState.from_save_data(_store.load_data(), CATALOG)
	_expect(restored != null and restored.get_money() == expected_money and restored.get_stored_items().size() == 1, "Saved hub differs from committed memory.")
	var keys := _store.load_data().keys()
	keys.sort()
	_expect(keys == ["bag_slots", "harness_durability", "harness_modules", "harness_upgrades", "money", "next_expedition_id", "registered_items", "stored_items"], "Unexpected fields in the hub save.")
	_expect(restored.get_harness_durability() == _entry.get_hub_harness_durability(), "Survival settlement saved different equipment damage.")
	_expect(_store.load_data().registered_items.is_empty(), "G3 exploration registered an original automatically.")


func _check_holdings(expected_money: int) -> void:
	_expect(_entry.get_hub_money() == expected_money and _entry.get_hub_stored_items().size() == 1 and _entry.get_departure_preview().slot_capacity == 3, "Hub holdings/preparation changed.")
	if _entry.get_hub_stored_items().size() == 1:
		var item := _entry.get_hub_stored_items()[0]
		_expect(item.get_definition().stable_id == &"test_g1_unknown" and not item.is_identified() and item.get_risk_hint() == "희미한 진동이 느껴집니다.", "Prior unknown item was identified, sold or changed.")


func _check_fresh_departure() -> void:
	_expect(HubRepairTestInput.prepare_departure(_entry) == 5, "Survival loop repair cost changed.")
	var expected_money := 80 if _read_case else 85
	var world := await _depart()
	_expect(world.get_node_or_null("EmergencyEscape") == null and world.get_node_or_null("ChangingPassage") == null, "Default departure silently enabled trial events.")
	_expect(world.get_node("PlayerSurvival").get_injury_remaining() == 0 and world.get_node("Player/HarnessController").get_current_charge() == 3 and world.get_map_state().get_observed_passage_count() == 0, "New departure retained injury, charge or map.")
	await _walk(world.get_node("Player"), Vector2(-680, 0))
	_tap(KEY_E)
	await _frames(5)
	await _settle(expected_money)
	await _capture("g3-review-saved-hub.png")
	_cases.append({"case": "fresh_default_departure", "health": 2, "charge_at_start": 3, "trial_events_active": false, "hub_money": expected_money})


func _click(button: Button) -> void:
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.position = button.get_global_rect().get_center()
		event.pressed = pressed
		get_viewport().push_input(event)


func _capture(filename: String) -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--review-render-directory="):
			var directory := argument.trim_prefix("--review-render-directory=")
			DirAccess.make_dir_recursive_absolute(directory)
			await RenderingServer.frame_post_draw
			_expect(get_viewport().get_texture().get_image().save_png(directory.path_join(filename)) == OK, "Review screenshot failed.")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		GameLog.error(&"SmokeTest", &"g3_survival_flow_failed", message)
