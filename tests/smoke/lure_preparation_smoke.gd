extends "res://tests/smoke/hub_harness_smoke.gd"

var _lures: HubLurePanel
var _checked_quotes := 0
var _checked_outcomes := 0


func _ready() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	_directory = OS.get_environment("TEMP").path_join("dungeon-lures-%d-%d" % [OS.get_process_id(), Time.get_ticks_usec()])
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--lure-directory="):
			_directory = argument.trim_prefix("--lure-directory=")
	_render = "--lure-render" in OS.get_cmdline_user_args()
	_expect(DirAccess.make_dir_recursive_absolute(_directory) == OK, "Cannot create lure test directory.")
	_path = _directory.path_join("progress.json")
	_store = ProgressStore.new(_path)
	_check_lure_domain()
	_check_lure_storage()
	_check_weight()
	await _check_weight_use()
	var settings := SettingsStore.new(_directory.path_join("settings.cfg"))
	var initial := _lure_data(10, 0, 2)
	initial.harness_durability = 0
	_expect(_store.save_data(initial) == OK and settings.save_settings(GameSettings.new()) == OK, "Cannot seed lure app test.")
	_entry = ENTRY.instantiate()
	_entry.configure_progress(_store)
	_entry.configure_settings(settings)
	add_child(_entry)
	await _frames(5)
	_hub = _entry.get_node("Interface/HubPanel")
	_lures = _hub.get_node("LurePanel")
	_results = _entry.get_node("Interface/Results")
	_hub.lures_requested.emit()
	_expect(not _lures.visible, "Title allowed tool preparation.")
	_click(_entry.get_node("Interface/TitleScreen/%ContinueButton"))
	await _frames(5)
	await _choose_lures(4, true)
	_expect(_store.load_data().paid_lures == 2 and _entry.get_hub_money() == 0, "Two extra lures not purchased atomically.")
	await _choose_lures(3)
	_expect(_store.load_data().paid_lures == 2 and _entry.get_hub_money() == 0, "Reduced choice refunded/deleted stock.")
	_expect(HubRepairTestInput.prepare_departure(_entry) == 0, "Paid preparation blocked free minimum repair.")
	_click(_hub.get_node("%DepartureButton"))
	await _frames(5)
	var world: PrototypeExploration = _entry.get_node("PrototypeExploration")
	var tool: NoiseLureController = world.get_node("%NoiseLureController")
	var inventory: PlayerInventory = world.get_node("Player/Inventory")
	_expect(_store.load_data().pending_departure.phase == "started" and _store.load_data().paid_lures == 1, "Departure journal/left-behind stock incorrect.")
	_expect(tool.get_capacity() == 3 and inventory.get_total_weight() == 0.75 and inventory.get_used_slots() == 0, "Selected supply/mass not applied.")
	var player: PlayerController = world.get_node("Player")
	await _aim_lure(world, player.position)
	_tap(KEY_F)
	await _frames(4)
	_expect(tool.get_remaining_uses() == 3, "Rejected throw consumed prepared stock.")
	await _aim_lure(world, player.position + Vector2(120, -80))
	_tap(KEY_F)
	await _frames(3)
	_expect(tool.get_remaining_uses() == 2 and inventory.get_total_weight() == 0.5, "Actual F did not reduce mass at launch.")
	_tap(KEY_F)
	_tap(KEY_TAB)
	await _frames(25)
	_expect(tool.get_remaining_uses() == 2 and tool.is_in_flight(), "Repeated/menu throw consumed extra stock or advanced flight.")
	_tap(KEY_TAB)
	await _frames(24)
	for remaining in [1, 0]:
		_tap(KEY_F)
		await _frames(24)
		_expect(tool.get_remaining_uses() == remaining and inventory.get_total_weight() == remaining * 0.25, "Prepared paid/free use count/mass mismatch.")
	tool.set_active(false)
	tool.set_active(true)
	_expect(tool.get_remaining_uses() == 0, "Reactivation replenished tools.")
	await _capture_wear("all-used", world.get_node("%ToolStatus"))
	_tap(KEY_E)
	await _frames(5)
	_expect(_entry.get_pending_outcome().get_lure_usage() == {"capacity": 3, "used": 3}, "Outcome lost launch counts.")
	await _settle_lures(1, true)
	await _choose_lures(3)
	await _depart_return_lures(false, 1)
	await _choose_lures(3)
	await _depart_return_lures(true, 0)
	_expect(HubRepairTestInput.prepare_departure(_entry) == 0, "Failure did not retain free repair path.")
	_click(_hub.get_node("%DepartureButton"))
	await _frames(4)
	_expect(_lures.visible and _entry.get_hub_money() == 0 and _store.load_data().paid_lures == 0, "Remembered choice silently repurchased or departed without stock.")
	await _capture_wear("insufficient", _lures.get_node("Center/Card"))
	_tap(KEY_ESCAPE)
	await _frames(3)
	await _choose_lures(2)
	await _depart_return_lures(false, 0)
	await _choose_lures(0)
	await _depart_return_lures(false, 0)
	_write_json(_directory.path_join("lures.json"), {"passed": _failures.is_empty(), "quote_cases": _checked_quotes,
		"outcome_cases": _checked_outcomes, "final_hub": _store.load_data(), "failures": _failures})
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"lure_preparation_passed", _directory)
	get_tree().quit(0 if _failures.is_empty() else 1)


func _lure_data(money: int, stock: int, count: int) -> Dictionary:
	var data := HubState.new().to_save_data()
	data.money = str(money)
	data.costs = ExpeditionCosts.new_book(data.money.to_int())
	data.paid_lures = stock
	data.selected_lures = count
	var prices: Array = []
	for index in stock:
		prices.append("5")
	data.costs = ExpeditionCosts.new_book(money, prices)
	return data


func _check_lure_domain() -> void:
	for money in [0, 4, 5, 9, 10, 9223372036854775807]:
		for stock in range(3):
			for count in range(5):
				var hub := HubState.from_save_data(_lure_data(money, stock, 2), CATALOG)
				var source := hub.to_save_data()
				var quote := hub.quote_lures(count)
				var shortage := maxi(count - 2 - stock, 0)
				_expect(quote.get_cost() == shortage * 5 and quote.can_afford() == (money >= shortage * 5), "Quote matrix price/affordability mismatch.")
				var candidate := hub.copy()
				_expect(candidate.apply_lures(quote) == quote.can_afford(), "Preparation affordability boundary failed.")
				_expect(hub.to_save_data() == source, "Candidate mutated source hub.")
				if quote.can_afford():
					_expect(candidate.get_paid_lures() == stock + shortage and candidate.get_money() == money - shortage * 5, "Purchase amount incorrect.")
					if shortage > 0:
						_expect(not candidate.apply_lures(quote), "Paid quote replayed.")
				var changed := hub.copy()
				changed.select_bag_slots(3)
				_expect(not changed.apply_lures(quote), "Stale quote accepted.")
				_checked_quotes += 1
	var rule := LurePreparation.RULE.duplicate() as LureSupplyRule
	var priced := HubState.from_save_data(_lure_data(10, 0, 2), CATALOG)
	var old_quote := priced.quote_lures(4, rule)
	rule.unit_price = 6
	_expect(not priced.apply_lures(old_quote, rule), "Changed price accepted an old quote.")
	rule.unit_price = 9223372036854775807
	_expect(not rule.is_valid() and priced.quote_lures(4, rule) == null, "Price multiplication overflow accepted.")
	for invalid in [null, true, "2", -1, 5, 1.25, INF, NAN, 9223372036854775807]:
		_expect(HubState.new().quote_lures(invalid) == null, "Invalid count accepted.")
	for count in range(5):
		for used in range(count + 1):
			for ending in ["entrance", "emergency_escape", "failure"]:
				var hub := HubState.from_save_data(_lure_data(0, 2, count), CATALOG)
				var id := hub.reserve_departure()
				_expect(id == 1 and hub.to_save_data().is_empty() and hub.quote_lures(2) == null and not hub.select_bag_slots(3), "Reserved run allowed hub mutation.")
				_expect(hub.mark_departure_started(id) and not hub.mark_departure_started(id), "Start marker duplicated.")
				var outcome := ExplorationOutcome.failure(0) if ending == "failure" else ExplorationOutcome.safe_return_inventory_items([], StringName(ending))
				outcome.record_lure_usage(count, used)
				_expect(hub.prepare_settlement(id, outcome, ECONOMY) and hub.apply_settlement(id), "Prepared outcome rejected.")
				var carried := maxi(count - 2, 0)
				var lost := carried if ending == "failure" else mini(carried, maxi(used - 2, 0))
				_expect(hub.get_paid_lures() == 2 - lost and hub.get_money() == 0 and not hub.apply_settlement(id), "Paid stock duplicated/lost or money charged twice.")
				_checked_outcomes += 1
	for phase in ["reserved", "started"]:
		var hub := HubState.from_save_data(_lure_data(0, 2, 4), CATALOG)
		var id := hub.reserve_departure()
		if phase == "started":
			hub.mark_departure_started(id)
		var resumed := HubState.from_save_data(hub.to_progress_data(), CATALOG)
		_expect(resumed.recover_departure() and not resumed.recover_departure(), "Recovery not exactly once.")
		_expect(resumed.get_paid_lures() == (2 if phase == "reserved" else 0) and resumed.to_save_data().next_expedition_id == "2", "Recovery stock/id incorrect.")


func _check_lure_storage() -> void:
	var path := _directory.path_join("migration.json")
	var store := ProgressStore.new(path)
	for version in range(1, 6):
		var data := _repair_data(10, 1)
		for key in ["paid_lures", "selected_lures", "pending_departure", "costs"]:
			data.erase(key)
		if version < 5:
			data.erase("harness_upgrades")
			data.erase("paid_lures")
			data.erase("selected_lures")
			data.erase("pending_departure")
			data.erase("costs")
		if version < 4:
			data.erase("harness_modules")
		if version < 3:
			data.erase("harness_durability")
		if version < 2:
			data.erase("registered_items")
		_write_json(path, _envelope(version, data))
		var bytes := FileAccess.get_file_as_bytes(path)
		var loaded := store.load_data()
		_expect(HubState.from_save_data(loaded, CATALOG) != null and loaded.paid_lures == 0 and loaded.selected_lures == 2 and loaded.pending_departure.is_empty(), "Legacy supply defaults invalid.")
		_expect(FileAccess.get_file_as_bytes(path) == bytes and store.save_data(loaded) == OK, "Legacy read wrote or migration failed.")
	var reserved := HubState.from_save_data(_lure_data(0, 2, 4), CATALOG)
	reserved.reserve_departure()
	var valid := reserved.to_progress_data()
	for mutation in [{"paid_lures": 1}, {"paid_lures": true}, {"selected_lures": 3}, {"pending_departure": null},
		{"pending_departure": {"id": "1", "phase": "unknown", "free": 2, "paid": 2}},
		{"pending_departure": {"id": "0", "phase": "reserved", "free": 2, "paid": 2}},
		{"pending_departure": {"id": "1", "phase": "reserved", "free": 1.5, "paid": 2}}]:
		var bad := valid.duplicate(true)
		bad.merge(mutation, true)
		_write_json(path, _envelope(ProgressStore.SCHEMA_VERSION, bad))
		var bytes := FileAccess.get_file_as_bytes(path)
		_expect(store.load_data().is_empty() and HubState.from_save_data(bad, CATALOG) == null and store.save_data(_lure_data(0, 0, 2)) != OK and FileAccess.get_file_as_bytes(path) == bytes, "Invalid journal accepted/replaced.")


func _check_weight() -> void:
	var inventory := PlayerInventory.new()
	inventory.configure_capacity(3, 2.5, 4.0)
	for row in [[2.49, 0], [2.5, 1], [2.51, 1], [3.99, 1], [4.0, 2], [4.01, 2]]:
		_expect(inventory.set_external_weight(row[0]) and inventory.get_weight_stage() == row[1] and inventory.get_used_slots() == 0, "External mass threshold incorrect.")
	_expect(not inventory.set_external_weight(-1) and not inventory.set_external_weight(NAN), "Invalid external mass accepted.")
	inventory.free()


func _choose_lures(count: int, retry := false) -> void:
	_click(_hub.get_node("%LureButton"))
	await _frames(3)
	var bytes := FileAccess.get_file_as_bytes(_path)
	_hub.departure_requested.emit()
	_hub.upgrade_requested.emit()
	_hub.bag_slots_selected.emit(3)
	_expect(_lures.visible and FileAccess.get_file_as_bytes(_path) == bytes, "Lure panel allowed another service/departure.")
	var choice: OptionButton = _lures.get_node("%LureChoice")
	choice.grab_focus()
	_tap(KEY_ENTER)
	await _frames(2)
	for step in range(absi(count - choice.selected)):
		_tap(KEY_DOWN if count > choice.selected else KEY_UP)
	_tap(KEY_ENTER)
	await _frames(3)
	_expect(choice.selected == count, "Keyboard supply selection failed.")
	_click(_lures.get_node("%ReviewLure"))
	await _frames(3)
	await _capture_wear("quote-%d" % count, _lures.get_node("Center/Card"))
	if retry:
		_expect(DirAccess.make_dir_absolute(_path + ".tmp") == OK, "Cannot block purchase.")
		for attempt in range(2):
			_click(_lures.get_node("%ConfirmLure"))
			await _frames(3)
			_expect(FileAccess.get_file_as_bytes(_path) == bytes and _entry.get_hub_money() == 10, "Failed purchase mutated money or supply.")
		await _capture_wear("purchase-retry", _lures.get_node("Center/Card"))
		_expect(DirAccess.remove_absolute(_path + ".tmp") == OK, "Cannot unblock purchase.")
	_lures.get_node("%ConfirmLure").grab_focus()
	_tap(KEY_ENTER)
	await _frames(3)
	_lures.confirmation_requested.emit()
	_expect(_store.load_data().selected_lures == count, "Supply confirm did not save count.")
	await _capture_wear("prepared-%d" % count, _lures.get_node("Center/Card"))
	_tap(KEY_ESCAPE)
	await _frames(3)
	_expect(not _lures.visible, "Escape did not close preparation.")


func _aim_lure(world: PrototypeExploration, position: Vector2) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = world.get_global_transform_with_canvas() * position
	get_viewport().push_input(motion, true)
	await _frames(3)


func _settle_lures(stock: int, retry := false) -> void:
	await _capture_wear("lure-results-%d" % stock, _results.get_node("NextStep"))
	var bytes := FileAccess.get_file_as_bytes(_path)
	if retry:
		DirAccess.make_dir_absolute(_path + ".tmp")
		_click(_results.get_node("NextStep/SettleButton"))
		await _frames(3)
		_expect(FileAccess.get_file_as_bytes(_path) == bytes, "Failed settlement returned stock.")
		DirAccess.remove_absolute(_path + ".tmp")
	_click(_results.get_node("NextStep/SettleButton"))
	await _frames(5)
	_results.settlement_requested.emit()
	_expect(_store.load_data().paid_lures == stock and _store.load_data().pending_departure.is_empty(), "Settlement returned stock twice or retained journal.")
	await _capture_wear("hub-stock-%d" % stock, _hub.get_node("Center/Card"))


func _depart_return_lures(failure: bool, stock: int) -> void:
	HubRepairTestInput.prepare_departure(_entry)
	_click(_hub.get_node("%DepartureButton"))
	await _frames(5)
	var world: PrototypeExploration = _entry.get_node("PrototypeExploration")
	_expect(world.get_node("%NoiseLureController").get_capacity() == _store.load_data().selected_lures, "Re-departure supply mismatch.")
	if failure:
		for point in [Vector2(-500, 0), Vector2(-500, 200), Vector2(-170, 200)]:
			await _walk(world.get_node("Player"), point)
		await _frames(100)
	else:
		_tap(KEY_E)
		await _frames(5)
	_expect(_entry.get_pending_outcome() != null and _entry.get_pending_outcome().is_failure() == failure, "Actual lure route failed.")
	await _settle_lures(stock)


func _check_weight_use() -> void:
	# Prepared load boundary, separate from the actual app recovery routes above.
	var world: PrototypeExploration = preload("res://src/app/prototype_exploration.tscn").instantiate()
	add_child(world)
	var loadout := HubState.new().create_departure_loadout()
	_expect(world.prepare_departure(loadout) and world.start_exploration(), "Weight fixture failed to start.")
	var inventory: PlayerInventory = world.get_node("Player/Inventory")
	var item := CATALOG.find_item(&"test_g1_light").duplicate() as ItemDefinition
	item.weight = 2.0
	_expect(inventory.try_add_item(item), "Weight fixture cargo failed.")
	var player: PlayerController = world.get_node("Player")
	var noise: MovementNoiseEmitter = world.get_node("%MovementNoiseEmitter")
	var speed := player.get_movement_speed_multiplier()
	var radius := noise.get_noise_radius()
	_expect(inventory.get_total_weight() == 2.5 and inventory.get_weight_stage() == PlayerInventory.WeightStage.BURDENED, "Cargo plus tools did not enter burden stage.")
	await _aim_lure(world, player.position + Vector2(120, -80))
	_tap(KEY_F)
	await _frames(3)
	_expect(inventory.get_total_weight() == 2.25 and inventory.get_used_slots() == 1 and player.get_movement_speed_multiplier() > speed and noise.get_noise_radius() < radius, "Throw failed to lighten movement/noise or erased cargo.")
	var tool: NoiseLureController = world.get_node("%NoiseLureController")
	tool.notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
	tool.set_active(false)
	tool.set_active(true)
	_expect(tool.get_remaining_uses() == 1 and inventory.get_total_weight() == 2.25, "Focus/reactivation refunded an in-flight lure.")
	world.queue_free()
	await _frames(3)
