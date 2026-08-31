class_name InspectablePickupInteractable
extends PickupInteractable

signal inspection_completed(summary: String, risk_hint: String)

@export var inspection_prompt := "조사하기"
@export_multiline var inspection_summary := "외형을 확인했습니다."
@export var risk_hint := "특이 위험 없음"

var _inspected := false


func get_interaction_prompt() -> String:
	if not _inspected:
		return inspection_prompt
	return super.get_interaction_prompt()


func is_inspected() -> bool:
	return _inspected


func get_inspection_text() -> String:
	return "%s | 무게 %.1f | %s" % [
		inspection_summary,
		item_definition.weight if item_definition != null else 0.0,
		risk_hint,
	]


func _perform_interaction(interactor: Node) -> bool:
	if not _inspected:
		_inspected = true
		inspection_completed.emit(inspection_summary, risk_hint)
		return true
	return super._perform_interaction(interactor)
