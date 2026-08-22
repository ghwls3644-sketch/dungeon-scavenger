class_name PlayerInventory
extends Node

signal inventory_changed
signal item_added(item: ItemDefinition)
signal item_dropped(item: ItemDefinition)
signal item_add_rejected(item: ItemDefinition, reason: StringName)

enum WeightStage {
	NORMAL,
	BURDENED,
	OVERLOADED,
}

const REJECT_INVALID_ITEM: StringName = &"invalid_item"
const REJECT_INVALID_CONFIGURATION: StringName = &"invalid_configuration"
const REJECT_SLOT_LIMIT: StringName = &"slot_limit"

@export var slot_capacity := 0
@export var burden_weight := 0.0
@export var overload_weight := 0.0

var _items: Array[ItemDefinition] = []
var _selected_index := -1


func configure_capacity(capacity: int, burden_threshold: float, overload_threshold: float) -> void:
	slot_capacity = capacity
	burden_weight = burden_threshold
	overload_weight = overload_threshold
	inventory_changed.emit()


func get_configuration_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if slot_capacity <= 0:
		errors.append("slot_capacity must be positive.")
	if burden_weight <= 0.0:
		errors.append("burden_weight must be positive.")
	if overload_weight <= burden_weight:
		errors.append("overload_weight must be greater than burden_weight.")
	return errors


func try_add_item(item: ItemDefinition) -> bool:
	if not _is_valid_inventory_item(item):
		item_add_rejected.emit(item, REJECT_INVALID_ITEM)
		return false
	if not get_configuration_errors().is_empty():
		item_add_rejected.emit(item, REJECT_INVALID_CONFIGURATION)
		return false
	if get_used_slots() + item.slot_size > slot_capacity:
		item_add_rejected.emit(item, REJECT_SLOT_LIMIT)
		return false

	_items.append(item)
	_selected_index = _items.size() - 1
	item_added.emit(item)
	inventory_changed.emit()
	return true


func select_item(index: int) -> bool:
	if index < 0 or index >= _items.size():
		return false
	_selected_index = index
	inventory_changed.emit()
	return true


func drop_selected_item() -> ItemDefinition:
	if _selected_index < 0 or _selected_index >= _items.size():
		return null

	var dropped_item := _items[_selected_index]
	_items.remove_at(_selected_index)
	_selected_index = mini(_selected_index, _items.size() - 1)
	item_dropped.emit(dropped_item)
	inventory_changed.emit()
	return dropped_item


func get_items() -> Array[ItemDefinition]:
	return _items.duplicate()


func get_selected_index() -> int:
	return _selected_index


func get_used_slots() -> int:
	var used_slots := 0
	for item in _items:
		used_slots += item.slot_size
	return used_slots


func get_total_weight() -> float:
	var total_weight := 0.0
	for item in _items:
		total_weight += item.weight
	return total_weight


func get_weight_stage() -> WeightStage:
	var total_weight := get_total_weight()
	if overload_weight > burden_weight and total_weight >= overload_weight:
		return WeightStage.OVERLOADED
	if burden_weight > 0.0 and total_weight >= burden_weight:
		return WeightStage.BURDENED
	return WeightStage.NORMAL


func _is_valid_inventory_item(item: ItemDefinition) -> bool:
	return (
		item != null
		and item.slot_size > 0
		and item.get_validation_errors().is_empty()
	)
