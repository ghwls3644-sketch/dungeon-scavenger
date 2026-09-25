class_name Interactable
extends Area2D

signal interacted(interactor: Node)

enum Action { INSTANT, INSPECT, RECOVER }

@export var interaction_prompt := ""

var _interaction_enabled := true
var _interacting := false


func get_interaction_prompt() -> String:
	return interaction_prompt


func is_interaction_available(_interactor: Node = null) -> bool:
	return _interaction_enabled and not _interacting and is_inside_tree() and not is_queued_for_deletion()


func get_interaction_action() -> Action:
	return Action.INSTANT


func get_interaction_block_reason(_interactor: Node) -> String:
	return ""


func interact(interactor: Node) -> bool:
	if not is_interaction_available(interactor):
		return false

	# Signals from inventory/inspection may synchronously attempt this same action.
	_interacting = true
	if not _perform_interaction(interactor):
		_interacting = false
		return false
	interacted.emit(interactor)
	_interacting = false
	return true


func set_interaction_enabled(enabled: bool) -> void:
	_interaction_enabled = enabled


func _perform_interaction(_interactor: Node) -> bool:
	push_error("Interactable subclasses must implement _perform_interaction().")
	return false
