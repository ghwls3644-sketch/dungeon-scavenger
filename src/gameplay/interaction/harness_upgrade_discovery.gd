class_name HarnessUpgradeDiscovery
extends Interactable

@export var upgrade_id: String = HarnessUpgradeRule.EMERGENCY
var _run: ExplorationRun
var _player: Node
var _found := false
var _configured := false


func configure(run: ExplorationRun, player: Node, owned: Array[String]) -> bool:
	if _configured or run == null or player == null or upgrade_id not in HarnessUpgradeRule.ALL \
			or not HarnessUpgradeRule.is_valid_owned(owned):
		return false
	_configured = true
	_run = run
	_player = player
	if upgrade_id in owned:
		set_interaction_enabled(false)
		hide()
		set_deferred("collision_layer", 0)
	return true


func get_interaction_action() -> Action:
	return Action.INSPECT


func get_interaction_prompt() -> String:
	return "%s 조사 · 안전 귀환 후 무료 획득" % HarnessUpgradeRule.label(upgrade_id)


func is_interaction_available(interactor: Node = null) -> bool:
	return super.is_interaction_available(interactor) and _configured and not _found \
		and _run.is_active() and can_process() and not get_tree().paused \
		and (interactor == null or interactor == _player)


func _perform_interaction(_interactor: Node) -> bool:
	if not _run.record_harness_discovery(upgrade_id):
		return false
	_found = true
	set_interaction_enabled(false)
	$Label.text = "개선 발견 · 안전 귀환 필요"
	return true
