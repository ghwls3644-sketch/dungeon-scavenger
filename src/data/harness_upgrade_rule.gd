class_name HarnessUpgradeRule
extends Resource

const OBSERVATION := "observation_timing"
const EMERGENCY := "emergency_duration"
const ALL: Array[String] = [OBSERVATION, EMERGENCY]

@export var observation_cost: int = 60
@export var emergency_cost: int = 60
@export var golem_bonus: float = 1.0
@export var door_bonus: float = 2.0


func is_valid() -> bool:
	return observation_cost > 0 and emergency_cost > 0 \
		and is_finite(golem_bonus) and golem_bonus > 0.0 \
		and is_finite(door_bonus) and door_bonus > 0.0


static func is_valid_owned(value: Variant) -> bool:
	if typeof(value) != TYPE_ARRAY or value.size() > ALL.size():
		return false
	var seen: Array[String] = []
	for id in value:
		if typeof(id) != TYPE_STRING or id not in ALL or id in seen:
			return false
		seen.append(id)
	return true


static func label(id: String) -> String:
	return "관찰 정보 개선" if id == OBSERVATION else ("비상 대응 개선" if id == EMERGENCY else "")


static func module_for(id: String) -> String:
	return HarnessModules.ANALYSIS if id == OBSERVATION else (HarnessModules.EMERGENCY if id == EMERGENCY else "")


func get_cost(id: String) -> int:
	if not is_valid():
		return -1
	return observation_cost if id == OBSERVATION else (emergency_cost if id == EMERGENCY else -1)


func snapshot() -> Dictionary:
	return {"observation_cost": observation_cost, "emergency_cost": emergency_cost,
		"golem_bonus": golem_bonus, "door_bonus": door_bonus}


func describe(id: String) -> String:
	if id == OBSERVATION:
		return "상태 설명 → 정밀 분석한 잔해·골렘의 남은 시간도 표시\n정밀 분석 충전 비용은 그대로입니다."
	if id == EMERGENCY:
		return "골렘 무력화 +%.1f초 · 문 고정 +%.1f초\n충전 비용은 그대로이며 영구 처치는 불가능합니다." % [golem_bonus, door_bonus]
	return ""
