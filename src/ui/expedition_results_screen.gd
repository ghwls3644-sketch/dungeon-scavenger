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
	$OutcomePanel.bind_outcome(outcome)
	_settle.disabled = settlement == null
	$NextStep/Title.text = "실패 결과" if outcome != null and outcome.is_failure() else "귀환 정산"
	if settlement == null:
		$NextStep/NetIncome.text = "정산 확인 필요"
		$NextStep/Totals.text = ""
		$NextStep/Items.text = "정산 자료를 준비하지 못했습니다."
		$NextStep/QuitButton.grab_focus()
		return
	$NextStep/NetIncome.text = "순이익 +%d" % settlement.get_net_income()
	$NextStep/Totals.text = "판매액 %d · 비용 %d\n이번에 보관할 물품 %d개" % [
		settlement.get_total_income(), settlement.get_total_cost(), settlement.get_retained_items().size(),
	]
	var lines := PackedStringArray()
	for sale in settlement.get_sales():
		lines.append("%s · 판매액 %d" % [sale.name, sale.amount])
	for item in settlement.get_retained_items():
		lines.append("%s · %s" % [item.get_definition().display_name, get_storage_reason(item)])
	if settlement.is_failure():
		lines.append("이번 회수품 %d개 손실\n기존 돈과 보관품은 유지됩니다." % settlement.get_lost_count())
	elif lines.is_empty():
		lines.append("이번에 회수한 물품이 없습니다.")
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
