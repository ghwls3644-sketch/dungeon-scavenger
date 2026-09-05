extends Node

const PLAYER_SCENE := preload("res://src/gameplay/player/player.tscn")
const ENTRANCE_EXIT_SCENE := preload("res://src/gameplay/recovery/entrance_exit.tscn")
const HAZARD_SCENE := preload("res://src/gameplay/hazards/unstable_debris_hazard.tscn")
const OUTCOME_PANEL_SCENE := preload("res://src/ui/exploration_outcome_panel.tscn")

var _failures := PackedStringArray()
var _failure_player: PlayerController
var _failure_run: ExplorationRun


func _ready() -> void:
	await _check_safe_return()
	await _check_failure()
	_check_reentrant_completion()

	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"exploration_end_passed")
		get_tree().quit(0)
		return

	for failure in _failures:
		GameLog.error(&"SmokeTest", &"exploration_end_failed", failure)
	get_tree().quit(1)


func _check_safe_return() -> void:
	var player: PlayerController = PLAYER_SCENE.instantiate()
	player.name = "ReturnPlayer"
	player.movement_speed = 0.0
	add_child(player)
	var inventory := player.get_node("Inventory") as PlayerInventory
	inventory.configure_capacity(3, 10.0, 20.0)
	var first_item := _create_test_item(&"test_return_first", "First return item")
	var second_item := _create_test_item(&"test_return_second", "Second return item")
	_expect(inventory.try_add_item(first_item), "First safe-return item was rejected.")
	_expect(inventory.try_add_item(second_item), "Second safe-return item was rejected.")

	var exploration_run := ExplorationRun.new()
	exploration_run.name = "ReturnRun"
	_expect(exploration_run.bind_inventory(inventory), "Safe-return run did not bind its inventory.")
	add_child(exploration_run)

	var entrance_exit: EntranceExit = ENTRANCE_EXIT_SCENE.instantiate()
	entrance_exit.name = "ReturnExit"
	entrance_exit.global_position = player.global_position
	_expect(entrance_exit.bind_exploration_run(exploration_run), "Entrance did not bind the safe-return run.")
	add_child(entrance_exit)

	await get_tree().physics_frame
	await get_tree().physics_frame
	var detector := player.get_node("InteractionDetector") as InteractionDetector
	detector.refresh_current_interactable()
	_expect(detector.get_current_interactable() == entrance_exit, "Player did not detect the entrance as the return point.")
	var controller := player.get_node("InteractionController") as InteractionController
	_expect(controller.interact_current(), "Entrance interaction did not complete safe return.")

	var outcome := exploration_run.get_outcome()
	_expect(exploration_run.get_state() == ExplorationRun.State.SAFE_RETURN, "Safe return did not enter a terminal state.")
	_expect(outcome != null and outcome.is_safe_return(), "Safe return did not create a success outcome.")
	_expect(inventory.get_items().is_empty(), "Returned items remained in the exploration inventory.")
	_expect(outcome.get_recovery_result().get_item_count() == 2, "Safe return did not hand over all carried items.")
	var recovered_ids := outcome.get_recovery_result().get_recovered_items().map(func(item: ItemDefinition): return item.stable_id)
	_expect(recovered_ids.has(first_item.stable_id), "First carried item was missing after safe return.")
	_expect(recovered_ids.has(second_item.stable_id), "Second carried item was missing after safe return.")
	_expect(not exploration_run.complete_failure(), "A completed safe return was overwritten by failure.")
	_expect(not entrance_exit.is_interaction_available(player), "Entrance remained available after exploration ended.")

	var panel: ExplorationOutcomePanel = OUTCOME_PANEL_SCENE.instantiate()
	add_child(panel)
	panel.bind_outcome(outcome)
	_expect(panel.get_title_text() == "생환", "Success outcome UI did not show safe return.")
	_expect(panel.is_recovery_result_visible(), "Success outcome UI hid the recovery result.")
	_expect(panel.get_recovery_summary_text().contains("회수품 2개"), "Success outcome UI did not show recovered items.")

	panel.queue_free()
	entrance_exit.queue_free()
	exploration_run.queue_free()
	player.queue_free()
	await get_tree().process_frame


func _check_failure() -> void:
	_failure_player = PLAYER_SCENE.instantiate()
	_failure_player.name = "FailurePlayer"
	_failure_player.movement_speed = 0.0
	add_child(_failure_player)
	var inventory := _failure_player.get_node("Inventory") as PlayerInventory
	inventory.configure_capacity(3, 10.0, 20.0)
	_expect(
		inventory.try_add_item(_create_test_item(&"test_failure_item", "Failure item")),
		"Failure-path item was rejected."
	)

	_failure_run = ExplorationRun.new()
	_failure_run.name = "FailureRun"
	_expect(_failure_run.bind_inventory(inventory), "Failure run did not bind its inventory.")
	add_child(_failure_run)

	var hazard: UnstableDebrisHazard = HAZARD_SCENE.instantiate()
	hazard.name = "FailureHazard"
	hazard.warning_duration = 0.15
	hazard.global_position = _failure_player.global_position
	hazard.body_caught.connect(_on_failure_body_caught)
	add_child(hazard)

	await get_tree().physics_frame
	await get_tree().physics_frame
	_expect(hazard.get_state() == UnstableDebrisHazard.State.WARNING, "Failure hazard skipped its warning state.")
	_expect(_failure_run.is_active(), "Exploration failed before the hazard warning completed.")
	await get_tree().create_timer(0.2).timeout

	var outcome := _failure_run.get_outcome()
	_expect(_failure_run.get_state() == ExplorationRun.State.FAILURE, "Hazard capture did not enter the failure state.")
	_expect(outcome != null and outcome.is_failure(), "Hazard capture did not create a failure outcome.")
	_expect(inventory.get_items().is_empty(), "Failed exploration kept current-run items.")
	_expect(outcome.get_lost_item_count() == 1, "Failure outcome did not record the lost item count.")
	_expect(outcome.get_recovery_result() == null, "Failed exploration created a recovery result.")
	_expect(not _failure_run.complete_safe_return(), "A completed failure was overwritten by safe return.")

	var panel: ExplorationOutcomePanel = OUTCOME_PANEL_SCENE.instantiate()
	add_child(panel)
	panel.bind_outcome(outcome)
	_expect(panel.get_title_text() == "탐험 실패", "Failure outcome UI did not show failure.")
	_expect(panel.get_summary_text().contains("회수품 1개"), "Failure outcome UI did not show the lost item count.")
	_expect(not panel.is_recovery_result_visible(), "Failure outcome UI exposed a recovery result.")

	panel.queue_free()
	hazard.queue_free()
	_failure_run.queue_free()
	_failure_player.queue_free()
	_failure_run = null
	_failure_player = null
	await get_tree().process_frame


func _check_reentrant_completion() -> void:
	for safe_return in [true, false]:
		var inventory := PlayerInventory.new()
		add_child(inventory)
		inventory.configure_capacity(3, 4.0, 7.0)
		_expect(inventory.try_add_item(_create_test_item(&"test_reentry", "Reentry item")), "Reentry setup could not add an item.")
		var run := ExplorationRun.new()
		run.bind_inventory(inventory)
		add_child(run)
		var replacement_inventory := PlayerInventory.new()
		add_child(replacement_inventory)
		var outcomes: Array[ExplorationOutcome] = []
		run.run_ended.connect(func(outcome: ExplorationOutcome): outcomes.append(outcome))
		var nested_requests: Array[bool] = []
		inventory.inventory_changed.connect(func():
			nested_requests.append(run.complete_safe_return())
			nested_requests.append(run.complete_failure())
			nested_requests.append(run.bind_inventory(replacement_inventory)), CONNECT_ONE_SHOT)
		var completed := run.complete_safe_return() if safe_return else run.complete_failure()
		_expect(completed, "The first completion request was rejected.")
		_expect(nested_requests == [false, false, false], "Completion allowed a reentrant end or inventory rebind.")
		_expect(outcomes.size() == 1, "A single completion emitted multiple terminal outcomes.")
		_expect(run.get_outcome().is_safe_return() == safe_return, "A nested request changed the terminal result.")
		_expect(inventory.get_items().is_empty(), "Completion did not clear the original inventory.")
		if safe_return:
			_expect(run.get_outcome().get_recovery_result().get_item_count() == 1, "Reentrant request lost the safe-return item.")
		else:
			_expect(run.get_outcome().get_lost_item_count() == 1, "Reentrant request changed the loss count.")
		_expect(not run.complete_safe_return() and not run.complete_failure(), "Completed run accepted another terminal request.")
		run.queue_free()
		inventory.queue_free()
		replacement_inventory.queue_free()


func _on_failure_body_caught(body: Node2D) -> void:
	if body == _failure_player and _failure_run != null:
		_failure_run.complete_failure()


func _create_test_item(id: StringName, display_name: String) -> ItemDefinition:
	var item := ItemDefinition.new()
	item.stable_id = id
	item.display_name = display_name
	item.category = ItemDefinition.CATEGORY_SCRAP
	item.weight = 1.0
	item.slot_size = 1
	item.value_min = 10
	item.value_max = 20
	return item


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
