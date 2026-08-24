extends Node2D

@onready var _result_panel: RecoveryResultPanel = %RecoveryResultPanel


func _ready() -> void:
	var recovered_items: Array[ItemDefinition] = [
		_create_test_item(&"test_small_scrap", "시험용 소형 폐품", ItemDefinition.CATEGORY_SCRAP, 10, 20),
		_create_test_item(&"test_residue", "시험용 잔재", ItemDefinition.CATEGORY_RESIDUE, 30, 40),
		_create_test_item(&"test_artifact", "시험용 고유 유물", ItemDefinition.CATEGORY_UNIQUE_ARTIFACT, 0, 0),
	]
	_result_panel.bind_result(RecoveryResult.from_recovered_items(recovered_items))


func _create_test_item(
	id: StringName,
	display_name: String,
	category: StringName,
	value_min: int,
	value_max: int
) -> ItemDefinition:
	var item := ItemDefinition.new()
	item.stable_id = id
	item.display_name = display_name
	item.category = category
	item.weight = 1.0
	item.slot_size = 1
	item.value_min = value_min
	item.value_max = value_max
	item.sale_protected = not item.has_monetary_value()
	return item
