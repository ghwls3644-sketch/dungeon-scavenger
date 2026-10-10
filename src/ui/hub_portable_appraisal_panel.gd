class_name HubPortableAppraisalPanel
extends Control

signal review_requested(count: int)
signal confirmation_requested
signal selection_requested
signal close_requested

var _source: HubState
var _reviewing := false
@onready var _choice: OptionButton = %PortableChoice


func _ready() -> void:
	_choice.item_selected.connect(func(_index: int): _show_selection())
	%ReviewPortable.pressed.connect(func(): review_requested.emit(_choice.selected))
	%ConfirmPortable.pressed.connect(func(): confirmation_requested.emit())
	%CancelPortable.pressed.connect(func(): selection_requested.emit())
	%ClosePortable.pressed.connect(func(): close_requested.emit())


func present(hub: HubState) -> void:
	_source = hub.copy()
	_choice.clear()
	for count in range(AppraisalPreparation.RULE.maximum_count + 1):
		_choice.add_item("총 %d개 휴대" % count)
	_choice.select(hub.create_departure_loadout().appraisal_count)
	%PortableSummary.text = "보유금 %d · 거점 감정 도구 %d개 · 도구 개당 %d" % [hub.get_money(), hub.get_paid_appraisals(), AppraisalPreparation.RULE.unit_price]
	show()
	set_review(null)
	_choice.grab_focus()


func set_review(quote: AppraisalPreparationQuote) -> void:
	_reviewing = quote != null
	_choice.disabled = _reviewing
	%ReviewPortable.visible = not _reviewing
	%ConfirmPortable.visible = _reviewing
	%CancelPortable.visible = _reviewing
	if _reviewing:
		%ConfirmPortable.disabled = not quote.can_afford()
		set_status("이번 지불액 %d · 확정 후 보유금 %d\n확정하면 부족분 구매와 휴대 수량을 함께 저장합니다." % [quote.get_cost(), quote.get_money_after()])
		%ConfirmPortable.grab_focus()
	else:
		_show_selection()


func _show_selection() -> void:
	if _reviewing or _source == null:
		return
	var quote := _source.quote_portable_appraisals(_choice.selected)
	if quote == null:
		return
	%PortableDetails.text = "휴대 %d개 · 시작 무게 %.2f · 회수품 가방 칸은 그대로\n보유분 %d개 + 부족분 구매 %d개\n거점에 남길 감정 도구 %d개" % [
		quote.get_count(), quote.get_start_weight(), quote.get_count() - quote.get_bought_count(),
		quote.get_bought_count(), quote.get_stock_left()]
	%ReviewPortable.disabled = not quote.can_afford()
	set_status("예상 비용 %d · 확정 후 보유금 %d" % [quote.get_cost(), quote.get_money_after()] if quote.can_afford() else "보유금이 %d 부족합니다. 0개로 출정하고 거점 감정을 이용할 수 있습니다." % -quote.get_money_after())


func set_status(message: String) -> void:
	%PortableStatus.text = message


func _unhandled_key_input(event: InputEvent) -> void:
	if is_visible_in_tree() and event.is_action_pressed(&"pause") and not event.is_echo():
		if _reviewing:
			selection_requested.emit()
		else:
			close_requested.emit()
		get_viewport().set_input_as_handled()
