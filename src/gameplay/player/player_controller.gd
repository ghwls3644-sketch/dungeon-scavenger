class_name PlayerController
extends CharacterBody2D

@export var movement_speed := 0.0


func _physics_process(_delta: float) -> void:
	velocity = InputActions.get_move_vector() * movement_speed
	move_and_slide()
