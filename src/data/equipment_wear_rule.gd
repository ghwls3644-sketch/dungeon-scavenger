class_name EquipmentWearRule
extends Resource

# Prototype outcome-based wear. Charge, health and repair prices are separate.
@export var max_durability: int = 0
@export var return_damage: int = 0
@export var failure_damage: int = 0


func is_valid() -> bool:
	return max_durability > 0 and return_damage >= 0 and failure_damage >= 0


func get_damage(failure: bool) -> int:
	return failure_damage if failure else return_damage
