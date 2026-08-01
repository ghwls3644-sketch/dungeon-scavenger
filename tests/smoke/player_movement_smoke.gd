extends Node

const PLAYER_SCENE := preload("res://src/gameplay/player/player.tscn")

var _failures := PackedStringArray()


func _ready() -> void:
	await _run_movement_checks()
	_cleanup_input()
	get_tree().paused = false

	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"player_movement_passed")
		get_tree().quit(0)
		return

	for failure in _failures:
		GameLog.error(&"SmokeTest", &"player_movement_failed", failure)
	get_tree().quit(1)


func _run_movement_checks() -> void:
	var player: PlayerController = PLAYER_SCENE.instantiate()
	add_child(player)
	await get_tree().physics_frame

	var camera := player.get_node_or_null("Camera2D") as Camera2D
	_expect(camera != null and camera.enabled, "Player camera must exist and be enabled.")
	_expect(player.movement_speed > 0.0, "Prototype movement speed must be positive.")

	var start_position := player.global_position
	Input.action_press(InputActions.MOVE_RIGHT)
	await get_tree().physics_frame
	await get_tree().physics_frame
	_expect(player.global_position.x > start_position.x, "Move-right input did not move the player.")
	_expect(
		is_equal_approx(player.velocity.length(), player.movement_speed),
		"Single-axis movement speed was not stable."
	)

	Input.action_press(InputActions.MOVE_DOWN)
	await get_tree().physics_frame
	_expect(
		is_equal_approx(player.velocity.length(), player.movement_speed),
		"Diagonal movement exceeded the configured movement speed."
	)
	if camera != null:
		_expect(
			camera.global_position.is_equal_approx(player.global_position),
			"Camera did not follow the player position."
		)

	get_tree().paused = true
	var paused_position := player.global_position
	await get_tree().physics_frame
	await get_tree().physics_frame
	_expect(
		player.global_position.is_equal_approx(paused_position),
		"Player moved while the scene tree was paused."
	)


func _cleanup_input() -> void:
	Input.action_release(InputActions.MOVE_RIGHT)
	Input.action_release(InputActions.MOVE_DOWN)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
