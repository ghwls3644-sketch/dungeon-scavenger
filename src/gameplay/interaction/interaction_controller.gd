class_name InteractionController
extends Node

signal prompt_changed(prompt: String, should_show: bool)

@export var detector_path: NodePath
@export var interactor_path: NodePath

var _detector: InteractionDetector
var _interactor: Node


func _ready() -> void:
	_detector = get_node_or_null(detector_path) as InteractionDetector
	_interactor = get_node_or_null(interactor_path)
	assert(_detector != null, "InteractionController requires an InteractionDetector.")
	assert(_interactor != null, "InteractionController requires an interactor node.")
	_detector.current_interactable_changed.connect(_on_current_interactable_changed)
	_publish_prompt(_detector.get_current_interactable())


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed(InputActions.INTERACT):
		return
	if not interact_current():
		return

	get_viewport().set_input_as_handled()


func interact_current() -> bool:
	var interactable := _detector.get_current_interactable()
	if interactable == null:
		return false
	if not interactable.interact(_interactor):
		return false

	_detector.refresh_current_interactable()
	return true


func get_current_prompt() -> String:
	var interactable := _detector.get_current_interactable()
	if interactable == null:
		return ""
	return interactable.get_interaction_prompt()


func _on_current_interactable_changed(interactable: Interactable) -> void:
	_publish_prompt(interactable)


func _publish_prompt(interactable: Interactable) -> void:
	if interactable == null:
		prompt_changed.emit("", false)
		return

	prompt_changed.emit(interactable.get_interaction_prompt(), true)
