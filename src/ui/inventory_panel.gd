class_name InventoryPanel
extends PanelContainer

@export var inventory_source_path: NodePath

var _inventory: PlayerInventory
var _tree_was_paused := false

@onready var _summary: Label = %Summary
@onready var _item_list: ItemList = %ItemList
@onready var _status: Label = %Status
@onready var _drop_button: Button = %DropButton
@onready var _close_button: Button = %CloseButton
@onready var _drop_confirmation: ConfirmationDialog = %DropConfirmation


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_item_list.item_selected.connect(_on_item_selected)
	_drop_button.pressed.connect(_on_drop_pressed)
	_close_button.pressed.connect(close_inventory)
	_drop_confirmation.confirmed.connect(_on_drop_confirmed)
	hide()
	if not inventory_source_path.is_empty():
		bind_inventory(get_node_or_null(inventory_source_path) as PlayerInventory)


func _input(event: InputEvent) -> void:
	# Handle both directions before focused controls consume Tab as focus navigation.
	if not event.is_action_pressed(InputActions.INVENTORY):
		return

	get_viewport().set_input_as_handled()
	if visible:
		close_inventory()
	else:
		open_inventory()


func _exit_tree() -> void:
	if visible and get_tree() != null:
		get_tree().paused = _tree_was_paused


func bind_inventory(inventory: PlayerInventory) -> void:
	if _inventory != null:
		if _inventory.inventory_changed.is_connected(_render):
			_inventory.inventory_changed.disconnect(_render)
		if _inventory.item_add_rejected.is_connected(_on_item_add_rejected):
			_inventory.item_add_rejected.disconnect(_on_item_add_rejected)
		if _inventory.item_drop_rejected.is_connected(_on_item_drop_rejected):
			_inventory.item_drop_rejected.disconnect(_on_item_drop_rejected)

	_inventory = inventory
	if _inventory == null:
		_render()
		return

	_inventory.inventory_changed.connect(_render)
	_inventory.item_add_rejected.connect(_on_item_add_rejected)
	_inventory.item_drop_rejected.connect(_on_item_drop_rejected)
	_render()


func open_inventory() -> void:
	if visible:
		return
	_tree_was_paused = get_tree().paused
	show()
	get_tree().paused = true
	_render()


func close_inventory() -> void:
	if not visible:
		return
	_drop_confirmation.hide()
	hide()
	get_tree().paused = _tree_was_paused


func get_summary_text() -> String:
	return _summary.text


func get_status_text() -> String:
	return _status.text


func get_displayed_item_count() -> int:
	return _item_list.item_count


func get_displayed_item_text(index: int) -> String:
	if index < 0 or index >= _item_list.item_count:
		return ""
	return _item_list.get_item_text(index)


func _render() -> void:
	_item_list.clear()
	if _inventory == null:
		_summary.text = "인벤토리 연결 없음"
		_drop_button.disabled = true
		return

	var items := _inventory.get_inventory_items()
	for item in items:
		_item_list.add_item(_format_item(item))

	var selected_index := _inventory.get_selected_index()
	if selected_index >= 0 and selected_index < items.size():
		_item_list.select(selected_index)
	_drop_button.disabled = selected_index < 0
	_summary.text = "슬롯 %d/%d | 무게 %.1f | 상태 %s" % [
		_inventory.get_used_slots(),
		_inventory.slot_capacity,
		_inventory.get_total_weight(),
		_get_weight_stage_text(_inventory.get_weight_stage()),
	]


func _format_item(item: InventoryItem) -> String:
	var definition := item.get_definition()
	var risk_text := " | %s" % item.get_risk_hint() if not item.get_risk_hint().is_empty() else ""
	if not item.is_identified():
		return "%s | %d칸 | 무게 %.1f%s | 미확인 물품 | 가치 미확인 | 보호 여부 미확인" % [
			definition.display_name,
			definition.slot_size,
			definition.weight,
			risk_text,
		]

	var protection_text := "보호" if definition.is_protected() else "일반"
	return "%s | %d칸 | 무게 %.1f%s | %s | %s | %s" % [
		definition.display_name,
		definition.slot_size,
		definition.weight,
		risk_text,
		_get_category_text(definition.category),
		ItemValueText.format_inventory_item_value(item),
		protection_text,
	]


func _get_weight_stage_text(stage: PlayerInventory.WeightStage) -> String:
	match stage:
		PlayerInventory.WeightStage.BURDENED:
			return "부담"
		PlayerInventory.WeightStage.OVERLOADED:
			return "과적"
		_:
			return "정상"


func _get_category_text(category: StringName) -> String:
	match category:
		ItemDefinition.CATEGORY_SCRAP:
			return "폐품"
		ItemDefinition.CATEGORY_RESIDUE:
			return "잔재"
		ItemDefinition.CATEGORY_UNIQUE_ARTIFACT:
			return "고유 유물"
		ItemDefinition.CATEGORY_CORE_RECORD:
			return "핵심 기록물"
		_:
			return "미분류"


func _on_item_selected(index: int) -> void:
	if _inventory != null:
		_inventory.select_item(index)


func _on_drop_pressed() -> void:
	if _inventory == null:
		return
	var index := _inventory.get_selected_index()
	var items := _inventory.get_items()
	if index < 0 or index >= items.size():
		_status.text = "버릴 물품을 선택하세요."
		return

	_drop_confirmation.dialog_text = "%s을(를) 버리겠습니까?" % items[index].display_name
	_drop_confirmation.popup_centered()


func _on_drop_confirmed() -> void:
	if _inventory == null:
		return
	var dropped_item := _inventory.drop_selected_item()
	if dropped_item == null:
		return
	_status.text = "%s을(를) 버렸습니다." % dropped_item.display_name


func _on_item_drop_rejected(reason: StringName) -> void:
	_status.text = "이 물품은 버릴 수 없습니다." if reason == PlayerInventory.REJECT_PROTECTED_ITEM else "버릴 물품을 선택하세요."


func _on_item_add_rejected(_item: ItemDefinition, reason: StringName) -> void:
	match reason:
		PlayerInventory.REJECT_SLOT_LIMIT:
			_status.text = "슬롯 한도를 초과해 회수하지 못했습니다."
		PlayerInventory.REJECT_INVALID_CONFIGURATION:
			_status.text = "인벤토리 한도 설정을 확인하세요."
		_:
			_status.text = "회수할 수 없는 물품입니다."
