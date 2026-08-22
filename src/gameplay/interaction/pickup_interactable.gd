class_name PickupInteractable
extends Interactable

signal collected(interactor: Node)

@export var item_definition: ItemDefinition


func is_interaction_available(interactor: Node = null) -> bool:
	if not super.is_interaction_available(interactor):
		return false
	return item_definition != null


func _perform_interaction(interactor: Node) -> bool:
	var inventory := interactor.get_node_or_null("Inventory") as PlayerInventory
	if inventory == null:
		return false
	if not inventory.try_add_item(item_definition):
		return false

	set_interaction_enabled(false)
	collected.emit(interactor)
	hide()
	queue_free()
	return true
