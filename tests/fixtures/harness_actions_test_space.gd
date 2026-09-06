extends Node2D

@onready var _harness: HarnessController = $Player/HarnessController
@onready var _event_status: Label = %EventStatus


func _ready() -> void:
	_harness.configure_charge(3)
	_harness.analysis_completed.connect(_on_analysis_completed)
	_harness.action_succeeded.connect(_on_stabilized)
	_harness.discharge_succeeded.connect(_on_discharged)


func _on_analysis_completed(_target: Node2D, _information: String) -> void:
	_event_status.text = "정밀 분석에 충전을 사용했습니다. 남은 충전으로 위험에 대응하세요."


func _on_stabilized(_hazard: StabilizableHazard) -> void:
	_event_status.text = "잔해를 안정화했습니다. 분석과 위험 대응은 같은 충전을 씁니다."


func _on_discharged(_golem: BrokenGuardGolem) -> void:
	_event_status.text = "골렘이 잠시 멈췄습니다. 다시 움직이기 전에 탐지 범위에서 벗어나세요."
