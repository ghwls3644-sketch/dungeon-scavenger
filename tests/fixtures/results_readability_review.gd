extends Node

const SCREEN := preload("res://src/ui/expedition_results_screen.tscn")
const CATALOG := preload("res://src/data/prototype_item_catalog.tres")
const ECONOMY := preload("res://src/data/prototype_economy.tres")
const UPGRADES := preload("res://src/data/prototype_harness_upgrades.tres")
const CASES := ["paid_tools", "failure", "missed", "empty", "unknown", "legacy", "long_money", "negative", "protected", "investment"]


func _ready() -> void:
	var case_name := "paid_tools"
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--result-case="):
			case_name = argument.trim_prefix("--result-case=")
	var example := make_case(case_name)
	if example.is_empty():
		push_error("Invalid result review case.")
		get_tree().quit(1)
		return
	get_window().size = Vector2i(1152, 648)
	get_window().title = "Dungeon Scavenger · 정산 화면 검토 · 예시 자료"
	var screen: ExpeditionResultsScreen = SCREEN.instantiate()
	add_child(screen)
	screen.show()
	screen.present_result(example.outcome, example.settlement)
	# A display-only review never reads or writes personal progress/settings.
	screen.settlement_requested.connect(func(): get_tree().quit())
	screen.quit_requested.connect(func(): get_tree().quit())
	GameLog.info(&"Review", &"results_ready", case_name)


static func make_case(case_name: String) -> Dictionary:
	if case_name not in CASES:
		return {}
	var data := HubState.new().to_save_data()
	var money := 200 if case_name == "investment" else (ExpeditionCosts.LIMIT if case_name == "long_money" else 100)
	data.money = str(money)
	var stock: Array = [""] if case_name == "unknown" else (["5"] if case_name == "negative" else [])
	data.paid_lures = stock.size()
	data.selected_lures = 2 + stock.size()
	data.costs = ExpeditionCosts.new_book(money, stock, case_name == "unknown")
	if case_name in ["legacy", "long_money"]:
		data.costs.period.opening_money = "0" if case_name == "long_money" else "20"
		data.costs.period.storage_income = str(money) if case_name == "long_money" else "80"
		data.costs.period.tax_legacy_income = data.costs.period.storage_income
	if case_name == "investment":
		data.harness_durability = 2
	var hub := HubState.from_save_data(data, CATALOG)
	if hub == null:
		return {}
	if case_name in ["paid_tools", "failure"]:
		if not hub.apply_lures(hub.quote_lures(4, LurePreparation.RULE), LurePreparation.RULE) or not hub.apply_portable_appraisals(hub.quote_portable_appraisals(2)):
			return {}
	if case_name == "investment":
		if not hub.apply_repair(hub.quote_repair(1, ECONOMY), ECONOMY) or not hub.apply_harness_upgrade(hub.quote_harness_upgrade(HarnessUpgradeRule.OBSERVATION, UPGRADES), UPGRADES):
			return {}
	if case_name in ["paid_tools", "failure", "missed", "investment"]:
		if not hub.select_objective(ExpeditionObjective.RULE.offer(), hub.to_save_data()):
			return {}
	var id := hub.reserve_departure()
	if id <= 0 or not hub.mark_departure_started(id):
		return {}
	var items: Array[InventoryItem] = []
	var ids: Array = []
	if case_name in ["paid_tools", "unknown", "investment"]:
		ids = ["test_g1_heavy", "test_g1_light"]
	elif case_name == "missed":
		ids = ["test_g1_heavy"]
	elif case_name == "protected":
		ids = ["test_g1_known", "test_g4_artifact", "test_g4_record"]
	for item_id in ids:
		items.append(InventoryItem.from_definition(CATALOG.find_item(StringName(item_id)), true))
	var outcome := ExplorationOutcome.failure(2) if case_name in ["failure", "negative"] else ExplorationOutcome.safe_return_inventory_items(items)
	var loadout := hub.create_departure_loadout()
	outcome.record_lure_usage(loadout.lure_count, 3 if case_name in ["paid_tools", "unknown"] else 0)
	outcome.record_appraisal_usage(loadout.appraisal_count, 1 if case_name == "paid_tools" else 0)
	if not hub.prepare_settlement(id, outcome, ECONOMY):
		return {}
	return {"hub": hub, "outcome": outcome, "settlement": hub.get_pending_settlement()}
