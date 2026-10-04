class_name HarnessModules
extends RefCounted

# DEV-0409 comparison catalog, not permanent unlocks or final slot balance.
const ANALYSIS := "precise_analysis"
const STABILIZATION := "stabilization"
const EMERGENCY := "emergency_discharge"
const ALL: Array[String] = [ANALYSIS, STABILIZATION, EMERGENCY]
const DEFAULT: Array[String] = [STABILIZATION, EMERGENCY]
const PAIRS := [[STABILIZATION, EMERGENCY], [ANALYSIS, STABILIZATION], [ANALYSIS, EMERGENCY]]


static func is_valid(value: Variant, required_count: int = 2) -> bool:
	if typeof(value) != TYPE_ARRAY or value.size() != required_count:
		return false
	var seen: Array[String] = []
	for id in value:
		if typeof(id) != TYPE_STRING or id not in ALL or id in seen:
			return false
		seen.append(id)
	return true


static func label(id: String) -> String:
	match id:
		ANALYSIS: return "정밀 분석"
		STABILIZATION: return "안정화"
		EMERGENCY: return "비상 방전"
	return ""


static func describe(ids: Array) -> String:
	var names := PackedStringArray()
	for id in ids:
		names.append(label(id))
	return " · ".join(names)


static func details(ids: Array) -> String:
	var lines := PackedStringArray()
	for id in ALL:
		var effect := "지원 대상의 정밀 정보 확인" if id == ANALYSIS else (
			"잔해·함정·잔여 구역 입구 안정화" if id == STABILIZATION else "골렘 방전·문 임시 고정")
		lines.append("%s %s — %s" % ["장착" if id in ids else "미장착", label(id), effect])
	return "\n".join(lines)
