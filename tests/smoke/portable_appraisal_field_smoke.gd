extends "res://tests/smoke/portable_appraisal_flow_smoke.gd"

const PORTABLE_WORLD := preload("res://src/app/prototype_exploration.tscn")


func _ready() -> void:
	_directory = OS.get_environment("TEMP").path_join("dungeon-portable-field-%d-%d" % [OS.get_process_id(), Time.get_ticks_usec()])
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--portable-directory="):
			_directory = argument.trim_prefix("--portable-directory=")
	_render = "--portable-field-render" in OS.get_cmdline_user_args()
	DirAccess.make_dir_recursive_absolute(_directory)
	get_tree().root.size = Vector2i(1152, 648)
	# Prepared boundary cargo is separate from the real pickup/return route in portable_flow.
	for mode in ["safe", "emergency", "failure"]:
		await _field_boundary(mode)
	_write_json(_directory.path_join("portable-field.json"), {"passed": _failures.is_empty(), "prepared_cases": 3, "failures": _failures})
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"portable_appraisal_field_passed", _directory)
	get_tree().quit(0 if _failures.is_empty() else 1)


func _field_boundary(mode: String) -> void:
	var world: PrototypeExploration = PORTABLE_WORLD.instantiate()
	add_child(world)
	await _frames(3)
	var state := HubState.from_save_data(_lure_data(100, 0, 1), CATALOG)
	_expect(state.apply_portable_appraisals(state.quote_portable_appraisals(2)), "Field stock preparation failed.")
	state.select_objective(ExpeditionObjective.RULE.offer(), state.to_save_data())
	var id := state.reserve_departure()
	state.mark_departure_started(id)
	_expect(world.prepare_departure(state.create_departure_loadout(), ExpeditionObjective.RULE.offer()) and world.start_exploration(), "Field boundary start failed.")
	var inventory: PlayerInventory = world.get_node("Player/Inventory")
	var panel: InventoryPanel = world.get_node("%InventoryPanel")
	var tool: PortableAppraisalController = world.get_node("PortableAppraisalController")
	var scrap := CATALOG.find_item(&"test_g1_light").duplicate(true) as ItemDefinition
	scrap.weight = 1.0
	var original := CATALOG.find_item(&"test_g4_artifact").duplicate(true) as ItemDefinition
	original.weight = 1.0
	var first := InventoryItem.from_definition(scrap, false)
	var protected_item := InventoryItem.from_definition(original, false)
	inventory.try_add_inventory_item(first)
	inventory.try_add_inventory_item(protected_item)
	inventory.select_item(0)
	_tap(KEY_TAB)
	await _frames(3)
	_expect(inventory.get_total_weight() == 2.75 and inventory.get_weight_stage() == PlayerInventory.WeightStage.BURDENED, "Combined boundary weight wrong.")
	_click(panel.get_node("%PortableAppraisalButton"))
	await _frames(2)
	panel.close_inventory()
	_expect(tool.get_remaining_uses() == 2, "Closing confirmation consumed a tool.")
	_tap(KEY_TAB)
	await _frames(2)
	await _confirm_field(panel)
	_expect(first.is_identified() and "1/2" in world.get_node("%ObjectiveStatus").text and inventory.get_total_weight() == 2.5, "Scrap appraisal did not update actual quest/mass.")
	inventory.select_item(1)
	if mode == "safe":
		await _confirm_field(panel)
		_expect(protected_item.is_identified() and tool.get_remaining_uses() == 0 and inventory.get_total_weight() == 2.25 and inventory.get_weight_stage() == PlayerInventory.WeightStage.NORMAL, "Appraisal did not cross burden threshold.")
		_expect(world.get_node("Player").get_load_speed_multiplier() == 1.0 and "소음 작음" in world.get_node("%LoadStatus").text, "Movement/noise HUD did not follow combined mass.")
		_expect(inventory.drop_selected_item() == null and inventory.get_quick_drop_item() == null and panel.get_node("%PortableAppraisalButton").disabled and "1/2" in world.get_node("%ObjectiveStatus").text, "Protected/empty tool allowed action or quest credit.")
		await _capture_wear("portable-protected-empty", panel)
	panel.close_inventory()
	var run: ExplorationRun = world.get_node("ExplorationRun")
	if mode == "failure":
		_expect(run.complete_failure(&"test"), "Prepared failure rejected.")
	elif mode == "emergency":
		_expect(run.complete_emergency_return(), "Prepared emergency return rejected.")
	else:
		_expect(run.complete_safe_return(), "Prepared safe return rejected.")
	await _frames(3)
	var outcome := run.get_outcome()
	_expect(tool.request_selected().is_empty() and state.prepare_settlement(id, outcome, ECONOMY) and state.apply_settlement(id), "End-state tool or settlement failed.")
	_expect(state.get_registered_items().is_empty(), "Field appraisal auto-registered originals.")
	if mode == "failure":
		_expect(state.get_stored_items().is_empty() and state.get_paid_appraisals() == 0 and state.get_money() == 80, "Failure preserved run-only appraisal/cargo or charged old money.")
		_expect(not InventoryItem.from_definition(scrap, false).is_identified(), "Later copy inherited failed-run knowledge.")
	else:
		var retained := state.get_stored_items()
		_expect(retained.size() == 1 and retained[0].is_identified() == (mode == "safe") and state.get_money() == 89 and state.get_paid_appraisals() == (0 if mode == "safe" else 1), "Safe/emergency return lost appraisal or unused stock.")
	world.queue_free()
	await _frames(4)


func _confirm_field(panel: InventoryPanel) -> void:
	_click(panel.get_node("%PortableAppraisalButton"))
	await _frames(2)
	panel.get_node("%PortableConfirmation").get_ok_button().grab_focus()
	_tap(KEY_ENTER)
	await _frames(3)
