extends Node2D

const GOLEM_SCRIPT := preload("res://src/gameplay/hazards/broken_guard_golem.gd")

@onready var _golem := %BrokenGuardGolem
@onready var _detection_guide: Polygon2D = %DetectionGuide
@onready var _state_status: Label = %StateStatus
@onready var _event_status: Label = %EventStatus


func _ready() -> void:
	_golem.state_changed.connect(_on_state_changed)
	_golem.warning_started.connect(_on_warning_started)
	_golem.chase_started.connect(_on_chase_started)
	_golem.search_started.connect(_on_search_started)
	_update_state_status()


func _process(_delta: float) -> void:
	_detection_guide.global_position = _golem.global_position


func _on_state_changed(_previous_state: int, _current_state: int) -> void:
	_update_state_status()


func _on_warning_started(_last_known_position: Vector2) -> void:
	_event_status.text = "탐지음이 먼저 울렸습니다. 시야에서 벗어나면 수색으로 낮아집니다."


func _on_chase_started(_last_known_position: Vector2) -> void:
	_event_status.text = "추적 중입니다. 골렘을 처치하지 말고 경로를 바꿔 벗어나세요."


func _on_search_started(_last_known_position: Vector2) -> void:
	_event_status.text = "마지막 위치를 수색합니다. 잠시 뒤 순찰로 돌아갑니다."


func _update_state_status() -> void:
	var state_name := "순찰"
	match _golem.get_state():
		GOLEM_SCRIPT.State.SUSPICIOUS:
			state_name = "의심"
		GOLEM_SCRIPT.State.CHASE:
			state_name = "추적"
		GOLEM_SCRIPT.State.SEARCH:
			state_name = "수색"
	_state_status.text = "현재 상태: %s | %s" % [state_name, _golem.get_status_text()]
