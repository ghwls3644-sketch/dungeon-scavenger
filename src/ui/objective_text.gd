class_name ObjectiveText
extends RefCounted


static func description(offer: Dictionary) -> String:
	if offer.is_empty():
		return "자유 수색\n의뢰 없이 출정합니다. 회수품은 평소처럼 정산합니다."
	return "폐품 회수 의뢰\n이번 출정에서 확인된 일반 폐품 %d개를 가져오세요.\n안전 귀환 시 판매액 외 추가 보상 %s\n미달성해도 회수품은 정상 정산합니다.\n수락 비용·미달성 벌금 없음 · 정산 후 선택 초기화" % [offer.required, offer.reward]


static func progress(offer: Dictionary, count: int) -> String:
	if offer.is_empty():
		return "자유 수색"
	return "폐품 회수 의뢰 %d/%d · 안전 귀환 시 보상 %s" % [count, offer.required, offer.reward]


static func result(summary: Dictionary) -> String:
	if not summary.selected:
		return "자유 수색 · 의뢰 보상 없음"
	match summary.status:
		"achieved": return "의뢰 달성 %d/%d · 추가 보상 %d" % [summary.count, summary.required, summary.reward]
		"missed": return "의뢰 미달성 %d/%d · 보상 0\n회수품은 정상 정산합니다." % [summary.count, summary.required]
		"interrupted": return "의뢰 미확정 · 정산 전 종료 · 보상 0"
	return "의뢰 미달성 · 탐험 실패 · 보상 0"
