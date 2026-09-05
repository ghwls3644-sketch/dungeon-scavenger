class_name PlayerInventory
extends Node

signal inventory_changed
signal item_added(item: ItemDefinition)
signal item_dropped(item: ItemDefinition)
signal item_add_rejected(item: ItemDefinition, reason: StringName)
signal item_drop_rejected(reason: StringName)

enum WeightStage {
	NORMAL,
	BURDENED,
	OVERLOADED,
}

const REJECT_INVALID_ITEM: StringName = &"invalid_item"
const REJECT_INVALID_CONFIGURATION: StringName = &"invalid_configuration"
const REJECT_SLOT_LIMIT: StringName = &"slot_limit"
const REJECT_PROTECTED_ITEM: StringName = &"protected_item"
const REJECT_NO_SELECTION: StringName = &"no_selection"

@export var slot_capacity := 0
@export var burden_weight := 0.0
@export var overload_weight := 0.0

var _items: Array[InventoryItem] = []
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


func try_add_item(item: ItemDefinition, starts_identified := true, known_risk_hint := "") -> bool:
	return try_add_inventory_item(InventoryItem.from_definition(item, starts_identified, known_risk_hint))


func try_add_inventory_item(item: InventoryItem) -> bool:
	var definition := item.get_definition() if item != null else null
	if not _is_valid_inventory_item(item):
		item_add_rejected.emit(definition, REJECT_INVALID_ITEM)
		return false
	if not get_configuration_errors().is_empty():
		item_add_rejected.emit(definition, REJECT_INVALID_CONFIGURATION)
		return false
	if get_used_slots() + definition.slot_size > slot_capacity:
		item_add_rejected.emit(definition, REJECT_SLOT_LIMIT)
		return false

	_items.append(item)
	_selected_index = _items.size() - 1
	item_added.emit(definition)
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
		item_drop_rejected.emit(REJECT_NO_SELECTION)
		return null

	var dropped_item := _items[_selected_index]
	var definition := dropped_item.get_definition()
	if definition.is_protected():
		item_drop_rejected.emit(REJECT_PROTECTED_ITEM)
		return null

	_items.remove_at(_selected_index)
	_selected_index = mini(_selected_index, _items.size() - 1)
	item_dropped.emit(definition)
	inventory_changed.emit()
	return definition


func get_items() -> Array[ItemDefinition]:
	var definitions: Array[ItemDefinition] = []
	for item in _items:
		definitions.append(item.get_definition())
	return definitions


func get_inventory_items() -> Array[InventoryItem]:
	return _items.duplicate()


func take_all_items() -> Array[ItemDefinition]:
	var taken_items := get_items()
	_clear_items()
	return taken_items


func take_all_inventory_items() -> Array[InventoryItem]:
	var taken_items := _items.duplicate()
	_clear_items()
	return taken_items


func _clear_items() -> void:
	_items.clear()
	_selected_index = -1
	inventory_changed.emit()


func get_selected_index() -> int:
	return _selected_index


func get_used_slots() -> int:
	var used_slots := 0
	for item in _items:
		used_slots += item.get_definition().slot_size
	return used_slots


func get_total_weight() -> float:
	var total_weight := 0.0
	for item in _items:
		total_weight += item.get_definition().weight
	return total_weight


func get_weight_stage() -> WeightStage:
	var total_weight := get_total_weight()
	if overload_weight > burden_weight and total_weight >= overload_weight:
		return WeightStage.OVERLOADED
	if burden_weight > 0.0 and total_weight >= burden_weight:
		return WeightStage.BURDENED
	return WeightStage.NORMAL


func _is_valid_inventory_item(item: InventoryItem) -> bool:
	if item == null or not item.is_valid():
		return false
	return item.get_definition().slot_size > 0
