class_name HubRepairTestInput
extends RefCounted

# Repeated expedition tests explicitly buy the minimum repair through the service.
static func prepare_departure(entry: GameEntry) -> int:
	if entry.get_hub_harness_durability() >= 1:
		return 0
	var before := entry.get_hub_money()
	var hub: HubPanel = entry.get_node("Interface/HubPanel")
	var panel: HubRepairPanel = hub.get_node("RepairPanel")
	hub.repair_requested.emit()
	panel.get_node("%ReviewRepair").pressed.emit()
	panel.get_node("%ConfirmRepair").pressed.emit()
	panel.get_node("%CloseRepair").pressed.emit()
	assert(entry.get_hub_harness_durability() == 1, "Minimum repair failed before repeated expedition.")
	return before - entry.get_hub_money()
