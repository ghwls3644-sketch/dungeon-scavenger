class_name ExpeditionResultsScreen
extends Control

signal settlement_requested
signal quit_requested

@onready var _settle: Button = $NextStep/SettleButton
@onready var _default_notice: String = $NextStep/Notice.text


func _ready() -> void:
	_settle.pressed.connect(func(): settlement_requested.emit())
	$NextStep/QuitButton.pressed.connect(func(): quit_requested.emit())
	$NextStep/DetailButton.toggled.connect(_show_details)
	$NextStep/RecoveryButton.pressed.connect(_open_recovery)
	$CloseRecovery.pressed.connect(_close_recovery)
	resized.connect(_layout)
	_layout()
	_layout.call_deferred()


func present_result(outcome: ExplorationOutcome, settlement: SettlementResult) -> void:
	$NextStep.show()
	$OutcomePanel.hide()
	$CloseRecovery.hide()
	$NextStep/DetailButton.set_pressed_no_signal(false)
	_show_details(false)
	$NextStep/Notice.text = _default_notice
	$OutcomePanel.bind_outcome(outcome)
	_settle.disabled = settlement == null
	$NextStep/RecoveryButton.disabled = outcome == null
	$NextStep/RecoveryButton.text = "회수품 보기"
	$NextStep/Title.text = "실패 결과" if outcome != null and outcome.is_failure() else "귀환 정산"
	$NextStep/Outcome.text = $OutcomePanel.get_title_text()
	$NextStep/EquipmentDamage.text = ""
	$NextStep/ProfitTitle.text = "이번 준비·탐험 손익"
	$NextStep/ProfitNote.text = ""
	$NextStep/Credit.text = "—"
	$NextStep/CashNote.text = ""
	$NextStep/Overview.text = ""
	$NextStep/NetIncome.remove_theme_color_override("font_color")
	if settlement == null:
		$NextStep/NetIncome.text = "정산 확인 필요"
		$NextStep/Totals.text = ""
		$NextStep/Items.text = "정산 자료를 준비하지 못했습니다."
		$NextStep/Overview.text = "정산 자료를 준비하지 못했습니다."
		$NextStep/QuitButton.grab_focus()
		_fit_numbers()
		return
	var costs := settlement.get_cost_summary()
	$NextStep/NetIncome.text = "손익 계산 보류" if not costs.is_empty() and costs.unknown_count > 0 else (
		"%+d" % costs.profit if not costs.is_empty() else "%+d" % settlement.get_net_income())
	$NextStep/ProfitTitle.text = "이번 준비·탐험 손익" if not costs.is_empty() else "회수품 정산액"
	$NextStep/Credit.text = "+%d" % settlement.get_net_income()
	if not costs.is_empty():
		$NextStep/ProfitNote.text = CostReportText.result_equation(costs)
		$NextStep/Totals.text = "현금 변화 %+d\n정산 후 보유금 %d" % [costs.cash_change, costs.money_after]
		$NextStep/CashNote.text = "준비 시작 보유금 %d\n구매·투자까지 포함한 지갑 변화" % costs.opening_money
		$NextStep/Overview.text = CostReportText.result_overview(costs)
		if costs.unknown_count == 0:
			$NextStep/NetIncome.add_theme_color_override("font_color", Color("efad98") if costs.profit < 0 else Color("a8e2cb"))
	else:
		$NextStep/Totals.text = "판매액 %d · 비용 %d" % [settlement.get_total_income(), settlement.get_total_cost()]
	var wear := settlement.get_equipment_damage()
	if not wear.is_empty():
		$NextStep/EquipmentDamage.text = "기본 하네스 내구 %d/%d → %d/%d\n이번 손상 %d · 정산 저장 시 반영\n수리비는 차감하지 않았습니다." % [
			wear.before, wear.maximum, wear.after, wear.maximum, wear.damage,
		]
		var estimate := settlement.get_full_repair_estimate()
		if estimate >= 0:
			$NextStep/EquipmentDamage.text += "\n완전 수리 예상 %d · 거점에서 선택" % estimate
	var lines := PackedStringArray()
	if not costs.is_empty():
		lines.append(CostReportText.details(costs))
	lines.append("\n회수품 처리\n이번에 보관할 물품 %d개" % settlement.get_retained_items().size())
	for id in settlement.get_harness_upgrades():
		lines.append("%s · 무료 발견\n정산 저장 후 영구 보유" % HarnessUpgradeRule.label(id))
	for sale in settlement.get_sales():
		lines.append("%s · 판매액 %d" % [sale.name, sale.amount])
	for item in settlement.get_retained_items():
		lines.append("%s · %s" % [item.get_definition().display_name, get_storage_reason(item)])
	var recovery := "판매 %d건 · 보관 %d개" % [settlement.get_sales().size(), settlement.get_retained_items().size()]
	if settlement.is_failure():
		recovery = "회수품 %d개 손실 · 기존 보관품은 유지" % settlement.get_lost_count()
		lines.append("이번 회수품 %d개 손실 · 새 개선 발견 미확보\n기존 돈·보관품·보유 개선은 유지됩니다." % settlement.get_lost_count())
	$NextStep/RecoveryButton.text = "회수품 보기 · " + recovery
	if not wear.is_empty():
		$NextStep/Overview.text += "\n하네스 내구 %d/%d → %d/%d · 수리는 거점에서 선택" % [wear.before, wear.maximum, wear.after, wear.maximum]
		lines.append("\n장비와 수리\n" + $NextStep/EquipmentDamage.text)
	if outcome != null:
		var tools := outcome.get_lure_summary()
		if not tools.is_empty() and costs.is_empty():
			lines.append("유인물 무료 %d개 / 추가 %d개 사용\n%s · 정산 저장 시 반영\n구매비는 거점에서 이미 지불" % [tools.free_used, tools.paid_used,
				"미사용 추가분 %d개 반환" % tools.returned if outcome.is_safe_return() else "휴대 추가분 %d개 소실" % tools.lost])
	$NextStep/Items.text = "\n".join(lines)
	$NextStep/Items.scroll_to_line(0)
	$NextStep/Overview.scroll_to_line(0)
	_settle.text = "거점으로 돌아가기" if settlement.is_failure() else "정산하고 거점으로"
	_fit_numbers()
	_layout.call_deferred()
	_settle.grab_focus()


func _show_details(expanded: bool) -> void:
	$NextStep/Items.visible = expanded
	$NextStep/Overview.visible = not expanded
	$NextStep/DetailButton.text = "상세 내역 접기" if expanded else "비용·도구 상세 보기"


func _open_recovery() -> void:
	$NextStep.hide()
	$OutcomePanel.show()
	$CloseRecovery.show()
	$CloseRecovery.grab_focus()
	_layout.call_deferred()


func _close_recovery() -> void:
	$OutcomePanel.hide()
	$CloseRecovery.hide()
	$NextStep.show()
	$NextStep/RecoveryButton.grab_focus()


func _unhandled_key_input(event: InputEvent) -> void:
	if visible and $OutcomePanel.visible and event.is_action_pressed("ui_cancel"):
		_close_recovery()
		get_viewport().set_input_as_handled()


func set_busy(busy: bool) -> void:
	_settle.disabled = busy
	$NextStep/QuitButton.disabled = busy


func set_status(message: String) -> void:
	$NextStep/Notice.text = message


func _place(path: String, x: float, y: float, width: float, height: float) -> void:
	var control := get_node(path) as Control
	control.position = Vector2(x, y)
	control.size = Vector2(width, height)


func _layout() -> void:
	if not is_node_ready():
		return
	var width := size.x - 48.0
	var height := size.y - 48.0
	_place("NextStep", 24, 24, width, height)
	_place("NextStep/Title", 0, 0, width - 220, 42)
	_place("NextStep/Outcome", width - 210, 8, 210, 32)
	var profit_width := width * 0.39
	var credit_x := profit_width + 12
	var credit_width := width * 0.24
	var cash_x := credit_x + credit_width + 12
	var cash_width := width - cash_x
	_place("NextStep/ProfitCard", 0, 60, profit_width, 160)
	_place("NextStep/CreditCard", credit_x, 60, credit_width, 160)
	_place("NextStep/CashCard", cash_x, 60, cash_width, 160)
	_place("NextStep/ProfitTitle", 18, 73, profit_width - 36, 28)
	_place("NextStep/NetIncome", 18, 103, profit_width - 36, 60)
	_place("NextStep/ProfitNote", 18, 166, profit_width - 36, 42)
	_place("NextStep/CreditTitle", credit_x + 18, 73, credit_width - 36, 28)
	_place("NextStep/Credit", credit_x + 18, 109, credit_width - 36, 50)
	_place("NextStep/CreditNote", credit_x + 18, 168, credit_width - 36, 40)
	_place("NextStep/Totals", cash_x + 18, 79, cash_width - 36, 70)
	_place("NextStep/CashNote", cash_x + 18, 162, cash_width - 36, 44)
	_place("NextStep/DetailButton", 0, 234, 232, 40)
	_place("NextStep/RecoveryButton", 244, 234, width - 244, 40)
	_place("NextStep/Overview", 12, 292, width - 24, height - 426)
	_place("NextStep/Items", 12, 292, width - 24, height - 426)
	_place("NextStep/Notice", 0, height - 118, width, 52)
	_place("NextStep/SettleButton", width - 312, height - 50, 312, 50)
	_place("NextStep/QuitButton", 0, height - 50, 160, 50)
	_place("OutcomePanel", (size.x - 680) / 2.0, (size.y - 570) / 2.0, 680, 500)
	_place("CloseRecovery", (size.x - 260) / 2.0, (size.y - 570) / 2.0 + 518, 260, 48)
	_fit_numbers()


func _fit_numbers() -> void:
	# Preserve every digit even at the 64-bit money boundary.
	for name in ["NetIncome", "Credit", "Totals", "ProfitNote", "CashNote", "Notice"]:
		var label := get_node("NextStep/" + name) as Label
		var font := label.get_theme_font("font")
		var font_size := 44 if name == "NetIncome" else (34 if name == "Credit" else (23 if name == "Totals" else 16))
		for line in label.text.split("\n"):
			while font_size > 14 and font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > label.size.x:
				font_size -= 1
		label.add_theme_font_size_override("font_size", font_size)


static func get_storage_reason(item: InventoryItem) -> String:
	if not item.is_identified():
		return "미확인 · 감정 대기"
	var definition := item.get_definition()
	if not definition.has_monetary_value():
		return "등록·정보 보상 대기"
	if definition.is_protected():
		return "판매 보호 · 보관"
	return "판매가 미설정 · 보관"
