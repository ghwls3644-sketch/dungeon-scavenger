class_name HubRepairPanel
extends Control

signal review_requested(amount: int, supported: bool)
signal confirmation_requested
signal selection_requested
signal close_requested

var _offers: Array[RepairQuote] = []
var _reviewing := false

@onready var _choices: OptionButton = %RepairChoice


func _ready() -> void:
	_choices.item_selected.connect(func(_index: int): _show_selection())
	%ReviewRepair.pressed.connect(_request_review)
	%ConfirmRepair.pressed.connect(func(): confirmation_requested.emit())
	%CancelRepair.pressed.connect(func(): selection_requested.emit())
	%CloseRepair.pressed.connect(func(): close_requested.emit())


func present(durability: int, maximum: int, money: int, minimum: int, offers: Array[RepairQuote]) -> void:
	_offers = offers.duplicate()
	_choices.clear()
	%RepairSummary.text = "기본 하네스 내구 %d/%d · 보유금 %d\n수리 없이도 출정 가능 · 최소 복구 지원 목표: 내구 %d" % [durability, maximum, money, minimum]
	for quote in offers:
		var label := "최소 복구 지원 · 내구 +%d · 비용 0" % quote.get_amount() if quote.is_supported() \
			else "%s · 내구 +%d · 비용 %d" % ["완전 수리" if quote.get_durability_after() == maximum else "부분 수리", quote.get_amount(), quote.get_cost()]
		_choices.add_item(label)
	show()
	set_review(null)
	if _offers.is_empty():
		%CloseRepair.grab_focus()
	else:
		_choices.select(0)
		_choices.grab_focus()


func set_review(quote: RepairQuote) -> void:
	_reviewing = quote != null
	_choices.disabled = _reviewing or _offers.is_empty()
	%ReviewRepair.visible = not _reviewing
	%ReviewRepair.disabled = _offers.is_empty()
	%ConfirmRepair.visible = _reviewing
	%CancelRepair.visible = _reviewing
	if quote == null:
		_show_selection()
		return
	%RepairDetails.text = _describe(quote)
	%ConfirmRepair.disabled = not quote.can_afford()
	%ConfirmRepair.text = "지원 복구 확정" if quote.is_supported() else "비용 지불 · 수리 확정"
	if quote.can_afford():
		set_status("확정하면 복구 결과와 보유금을 저장합니다.")
		%ConfirmRepair.grab_focus()
	else:
		set_status("보유금이 %d 부족합니다. 복구량을 줄이거나 최소 복구 지원을 확인하세요." % -quote.get_money_after())
		%CancelRepair.grab_focus()


func set_status(message: String) -> void:
	%RepairStatus.text = message


func _show_selection() -> void:
	if _reviewing:
		return
	var index := _choices.selected
	if index < 0 or index >= _offers.size():
		%RepairDetails.text = "수리할 손상이 없습니다."
		set_status("거점으로 돌아가 출정할 수 있습니다.")
		return
	%RepairDetails.text = _describe(_offers[index])
	set_status("복구량과 비용을 확인한 뒤 확정하세요. 아직 비용을 지불하지 않았습니다.")


func _request_review() -> void:
	if _reviewing or _choices.selected < 0 or _choices.selected >= _offers.size():
		return
	var quote := _offers[_choices.selected]
	review_requested.emit(quote.get_amount(), quote.is_supported())


func _describe(quote: RepairQuote) -> String:
	var balance := "복구 후 보유금 %d" % quote.get_money_after() if quote.can_afford() else "보유금 %d 부족" % -quote.get_money_after()
	return "내구 %d/%d → %d/%d\n%s · 예상 비용 %d · %s\n%s" % [
		quote.get_durability_before(), quote.get_maximum(), quote.get_durability_after(), quote.get_maximum(),
		"최소 복구 지원 견적" if quote.is_supported() else "선택 수리 견적", quote.get_cost(), balance,
		"최소 수리비가 부족할 때 내구 %d까지 무료로 복구합니다." % quote.get_durability_after() if quote.is_supported() else "이번에 선택한 복구량만 수리합니다.",
	]


func _unhandled_key_input(event: InputEvent) -> void:
	if is_visible_in_tree() and event.is_action_pressed(&"pause") and not event.is_echo():
		if _reviewing:
			selection_requested.emit()
		else:
			close_requested.emit()
		get_viewport().set_input_as_handled()
