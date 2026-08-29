extends Node2D

@onready var _player: PlayerController = %Player
@onready var _inventory: PlayerInventory = $Player/Inventory
@onready var _harness: HarnessController = $Player/HarnessController
@onready var _exploration_run: ExplorationRun = %ExplorationRun
@onready var _hazard: UnstableDebrisHazard = %RiskHazard
@onready var _choice_status: Label = %ChoiceStatus
@onready var _inventory_panel: InventoryPanel = %InventoryPanel
@onready var _outcome_panel: ExplorationOutcomePanel = %ExplorationOutcomePanel


func _ready() -> void:
	_inventory.configure_capacity(2, 2.5, 4.0)
	_harness.configure_charge(1)
	_inventory.item_added.connect(_on_item_added)
	_inventory.item_dropped.connect(_on_item_dropped)
	_inventory.item_add_rejected.connect(_on_item_add_rejected)
	_harness.action_succeeded.connect(_on_harness_action_succeeded)
	_exploration_run.run_ended.connect(_on_run_ended)
	_hazard.warning_started.connect(_on_warning_started)
	_hazard.body_caught.connect(_on_body_caught)
	_outcome_panel.hide()


func _on_item_added(item: ItemDefinition) -> void:
	_choice_status.text = "%s 회수 | 슬롯 %d/%d" % [
		item.display_name,
		_inventory.get_used_slots(),
		_inventory.slot_capacity,
	]


func _on_item_dropped(item: ItemDefinition) -> void:
	_choice_status.text = "%s을(를) 버려 슬롯을 확보했습니다." % item.display_name


func _on_item_add_rejected(item: ItemDefinition, reason: StringName) -> void:
	if reason == PlayerInventory.REJECT_SLOT_LIMIT:
		_choice_status.text = "%s: 슬롯이 가득 찼습니다. Tab에서 물품 하나를 버릴지 선택하세요." % item.display_name


func _on_warning_started(_duration: float) -> void:
	_choice_status.text = "위험 경로의 먼지·진동 징후입니다. Q로 안정화하거나 돌아가세요."


func _on_harness_action_succeeded(_hazard_target: StabilizableHazard) -> void:
	_choice_status.text = "하네스 충전을 사용해 위험 경로를 안정화했습니다."


func _on_body_caught(body: Node2D) -> void:
	if body == _player:
		_exploration_run.complete_failure()


func _on_run_ended(outcome: ExplorationOutcome) -> void:
	if _inventory_panel.visible:
		_inventory_panel.close_inventory()
	_player.process_mode = Node.PROCESS_MODE_DISABLED
	_outcome_panel.bind_outcome(outcome)
	_outcome_panel.show()
	_choice_status.text = "탐험이 종료되었습니다. 결과와 선택을 확인하세요."
