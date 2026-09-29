class_name HubAppraisalPanel
extends Control

signal review_requested(indices: PackedInt32Array)
signal confirmation_requested
signal selection_requested
signal close_requested

var _items: Array[InventoryItem] = []
var _reviewing := false

@onready var _list: ItemList = %AppraisalItems


func _ready() -> void:
	_list.resized.connect(_fit_rows)
	_fit_rows.call_deferred()
	%SelectAll.pressed.connect(_select_all)
	%ReviewAppraisal.pressed.connect(func(): review_requested.emit(_list.get_selected_items()))
	%ConfirmAppraisal.pressed.connect(func(): confirmation_requested.emit())
	%CancelAppraisal.pressed.connect(func(): selection_requested.emit())
	%CloseAppraisal.pressed.connect(func(): close_requested.emit())
	_list.multi_selected.connect(func(_index: int, _selected: bool): _selection_changed())


func _fit_rows() -> void:
	_list.fixed_column_width = maxi(1, int(_list.size.x) - 32)


func present(money: int, items: Array[InventoryItem], fee: int) -> void:
	_items = items
	_list.clear()
	%AppraisalMoney.text = "보유금 %d · 감정 비용 개당 %d" % [money, fee]
	for item in items:
		var index := _list.add_item(format_item(item), ItemCategoryIcon.for_item(item))
		_list.set_item_selectable(index, not item.is_identified())
		_list.set_item_tooltip(index, format_item(item))
	show()
	set_review(null)
	_list.grab_focus()


func set_review(quote: AppraisalQuote) -> void:
	_reviewing = quote != null
	_list.mouse_filter = Control.MOUSE_FILTER_IGNORE if _reviewing else Control.MOUSE_FILTER_STOP
	_list.focus_mode = Control.FOCUS_NONE if _reviewing else Control.FOCUS_ALL
	%SelectAll.disabled = _reviewing or _unidentified_count() == 0
	%ReviewAppraisal.visible = not _reviewing
	%ConfirmAppraisal.visible = _reviewing
	%CancelAppraisal.visible = _reviewing
	if quote == null:
		_selection_changed()
		return
	%ConfirmAppraisal.disabled = not quote.can_afford()
	if quote.can_afford():
		%AppraisalStatus.text = "선택 %d개 · 비용 %d · 감정 후 보유금 %d\n확정하면 비용을 지불하고 감정 결과를 저장합니다." % [quote.get_count(), quote.get_cost(), quote.get_remaining_money()]
		%ConfirmAppraisal.grab_focus()
	else:
		%AppraisalStatus.text = "선택 %d개 · 비용 %d · 보유금 %d 부족\n선택을 줄이거나 다음 출정 후 다시 이용해 주세요." % [quote.get_count(), quote.get_cost(), -quote.get_remaining_money()]
		%CancelAppraisal.grab_focus()


func set_status(message: String) -> void:
	%AppraisalStatus.text = message


func _selection_changed() -> void:
	if _reviewing:
		return
	var count := _list.get_selected_items().size()
	%ReviewAppraisal.disabled = count == 0
	%AppraisalStatus.text = "선택 %d개 · 비용 확인 후 감정할 수 있습니다." % count if _unidentified_count() > 0 else "감정할 미확인 물품이 없습니다."


func _select_all() -> void:
	if _reviewing:
		return
	for index in _items.size():
		if not _items[index].is_identified():
			_list.select(index, false)
	_selection_changed()


func _unidentified_count() -> int:
	var count := 0
	for item in _items:
		if not item.is_identified():
			count += 1
	return count


func _unhandled_key_input(event: InputEvent) -> void:
	if is_visible_in_tree() and event.is_action_pressed(&"pause") and not event.is_echo():
		if _reviewing:
			selection_requested.emit()
		else:
			close_requested.emit()
		get_viewport().set_input_as_handled()


static func format_item(item: InventoryItem) -> String:
	var definition := item.get_definition()
	var details := "미확인 물품 · 감정 대기 · 가치 미확인"
	if item.is_identified():
		var categories := {
			ItemDefinition.CATEGORY_SCRAP: "폐품", ItemDefinition.CATEGORY_RESIDUE: "잔재",
			ItemDefinition.CATEGORY_UNIQUE_ARTIFACT: "고유 유물", ItemDefinition.CATEGORY_CORE_RECORD: "핵심 기록물",
		}
		details = "%s · %s\n%s" % [categories.get(definition.category, "미분류"), ItemValueText.format_inventory_item_value(item), "판매·폐기 보호 · 보관" if definition.is_protected() else "판매 가능한 분류 · 현재 거점 보관"]
	if not item.get_risk_hint().is_empty():
		details += " · " + item.get_risk_hint()
	return "%s · 무게 %.1f\n%s" % [definition.display_name, definition.weight, details]
