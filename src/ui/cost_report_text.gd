class_name CostReportText
extends RefCounted


static func headline(summary: Dictionary) -> String:
	if summary.unknown_count > 0:
		return "손익 계산 보류\n도구 원가 미기록 %d개" % summary.unknown_count
	return "이번 준비·탐험 손익\n%+d" % summary.profit


static func _cost(amount: int, unknown: int) -> String:
	return "%d · 원가 미기록 %d개 별도" % [amount, unknown] if unknown > 0 else str(amount)


static func details(summary: Dictionary) -> String:
	var lines := PackedStringArray([
		"기록 시작 이후의 거래입니다." if summary.partial else "직전 정산 뒤 준비부터 이번 정산까지",
		"수입 %d · 이번 회수품 %d / 거점 보관품 %d" % [summary.income, summary.loot_income, summary.storage_income],
		ObjectiveText.result(summary.objective),
		"감정 지불 %d · 수리 지불 %d" % [summary.appraisal_paid, summary.repair_paid],
		"도구 사용 원가 %s" % _cost(summary.used_cost, summary.used_unknown),
		"%s 원가 %s" % ["종료로 휴대분 소실" if summary.outcome == "interrupted" else "미사용 도구 소실", _cost(summary.lost_cost, summary.lost_unknown)],
		"새 도구 구매 %d · 영구 개선 투자 %d" % [summary.lure_bought, summary.upgrade_paid],
		"위 지출은 이미 지불했습니다. 다시 차감하지 않습니다.",
	])
	if summary.outcome == "interrupted":
		lines.append("미정산 종료 · 휴대 추가분 %d개 소실\n사용 횟수는 기록되지 않았습니다." % summary.lost_count)
	else:
		lines.append("유인물 무료 %d개 / 추가 %d개 사용\n미사용 추가분 %d개 반환 · %d개 소실" % [summary.free_used, summary.paid_used, summary.returned_count, summary.lost_count])
	if summary.stock_after.count("") > 0:
		lines.append("보존한 추가분 중 %d개는 원가 미기록입니다." % summary.stock_after.count(""))
	return "\n".join(lines)


static func preparation(summary: Dictionary, last: Dictionary) -> String:
	if summary.is_empty():
		return "비용 기록을 확인할 수 없습니다."
	var text := "이번 준비\n%s\n시작 보유금 %d · 현금 변화 %+d\n거점 보관품 판매 %d\n감정 지불 %d · 수리 지불 %d\n새 도구 구매 %d · 영구 개선 투자 %d\n추가분 재고 %d개" % [
		"기록 시작 이후" if summary.partial else "직전 정산 이후",
		summary.opening_money, summary.cash_change, summary.storage_income,
		summary.appraisal_paid, summary.repair_paid, summary.lure_bought, summary.upgrade_paid, summary.stock.size(),
	]
	if summary.stock.count("") > 0:
		text += " · 원가 미기록 %d개" % summary.stock.count("")
	text += "\n구매와 소모 비용은 다릅니다.\n수리 견적은 지불하기 전까지 제외합니다."
	if last.is_empty():
		return text + "\n\n아직 기록된 탐험 결과가 없습니다."
	return text + "\n\n마지막 출정 %s · 저장 완료\n%s\n현금 변화 %+d · 정산 후 보유금 %d\n%s" % [
		last.id, headline(last), last.cash_change, last.money_after, details(last),
	]
