class_name MovementNoiseEmitter
extends Node

signal noise_emitted(source_position: Vector2, radius: float, loud: bool)

@export var player_path: NodePath
@export var inventory_path: NodePath
@export var noise_rule: LoadNoiseRule

var _active := false
var _distance := 0.0

@onready var _player := get_node_or_null(player_path) as PlayerController
@onready var _inventory := get_node_or_null(inventory_path) as PlayerInventory


func _ready() -> void:
	# Sample the motion produced by the player's current physics step.
	process_physics_priority = 1
	process_mode = Node.PROCESS_MODE_ALWAYS


func set_active(active: bool) -> void:
	_active = active
	_distance = 0.0


func get_noise_radius() -> float:
	if noise_rule == null or not noise_rule.is_valid() or not is_instance_valid(_inventory):
		return 0.0
	match _inventory.get_weight_stage():
		PlayerInventory.WeightStage.BURDENED:
			return noise_rule.burdened_radius
		PlayerInventory.WeightStage.OVERLOADED:
			return noise_rule.overloaded_radius
		_:
			return noise_rule.normal_radius


func _physics_process(_delta: float) -> void:
	if not _active or get_tree().paused or not is_instance_valid(_player) or not _player.can_process() or get_noise_radius() <= 0.0:
		_distance = 0.0
		return
	# Input or velocity alone would make footsteps against a wall; global position
	# differences would mistake teleports for walking.
	var moved := _player.get_position_delta().length()
	if not is_finite(moved) or moved <= 0.001:
		_distance = 0.0
		return
	_distance += moved
	if _distance >= noise_rule.step_distance:
		_distance = fmod(_distance, noise_rule.step_distance)
		noise_emitted.emit(
			_player.global_position,
			get_noise_radius(),
			_inventory.get_weight_stage() == PlayerInventory.WeightStage.OVERLOADED
		)
