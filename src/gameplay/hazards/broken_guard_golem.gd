class_name BrokenGuardGolem
extends CharacterBody2D

signal state_changed(previous_state: int, current_state: int)
signal warning_started(last_known_position: Vector2)
signal chase_started(last_known_position: Vector2)
signal search_started(last_known_position: Vector2)
signal sight_lost(last_known_position: Vector2)
signal obstacle_contacted(obstacle: Node2D)

enum State {
	PATROL,
	SUSPICIOUS,
	CHASE,
	SEARCH,
	DISABLED,
}

@export var patrol_offset := Vector2(180.0, 0.0)
@export var patrol_speed := 55.0
@export var suspicious_speed := 75.0
@export var chase_speed := 115.0
@export var search_speed := 65.0
@export var suspicion_duration := 0.8
@export var search_duration := 1.5
@export var analysis_charge_cost := 1
@export var discharge_charge_cost := 1
@export var discharge_duration := 1.5
# Opt in on the current expedition; historical G1 fixtures retain their baseline.
@export var use_sight_occlusion := false
@export_flags_2d_physics var sight_blocker_mask := 9

var _state: State = State.PATROL
var _patrol_origin := Vector2.ZERO
var _patrol_destination := Vector2.ZERO
var _last_known_position := Vector2.ZERO
var _tracked_target: Node2D
var _alarm_escalation := false
var _heading_to_patrol_end := true

@onready var _body: Polygon2D = %Body
@onready var _warning_glow: Polygon2D = %WarningGlow
@onready var _status: Label = %Status
@onready var _detection_area: Area2D = %DetectionArea
@onready var _suspicion_timer: Timer = %SuspicionTimer
@onready var _search_timer: Timer = %SearchTimer
@onready var _discharge_timer: Timer = %DischargeTimer


func _ready() -> void:
	_patrol_origin = global_position
	_patrol_destination = _patrol_origin + patrol_offset
	_last_known_position = _patrol_origin
	_detection_area.body_entered.connect(_on_detection_body_entered)
	_detection_area.body_exited.connect(_on_detection_body_exited)
	_suspicion_timer.timeout.connect(_on_suspicion_timeout)
	_search_timer.timeout.connect(_on_search_timeout)
	_discharge_timer.timeout.connect(_on_discharge_timeout)
	if use_sight_occlusion:
		for timer in [_suspicion_timer, _search_timer, _discharge_timer]:
			timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	_render_state()


func _physics_process(_delta: float) -> void:
	if use_sight_occlusion and _state != State.DISABLED:
		_refresh_visual_target()
	match _state:
		State.PATROL:
			if _move_toward_position(_patrol_destination, patrol_speed):
				_heading_to_patrol_end = not _heading_to_patrol_end
				_patrol_destination = (
					_patrol_origin + patrol_offset if _heading_to_patrol_end else _patrol_origin
				)
		State.SUSPICIOUS:
			_move_toward_position(_last_known_position, suspicious_speed)
		State.CHASE:
			if is_instance_valid(_tracked_target):
				_last_known_position = _tracked_target.global_position
			if _move_toward_position(_last_known_position, chase_speed) and not is_instance_valid(_tracked_target):
				_begin_search()
		State.SEARCH:
			_move_toward_position(_last_known_position, search_speed)


func get_state() -> State:
	return _state


func get_status_text() -> String:
	return _status.text


func get_last_known_position() -> Vector2:
	return _last_known_position


func can_be_permanently_defeated() -> bool:
	return false


func get_analysis_charge_cost() -> int:
	return analysis_charge_cost


func get_basic_analysis() -> String:
	if use_sight_occlusion:
		return "%s\n벽·닫힌 문 뒤로 숨으면 마지막으로 본 위치를 수색합니다. 소음은 들릴 수 있습니다." % get_status_text()
	return get_status_text()


func get_precise_analysis() -> String:
	match _state:
		State.SUSPICIOUS:
			return "탐지된 위치를 확인하고 있습니다. 계속 노출되면 추적을 시작합니다."
		State.CHASE:
			if use_sight_occlusion:
				return "추적 중입니다. 벽·닫힌 문으로 시야를 끊거나 비상 방전으로 잠시 멈출 수 있습니다. 소음에는 주의하세요."
			return "추적 중입니다. 비상 방전으로 잠시 멈춘 사이 탐지 범위에서 벗어나세요."
		State.SEARCH:
			return "마지막으로 확인한 위치를 수색합니다. 다시 탐지되지 않으면 순찰로 돌아갑니다."
		State.DISABLED:
			return "비상 방전으로 잠시 정지했습니다. 곧 다시 움직이며 영구 처치는 되지 않습니다."
		_:
			return "순찰 중입니다. 탐지 뒤 경고를 거쳐 추적합니다. 비상 방전은 잠시만 움직임을 멈춥니다."


func get_discharge_charge_cost() -> int:
	return discharge_charge_cost


func can_emergency_discharge() -> bool:
	return _state != State.DISABLED and is_finite(discharge_duration) and discharge_duration > 0.0


func emergency_discharge() -> bool:
	if not can_emergency_discharge():
		return false

	if is_instance_valid(_tracked_target):
		_last_known_position = _tracked_target.global_position
	_tracked_target = null
	_alarm_escalation = false
	_suspicion_timer.stop()
	_search_timer.stop()
	velocity = Vector2.ZERO
	_discharge_timer.start(discharge_duration)
	_set_state(State.DISABLED)
	return true


func can_investigate_noise() -> bool:
	return _state not in [State.CHASE, State.DISABLED] and not is_instance_valid(_tracked_target) and not _alarm_escalation


func investigate_noise(source_position: Vector2) -> bool:
	if not can_investigate_noise():
		return false

	_begin_suspicion(source_position, null, false)
	return true


func investigate_lure(source_position: Vector2) -> bool:
	# A lure can redirect a sound-only chase, but cannot erase stronger evidence.
	if not source_position.is_finite() or _state == State.DISABLED or is_instance_valid(_tracked_target) or _alarm_escalation:
		return false
	_begin_suspicion(source_position, null, false)
	return true


func raise_alarm(last_known_position: Vector2) -> bool:
	if _state == State.DISABLED:
		return false
	# A current visual target is stronger evidence than an external position.
	if is_instance_valid(_tracked_target):
		return true
	if _state == State.CHASE:
		_last_known_position = last_known_position
		return true

	_begin_suspicion(last_known_position, null, true)
	return true


func _on_detection_body_entered(body: Node2D) -> void:
	if use_sight_occlusion:
		return # Evaluate live overlaps and blockers together on the physics tick.
	if not body is PlayerController or _state == State.DISABLED:
		return
	if _state == State.CHASE:
		if _tracked_target == null:
			_tracked_target = body
		return

	_begin_suspicion(body.global_position, body, true)


func _on_detection_body_exited(body: Node2D) -> void:
	if use_sight_occlusion:
		return # Preserve the last visible position, never the hidden exit position.
	if not is_inside_tree() or is_queued_for_deletion() or not _search_timer.is_inside_tree():
		return
	if body != _tracked_target:
		return

	_last_known_position = body.global_position
	_tracked_target = null
	if _state == State.SUSPICIOUS or _state == State.CHASE:
		_begin_search()


func _on_suspicion_timeout() -> void:
	if use_sight_occlusion and _refresh_visual_target():
		return # A newly acquired target must receive its entire warning duration.
	if _state != State.SUSPICIOUS:
		return

	if is_instance_valid(_tracked_target):
		_last_known_position = _tracked_target.global_position
	if is_instance_valid(_tracked_target) or _alarm_escalation:
		_begin_chase()
	else:
		_begin_search()


func _on_search_timeout() -> void:
	if _state != State.SEARCH:
		return

	_heading_to_patrol_end = false
	_patrol_destination = _patrol_origin
	_set_state(State.PATROL)


func _on_discharge_timeout() -> void:
	if _state != State.DISABLED:
		return
	if use_sight_occlusion:
		_begin_search()
		_refresh_visual_target()
		return

	# Reacquire only bodies still present; an escaped player is no longer tracked.
	for body in _detection_area.get_overlapping_bodies():
		if body is PlayerController and not body.is_queued_for_deletion():
			_begin_suspicion(body.global_position, body, true)
			return
	_begin_search()


func has_visual_contact() -> bool:
	return is_instance_valid(_tracked_target)


func _can_see(body: Node2D) -> bool:
	if not is_instance_valid(body) or body.is_queued_for_deletion() or not body is PlayerController:
		return false
	if not body.can_process() or not _detection_area.overlaps_body(body):
		return false
	var query := PhysicsRayQueryParameters2D.create(global_position, body.global_position, sight_blocker_mask)
	query.exclude = [get_rid(), (body as PlayerController).get_rid()]
	query.hit_from_inside = true
	return get_world_2d().direct_space_state.intersect_ray(query).is_empty()


func _refresh_visual_target() -> bool:
	if not can_process() or is_queued_for_deletion() or _state == State.DISABLED:
		return false
	if is_instance_valid(_tracked_target):
		if _can_see(_tracked_target):
			_last_known_position = _tracked_target.global_position
			return false
		_begin_search()
		sight_lost.emit(_last_known_position)
	elif _tracked_target != null:
		_begin_search()
		sight_lost.emit(_last_known_position)
	for body in _detection_area.get_overlapping_bodies():
		if not _can_see(body):
			continue
		if _state == State.CHASE:
			# An already escalated sound/alarm chase keeps its urgency.
			_tracked_target = body
			_last_known_position = body.global_position
		else:
			_begin_suspicion(body.global_position, body, true)
		return true
	return false


func _begin_suspicion(
	last_known_position: Vector2,
	target: Node2D,
	escalate_to_chase: bool
) -> void:
	_search_timer.stop()
	_suspicion_timer.stop()
	_last_known_position = last_known_position
	_tracked_target = target
	_alarm_escalation = escalate_to_chase
	_set_state(State.SUSPICIOUS)
	_suspicion_timer.start(maxf(suspicion_duration, 0.01))
	warning_started.emit(_last_known_position)


func _begin_chase() -> void:
	_alarm_escalation = false
	_set_state(State.CHASE)
	chase_started.emit(_last_known_position)


func _begin_search() -> void:
	_suspicion_timer.stop()
	_alarm_escalation = false
	_tracked_target = null
	_set_state(State.SEARCH)
	_search_timer.start(maxf(search_duration, 0.01))
	search_started.emit(_last_known_position)


func _move_toward_position(destination: Vector2, speed: float) -> bool:
	var offset := destination - global_position
	if offset.length() <= 3.0:
		velocity = Vector2.ZERO
		return true

	velocity = offset.normalized() * maxf(speed, 0.0)
	move_and_slide()
	for index in range(get_slide_collision_count()):
		var obstacle := get_slide_collision(index).get_collider() as Node2D
		if obstacle != null:
			obstacle_contacted.emit(obstacle)
	return false


func _set_state(next_state: State) -> void:
	if next_state == _state:
		_render_state()
		return

	var previous_state := _state
	_state = next_state
	_render_state()
	state_changed.emit(previous_state, _state)


func _render_state() -> void:
	match _state:
		State.DISABLED:
			_body.color = Color(0.2, 0.65, 0.72, 1.0)
			_warning_glow.hide()
			_status.text = "비상 방전: 잠시 정지 중"
		State.SUSPICIOUS:
			_body.color = Color(0.78, 0.58, 0.2, 1.0)
			_warning_glow.show()
			_status.text = "탐지음: 마지막 위치 확인 중"
		State.CHASE:
			_body.color = Color(0.78, 0.22, 0.18, 1.0)
			_warning_glow.show()
			_status.text = "경비 골렘 추적 중"
		State.SEARCH:
			_body.color = Color(0.48, 0.38, 0.64, 1.0)
			_warning_glow.hide()
			_status.text = "마지막 위치 수색 중"
		_:
			_body.color = Color(0.34, 0.4, 0.44, 1.0)
			_warning_glow.hide()
			_status.text = "징후: 무거운 발소리와 긁힌 흔적"
