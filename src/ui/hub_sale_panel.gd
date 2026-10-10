class_name HubSalePanel
extends Control

signal review_requested(indices: PackedInt32Array)
signal confirmation_requested
signal selection_requested
signal close_requested

var _offers: Array[Dictionary] = []
var _reviewing := false

@onready var _list: ItemList = %SaleItems


func _ready() -> void:
	_list.resized.connect(_fit_rows)
	_fit_rows.call_deferred()
	%ReviewSale.pressed.connect(func(): review_requested.emit(_list.get_selected_items()))
	%ConfirmSale.pressed.connect(func(): confirmation_requested.emit())
	%CancelSale.pressed.connect(func(): selection_requested.emit())
	%CloseSale.pressed.connect(func(): close_requested.emit())
	_list.multi_selected.connect(func(_index: int, _selected: bool): _selection_changed())


func _fit_rows() -> void:
	_list.fixed_column_width = maxi(1, int(_list.size.x) - 32)


func present(money: int, offers: Array[Dictionary]) -> void:
	_offers = offers
	_list.clear()
	%SaleMoney.text = "보유금 %d" % money
	for offer in offers:
		var item: InventoryItem = offer.item
		var details := HubAppraisalPanel.format_item(item, format_availability(offer))
		var index := _list.add_item(details, ItemCategoryIcon.for_item(item))
		_list.set_item_selectable(index, offer.status == SaleQuote.Status.AVAILABLE)
		_list.set_item_tooltip(index, details)
	show()
	set_review(null)
	_list.grab_focus()


func set_review(quote: SaleQuote) -> void:
	_reviewing = quote != null
	_list.mouse_filter = Control.MOUSE_FILTER_IGNORE if _reviewing else Control.MOUSE_FILTER_STOP
	_list.focus_mode = Control.FOCUS_NONE if _reviewing else Control.FOCUS_ALL
	%ReviewSale.visible = not _reviewing
	%ConfirmSale.visible = _reviewing
	%CancelSale.visible = _reviewing
	if quote == null:
		_selection_changed()
		return
	%SaleStatus.text = "선택 %d개 · 판매 총액 %d · 회수세 %d (%d%%)\n실제 입금 +%d · 판매 후 보유금 %d\n확정하면 선택한 물품을 판매하고 결과를 저장합니다." % [quote.get_count(), quote.get_income(), quote.get_tax(), quote.get_tax_receipt().rate, quote.get_net_income(), quote.get_money_after()]
	%ConfirmSale.grab_focus()


func set_status(message: String) -> void:
	%SaleStatus.text = message


func _selection_changed() -> void:
	if _reviewing:
		return
	var count := _list.get_selected_items().size()
	%ReviewSale.disabled = count == 0
	var available := false
	for offer in _offers:
		if offer.status == SaleQuote.Status.AVAILABLE:
			available = true
	%SaleStatus.text = "선택 %d개 · 판매액을 확인한 뒤 확정하세요." % count if available else "판매 가능한 보관품이 없습니다."


func _unhandled_key_input(event: InputEvent) -> void:
	if is_visible_in_tree() and event.is_action_pressed(InputActions.PAUSE) and not event.is_echo():
		if _reviewing:
			selection_requested.emit()
		else:
			close_requested.emit()
		get_viewport().set_input_as_handled()


static func format_availability(offer: Dictionary) -> String:
	match offer.status:
		SaleQuote.Status.AVAILABLE:
			return "판매가 %d" % offer.price
		SaleQuote.Status.UNIDENTIFIED:
			return "미확인 · 감정 필요"
		SaleQuote.Status.PROTECTED:
			return "판매 불가 · 보호 물품"
		SaleQuote.Status.UNPRICED:
			return "판매가 미설정 · 보관"
		_:
			return "판매 정보를 확인할 수 없습니다."
