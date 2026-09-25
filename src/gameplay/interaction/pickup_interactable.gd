class_name PickupInteractable
extends Interactable

signal collected(interactor: Node)

@export var item_definition: ItemDefinition
@export var starts_identified := true


func get_interaction_action() -> Action:
	return Action.RECOVER


func get_interaction_block_reason(interactor: Node) -> String:
	var inventory := interactor.get_node_or_null("Inventory") as PlayerInventory
	if inventory == null or item_definition == null or not inventory.get_configuration_errors().is_empty():
		return "지금은 회수할 수 없습니다."
	if inventory.get_used_slots() + item_definition.slot_size > inventory.slot_capacity:
		return "가방 공간이 부족합니다. Tab으로 물품을 비교하세요."
	return ""


func is_interaction_available(interactor: Node = null) -> bool:
	if not super.is_interaction_available(interactor):
		return false
	return item_definition != null


func _perform_interaction(interactor: Node) -> bool:
	var inventory := interactor.get_node_or_null("Inventory") as PlayerInventory
	if inventory == null:
		return false
	if not inventory.try_add_item(item_definition, starts_identified, _get_inventory_risk_hint()):
		return false

	set_interaction_enabled(false)
	collected.emit(interactor)
	hide()
	queue_free()
	return true


func _get_inventory_risk_hint() -> String:
	return ""
