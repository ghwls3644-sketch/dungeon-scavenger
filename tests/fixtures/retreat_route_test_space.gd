extends PrototypeExploration

@export var auto_start := true

var _last_route_notice := ""


func _ready() -> void:
	super._ready()
	exploration_ended.connect(_show_result)
	$ResultOverlay/Retry.pressed.connect(func(): get_tree().reload_current_scene())
	if auto_start:
		var loadout := ExpeditionLoadout.new()
		loadout.slot_capacity = 3
		loadout.burden_weight = 2.5
		loadout.overload_weight = 4.0
		loadout.charge_capacity = 3
		loadout.starting_charge = 3
		prepare_departure(loadout)
		start_exploration()


func start_exploration() -> bool:
	if not super.start_exploration():
		return false
	return $ChangingPassage.start_exploration(_player)


func _set_simulation_enabled(enabled: bool) -> void:
	super._set_simulation_enabled(enabled)
	if not enabled:
		$ChangingPassage.end_exploration()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if _started and not _finished:
		var notice := get_route_notice()
		if notice != _last_route_notice and not %GolemContactThreat.is_warning():
			%ChoiceStatus.text = notice
			_last_route_notice = notice


func get_route_notice() -> String:
	var passage: ChangingPassage = $ChangingPassage
	match passage.get_phase():
		ChangingPassage.Phase.WARNING:
			return "위쪽 연결에 붕괴 징후! %.1f초 뒤 막힙니다.\n지금 후퇴하거나 오른쪽·아래쪽 길을 살펴보세요." % passage.get_warning_remaining()
		ChangingPassage.Phase.WAITING:
			return "위쪽 연결 붕괴 임박 · 통로 안에서 벗어나세요.\nM 지도는 마지막 관찰 기록입니다."
		ChangingPassage.Phase.BLOCKED:
			if _map_state.get_passage_status(&"prototype_upper_link") == ExplorationMapState.PassageStatus.BLOCKED:
				return "위쪽 연결 막힘 확인 · 오른쪽·아래쪽 길을 살펴보세요.\n통로 하나가 막혀도 탐험은 계속됩니다. 원래 입구로 돌아오세요."
			return "위쪽 연결에 이상 징후 · 가까이에서 다시 확인하세요.\nM 지도는 마지막 관찰 기록입니다. 화살표는 입구 방향입니다."
	return "위쪽 연결을 지나가면 붕괴 경고가 시작됩니다.\n물품을 챙기고 돌아올 길을 확인하세요. M 지도 · 같은 입구로 귀환"


func _show_result(outcome: ExplorationOutcome) -> void:
	$ResultOverlay/Outcome.bind_outcome(outcome)
	$ResultOverlay.show()
