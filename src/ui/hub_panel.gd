class_name HubPanel
extends Control

signal bag_slots_selected(slots: int)
signal departure_requested
signal quit_requested
signal appraisal_requested

@onready var _bags: OptionButton = %BagChoice
@onready var _details: Label = %PreparationDetails
@onready var _departure: Button = %DepartureButton
@onready var _quit: Button = %HubQuitButton
@onready var _status: Label = %HubStatus


func _ready() -> void:
	_bags.item_selected.connect(func(index: int): bag_slots_selected.emit(_bags.get_item_id(index)))
	_departure.pressed.connect(func(): departure_requested.emit())
	_quit.pressed.connect(func(): quit_requested.emit())
	%AppraisalButton.pressed.connect(func(): appraisal_requested.emit())


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
	_details.text = "적재 여유 %d칸 · 시작 무게 0\n부담 %.1f / 과적 %.1f\n하네스 충전 %d/%d\n분석 · 안정화 · 비상 방전" % [
		loadout.slot_capacity, loadout.burden_weight, loadout.overload_weight,
		loadout.starting_charge, loadout.charge_capacity,
	]
	_status.text = "출정 준비 중…" if busy else ""


func set_status(message: String) -> void:
	_status.text = message


func render_holdings(money: int, items: Array[InventoryItem]) -> void:
	%Money.text = "보유금 %d" % money
	%StoredCount.text = "거점 보관 %d개" % items.size()
	var lines := PackedStringArray()
	for item in items:
		lines.append(HubAppraisalPanel.format_item(item))
	%StoredItems.text = "\n\n".join(lines) if not lines.is_empty() else "보관 중인 물품이 없습니다."


func present() -> void:
	show()
	_departure.grab_focus()
