class_name ExpeditionResultsScreen
extends Control

signal settlement_requested
signal quit_requested

@onready var _settle: Button = $NextStep/SettleButton
@onready var _default_notice: String = $NextStep/Notice.text


func _ready() -> void:
	_settle.pressed.connect(func(): settlement_requested.emit())
	$NextStep/QuitButton.pressed.connect(func(): quit_requested.emit())


func present_result(outcome: ExplorationOutcome, settlement: SettlementResult) -> void:
	$NextStep/Notice.text = _default_notice
	$NextStep/EquipmentDamage.hide()
	$OutcomePanel.bind_outcome(outcome)
	_settle.disabled = settlement == null
	$NextStep/Title.text = "실패 결과" if outcome != null and outcome.is_failure() else "귀환 정산"
	if settlement == null:
		$NextStep/NetIncome.text = "정산 확인 필요"
		$NextStep/Totals.text = ""
		$NextStep/Items.text = "정산 자료를 준비하지 못했습니다."
		$NextStep/QuitButton.grab_focus()
		return
	var costs := settlement.get_cost_summary()
	$NextStep/NetIncome.text = CostReportText.headline(costs) if not costs.is_empty() else "회수품 정산액 %+d" % settlement.get_net_income()
	$NextStep/Totals.text = "현금 변화 %+d\n정산 후 보유금 %d · 저장 전" % [costs.cash_change, costs.money_after] if not costs.is_empty() else "판매액 %d · 비용 %d" % [settlement.get_total_income(), settlement.get_total_cost()]
	var wear := settlement.get_equipment_damage()
	if not wear.is_empty():
		$NextStep/EquipmentDamage.text = "기본 하네스 내구 %d/%d → %d/%d\n이번 손상 %d · 정산 저장 시 반영\n수리비는 차감하지 않았습니다." % [
			wear.before, wear.maximum, wear.after, wear.maximum, wear.damage,
		]
		$NextStep/EquipmentDamage.show()
		var estimate := settlement.get_full_repair_estimate()
		if estimate >= 0:
			$NextStep/EquipmentDamage.text += "\n완전 수리 예상 %d · 거점에서 선택" % estimate
	var lines := PackedStringArray()
	if not costs.is_empty():
		lines.append(CostReportText.details(costs))
	lines.append("이번에 보관할 물품 %d개" % settlement.get_retained_items().size())
	for id in settlement.get_harness_upgrades():
		lines.append("%s · 무료 발견\n정산 저장 후 영구 보유" % HarnessUpgradeRule.label(id))
	for sale in settlement.get_sales():
		lines.append("%s · 판매액 %d" % [sale.name, sale.amount])
	for item in settlement.get_retained_items():
		lines.append("%s · %s" % [item.get_definition().display_name, get_storage_reason(item)])
	if settlement.is_failure():
		lines.append("이번 회수품 %d개 손실 · 새 개선 발견 미확보\n기존 돈·보관품·보유 개선은 유지됩니다." % settlement.get_lost_count())
	elif lines.is_empty():
		lines.append("이번에 회수한 물품이 없습니다.")
	var tools := outcome.get_lure_summary()
	if not tools.is_empty() and costs.is_empty():
		lines.append("유인물 무료 %d개 / 추가 %d개 사용\n%s · 정산 저장 시 반영\n구매비는 거점에서 이미 지불" % [tools.free_used, tools.paid_used,
			"미사용 추가분 %d개 반환" % tools.returned if outcome.is_safe_return() else "휴대 추가분 %d개 소실" % tools.lost])
	$NextStep/Items.text = "\n".join(lines)
	_settle.text = "거점으로 돌아가기" if settlement.is_failure() else "정산하고 거점으로"
	_settle.grab_focus()


func set_busy(busy: bool) -> void:
	_settle.disabled = busy
	$NextStep/QuitButton.disabled = busy


func set_status(message: String) -> void:
	$NextStep/Notice.text = message


static func get_storage_reason(item: InventoryItem) -> String:
	if not item.is_identified():
		return "미확인 · 감정 대기"
	var definition := item.get_definition()
	if not definition.has_monetary_value():
		return "등록·정보 보상 대기"
	if definition.is_protected():
		return "판매 보호 · 보관"
	return "판매가 미설정 · 보관"
