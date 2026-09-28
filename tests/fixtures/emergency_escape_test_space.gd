extends "res://tests/fixtures/retreat_route_test_space.gd"


func start_exploration() -> bool:
	if not $EmergencyEscape.is_configured() or not super.start_exploration():
		return false
	return $LowerPassage.start_exploration(_player)


func _set_simulation_enabled(enabled: bool) -> void:
	super._set_simulation_enabled(enabled)
	$EmergencyEscape.set_exploration_active(enabled)
	if not enabled:
		$LowerPassage.end_exploration()


func get_route_notice() -> String:
	var escape: EmergencyEscape = $EmergencyEscape
	if escape.is_route_lost():
		var guidance := "비상 탈출 지점에서 E · 준비 %.0f초 · 성공 시 충전 %d · 회수품 유지" % [escape.get_preparation_duration(), escape.get_charge_cost()]
		if _harness.get_current_charge() < escape.get_charge_cost():
			guidance = "비상 탈출 충전 부족 · 충전 %d이 필요합니다." % escape.get_charge_cost()
		return "퇴로 끊김 · 탈출 제한 %.1f초\n%s" % [escape.get_time_remaining(), guidance]
	var passage: ChangingPassage = $ChangingPassage
	if passage.get_phase() in [ChangingPassage.Phase.WARNING, ChangingPassage.Phase.WAITING]:
		return "위·아래 입구 연결에 붕괴 징후 · %.1f초 뒤 차단\n지금 입구로 후퇴하거나 비상 탈출 지점을 확인하세요." % passage.get_warning_remaining()
	return "안쪽에 들어가면 위·아래 입구 연결에 붕괴 경고가 시작됩니다.\n두 길이 모두 막히면 비상 탈출 지점에서 E · 충전 1을 남기세요."
