class_name PlayerController
extends CharacterBody2D

@export var movement_speed := 0.0
@export var load_movement_rule: LoadMovementRule
@export var survival_path: NodePath

@onready var _inventory := get_node_or_null("Inventory") as PlayerInventory
@onready var _survival := get_node_or_null(survival_path) as PlayerSurvival


func _physics_process(_delta: float) -> void:
	velocity = InputActions.get_move_vector() * get_current_movement_speed()
	move_and_slide()


func get_current_movement_speed() -> float:
	return movement_speed * get_movement_speed_multiplier()


func get_movement_speed_multiplier() -> float:
	var injury := _survival.get_movement_multiplier() if is_instance_valid(_survival) else 1.0
	return get_load_speed_multiplier() * injury


func get_load_speed_multiplier() -> float:
	# Unconfigured legacy/test scenes retain their original movement.
	if load_movement_rule == null or not load_movement_rule.is_valid() or _inventory == null:
		return 1.0
	match _inventory.get_weight_stage():
		PlayerInventory.WeightStage.BURDENED:
			return load_movement_rule.burdened_multiplier
		PlayerInventory.WeightStage.OVERLOADED:
			return load_movement_rule.overloaded_multiplier
		_:
			return 1.0
