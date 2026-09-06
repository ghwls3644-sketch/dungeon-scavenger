extends Node

const PLAYER_SCENE := preload("res://src/gameplay/player/player.tscn")
const HAZARD_SCENE := preload("res://src/gameplay/hazards/unstable_debris_hazard.tscn")
const GOLEM_SCENE := preload("res://src/gameplay/hazards/broken_guard_golem.tscn")
const STATUS_SCENE := preload("res://src/ui/harness_status.tscn")

class RefusingHazard extends StabilizableHazard:
	func can_stabilize() -> bool:
		return true

	func stabilize() -> bool:
		return false


var _failures := PackedStringArray()


func _ready() -> void:
	await _check_shared_charge_and_escape()
	await _check_recovery_with_player_present()
	await _check_analysis_boundaries()

	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"harness_actions_passed")
		get_tree().quit(0)
		return
	for failure in _failures:
		GameLog.error(&"SmokeTest", &"harness_actions_failed", failure)
	get_tree().quit(1)


func _check_shared_charge_and_escape() -> void:
	var space := Node2D.new()
	add_child(space)
	var player: PlayerController = PLAYER_SCENE.instantiate()
	player.movement_speed = 0.0
	space.add_child(player)
	var harness := player.get_node("HarnessController") as HarnessController
	var detector := player.get_node("HazardDetector") as HazardDetector
	harness.configure_charge(3)
	var status: HarnessStatus = STATUS_SCENE.instantiate()
	space.add_child(status)
	status.bind_source(harness)
	var analyze_button := status.get_node("%AnalyzeButton") as Button

	var hazard: UnstableDebrisHazard = HAZARD_SCENE.instantiate()
	hazard.position = Vector2(100.0, 0.0)
	hazard.warning_duration = 5.0
	space.add_child(hazard)
	await _settle()
	_expect(hazard.get_state() == UnstableDebrisHazard.State.IDLE, "Basic reading required entering the danger.")
	_expect(not harness.get_basic_analysis().is_empty(), "Nearby hazard had no free basic analysis.")
	_expect(harness.get_precise_analysis().is_empty(), "Precise information appeared without payment.")
	_expect(harness.get_current_charge() == 3, "Basic analysis consumed charge.")
	_expect(status.get_analysis_text().contains("무료"), "UI did not identify free analysis.")

	analyze_button.pressed.emit()
	_expect(harness.get_current_charge() == 2, "Analysis button did not spend one charge.")
	_expect(harness.get_precise_analysis().contains("접근하면"), "Precise reading did not describe the idle hazard.")
	_expect(analyze_button.disabled, "Completed reading remained purchasable in the UI.")
	_expect(not harness.analyze_current_target(), "An unchanged reading was charged again.")
	_expect(harness.get_current_charge() == 2, "Duplicate reading changed charge.")

	hazard.begin_warning()
	detector.refresh_current_hazard()
	_expect(harness.get_precise_analysis().is_empty(), "Old reading survived a target state change.")
	_expect(status.get_analysis_text().contains("진동"), "Basic reading did not update with the warning.")
	analyze_button.grab_focus()
	_press_q()
	_expect(hazard.get_state() == UnstableDebrisHazard.State.STABILIZED, "Q did not stabilize with a focused analysis button.")
	_expect(harness.get_current_charge() == 1, "Stabilization did not share the analysis charge pool.")

	# A nearer, stabilized target must not hide an actionable golem.
	hazard.position = Vector2(20.0, 0.0)
	var golem: BrokenGuardGolem = GOLEM_SCENE.instantiate()
	golem.position = Vector2(80.0, 0.0)
	golem.patrol_speed = 0.0
	golem.suspicious_speed = 0.0
	golem.chase_speed = 30.0
	golem.suspicion_duration = 0.08
	golem.search_duration = 0.15
	golem.discharge_duration = 0.35
	space.add_child(golem)
	await _settle()
	await get_tree().create_timer(0.12).timeout
	_expect(golem.get_state() == BrokenGuardGolem.State.CHASE, "Golem did not reach chase before the discharge check.")
	_expect(detector.get_current_harness_target() == golem, "An inactive hazard hid the actionable golem.")
	_expect(harness.get_current_prompt().contains("비상 방전"), "Q prompt did not name the chosen physical action.")

	var nested_accepts: Array[bool] = []
	golem.state_changed.connect(func(_previous: int, current: int) -> void:
		if current == BrokenGuardGolem.State.DISABLED:
			nested_accepts.append(harness.use_current_harness_action())
			nested_accepts.append(harness.analyze_current_target())
			nested_accepts.append(harness.configure_charge(99))
	)
	_press_q()
	_expect(golem.get_state() == BrokenGuardGolem.State.DISABLED, "Q did not stop the chasing golem.")
	_expect(harness.get_current_charge() == 0, "Discharge did not spend the last shared charge.")
	_expect(nested_accepts == [false, false, false], "A target callback changed the reserved charge.")
	var stopped_position := golem.global_position
	var last_seen_position := golem.get_last_known_position()
	_expect(not harness.use_current_harness_action(), "Repeated discharge was accepted while stopped.")
	_expect(not golem.emergency_discharge(), "Direct repeated discharge extended the stop.")
	_expect(not golem.investigate_noise(Vector2(400.0, 0.0)), "Noise cancelled the stop.")
	_expect(not golem.raise_alarm(Vector2(400.0, 0.0)), "Alarm cancelled the stop.")
	await get_tree().create_timer(0.08).timeout
	_expect(golem.global_position.is_equal_approx(stopped_position), "Disabled golem continued moving.")

	get_tree().paused = true
	_expect(not harness.analyze_current_target(), "Analysis executed while exploration was paused.")
	_expect(not harness.use_current_harness_action(), "Discharge executed while exploration was paused.")
	await get_tree().create_timer(0.4).timeout
	_expect(golem.get_state() == BrokenGuardGolem.State.DISABLED, "Discharge timer advanced during pause.")
	get_tree().paused = false

	player.global_position = Vector2(600.0, 0.0)
	await _settle()
	_expect(harness.get_basic_analysis().is_empty(), "Out-of-range target retained analysis.")
	_expect(not status.is_prompt_visible(), "Out-of-range target retained the Q prompt.")
	_expect(not harness.use_current_harness_action(), "Out-of-range action succeeded.")
	await get_tree().create_timer(0.3).timeout
	_expect(golem.get_state() == BrokenGuardGolem.State.SEARCH, "Escaped player was reacquired without detection.")
	_expect(golem.get_last_known_position().is_equal_approx(last_seen_position), "Stopped golem secretly tracked an escaping player.")
	await get_tree().create_timer(0.2).timeout
	_expect(golem.get_state() == BrokenGuardGolem.State.PATROL, "Recovered golem did not return to patrol.")
	_expect(not golem.can_be_permanently_defeated(), "Discharge allowed permanent defeat.")
	_expect(harness.get_current_charge() == 0, "Rejected commands changed empty charge.")

	space.queue_free()
	await _settle()


func _check_recovery_with_player_present() -> void:
	var space := Node2D.new()
	add_child(space)
	var player: PlayerController = PLAYER_SCENE.instantiate()
	player.movement_speed = 0.0
	space.add_child(player)
	var harness := player.get_node("HarnessController") as HarnessController
	harness.configure_charge(2)
	var golem: BrokenGuardGolem = GOLEM_SCENE.instantiate()
	golem.position = Vector2(60.0, 0.0)
	golem.patrol_speed = 0.0
	golem.suspicious_speed = 0.0
	golem.chase_speed = 0.0
	golem.suspicion_duration = 0.2
	golem.discharge_duration = 0.4
	space.add_child(golem)
	await _settle()

	for invalid_cost in [0, -1]:
		golem.discharge_charge_cost = invalid_cost
		_expect(not harness.use_current_harness_action(), "Nonpositive discharge cost was accepted.")
		_expect(harness.get_current_charge() == 2, "Invalid cost changed charge.")
	golem.discharge_charge_cost = 1
	_expect(harness.use_current_harness_action(), "Valid discharge failed.")
	player.position = Vector2(400.0, 0.0)
	await _settle()
	player.position = Vector2.ZERO
	await _settle()
	_expect(golem.get_state() == BrokenGuardGolem.State.DISABLED, "Re-entry cancelled the stop early.")
	await get_tree().create_timer(0.32).timeout
	_expect(golem.get_state() == BrokenGuardGolem.State.SUSPICIOUS, "Recovery did not warn again about a nearby player.")
	await get_tree().create_timer(0.22).timeout
	_expect(golem.get_state() == BrokenGuardGolem.State.CHASE, "Recovered golem never resumed chasing.")

	harness.configure_charge(0)
	_expect(not harness.get_basic_analysis().is_empty(), "Empty charge hid basic analysis.")
	_expect(not harness.analyze_current_target(), "Precise analysis succeeded with empty charge.")
	_expect(not harness.use_current_harness_action(), "Discharge succeeded with empty charge.")
	_expect(golem.get_state() == BrokenGuardGolem.State.CHASE, "Rejected discharge stopped the golem.")
	harness.configure_charge(1)
	_expect(harness.use_current_harness_action(), "Golem could not be stopped again after recovery.")
	_expect(harness.get_current_charge() == 0, "Second successful discharge had an incorrect cost.")

	space.queue_free()
	await _settle()


func _check_analysis_boundaries() -> void:
	var space := Node2D.new()
	add_child(space)
	var player: PlayerController = PLAYER_SCENE.instantiate()
	player.movement_speed = 0.0
	space.add_child(player)
	var harness := player.get_node("HarnessController") as HarnessController
	var detector := player.get_node("HazardDetector") as HazardDetector
	harness.configure_charge(2)
	_expect(not harness.analyze_current_target(), "Analysis without a target succeeded.")
	var golem: BrokenGuardGolem = GOLEM_SCENE.instantiate()
	golem.position = Vector2(70.0, 0.0)
	golem.patrol_speed = 0.0
	golem.suspicious_speed = 0.0
	golem.suspicion_duration = 5.0
	space.add_child(golem)
	await _settle()
	for invalid_cost in [0, -1]:
		golem.analysis_charge_cost = invalid_cost
		_expect(not harness.analyze_current_target(), "Nonpositive analysis cost was accepted.")
		_expect(harness.get_current_charge() == 2, "Invalid analysis cost changed charge.")
	golem.analysis_charge_cost = 3
	_expect(not harness.analyze_current_target(), "Analysis ignored insufficient charge.")
	golem.analysis_charge_cost = 1
	_expect(harness.analyze_current_target(), "Valid golem analysis failed.")
	_expect(harness.get_precise_analysis().contains("계속 노출"), "Golem analysis did not describe its current state.")
	golem.queue_free()
	detector.refresh_current_hazard()
	_expect(harness.get_precise_analysis().is_empty(), "Queued deletion retained precise information.")
	_expect(not harness.analyze_current_target(), "Queued target deletion allowed analysis.")
	await _settle()
	_expect(harness.get_basic_analysis().is_empty(), "Freed target retained basic information.")
	_expect(harness.get_current_charge() == 1, "Rejected or stale readings changed charge.")
	var refusing_hazard := RefusingHazard.new()
	refusing_hazard.collision_layer = 4
	refusing_hazard.collision_mask = 0
	var shape := CollisionShape2D.new()
	shape.shape = CircleShape2D.new()
	refusing_hazard.add_child(shape)
	space.add_child(refusing_hazard)
	await _settle()
	_expect(detector.get_current_hazard() == refusing_hazard, "Refusing target was not detected.")
	_expect(not harness.use_current_harness_action(), "A refused physical action was reported as successful.")
	_expect(harness.get_current_charge() == 1, "A refused physical action failed to refund its reservation.")
	space.queue_free()
	await _settle()


func _press_q() -> void:
	var event := InputEventKey.new()
	event.physical_keycode = KEY_Q
	event.pressed = true
	get_viewport().push_input(event)
	var release := InputEventKey.new()
	release.physical_keycode = KEY_Q
	get_viewport().push_input(release)


func _settle(frames := 4) -> void:
	for _frame in range(frames):
		await get_tree().physics_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
