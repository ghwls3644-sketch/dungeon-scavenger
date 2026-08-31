class_name ExplorationOutcomePanel
extends PanelContainer

var _outcome: ExplorationOutcome

@onready var _title: Label = %Title
@onready var _summary: Label = %Summary
@onready var _recovery_result_panel: RecoveryResultPanel = %RecoveryResultPanel


func _ready() -> void:
	_render()


func bind_outcome(outcome: ExplorationOutcome) -> void:
	_outcome = outcome
	if is_node_ready():
		_render()


func get_title_text() -> String:
	return _title.text


func get_summary_text() -> String:
	return _summary.text


func is_recovery_result_visible() -> bool:
	return _recovery_result_panel.visible


func get_recovery_summary_text() -> String:
	return _recovery_result_panel.get_summary_text()


func get_recovery_displayed_item_text(index: int) -> String:
	return _recovery_result_panel.get_displayed_item_text(index)


func _render() -> void:
	if _outcome == null:
		_title.text = "탐험 결과 없음"
		_summary.text = "입구 귀환 또는 실패 결과를 연결하면 표시됩니다."
		_recovery_result_panel.bind_result(null)
		_recovery_result_panel.hide()
		return

	if _outcome.is_safe_return():
		_title.text = "생환"
		_summary.text = "입구로 안전 귀환했습니다. 들고 나온 물품을 정산 대상으로 넘깁니다."
		_recovery_result_panel.bind_result(_outcome.get_recovery_result())
		_recovery_result_panel.show()
		return

	_title.text = "탐험 실패"
	_summary.text = "현재 탐험의 회수품 %d개를 잃었습니다. 획득 확정이나 정산에는 포함되지 않습니다." % _outcome.get_lost_item_count()
	_recovery_result_panel.bind_result(null)
	_recovery_result_panel.hide()
