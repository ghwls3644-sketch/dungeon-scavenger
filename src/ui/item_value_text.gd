class_name ItemValueText
extends RefCounted


static func format_item_value(item: ItemDefinition) -> String:
	if item == null:
		return "가치 정보 없음"
	if not item.has_monetary_value():
		return "등록·정보 보상"
	return "예상 가치 %s" % format_range(item.value_min, item.value_max)


static func format_inventory_item_value(item: InventoryItem) -> String:
	if item == null or not item.is_valid():
		return "가치 정보 없음"
	if not item.is_identified():
		return "가치 미확인"
	return format_item_value(item.get_definition())


static func format_range(value_min: int, value_max: int) -> String:
	if value_min == value_max:
		return str(value_min)
	return "%d~%d" % [value_min, value_max]


static func format_weight_value(item: InventoryItem) -> String:
	var comparison := ItemValueComparison.from_item(item)
	match comparison.status:
		ItemValueComparison.Status.UNIDENTIFIED:
			return "무게 대비 가치 미확인"
		ItemValueComparison.Status.NON_MONETARY:
			return "금전 비교 제외"
		ItemValueComparison.Status.ZERO_WEIGHT:
			return "무게 0 · 비교 제외"
		ItemValueComparison.Status.AVAILABLE:
			var low := "%.1f" % comparison.minimum
			var high := "%.1f" % comparison.maximum
			return "무게 1당 약 %s" % (low if low == high else "%s~%s" % [low, high])
		_:
			return "무게 대비 가치 정보 없음"
