extends Node

const PLAYTEST_SCENE := preload("res://tests/fixtures/core_loop_playtest_space.tscn")

var _failures := PackedStringArray()
var _last_rejection_reason: StringName


func _ready() -> void:
	await _check_safe_route()
	await _check_risk_reward_route()
	await _check_unanswered_risk_failure()

	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"core_loop_playtest_passed")
		get_tree().quit(0)
		return

	for failure in _failures:
		GameLog.error(&"SmokeTest", &"core_loop_playtest_failed", failure)
	get_tree().quit(1)


func _check_safe_route() -> void:
	var space: Node2D = PLAYTEST_SCENE.instantiate()
	add_child(space)
	await get_tree().physics_frame

	var player := space.get_node("Player") as PlayerController
	player.movement_speed = 0.0
	var inventory := player.get_node("Inventory") as PlayerInventory
	var exploration_run := space.get_node("ExplorationRun") as ExplorationRun
	var entrance_exit := space.get_node("EntranceExit") as EntranceExit
	var safe_light := space.get_node("SafeLightPickup") as PickupInteractable
	var safe_heavy := space.get_node("SafeHeavyPickup") as PickupInteractable
	var risk_hazard := space.get_node("RiskHazard") as UnstableDebrisHazard
	var risk_reward := space.get_node("RiskRewardPickup") as PickupInteractable

	_expect(safe_light.position.y < 0.0 and safe_heavy.position.y < 0.0, "Safe-route pickups were not placed on the safe branch.")
	_expect(risk_hazard.position.y > 0.0 and risk_reward.position.y > 0.0, "Risk and reward were not placed on the risk branch.")
	_expect(entrance_exit.position.x < safe_light.position.x, "Entrance was not the return point before both branches.")
	_expect(await _interact_at(player, safe_light), "Safe route first pickup was not collected.")
	_expect(await _interact_at(player, safe_heavy), "Safe route second pickup was not collected.")
	_expect(inventory.get_used_slots() == 2, "Safe route did not fill the two test slots.")
	_expect(inventory.get_weight_stage() == PlayerInventory.WeightStage.BURDENED, "Safe route did not expose the test burden stage.")
	_expect(risk_hazard.get_state() == UnstableDebrisHazard.State.IDLE, "Safe route activated the risk hazard.")
	_expect(await _interact_at(player, entrance_exit), "Safe route did not return through the entrance.")

	var outcome := exploration_run.get_outcome()
	_expect(outcome != null and outcome.is_safe_return(), "Safe route did not end in safe return.")
	_expect(outcome.get_recovery_result().get_item_count() == 2, "Safe route did not recover both carried items.")
	_expect(outcome.get_recovery_result().get_total_value_min() == 40, "Safe route minimum value total was incorrect.")
	_expect(outcome.get_recovery_result().get_total_value_max() == 60, "Safe route maximum value total was incorrect.")

	space.queue_free()
	await get_tree().process_frame


func _check_risk_reward_route() -> void:
	_last_rejection_reason = &""
	var space: Node2D = PLAYTEST_SCENE.instantiate()
	add_child(space)
	await get_tree().physics_frame

	var player := space.get_node("Player") as PlayerController
	player.movement_speed = 0.0
	var inventory := player.get_node("Inventory") as PlayerInventory
	inventory.item_add_rejected.connect(_on_item_add_rejected)
	var harness := player.get_node("HarnessController") as HarnessController
	var hazard_detector := player.get_node("HazardDetector") as HazardDetector
	var exploration_run := space.get_node("ExplorationRun") as ExplorationRun
	var entrance_exit := space.get_node("EntranceExit") as EntranceExit
	var safe_light := space.get_node("SafeLightPickup") as PickupInteractable
	var safe_light_item := safe_light.item_definition
	var safe_heavy := space.get_node("SafeHeavyPickup") as PickupInteractable
	var safe_heavy_item := safe_heavy.item_definition
	var risk_hazard := space.get_node("RiskHazard") as UnstableDebrisHazard
	var risk_reward := space.get_node("RiskRewardPickup") as PickupInteractable
	var risk_reward_item := risk_reward.item_definition

	_expect(await _interact_at(player, safe_light), "Risk route setup did not collect the first safe item.")
	_expect(await _interact_at(player, safe_heavy), "Risk route setup did not collect the second safe item.")
	player.global_position = risk_hazard.global_position
	for _frame in range(6):
		await get_tree().physics_frame
		if risk_hazard.get_state() != UnstableDebrisHazard.State.IDLE:
			break
	hazard_detector.refresh_current_hazard()
	_expect(risk_hazard.get_state() == UnstableDebrisHazard.State.WARNING, "Risk route did not expose a warning before the reward.")
	_expect(hazard_detector.get_current_hazard() == risk_hazard, "Harness did not detect the risk-route hazard.")
	_expect(harness.use_current_harness_action(), "Risk route hazard was not stabilized with the harness.")
	_expect(risk_hazard.get_state() == UnstableDebrisHazard.State.STABILIZED, "Risk route remained dangerous after stabilization.")
	_expect(harness.get_current_charge() == 0, "Risk route did not spend the single test charge.")

	_expect(not await _interact_at(player, risk_reward), "Full inventory accepted the risk reward without a load choice.")
	_expect(_last_rejection_reason == PlayerInventory.REJECT_SLOT_LIMIT, "Risk reward rejection did not report the slot limit.")
	_expect(inventory.select_item(0), "Could not select the low-value item for the load choice.")
	_expect(inventory.drop_selected_item() == safe_light_item, "Load choice dropped the wrong safe-route item.")
	_expect(await _interact_at(player, risk_reward), "Risk reward was not collected after freeing a slot.")
	_expect(inventory.get_items().has(safe_heavy_item), "Risk route lost the retained safe item.")
	_expect(inventory.get_items().has(risk_reward_item), "Risk route did not hold the high-value reward.")
	_expect(inventory.get_weight_stage() == PlayerInventory.WeightStage.OVERLOADED, "Risk reward did not expose the test overload stage.")
	_expect(await _interact_at(player, entrance_exit), "Risk-reward route did not return through the entrance.")

	var outcome := exploration_run.get_outcome()
	var result := outcome.get_recovery_result()
	_expect(outcome != null and outcome.is_safe_return(), "Risk-reward route did not end in safe return.")
	_expect(result.get_item_count() == 2, "Risk-reward route recovered the wrong item count.")
	_expect(not result.get_recovered_items().has(safe_light_item), "Dropped low-value item appeared in the result.")
	_expect(result.get_recovered_items().has(safe_heavy_item), "Retained safe item was missing from the result.")
	_expect(result.get_recovered_items().has(risk_reward_item), "High-value risk reward was missing from the result.")
	_expect(result.get_total_value_min() == 130, "Risk-reward minimum value total was incorrect.")
	_expect(result.get_total_value_max() == 180, "Risk-reward maximum value total was incorrect.")

	space.queue_free()
	await get_tree().process_frame


func _check_unanswered_risk_failure() -> void:
	var space: Node2D = PLAYTEST_SCENE.instantiate()
	add_child(space)
	await get_tree().physics_frame

	var player := space.get_node("Player") as PlayerController
	player.movement_speed = 0.0
	var inventory := player.get_node("Inventory") as PlayerInventory
	var exploration_run := space.get_node("ExplorationRun") as ExplorationRun
	var safe_light := space.get_node("SafeLightPickup") as PickupInteractable
	var risk_hazard := space.get_node("RiskHazard") as UnstableDebrisHazard
	risk_hazard.warning_duration = 0.1

	_expect(await _interact_at(player, safe_light), "Failure route did not collect a current-run item.")
	player.global_position = risk_hazard.global_position
	for _frame in range(6):
		await get_tree().physics_frame
		if risk_hazard.get_state() != UnstableDebrisHazard.State.IDLE:
			break
	_expect(risk_hazard.get_state() == UnstableDebrisHazard.State.WARNING, "Failure route skipped the risk warning.")
	await get_tree().create_timer(0.15).timeout

	var outcome := exploration_run.get_outcome()
	_expect(risk_hazard.get_state() == UnstableDebrisHazard.State.TRIGGERED, "Unanswered risk did not trigger.")
	_expect(outcome != null and outcome.is_failure(), "Unanswered risk did not end the exploration in failure.")
	_expect(outcome.get_lost_item_count() == 1, "Failure did not record the carried item loss.")
	_expect(inventory.get_items().is_empty(), "Failure kept a current-run item in the inventory.")
	_expect(outcome.get_recovery_result() == null, "Failure produced a recovery result.")

	space.queue_free()
	await get_tree().process_frame


func _interact_at(player: PlayerController, target: Interactable) -> bool:
	player.global_position = target.global_position
	await get_tree().physics_frame
	await get_tree().physics_frame
	var detector := player.get_node("InteractionDetector") as InteractionDetector
	detector.refresh_current_interactable()
	_expect(detector.get_current_interactable() == target, "Interaction detector selected the wrong playtest target.")
	var controller := player.get_node("InteractionController") as InteractionController
	var interaction_succeeded := controller.interact_current()
	await get_tree().process_frame
	return interaction_succeeded


func _on_item_add_rejected(_item: ItemDefinition, reason: StringName) -> void:
	_last_rejection_reason = reason


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
