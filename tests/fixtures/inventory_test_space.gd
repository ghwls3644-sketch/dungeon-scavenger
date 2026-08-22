extends Node2D

@onready var _inventory: PlayerInventory = $Player/Inventory


func _ready() -> void:
	_inventory.configure_capacity(2, 2.0, 3.0)
