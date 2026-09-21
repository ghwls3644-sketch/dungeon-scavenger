class_name DoorHoldTarget
extends StabilizableHazard

@onready var _door: TemporaryDoor = get_parent()


func get_analysis_charge_cost() -> int:
	return 0


func get_basic_analysis() -> String:
	return _door.get_basic_analysis()


func get_stabilization_charge_cost() -> int:
	return _door.get_hold_cost()


func can_stabilize() -> bool:
	return _door.can_hold()


func stabilize() -> bool:
	return _door.hold_closed()
