class_name RecoveryResult
extends RefCounted

var _recovered_items: Array[ItemDefinition] = []
var _total_value_min := 0
var _total_value_max := 0
var _non_monetary_reward_count := 0


static func from_recovered_items(recovered_items: Array[ItemDefinition]) -> RecoveryResult:
	var result := RecoveryResult.new()
	result._capture(recovered_items)
	return result


func get_recovered_items() -> Array[ItemDefinition]:
	return _recovered_items.duplicate()


func get_item_count() -> int:
	return _recovered_items.size()


func get_total_value_min() -> int:
	return _total_value_min


func get_total_value_max() -> int:
	return _total_value_max


func get_non_monetary_reward_count() -> int:
	return _non_monetary_reward_count


func _capture(recovered_items: Array[ItemDefinition]) -> void:
	for item in recovered_items:
		if item == null:
			continue

		_recovered_items.append(item)
		if item.has_monetary_value():
			_total_value_min += item.value_min
			_total_value_max += item.value_max
		else:
			_non_monetary_reward_count += 1
