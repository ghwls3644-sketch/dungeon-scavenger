class_name RecoveryResultPanel
extends PanelContainer

var _result: RecoveryResult

@onready var _summary: Label = %Summary
@onready var _item_list: ItemList = %ItemList
@onready var _note: Label = %Note


func _ready() -> void:
	_render()


func bind_result(result: RecoveryResult) -> void:
	_result = result
	if is_node_ready():
		_render()


func get_summary_text() -> String:
	return _summary.text


func get_note_text() -> String:
	return _note.text


func get_displayed_item_count() -> int:
	return _item_list.item_count


func get_displayed_item_text(index: int) -> String:
	if index < 0 or index >= _item_list.item_count:
		return ""
	return _item_list.get_item_text(index)


func _render() -> void:
	_item_list.clear()
	if _result == null:
		_summary.text = "회수 결과 없음"
		_note.text = "안전 귀환한 회수품을 연결하면 예상 가치가 표시됩니다."
		return

	for item in _result.get_recovered_items():
		_item_list.add_item("%s | %s" % [
			item.display_name,
			ItemValueText.format_item_value(item),
		])

	_summary.text = "회수품 %d개 | 예상 가치 합계 %s" % [
		_result.get_item_count(),
		ItemValueText.format_range(
			_result.get_total_value_min(),
			_result.get_total_value_max(),
		),
	]
	if _result.get_non_monetary_reward_count() > 0:
		_summary.text += " | 등록·정보 보상 %d개" % _result.get_non_monetary_reward_count()

	_note.text = "판매·비용 정산 전 예상값이며, 현재 회수품만 포함합니다."
