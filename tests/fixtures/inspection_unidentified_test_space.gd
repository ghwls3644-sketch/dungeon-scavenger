extends Node2D

@onready var _player: PlayerController = %Player
@onready var _inventory: PlayerInventory = $Player/Inventory
@onready var _exploration_run: ExplorationRun = %ExplorationRun
@onready var _inventory_panel: InventoryPanel = %InventoryPanel
@onready var _outcome_panel: ExplorationOutcomePanel = %ExplorationOutcomePanel
@onready var _status: Label = %Status


func _ready() -> void:
	_inventory.configure_capacity(3, 4.0, 7.0)
	for pickup in [%UnknownScrapPickup, %UnknownResiduePickup]:
		pickup.inspection_completed.connect(_on_inspection_completed.bind(pickup))
	_inventory.item_added.connect(_on_item_added)
	_exploration_run.run_ended.connect(_on_run_ended)
	_outcome_panel.hide()


func _on_inspection_completed(
	_summary: String,
	_risk_hint: String,
	pickup: InspectablePickupInteractable
) -> void:
	_status.text = pickup.get_inspection_text()


func _on_item_added(item: ItemDefinition) -> void:
	_status.text = "%s을(를) 미확인 상태로 회수했습니다." % item.display_name


func _on_run_ended(outcome: ExplorationOutcome) -> void:
	if _inventory_panel.visible:
		_inventory_panel.close_inventory()
	_player.process_mode = Node.PROCESS_MODE_DISABLED
	_outcome_panel.bind_outcome(outcome)
	_outcome_panel.show()
	_status.text = "생환 결과에서 미확인 물품의 가치와 실제 분류가 숨겨지는지 확인하세요."
