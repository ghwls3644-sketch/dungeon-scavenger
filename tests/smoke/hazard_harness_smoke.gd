extends Node

const PLAYER_SCENE := preload("res://src/gameplay/player/player.tscn")
const HAZARD_SCENE := preload("res://src/gameplay/hazards/unstable_debris_hazard.tscn")
const HARNESS_STATUS_SCENE := preload("res://src/ui/harness_status.tscn")

var _failures := PackedStringArray()
var _caught_count := 0


func _ready() -> void:
	await _run_hazard_harness_checks()

	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"hazard_harness_passed")
		get_tree().quit(0)
		return

	for failure in _failures:
		GameLog.error(&"SmokeTest", &"hazard_harness_failed", failure)
	get_tree().quit(1)


func _run_hazard_harness_checks() -> void:
	var player: PlayerController = PLAYER_SCENE.instantiate()
	player.movement_speed = 0.0
	add_child(player)
	var detector := player.get_node("HazardDetector") as HazardDetector
	var harness := player.get_node("HarnessController") as HarnessController
	_expect(harness.configure_charge(2), "Harness charge configuration was rejected.")

	var status: HarnessStatus = HARNESS_STATUS_SCENE.instantiate()
	add_child(status)
	status.bind_source(harness)

	var stabilized_hazard: UnstableDebrisHazard = HAZARD_SCENE.instantiate()
	stabilized_hazard.warning_duration = 0.1
	stabilized_hazard.body_caught.connect(_on_body_caught)
	add_child(stabilized_hazard)

	await get_tree().physics_frame
	await get_tree().physics_frame
	detector.refresh_current_hazard()
	_expect(
		stabilized_hazard.get_state() == UnstableDebrisHazard.State.WARNING,
		"Hazard did not enter the warning state before triggering."
	)
	_expect(stabilized_hazard.get_status_text().contains("먼지와 진동"), "Hazard warning did not expose a readable clue.")
	_expect(
		detector.get_current_hazard() == stabilized_hazard,
		"Hazard detector did not select the warned hazard. overlaps=%d" % detector.get_overlapping_areas().size()
	)
	_expect(status.is_prompt_visible(), "Harness prompt was not shown during the warning window.")
	_expect(status.get_status_text().contains("[Q]"), "Harness prompt did not show the configured action key.")
	_expect(harness.use_current_harness_action(), "Harness stabilization did not execute during the warning.")
	_expect(
		stabilized_hazard.get_state() == UnstableDebrisHazard.State.STABILIZED,
		"Hazard did not enter the stabilized state."
	)
	_expect(harness.get_current_charge() == 1, "Successful stabilization did not spend one test charge.")
	_expect(not status.is_prompt_visible(), "Harness prompt remained after stabilization.")
	_expect(status.get_status_text().contains("1/2"), "Harness UI did not update the remaining test charge.")

	await get_tree().create_timer(0.15).timeout
	_expect(
		stabilized_hazard.get_state() == UnstableDebrisHazard.State.STABILIZED,
		"Stabilized hazard triggered after its warning duration."
	)
	_expect(_caught_count == 0, "Stabilized hazard caught the player.")

	var triggered_hazard: UnstableDebrisHazard = HAZARD_SCENE.instantiate()
	triggered_hazard.position = Vector2(240.0, 0.0)
	triggered_hazard.warning_duration = 1.0
	triggered_hazard.body_caught.connect(_on_body_caught)
	add_child(triggered_hazard)
	player.global_position = triggered_hazard.global_position

	for _frame in range(6):
		await get_tree().physics_frame
		if triggered_hazard.get_state() != UnstableDebrisHazard.State.IDLE:
			break
	detector.refresh_current_hazard()
	_expect(
		triggered_hazard.get_state() == UnstableDebrisHazard.State.WARNING,
		"Second hazard skipped its warning state."
	)
	_expect(triggered_hazard.get_status_text().contains("먼지와 진동"), "Second hazard did not show a clue before triggering.")

	await get_tree().create_timer(1.1).timeout
	_expect(
		triggered_hazard.get_state() == UnstableDebrisHazard.State.TRIGGERED,
		"Unanswered hazard did not trigger after the warning window."
	)
	_expect(_caught_count == 1, "Player remaining in the unanswered hazard was not caught exactly once.")
	_expect(harness.get_current_charge() == 1, "Unanswered hazard changed harness charge.")


func _on_body_caught(body: Node2D) -> void:
	if body is PlayerController:
		_caught_count += 1


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
