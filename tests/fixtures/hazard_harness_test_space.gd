extends Node2D

@onready var _harness: HarnessController = $Player/HarnessController
@onready var _hazard: UnstableDebrisHazard = %UnstableDebrisHazard
@onready var _result_status: Label = %ResultStatus


func _ready() -> void:
	_harness.configure_charge(2)
	_hazard.warning_started.connect(_on_warning_started)
	_hazard.stabilized.connect(_on_stabilized)
	_hazard.hazard_triggered.connect(_on_hazard_triggered)
	_hazard.body_caught.connect(_on_body_caught)


func _on_warning_started(_duration: float) -> void:
	_result_status.text = "먼지와 진동이 보입니다. 붕괴 전에 Q로 안정화하세요."


func _on_stabilized() -> void:
	_result_status.text = "하네스로 잔해를 안정화했습니다."


func _on_hazard_triggered() -> void:
	_result_status.text = "잔해가 붕괴했습니다."


func _on_body_caught(body: Node2D) -> void:
	if body is PlayerController:
		_result_status.text = "붕괴 범위 안에 남아 있었습니다."
