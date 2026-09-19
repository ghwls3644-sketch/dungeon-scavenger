class_name QuickDropController
extends Node

signal status_changed

@export var inventory_path: NodePath
# Prototype timing, configurable independently of item and movement balance.
@export var hold_duration := 0.6

var _inventory: PlayerInventory
var _active := false
var _pressed := false
var _target: InventoryItem
var _elapsed := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_inventory = get_node(inventory_path) as PlayerInventory
	_inventory.inventory_changed.connect(_on_inventory_changed)


func set_active(active: bool) -> void:
	_active = active
	cancel_hold()
	_pressed = InputActions.is_pressed(InputActions.QUICK_DROP)


func cancel_hold() -> void:
	_target = null
	_elapsed = 0.0
	status_changed.emit()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		cancel_hold()


func _input(event: InputEvent) -> void:
	if event.is_action_released(InputActions.QUICK_DROP):
		_pressed = false
		cancel_hold()
	elif event.is_action_pressed(InputActions.QUICK_DROP):
		if _pressed:
			return
		_pressed = true
		if not _can_drop() or not is_finite(hold_duration) or hold_duration <= 0.0:
			return
		_target = _inventory.get_quick_drop_item()
		_elapsed = 0.0
		status_changed.emit()


func _physics_process(delta: float) -> void:
	if _target == null:
		return
	if not _can_drop() or _inventory.get_quick_drop_item() != _target:
		cancel_hold()
		return
	_elapsed += delta
	if _elapsed >= hold_duration:
		var target := _target
		cancel_hold()
		_inventory.drop_quick_drop_item(target)
	else:
		status_changed.emit()


func get_progress() -> float:
	return clampf(_elapsed / hold_duration, 0.0, 1.0) if _target != null and hold_duration > 0.0 else 0.0


func is_holding() -> bool:
	return _target != null


func _can_drop() -> bool:
	return _active and not get_tree().paused and _inventory.can_process()


func _on_inventory_changed() -> void:
	if _target != null and _inventory.get_quick_drop_item() != _target:
		cancel_hold()
	else:
		status_changed.emit()
