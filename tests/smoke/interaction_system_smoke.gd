extends Node

const PLAYER_SCENE := preload("res://src/gameplay/player/player.tscn")
const PICKUP_SCENE := preload("res://src/gameplay/interaction/pickup_interactable.tscn")
const DOOR_SCENE := preload("res://src/gameplay/interaction/door_interactable.tscn")
const PROMPT_SCENE := preload("res://src/ui/interaction_prompt.tscn")

var _failures := PackedStringArray()
var _pickup_collected := false


func _ready() -> void:
	await _run_interaction_checks()

	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"interaction_system_passed")
		get_tree().quit(0)
		return

	for failure in _failures:
		GameLog.error(&"SmokeTest", &"interaction_system_failed", failure)
	get_tree().quit(1)


func _run_interaction_checks() -> void:
	var player: PlayerController = PLAYER_SCENE.instantiate()
	player.movement_speed = 0.0
	add_child(player)

	var pickup: PickupInteractable = PICKUP_SCENE.instantiate()
	pickup.position = Vector2(40.0, 0.0)
	add_child(pickup)

	var door: DoorInteractable = DOOR_SCENE.instantiate()
	door.position = Vector2(260.0, 0.0)
	add_child(door)

	var controller := player.get_node("InteractionController") as InteractionController
	var detector := player.get_node("InteractionDetector") as InteractionDetector
	var prompt: InteractionPrompt = PROMPT_SCENE.instantiate()
	add_child(prompt)
	prompt.bind_source(controller)

	_expect(pickup is Interactable, "Pickup does not use the shared Interactable interface.")
	_expect(door is Interactable, "Door does not use the shared Interactable interface.")

	await get_tree().physics_frame
	await get_tree().physics_frame
	_expect(detector.get_current_interactable() == pickup, "Detector did not select the pickup.")
	_expect(prompt.visible, "Prompt was not shown for the pickup.")
	_expect(prompt.text.contains(pickup.get_interaction_prompt()), "Pickup prompt text was not presented.")

	pickup.collected.connect(_on_pickup_collected)
	_expect(controller.interact_current(), "Pickup interaction did not execute.")
	_expect(_pickup_collected, "Pickup did not report collection.")
	await get_tree().process_frame
	_expect(not is_instance_valid(pickup), "Pickup remained after interaction.")
	_expect(not prompt.visible, "Prompt remained visible without a target.")

	player.global_position = door.global_position
	await get_tree().physics_frame
	await get_tree().physics_frame
	_expect(detector.get_current_interactable() == door, "Detector did not select the door.")
	_expect(prompt.visible, "Prompt was not shown for the door.")
	_expect(prompt.text.contains(door.open_prompt), "Door open prompt was not presented.")

	_expect(controller.interact_current(), "Door open interaction did not execute.")
	await get_tree().physics_frame
	_expect(door.is_open, "Door did not enter the open state.")
	_expect(not door.is_blocking(), "Open door continued blocking movement.")
	_expect(prompt.text.contains(door.close_prompt), "Door prompt did not update after opening.")

	_expect(controller.interact_current(), "Door close interaction did not execute.")
	await get_tree().physics_frame
	_expect(not door.is_open, "Door did not return to the closed state.")
	_expect(door.is_blocking(), "Closed door did not restore movement blocking.")
	_expect(prompt.text.contains(door.open_prompt), "Door prompt did not update after closing.")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _on_pickup_collected(_interactor: Node) -> void:
	_pickup_collected = true
