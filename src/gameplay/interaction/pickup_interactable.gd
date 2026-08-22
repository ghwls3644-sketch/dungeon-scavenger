class_name PickupInteractable
extends Interactable

signal collected(interactor: Node)


func _perform_interaction(interactor: Node) -> void:
	set_interaction_enabled(false)
	collected.emit(interactor)
	hide()
	queue_free()
