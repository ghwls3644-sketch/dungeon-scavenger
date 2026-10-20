class_name HubDeparturePanel
extends Control

signal confirmation_requested(request_id: int)
signal close_requested(request_id: int)

var _request_id := 0


func _ready() -> void:
	%ReturnToHub.pressed.connect(func(): close_requested.emit(_request_id))
	%ProceedDeparture.pressed.connect(func(): confirmation_requested.emit(_request_id))


func present(request_id: int) -> void:
	_request_id = request_id
	show()
	%ReturnToHub.grab_focus()


func _unhandled_key_input(event: InputEvent) -> void:
	if is_visible_in_tree() and event.is_action_pressed(InputActions.PAUSE) and not event.is_echo():
		close_requested.emit(_request_id)
		get_viewport().set_input_as_handled()
