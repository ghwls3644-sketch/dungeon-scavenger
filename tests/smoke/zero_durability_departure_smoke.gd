extends "res://tests/smoke/equipment_wear_smoke.gd"

const BOUNDARY := preload("res://tests/fixtures/lure_boundary_store.gd")
const SERVICES := ["appraisal_requested", "sale_requested", "registration_requested",
	"repair_requested", "harness_requested", "upgrade_requested", "lures_requested", "portable_requested"]

var _warning: HubDeparturePanel
var _cash := 0
var _durability := 0
var _events: Array[Dictionary] = []
var _resume := false
var _legacy := false


func _ready() -> void:
	get_tree().root.size = Vector2i(1152, 648)
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--zero-directory="):
			_directory = argument.trim_prefix("--zero-directory=")
		if argument.begins_with("--zero-cash="):
			_cash = argument.trim_prefix("--zero-cash=").to_int()
		if argument.begins_with("--zero-durability="):
			_durability = argument.trim_prefix("--zero-durability=").to_int()
	_resume = "--zero-resume" in OS.get_cmdline_user_args()
	_legacy = "--zero-legacy" in OS.get_cmdline_user_args()
	_render = "--zero-render" in OS.get_cmdline_user_args()
	if _directory.is_empty():
		_directory = OS.get_environment("TEMP").path_join("dungeon-zero-%d-%d" % [OS.get_process_id(), Time.get_ticks_usec()])
	_expect(DirAccess.make_dir_recursive_absolute(_directory) == OK, "Cannot create isolated directory.")
	_path = _directory.path_join("progress.json")
	_store = BOUNDARY.new(_path)
	var settings := SettingsStore.new(_directory.path_join("settings.cfg"))
	if not _resume:
		var data := _initial_data()
		data.money = str(_cash)
		data.harness_durability = _durability
		data.paid_lures = 2
		data.selected_lures = 4
		data.paid_appraisals = 2
		data.selected_appraisals = 2
		data.costs = ExpeditionCosts.new_book(_cash, ["5", "5"], false, ["8", "10"])
		_expect(not _store.has_file(), "Fixture must not overwrite an existing save.")
		if _legacy:
			_write_json(_path, _envelope(9, data))
		else:
			_expect(ProgressStore.new(_path).save_data(data) == OK, "Cannot seed fixture.")
		_expect(settings.save_settings(GameSettings.new()) == OK, "Cannot seed settings.")
	var settings_bytes := FileAccess.get_file_as_bytes(_directory.path_join("settings.cfg"))
	var original := FileAccess.get_file_as_bytes(_path)
	_entry = ENTRY.instantiate()
	_entry.configure_progress(_store)
	_entry.configure_settings(settings)
	add_child(_entry)
	await _frames(5)
	_hub = _entry.get_node("Interface/HubPanel")
	_warning = _hub.get_node("DeparturePanel")
	_results = _entry.get_node("Interface/Results")
	_hub.departure_requested.emit()
	_warning.confirmation_requested.emit(0)
	_expect(not _warning.visible and _store.calls == 0, "Title accepted departure.")
	_click(_entry.get_node("Interface/TitleScreen/%ContinueButton"))
	await _frames(5)
	_expect(GameState.get_current_state() == GameState.State.HUB and FileAccess.get_file_as_bytes(_path) == original, "Continue rewrote the existing save.")
	_cash = _entry.get_hub_money()
	_durability = _entry.get_hub_harness_durability()
	if _durability == 0:
		await _check_warning()
		if not _resume:
			await _check_save_retries()
		await _depart_zero(true)
		await _finish_run(false)
		await _depart_zero(false)
		await _finish_run(true)
		if not _resume:
			# Failure consumed selected paid tools; preparation still applies after confirmation.
			await _check_missing_tools()
		await _depart_zero(false)
		await _finish_run(false)
		if not _resume:
			await _check_optional_repair()
	else:
		await _depart_zero(false)
		await _finish_run(false)
	_expect(FileAccess.get_file_as_bytes(_directory.path_join("settings.cfg")) == settings_bytes, "Departure changed settings.")
	_release()
	_write_json(_directory.path_join("zero-%s.json" % ("resume" if _resume else "write")), {
		"passed": _failures.is_empty(), "initial_cash": _cash, "initial_durability": _durability,
		"legacy": _legacy, "resume": _resume, "events": _events, "final_hub": _store.load_data(), "failures": _failures,
	})
	if _failures.is_empty():
		GameLog.info(&"SmokeTest", &"zero_durability_departure_passed")
	get_tree().quit(0 if _failures.is_empty() else 1)


func _open_warning() -> int:
	var bytes := FileAccess.get_file_as_bytes(_path)
	var before := _entry._hub_state.to_save_data()
	var calls: int = _store.calls
	_click(_hub.get_node("%DepartureButton"))
	await _frames(3)
	_expect(_warning.visible and not _hub.get_node("RepairPanel").visible and not _hub.get_node("Center").visible, "Zero departure did not open its warning.")
	_expect(_warning.get_node("%ReturnToHub").has_focus(), "Default warning action is not return.")
	_expect("내구가 0" in _warning.get_node("%DepartureWarning").text, "Warning omitted zero durability.")
	_expect(FileAccess.get_file_as_bytes(_path) == bytes and _entry._hub_state.to_save_data() == before and _store.calls == calls, "Opening warning mutated progress.")
	return _entry._departure_request_id


func _check_warning() -> void:
	await _capture_wear("hub-zero", _hub.get_node("Center/Card"))
	var original := FileAccess.get_file_as_bytes(_path)
	var state := _entry._hub_state.to_save_data()
	var id := await _open_warning()
	await _capture_wear("warning-zero", _warning.get_node("Center/Card"))
	for service in SERVICES:
		_hub.emit_signal(service)
	_hub.bag_slots_selected.emit(2)
	_hub.objective_selected.emit(ExpeditionObjective.RULE.offer(), state)
	_hub.departure_requested.emit()
	_hub.quit_requested.emit()
	_expect(_entry._hub_state.to_save_data() == state and _warning.visible, "Warning allowed competing service or selection.")
	for name in ["AppraisalPanel", "SalePanel", "RegistrationPanel", "RepairPanel", "HarnessPanel", "UpgradePanel", "LurePanel", "PortablePanel"]:
		_expect(not _hub.get_node(name).visible, "Warning allowed " + name)
	get_tree().paused = true
	_warning.confirmation_requested.emit(id)
	_warning.close_requested.emit(id)
	_expect(_warning.visible and _entry.get_node_or_null("PrototypeExploration") == null, "Paused warning accepted commands.")
	get_tree().paused = false
	_tap(KEY_ENTER)
	await _frames(3)
	_expect(not _warning.visible and _hub.get_node("%DepartureButton").has_focus(), "Default Enter failed to return.")
	var next := await _open_warning()
	_warning.confirmation_requested.emit(id)
	_warning.close_requested.emit(id)
	_expect(_warning.visible and _entry._departure_request_id == next, "Old warning token affected a later request.")
	_tap(KEY_TAB)
	await _frames(2)
	_expect(_warning.get_node("%ProceedDeparture").has_focus(), "Tab escaped the warning.")
	_tap(KEY_ESCAPE)
	await _frames(3)
	_expect(not _warning.visible, "Esc failed to return even with proceed focused.")
	await _open_warning()
	_click(_warning.get_node("%ReturnToHub"))
	await _frames(3)
	_expect(not _warning.visible and FileAccess.get_file_as_bytes(_path) == original and _entry._hub_state.to_save_data() == state, "Cancel changed holdings or save.")
	id = await _open_warning()
	_expect(_entry._hub_state.select_bag_slots(2), "Cannot simulate stale preparation.")
	_warning.confirmation_requested.emit(id)
	await _frames(3)
	_expect(not _warning.visible and "준비 상태가 바뀌었습니다" in _hub.get_node("%HubStatus").text and FileAccess.get_file_as_bytes(_path) == original, "Stale preparation was allowed to depart.")
	_expect(_entry._hub_state.select_bag_slots(3), "Cannot restore fixture preparation.")
	_entry._on_state_changed(GameState.State.HUB, GameState.State.HUB)
	await _frames(3)
	id = await _open_warning()
	_entry._on_state_changed(GameState.State.HUB, GameState.State.HUB)
	_warning.confirmation_requested.emit(id)
	_expect(not _warning.visible and _entry.get_node_or_null("PrototypeExploration") == null, "State reset retained an old confirmation.")
	# A service already open also rejects departure and obsolete confirmations.
	for service in SERVICES:
		_hub.emit_signal(service)
		_hub.departure_requested.emit()
		_warning.confirmation_requested.emit(id)
		_expect(not _warning.visible and _entry.get_node_or_null("PrototypeExploration") == null, "Departure interrupted an existing service.")
		_entry._on_state_changed(GameState.State.HUB, GameState.State.HUB)
	_expect(FileAccess.get_file_as_bytes(_path) == original, "Rejected commands wrote progress.")
	_events.append({"kind": "warning_cancel_stale_guards", "save_unchanged": true})


func _check_save_retries() -> void:
	var original := FileAccess.get_file_as_bytes(_path)
	_store.failures.assign([_store.calls + 1])
	var id := await _open_warning()
	_click(_warning.get_node("%ProceedDeparture"))
	await _frames(5)
	_expect(GameState.get_current_state() == GameState.State.HUB and _entry.get_node_or_null("PrototypeExploration") == null and FileAccess.get_file_as_bytes(_path) == original, "Failed reservation changed progress or started simulation.")
	_warning.confirmation_requested.emit(id)
	_expect(FileAccess.get_file_as_bytes(_path) == original, "Old confirmation retried a failed reservation.")
	_store.failures.assign([_store.calls + 2, _store.calls + 3])
	await _open_warning()
	_click(_warning.get_node("%ProceedDeparture"))
	await _frames(7)
	_expect(GameState.get_current_state() == GameState.State.HUB and _entry.get_node_or_null("PrototypeExploration") == null and _store.load_data().pending_departure.get("phase") == "reserved", "Start/recovery failures lost reservation.")
	var reserved := FileAccess.get_file_as_bytes(_path)
	for service in SERVICES:
		_hub.emit_signal(service)
	_hub.bag_slots_selected.emit(2)
	_expect(FileAccess.get_file_as_bytes(_path) == reserved, "Recovery allowed mutations.")
	_click(_hub.get_node("%DepartureButton"))
	await _frames(4)
	var recovered := _store.load_data()
	_expect(recovered.pending_departure.is_empty() and recovered.harness_durability == 0 and recovered.paid_lures == 2 and recovered.paid_appraisals == (0 if _legacy else 2), "Recovery lost or duplicated tools/durability.")
	_expect(not _warning.visible, "Recovery retry also started a new departure request.")
	_events.append({"kind": "reservation_start_recovery_retry", "recovered_next_id": recovered.next_expedition_id})


func _depart_zero(keyboard: bool) -> void:
	var before := _store.load_data()
	var id := 0
	if _entry.get_hub_harness_durability() == 0:
		id = await _open_warning()
		if keyboard:
			_tap(KEY_TAB)
			await _frames(2)
			_tap(KEY_ENTER)
		else:
			_click(_warning.get_node("%ProceedDeparture"))
		_warning.confirmation_requested.emit(id)
	else:
		_click(_hub.get_node("%DepartureButton"))
	await _frames(6)
	var world := _entry.get_node_or_null("PrototypeExploration") as PrototypeExploration
	_expect(world != null and GameState.get_current_state() == GameState.State.EXPLORATION and not _warning.visible, "Confirmed departure did not start.")
	if world == null:
		_finish_early()
		return
	_warning.confirmation_requested.emit(id)
	_hub.departure_requested.emit()
	var saved := _store.load_data()
	_expect(saved.next_expedition_id.to_int() == before.next_expedition_id.to_int() + 1 and saved.pending_departure.phase == "started", "Duplicate departure or missing journal.")
	_expect(saved.money == before.money and saved.harness_durability == before.harness_durability and saved.costs.period.repair_paid == before.costs.period.repair_paid, "Departure repaired or charged money.")
	_expect(saved.paid_lures == 0 and saved.paid_appraisals == 0, "Paid tools not reserved once.")
	_expect(world.get_node("Player/HarnessController").get_current_charge() == 3 and world.get_node("PlayerSurvival").get_health() == 2 and world.get_node("Player/Inventory").slot_capacity == 3, "Zero durability added ability/resource penalties.")
	_events.append({"kind": "departure", "durability": saved.harness_durability, "id": saved.pending_departure.id, "keyboard": keyboard})


func _finish_run(failed: bool) -> void:
	var world := _entry.get_node_or_null("PrototypeExploration") as PrototypeExploration
	if world == null:
		return
	if failed:
		for point in [Vector2(-500, 0), Vector2(-500, 200), Vector2(-170, 200)]:
			await _walk(world.get_node("Player"), point)
		await _frames(100)
	else:
		_tap(KEY_E)
		await _frames(5)
	_expect(GameState.get_current_state() == GameState.State.RESULTS and _entry.get_pending_outcome() != null and _entry.get_pending_outcome().is_failure() == failed, "Actual return/failure missing.")
	_warning.confirmation_requested.emit(_entry._departure_request_id)
	_hub.departure_requested.emit()
	var money := _entry.get_hub_money()
	var before := _entry.get_hub_harness_durability()
	var after := maxi(0, before - 2) if failed else before
	var bytes := FileAccess.get_file_as_bytes(_path)
	_store.failures.assign([_store.calls + 1])
	_click(_results.get_node("NextStep/SettleButton"))
	await _frames(3)
	_expect(GameState.get_current_state() == GameState.State.RESULTS and FileAccess.get_file_as_bytes(_path) == bytes, "Failed settlement changed saved state.")
	_click(_results.get_node("NextStep/SettleButton"))
	await _frames(5)
	_results.settlement_requested.emit()
	_expect(GameState.get_current_state() == GameState.State.HUB and _entry.get_hub_harness_durability() == after and _entry.get_hub_money() == money, "Settlement changed balance/damage or failed to return.")
	var saved := _store.load_data()
	_expect(saved.harness_durability == after and saved.pending_departure.is_empty(), "Settlement left a pending departure.")
	_events.append({"kind": "failure" if failed else "safe_return", "before": before, "after": after, "money": money})


func _check_missing_tools() -> void:
	await _open_warning()
	_click(_warning.get_node("%ProceedDeparture"))
	await _frames(3)
	var portable: HubPortableAppraisalPanel = _hub.get_node("PortablePanel")
	var lures: HubLurePanel = _hub.get_node("LurePanel")
	if not _legacy:
		_expect(portable.visible and not _warning.visible and GameState.get_current_state() == GameState.State.HUB, "Zero confirmation bypassed missing appraisal tools.")
		portable.review_requested.emit(0)
		portable.confirmation_requested.emit()
		portable.close_requested.emit()
		await _frames(3)
		await _open_warning()
		_click(_warning.get_node("%ProceedDeparture"))
		await _frames(3)
	_expect(lures.visible and not _warning.visible, "Zero confirmation bypassed missing lures.")
	lures.review_requested.emit(2)
	lures.confirmation_requested.emit()
	lures.close_requested.emit()
	await _frames(3)
	_events.append({"kind": "missing_tools_rechecked"})


func _check_optional_repair() -> void:
	_hub.repair_requested.emit()
	var panel: HubRepairPanel = _hub.get_node("RepairPanel")
	_expect(panel.visible and "수리 없이도 출정 가능" in panel.get_node("%RepairSummary").text, "Repair still claimed to be required.")
	panel.review_requested.emit(1, _cash < 5)
	panel.confirmation_requested.emit()
	panel.close_requested.emit()
	await _frames(3)
	_expect(_entry.get_hub_harness_durability() == 1 and _entry.get_hub_money() == _cash - (0 if _cash < 5 else 5), "Optional repair/support boundary changed.")
	await _depart_zero(false)
	await _finish_run(false)
	# Leave zero durability via actual failures, for the fresh-process continue check.
	await _depart_zero(false)
	await _finish_run(true)
	_expect(_entry.get_hub_harness_durability() == 0, "Could not prepare continuation at zero.")


func _finish_early() -> void:
	_release()
	get_tree().quit(1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		GameLog.error(&"SmokeTest", &"zero_durability_departure_failed", message)
