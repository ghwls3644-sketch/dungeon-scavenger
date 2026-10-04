class_name HubUpgradePanel
extends Control

signal review_requested(id: String)
signal confirmation_requested
signal selection_requested
signal close_requested

var _money := 0
var _loadout: ExpeditionLoadout
var _rule: HarnessUpgradeRule
var _reviewing := false
@onready var _choices: OptionButton = %UpgradeChoice


func _ready() -> void:
	_choices.item_selected.connect(func(_index: int): _show_selection())
	%ReviewUpgrade.pressed.connect(func():
		if not _reviewing and _choices.selected >= 0:
			review_requested.emit(HarnessUpgradeRule.ALL[_choices.selected]))
	%ConfirmUpgrade.pressed.connect(func(): confirmation_requested.emit())
	%CancelUpgrade.pressed.connect(func(): selection_requested.emit())
	%CloseUpgrade.pressed.connect(func(): close_requested.emit())


func present(money: int, loadout: ExpeditionLoadout, rule: HarnessUpgradeRule) -> void:
	_money = money
	_loadout = loadout.copy()
	_rule = rule.duplicate(true) as HarnessUpgradeRule
	_choices.clear()
	for id in HarnessUpgradeRule.ALL:
		_choices.add_item("%s · %s" % [HarnessUpgradeRule.label(id), "보유" if id in loadout.harness_upgrades else "미보유"])
	%UpgradeSummary.text = "보유금 %d · 각 개선 1단계\n장착: %s" % [money, HarnessModules.describe(loadout.harness_modules)]
	show()
	set_review(null)
	_choices.grab_focus()


func set_review(quote: HarnessUpgradeQuote) -> void:
	_reviewing = quote != null
	_choices.disabled = _reviewing
	%ReviewUpgrade.visible = not _reviewing
	%ConfirmUpgrade.visible = _reviewing
	%CancelUpgrade.visible = _reviewing
	if _reviewing:
		%ConfirmUpgrade.disabled = not quote.can_afford()
		set_status("구매 비용 %d · 구매 후 보유금 %d\n확정하면 결제와 영구 보유를 함께 저장합니다." % [quote.get_cost(), quote.get_money_after()])
		%ConfirmUpgrade.grab_focus()
	else:
		_show_selection()


func set_status(message: String) -> void:
	%UpgradeStatus.text = message


func _show_selection() -> void:
	if _reviewing or _choices.selected < 0:
		return
	var id: String = HarnessUpgradeRule.ALL[_choices.selected]
	var owned := id in _loadout.harness_upgrades
	var equipped := HarnessUpgradeRule.module_for(id) in _loadout.harness_modules
	var cost := _rule.get_cost(id)
	%UpgradeDetails.text = "%s\n%s\n필요 기능: %s · %s\n획득: %s" % [HarnessUpgradeRule.label(id), _rule.describe(id),
		HarnessModules.label(HarnessUpgradeRule.module_for(id)), "장착됨" if equipped else "미장착 · 장착 후 적용",
		"거점 구매 또는 탐험 중 무료 발견" if id == HarnessUpgradeRule.EMERGENCY else "거점 구매"]
	%ReviewUpgrade.disabled = owned or _money < cost
	set_status("이미 보유했습니다. 추가 결제 없이 관련 기능 장착 시 적용됩니다." if owned else (
		"가격 %d · %d 부족" % [cost, cost - _money] if _money < cost else
		"가격 %d · 구매 후 보유금 %d\n구매는 장착을 바꾸거나 수리하지 않습니다." % [cost, _money - cost]))


func _unhandled_key_input(event: InputEvent) -> void:
	if is_visible_in_tree() and event.is_action_pressed(&"pause") and not event.is_echo():
		if _reviewing:
			selection_requested.emit()
		else:
			close_requested.emit()
		get_viewport().set_input_as_handled()
