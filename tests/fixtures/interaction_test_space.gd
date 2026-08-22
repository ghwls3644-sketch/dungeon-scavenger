extends Node2D

@onready var _pickup: PickupInteractable = $PickupInteractable
@onready var _door: DoorInteractable = $DoorInteractable
@onready var _result_status: Label = %ResultStatus


func _ready() -> void:
	_pickup.collected.connect(_on_pickup_collected)
	_door.open_state_changed.connect(_on_door_open_state_changed)


func _on_pickup_collected(_interactor: Node) -> void:
	_result_status.text = "회수품 상호작용 완료"


func _on_door_open_state_changed(is_open: bool) -> void:
	_result_status.text = "문 열림" if is_open else "문 닫힘"
