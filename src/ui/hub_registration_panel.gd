class_name HubRegistrationPanel
extends Control

signal review_requested(index: int)
signal confirmation_requested
signal selection_requested
signal close_requested

var _items: Array[InventoryItem] = []
var _registered: Array[InventoryItem] = []
var _reasons: PackedStringArray
var _reviewing := false

@onready var _list: ItemList = %RegistrationItems
@onready var _archive: ItemList = %RegisteredItems


func _ready() -> void:
	_list.item_selected.connect(_selected)
	_archive.item_selected.connect(_read_registered)
	_list.resized.connect(_fit_rows)
	_archive.resized.connect(_fit_rows)
	_fit_rows.call_deferred()
	%ReviewRegistration.pressed.connect(func():
		var selected := _list.get_selected_items()
		if selected.size() == 1:
			review_requested.emit(selected[0]))
	%ConfirmRegistration.pressed.connect(func(): confirmation_requested.emit())
	%CancelRegistration.pressed.connect(func(): selection_requested.emit())
	%CloseRegistration.pressed.connect(func(): close_requested.emit())


func _fit_rows() -> void:
	for list in [_list, _archive]:
		list.fixed_column_width = maxi(1, int(list.size.x) - 32)


func present(items: Array[InventoryItem], reasons: PackedStringArray, registered: Array[InventoryItem]) -> void:
	_items = items
	_reasons = reasons
	_registered = registered
	_list.clear()
	_archive.clear()
	for index in items.size():
		var reason := "등록 가능 · 판매 불가" if reasons[index].is_empty() else reasons[index]
		var text := HubAppraisalPanel.format_item(items[index], reason)
		_list.add_item(text, ItemCategoryIcon.for_item(items[index]))
		_list.set_item_tooltip(index, text)
	for item in registered:
		_archive.add_item(item.get_definition().display_name, ItemCategoryIcon.for_item(item))
	%PendingCount.text = "거점 보관 %d개 · 하나씩 선택" % items.size()
	%RegisteredCount.text = "등록 목록 %d개 · 선택하여 다시 읽기" % registered.size()
	show()
	set_review(null)
	set_status("보관품을 선택하여 등록하거나, 등록 목록에서 설명을 다시 읽으세요.")
	_list.grab_focus()


func set_review(quote: RegistrationQuote) -> void:
	_reviewing = quote != null
	for list in [_list, _archive]:
		list.mouse_filter = Control.MOUSE_FILTER_IGNORE if _reviewing else Control.MOUSE_FILTER_STOP
		list.focus_mode = Control.FOCUS_NONE if _reviewing else Control.FOCUS_ALL
	%ReviewRegistration.visible = not _reviewing
	%ConfirmRegistration.visible = _reviewing
	%CancelRegistration.visible = _reviewing
	%ReviewRegistration.disabled = true
	if quote != null:
		set_status("%s\n이 원본을 등록 목록으로 옮겨 보관합니다. 등록 비용과 화폐 보상은 없습니다.\n확정하면 등록 결과를 저장합니다." % _items[quote.get_index()].get_definition().display_name)
		%ConfirmRegistration.grab_focus()
	elif not _list.get_selected_items().is_empty():
		_selected(_list.get_selected_items()[0])


func set_status(message: String) -> void:
	%RegistrationDetails.text = message


func _selected(index: int) -> void:
	if _reviewing:
		return
	_archive.deselect_all()
	%ReviewRegistration.disabled = not _reasons[index].is_empty()
	var reason := _reasons[index]
	if reason.is_empty():
		reason = "등록하면 원본을 보관하고 목록에서 설명을 다시 읽을 수 있습니다."
	set_status("%s\n%s" % [_items[index].get_definition().display_name, reason])


func _read_registered(index: int) -> void:
	if _reviewing:
		return
	_list.deselect_all()
	%ReviewRegistration.disabled = true
	var item := _registered[index]
	var definition := item.get_definition()
	var category := "핵심 기록물 · 연구자 보관" if definition.category == ItemDefinition.CATEGORY_CORE_RECORD else "고유 유물 · 수집 등록"
	set_status("%s · %s\n%s" % [definition.display_name, category, definition.registration_text])


func _unhandled_key_input(event: InputEvent) -> void:
	if is_visible_in_tree() and event.is_action_pressed(InputActions.PAUSE) and not event.is_echo():
		if _reviewing:
			selection_requested.emit()
		else:
			close_requested.emit()
		get_viewport().set_input_as_handled()
