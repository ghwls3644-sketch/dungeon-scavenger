class_name Interactable
extends Area2D

signal interacted(interactor: Node)

@export var interaction_prompt := ""

var _interaction_enabled := true


func get_interaction_prompt() -> String:
	return interaction_prompt


func is_interaction_available(_interactor: Node = null) -> bool:
	return _interaction_enabled and is_inside_tree()


func interact(interactor: Node) -> bool:
	if not is_interaction_available(interactor):
		return false

	if not _perform_interaction(interactor):
		return false
	interacted.emit(interactor)
	return true


func set_interaction_enabled(enabled: bool) -> void:
	_interaction_enabled = enabled


func _perform_interaction(_interactor: Node) -> bool:
	push_error("Interactable subclasses must implement _perform_interaction().")
	return false
