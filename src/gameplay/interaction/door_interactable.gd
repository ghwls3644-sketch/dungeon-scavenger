class_name DoorInteractable
extends Interactable

signal open_state_changed(is_open: bool)

@export var open_prompt := ""
@export var close_prompt := ""

var is_open := false

@onready var _barrier_collision: CollisionShape2D = %BarrierCollision
@onready var _door_visual: Polygon2D = %DoorVisual


func get_interaction_prompt() -> String:
	return close_prompt if is_open else open_prompt


func is_blocking() -> bool:
	return not _barrier_collision.disabled


func _perform_interaction(_interactor: Node) -> void:
	is_open = not is_open
	_barrier_collision.set_deferred(&"disabled", is_open)
	_door_visual.modulate.a = 0.35 if is_open else 1.0
	open_state_changed.emit(is_open)
