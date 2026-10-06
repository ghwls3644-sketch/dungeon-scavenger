class_name HubLurePanel
extends Control

signal review_requested(count: int)
signal confirmation_requested
signal selection_requested
signal close_requested

var _source: HubState
var _reviewing := false
@onready var _choice: OptionButton = %LureChoice


func _ready() -> void:
	_choice.item_selected.connect(func(_index: int): _show_selection())
	%ReviewLure.pressed.connect(func(): review_requested.emit(_choice.selected))
	%ConfirmLure.pressed.connect(func(): confirmation_requested.emit())
	%CancelLure.pressed.connect(func(): selection_requested.emit())
	%CloseLure.pressed.connect(func(): close_requested.emit())


func present(hub: HubState) -> void:
	_source = hub.copy()
	_choice.clear()
	for count in range(LurePreparation.RULE.maximum_count + 1):
		_choice.add_item("총 %d개 휴대" % count)
	_choice.select(hub.create_departure_loadout().lure_count)
	%LureSummary.text = "보유금 %d · 거점 추가분 %d개 · 추가분 개당 %d" % [hub.get_money(), hub.get_paid_lures(), LurePreparation.RULE.unit_price]
	show()
	set_review(null)
	_choice.grab_focus()


func set_review(quote: LurePreparationQuote) -> void:
	_reviewing = quote != null
	_choice.disabled = _reviewing
	%ReviewLure.visible = not _reviewing
	%ConfirmLure.visible = _reviewing
	%CancelLure.visible = _reviewing
	if _reviewing:
		%ConfirmLure.disabled = not quote.can_afford()
		set_status("이번 지불액 %d · 확정 후 보유금 %d\n확정하면 부족분 구매와 휴대 수량을 함께 저장합니다." % [quote.get_cost(), quote.get_money_after()])
		%ConfirmLure.grab_focus()
	else:
		_show_selection()


func _show_selection() -> void:
	if _reviewing or _source == null:
		return
	var quote := _source.quote_lures(_choice.selected)
	if quote == null:
		return
	%LureDetails.text = "휴대 %d개 · 시작 무게 %.2f · 회수품 가방 칸은 그대로\n무료 %d개 + 보유 추가분 %d개 + 부족분 구매 %d개\n거점에 남길 추가분 %d개" % [
		quote.get_count(), quote.get_start_weight(), quote.get_free_count(),
		quote.get_paid_count() - quote.get_bought_count(), quote.get_bought_count(),
		quote.get_stock_left()]
	%ReviewLure.disabled = not quote.can_afford()
	set_status("예상 비용 %d · 확정 후 보유금 %d" % [quote.get_cost(), quote.get_money_after()] if quote.can_afford() else "보유금이 %d 부족합니다. 무료 0~2개를 선택해 출정할 수 있습니다." % -quote.get_money_after())


func set_status(message: String) -> void:
	%LureStatus.text = message


func _unhandled_key_input(event: InputEvent) -> void:
	if is_visible_in_tree() and event.is_action_pressed(&"pause") and not event.is_echo():
		if _reviewing:
			selection_requested.emit()
		else:
			close_requested.emit()
		get_viewport().set_input_as_handled()
