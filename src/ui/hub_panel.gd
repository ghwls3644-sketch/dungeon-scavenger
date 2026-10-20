class_name HubPanel
extends Control

signal bag_slots_selected(slots: int)
signal departure_requested
signal quit_requested
signal appraisal_requested
signal sale_requested
signal registration_requested
signal upgrade_requested
signal harness_requested
signal repair_requested
signal lures_requested
signal portable_requested
signal objective_selected(offer: Dictionary, source: Dictionary)

var _objective_source: Dictionary = {}
var _objective_offer: Dictionary = {}
var _objective_busy := false

@onready var _bags: OptionButton = %BagChoice
@onready var _details: Label = %PreparationDetails
@onready var _departure: Button = %DepartureButton
@onready var _quit: Button = %HubQuitButton
@onready var _status: Label = %HubStatus


func _ready() -> void:
	%CostTabs.set_tab_title(0, "보관품")
	%CostTabs.set_tab_title(1, "수입·비용")
	%CostTabs.set_tab_title(2, "목표·의뢰")
	%ObjectiveChoice.add_item("자유 수색", 0)
	%ObjectiveChoice.add_item("폐품 회수 의뢰", 1)
	%ObjectiveChoice.item_selected.connect(func(_index: int): _render_objective_choice())
	%ObjectiveConfirm.pressed.connect(func(): objective_selected.emit(
		_objective_offer.duplicate(true) if %ObjectiveChoice.selected == 1 else {}, _objective_source.duplicate(true)))
	%PortableButton.pressed.connect(func(): portable_requested.emit())
	%LureButton.pressed.connect(func(): lures_requested.emit())
	_bags.item_selected.connect(func(index: int): bag_slots_selected.emit(_bags.get_item_id(index)))
	_departure.pressed.connect(func(): departure_requested.emit())
	_quit.pressed.connect(func(): quit_requested.emit())
	%AppraisalButton.pressed.connect(func(): appraisal_requested.emit())
	%SaleButton.pressed.connect(func(): sale_requested.emit())
	%RegistrationButton.pressed.connect(func(): registration_requested.emit())
	%UpgradeButton.pressed.connect(func(): upgrade_requested.emit())
	%HarnessButton.pressed.connect(func(): harness_requested.emit())
	%RepairButton.pressed.connect(func(): repair_requested.emit())


func configure_bag_choices(slots: Array[int]) -> void:
	_bags.clear()
	for capacity in slots:
		_bags.add_item("가방 %d칸" % capacity, capacity)


func render_preparation(loadout: ExpeditionLoadout, busy: bool) -> void:
	_bags.select(_bags.get_item_index(loadout.slot_capacity))
	_bags.disabled = busy
	_departure.disabled = busy
	_quit.disabled = busy
	%AppraisalButton.disabled = busy
	%SaleButton.disabled = busy
	%RegistrationButton.disabled = busy
	%RepairButton.disabled = busy
	%UpgradeButton.disabled = busy
	%HarnessButton.disabled = busy
	%LureButton.disabled = busy
	%PortableButton.disabled = busy
	_objective_busy = busy
	%ObjectiveChoice.disabled = busy
	_render_objective_choice()
	_details.text = "적재 여유 %d칸 · 시작 무게 %.2f\n유인물 %d개 · 감정 도구 %d개\n부담 %.1f / 과적 %.1f\n하네스 충전 %d/%d\n장착: %s" % [
		loadout.slot_capacity, loadout.lure_count * loadout.lure_weight + loadout.appraisal_count * loadout.appraisal_weight, loadout.lure_count, loadout.appraisal_count, loadout.burden_weight, loadout.overload_weight,
		loadout.starting_charge, loadout.charge_capacity, HarnessModules.describe(loadout.harness_modules),
	]
	if not loadout.harness_upgrades.is_empty():
		var names := PackedStringArray()
		for id in loadout.harness_upgrades:
			names.append(HarnessUpgradeRule.label(id) + (" 적용" if HarnessUpgradeRule.module_for(id) in loadout.harness_modules else " 미장착"))
		_details.text += "\n" + " · ".join(names)
	_status.text = "출정 준비 중…" if busy else ""


func set_status(message: String) -> void:
	_status.text = message


func render_equipment(durability: int, maximum: int) -> void:
	%EquipmentStatus.text = "기본 하네스 내구 %d/%d\n%s" % [durability, maximum,
		"수리 없이도 출정 가능 · 출정 전에 내구 0 상태를 확인합니다." if durability == 0 else "출정 가능 · 수리는 거점에서 선택할 수 있습니다."]
	_departure.text = "출정"


func render_holdings(money: int, items: Array[InventoryItem], preparation_costs: Dictionary = {}, last_costs: Dictionary = {}) -> void:
	%Money.text = "보유금 %d" % money
	%StoredCount.text = "거점 보관 %d개" % items.size()
	var lines := PackedStringArray()
	for item in items:
		lines.append(HubAppraisalPanel.format_item(item))
	%StoredItems.text = "\n\n".join(lines) if not lines.is_empty() else "보관 중인 물품이 없습니다."
	%CostDetails.text = CostReportText.preparation(preparation_costs, last_costs)


func present() -> void:
	show()
	_departure.grab_focus()


func render_objective(hub: HubState) -> void:
	_objective_source = hub.to_save_data()
	_objective_offer = ExpeditionObjective.RULE.offer()
	%ObjectiveChoice.select(0 if hub.get_objective_offer().is_empty() else 1)
	%ObjectiveCurrent.text = "현재 선택: " + ("자유 수색" if hub.get_objective_offer().is_empty() else "폐품 회수 의뢰")
	_render_objective_choice()


func _render_objective_choice() -> void:
	var selected: Dictionary = _objective_offer if %ObjectiveChoice.selected == 1 else {}
	%ObjectiveDescription.text = ObjectiveText.description(selected)
	%ObjectiveConfirm.disabled = _objective_busy or _objective_source.is_empty() \
		or selected == _objective_source.get("objective", {})
