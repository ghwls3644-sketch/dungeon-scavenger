extends Node2D

@onready var _player: PlayerController = %Player
@onready var _inventory: PlayerInventory = %Player/Inventory
@onready var _exploration_run: ExplorationRun = %ExplorationRun
@onready var _hazard: UnstableDebrisHazard = %UnstableDebrisHazard
@onready var _instructions: Label = %Instructions
@onready var _outcome_panel: ExplorationOutcomePanel = %ExplorationOutcomePanel


func _ready() -> void:
	_inventory.configure_capacity(3, 10.0, 20.0)
	_inventory.try_add_item(_create_test_item())
	_exploration_run.run_ended.connect(_on_run_ended)
	_hazard.body_caught.connect(_on_body_caught)
	_outcome_panel.hide()


func _on_body_caught(body: Node2D) -> void:
	if body == _player:
		_exploration_run.complete_failure()


func _on_run_ended(outcome: ExplorationOutcome) -> void:
	_player.process_mode = Node.PROCESS_MODE_DISABLED
	_outcome_panel.bind_outcome(outcome)
	_outcome_panel.show()
	_instructions.text = "탐험이 종료되었습니다. 생환과 실패 결과를 확인하세요."


func _create_test_item() -> ItemDefinition:
	var item := ItemDefinition.new()
	item.stable_id = &"test_exploration_end_scrap"
	item.display_name = "시험용 회수품"
	item.category = ItemDefinition.CATEGORY_SCRAP
	item.weight = 1.0
	item.slot_size = 1
	item.value_min = 10
	item.value_max = 20
	return item
