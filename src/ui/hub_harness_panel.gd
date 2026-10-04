class_name HubHarnessPanel
extends Control

signal review_requested(modules: Array)
signal confirmation_requested
signal selection_requested
signal close_requested

var _current: Array[String] = []
var _reviewing := false
@onready var _choices: OptionButton = %HarnessChoice


func _ready() -> void:
	_choices.item_selected.connect(func(_index: int): _show_selection())
	%ReviewHarness.pressed.connect(func():
		if not _reviewing and _choices.selected >= 0:
			review_requested.emit(HarnessModules.PAIRS[_choices.selected].duplicate()))
	%ConfirmHarness.pressed.connect(func(): confirmation_requested.emit())
	%CancelHarness.pressed.connect(func(): selection_requested.emit())
	%CloseHarness.pressed.connect(func(): close_requested.emit())


func present(current: Array[String]) -> void:
	_current = current.duplicate()
	_choices.clear()
	for pair in HarnessModules.PAIRS:
		_choices.add_item(HarnessModules.describe(pair))
		if _same_pair(current, pair):
			_choices.select(_choices.item_count - 1)
	%HarnessSummary.text = "현재 장착: %s\n세 기능 중 두 기능 장착 · 변경 비용 0 · 공용 충전 3" % HarnessModules.describe(current)
	show()
	set_review([])
	_choices.grab_focus()


func set_review(modules: Array) -> void:
	_reviewing = not modules.is_empty()
	_choices.disabled = _reviewing
	%ReviewHarness.visible = not _reviewing
	%ConfirmHarness.visible = _reviewing
	%CancelHarness.visible = _reviewing
	if _reviewing:
		%HarnessDetails.text = HarnessModules.details(modules)
		set_status("확정하면 다음 출정의 장착 구성을 저장합니다. 비용은 없습니다.")
		%ConfirmHarness.grab_focus()
	else:
		_show_selection()


func set_status(message: String) -> void:
	%HarnessStatus.text = message


func _show_selection() -> void:
	if _reviewing or _choices.selected < 0:
		return
	var pair: Array = HarnessModules.PAIRS[_choices.selected]
	%HarnessDetails.text = HarnessModules.details(pair)
	%ReviewHarness.disabled = _same_pair(_current, pair)
	set_status("현재 장착 중인 구성입니다." if %ReviewHarness.disabled else "가능한 행동과 미장착 기능을 확인하세요. 아직 장착을 변경하지 않았습니다.")


func _same_pair(first: Array, second: Array) -> bool:
	return first.size() == second.size() and first.all(func(id: String): return id in second)


func _unhandled_key_input(event: InputEvent) -> void:
	if is_visible_in_tree() and event.is_action_pressed(&"pause") and not event.is_echo():
		if _reviewing:
			selection_requested.emit()
		else:
			close_requested.emit()
		get_viewport().set_input_as_handled()
