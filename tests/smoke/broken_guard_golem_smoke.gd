extends Node

const PLAYER_SCENE := preload("res://src/gameplay/player/player.tscn")
const GOLEM_SCRIPT := preload("res://src/gameplay/hazards/broken_guard_golem.gd")
const GOLEM_SCENE := preload("res://src/gameplay/hazards/broken_guard_golem.tscn")

var _failures := PackedStringArray()
var _warning_count := 0
var _chase_count := 0
var _search_count := 0


func _ready() -> void:
	await _run_broken_guard_golem_checks()

	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"broken_guard_golem_passed")
		get_tree().quit(0)
		return

	for failure in _failures:
		GameLog.error(&"SmokeTest", &"broken_guard_golem_failed", failure)
	get_tree().quit(1)


func _run_broken_guard_golem_checks() -> void:
	var golem := GOLEM_SCENE.instantiate()
	golem.patrol_offset = Vector2(100.0, 0.0)
	golem.patrol_speed = 80.0
	golem.suspicious_speed = 90.0
	golem.chase_speed = 140.0
	golem.search_speed = 100.0
	golem.suspicion_duration = 0.08
	golem.search_duration = 0.08
	golem.warning_started.connect(_on_warning_started)
	golem.chase_started.connect(_on_chase_started)
	golem.search_started.connect(_on_search_started)
	add_child(golem)

	var player: PlayerController = PLAYER_SCENE.instantiate()
	player.movement_speed = 0.0
	player.position = Vector2(-360.0, 0.0)
	add_child(player)

	var patrol_start: Vector2 = golem.global_position
	for _frame in range(4):
		await get_tree().physics_frame
	_expect(
		golem.global_position.distance_to(patrol_start) > 0.5,
		"Golem did not move along its configured patrol route."
	)
	_expect(
		golem.get_status_text().contains("발소리") and golem.get_status_text().contains("긁힌 흔적"),
		"Patrol state did not expose readable advance clues."
	)
	_expect(not golem.can_be_permanently_defeated(), "Golem incorrectly allowed permanent defeat.")

	player.global_position = golem.global_position + Vector2(90.0, 0.0)
	for _frame in range(4):
		await get_tree().physics_frame
		if golem.get_state() == GOLEM_SCRIPT.State.SUSPICIOUS:
			break
	_expect(
		golem.get_state() == GOLEM_SCRIPT.State.SUSPICIOUS,
		"Visual detection skipped the suspicious warning state."
	)
	_expect(_warning_count == 1, "Visual detection did not emit exactly one warning clue.")
	_expect(_chase_count == 0, "Golem started chasing before the warning duration.")
	_expect(golem.get_status_text().contains("탐지음"), "Suspicious state did not expose a detection-sound clue.")

	var distance_before_chase: float = golem.global_position.distance_to(player.global_position)
	await get_tree().create_timer(0.1).timeout
	_expect(golem.get_state() == GOLEM_SCRIPT.State.CHASE, "Golem did not chase after sustained detection.")
	_expect(_chase_count == 1, "Sustained detection did not emit one chase event.")
	await get_tree().create_timer(0.05).timeout
	_expect(
		golem.global_position.distance_to(player.global_position) < distance_before_chase,
		"Chasing golem did not pressure the player's route."
	)

	var detection_exit_position: Vector2 = golem.global_position + Vector2(200.0, 0.0)
	player.global_position = detection_exit_position
	for _frame in range(4):
		await get_tree().physics_frame
		if golem.get_state() == GOLEM_SCRIPT.State.SEARCH:
			break
	_expect(golem.get_state() == GOLEM_SCRIPT.State.SEARCH, "Golem did not search after losing the player.")
	_expect(_search_count == 1, "Losing the player did not emit one search event.")
	_expect(
		golem.get_last_known_position().distance_to(detection_exit_position) < 12.0,
		"Search state did not retain the player's last known position."
	)
	await get_tree().create_timer(0.1).timeout
	_expect(golem.get_state() == GOLEM_SCRIPT.State.PATROL, "Search did not lower back to patrol.")

	var noise_position: Vector2 = golem.global_position + Vector2(-70.0, 20.0)
	_expect(golem.investigate_noise(noise_position), "Golem rejected a noise while patrolling.")
	_expect(golem.get_state() == GOLEM_SCRIPT.State.SUSPICIOUS, "Noise did not start an investigation.")
	_expect(
		golem.get_last_known_position().is_equal_approx(noise_position),
		"Noise investigation did not keep its source position."
	)
	await get_tree().create_timer(0.1).timeout
	_expect(golem.get_state() == GOLEM_SCRIPT.State.SEARCH, "Unconfirmed noise did not lower into search.")
	await get_tree().create_timer(0.1).timeout
	_expect(golem.get_state() == GOLEM_SCRIPT.State.PATROL, "Noise search did not return to patrol.")

	var alarm_position: Vector2 = golem.global_position + Vector2(90.0, 0.0)
	_expect(golem.raise_alarm(alarm_position), "Golem rejected an external alarm.")
	_expect(golem.get_state() == GOLEM_SCRIPT.State.SUSPICIOUS, "Alarm skipped the warning state.")
	await get_tree().create_timer(0.1).timeout
	_expect(golem.get_state() == GOLEM_SCRIPT.State.CHASE, "Alarm did not escalate into a chase.")
	_expect(_warning_count == 3, "Detection, noise, and alarm did not each provide a warning.")
	_expect(_chase_count == 2, "Detection and alarm did not each escalate into a chase.")
	_expect(
		golem.raise_alarm(alarm_position + Vector2(20.0, 0.0)),
		"Golem rejected an alarm while already chasing."
	)
	_expect(golem.get_state() == GOLEM_SCRIPT.State.CHASE, "Repeated alarm lowered an active chase.")
	_expect(_warning_count == 3, "Repeated alarm added a warning after chase had already started.")


func _on_warning_started(_last_known_position: Vector2) -> void:
	_warning_count += 1


func _on_chase_started(_last_known_position: Vector2) -> void:
	_chase_count += 1


func _on_search_started(_last_known_position: Vector2) -> void:
	_search_count += 1


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
