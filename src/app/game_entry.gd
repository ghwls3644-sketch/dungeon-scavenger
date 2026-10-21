class_name GameEntry
extends Node

const DEV_SCENE := preload("res://src/app/dev_main.tscn")
const EXPLORATION_SCENE := preload("res://src/app/prototype_exploration.tscn")
const PROTOTYPE_ECONOMY := preload("res://src/data/prototype_economy.tres")
const ITEM_CATALOG := preload("res://src/data/prototype_item_catalog.tres")
const HARNESS_UPGRADES := preload("res://src/data/prototype_harness_upgrades.tres")
const RESEARCH_CATALOG := preload("res://src/data/prototype_research_catalog.tres")

var _has_saved_game := Callable()
var _restore_saved_game := Callable()
var _starting := false
var _departing := false
var _departure_warning_open := false
var _departure_request_id := 0
var _departure_source: Dictionary = {}
var _hub_state := HubState.new()
var _exploration: PrototypeExploration
var _pending_outcome: ExplorationOutcome
var _expedition_id := 0
var _settling := false
var _settings_store := SettingsStore.new()
var _settings_notice := ""
var _progress_store := ProgressStore.new()
var _continue_overridden := false
var _awaiting_new_game_confirmation := false
var _appraisal_open := false
var _appraising := false
var _appraisal_quote: AppraisalQuote
var _sale_open := false
var _selling := false
var _sale_quote: SaleQuote
var _registration_open := false
var _registering := false
var _registration_quote: RegistrationQuote
var _repair_open := false
var _repairing := false
var _repair_quote: RepairQuote
var _harness_open := false
var _equipping := false
var _harness_source: Dictionary = {}
var _harness_selection: Array = []
var _progress_notice := ""
var _upgrade_open := false
var _upgrading := false
var _upgrade_quote: HarnessUpgradeQuote
var _lures_open := false
var _preparing_lures := false
var _lure_quote: LurePreparationQuote
var _recovery_required := false
var _portable_open := false
var _preparing_portable := false
var _portable_quote: AppraisalPreparationQuote

@onready var _portable: HubPortableAppraisalPanel = $Interface/HubPanel/PortablePanel

@onready var _lures: HubLurePanel = $Interface/HubPanel/LurePanel
@onready var _title: TitleScreen = $Interface/TitleScreen
@onready var _hub: HubPanel = $Interface/HubPanel
@onready var _results: ExpeditionResultsScreen = $Interface/Results
@onready var _appraisal: HubAppraisalPanel = $Interface/HubPanel/AppraisalPanel
@onready var _sale: HubSalePanel = $Interface/HubPanel/SalePanel
@onready var _registration: HubRegistrationPanel = $Interface/HubPanel/RegistrationPanel
@onready var _harness_panel: HubHarnessPanel = $Interface/HubPanel/HarnessPanel
@onready var _upgrade: HubUpgradePanel = $Interface/HubPanel/UpgradePanel
@onready var _repair: HubRepairPanel = $Interface/HubPanel/RepairPanel
@onready var _departure_warning: HubDeparturePanel = $Interface/HubPanel/DeparturePanel


func _ready() -> void:
	if OS.is_debug_build():
		for argument in OS.get_cmdline_user_args():
			if argument.begins_with("--dev-state="):
				get_tree().change_scene_to_packed.call_deferred(DEV_SCENE)
				return
	_initialize_settings()
	if not _continue_overridden:
		_has_saved_game = _has_progress
		_restore_saved_game = _restore_progress
	_title.new_game_requested.connect(_on_new_game_requested)
	_title.new_game_confirmed.connect(_on_new_game_confirmed)
	_title.new_game_cancelled.connect(func(): _awaiting_new_game_confirmation = false)
	_title.continue_requested.connect(_on_continue_requested)
	_title.quit_requested.connect(_on_quit_requested)
	_hub.configure_bag_choices(_hub_state.get_available_bag_slots())
	_hub.bag_slots_selected.connect(_on_bag_slots_selected)
	_hub.objective_selected.connect(_on_objective_selected)
	_hub.departure_requested.connect(_on_departure_requested)
	_departure_warning.confirmation_requested.connect(_on_departure_confirmed)
	_departure_warning.close_requested.connect(_on_departure_warning_closed)
	_hub.quit_requested.connect(_on_quit_requested)
	_hub.appraisal_requested.connect(_on_appraisal_requested)
	_appraisal.review_requested.connect(_on_appraisal_review_requested)
	_appraisal.confirmation_requested.connect(_on_appraisal_confirmed)
	_appraisal.selection_requested.connect(_on_appraisal_selection_requested)
	_appraisal.close_requested.connect(_on_appraisal_closed)
	_hub.sale_requested.connect(_on_sale_requested)
	_sale.review_requested.connect(_on_sale_review_requested)
	_sale.confirmation_requested.connect(_on_sale_confirmed)
	_sale.selection_requested.connect(_on_sale_selection_requested)
	_sale.close_requested.connect(_on_sale_closed)
	_hub.registration_requested.connect(_on_registration_requested)
	_registration.review_requested.connect(_on_registration_review_requested)
	_registration.confirmation_requested.connect(_on_registration_confirmed)
	_registration.selection_requested.connect(_on_registration_selection_requested)
	_registration.close_requested.connect(_on_registration_closed)
	_hub.repair_requested.connect(_on_repair_requested)
	_repair.review_requested.connect(_on_repair_review_requested)
	_repair.confirmation_requested.connect(_on_repair_confirmed)
	_repair.selection_requested.connect(_on_repair_selection_requested)
	_repair.close_requested.connect(_on_repair_closed)
	_hub.harness_requested.connect(_on_harness_requested)
	_harness_panel.review_requested.connect(_on_harness_review_requested)
	_harness_panel.confirmation_requested.connect(_on_harness_confirmed)
	_harness_panel.selection_requested.connect(_on_harness_selection_requested)
	_harness_panel.close_requested.connect(_on_harness_closed)
	_hub.upgrade_requested.connect(_on_upgrade_requested)
	_upgrade.review_requested.connect(_on_upgrade_review_requested)
	_upgrade.confirmation_requested.connect(_on_upgrade_confirmed)
	_upgrade.selection_requested.connect(_on_upgrade_selection_requested)
	_upgrade.close_requested.connect(_on_upgrade_closed)
	_hub.lures_requested.connect(_on_lures_requested)
	_lures.review_requested.connect(_on_lures_review_requested)
	_lures.confirmation_requested.connect(_on_lures_confirmed)
	_lures.selection_requested.connect(_on_lures_selection_requested)
	_lures.close_requested.connect(_on_lures_closed)
	_hub.portable_requested.connect(_on_portable_requested)
	_portable.review_requested.connect(_on_portable_review_requested)
	_portable.confirmation_requested.connect(_on_portable_confirmed)
	_portable.selection_requested.connect(_on_portable_selection_requested)
	_portable.close_requested.connect(_on_portable_closed)
	_results.settlement_requested.connect(_on_settlement_requested)
	_results.quit_requested.connect(_on_quit_requested)
	GameState.state_changed.connect(_on_state_changed)
	_boot.call_deferred()


func configure_settings(store: SettingsStore) -> void:
	if not is_node_ready() and store != null:
		_settings_store = store


func configure_progress(store: ProgressStore) -> void:
	if not is_node_ready() and store != null:
		_progress_store = store


func _has_progress() -> bool:
	return HubState.from_save_data(_progress_store.load_data(), ITEM_CATALOG) != null


func _restore_progress() -> bool:
	var restored := HubState.from_save_data(_progress_store.load_data(), ITEM_CATALOG)
	if restored == null:
		return false
	var interrupted := restored.to_progress_data().pending_departure as Dictionary
	if restored.has_pending_departure():
		if not restored.recover_departure() or not _save_hub(restored):
			return false
	_hub_state = restored
	_recovery_required = false
	_progress_notice = "이전 기록: 안정화·비상 방전 장착.\n하네스 장착에서 세 기능 중 둘을 고르세요." if _progress_store.has_legacy_modules() else ""
	if not interrupted.is_empty():
		_progress_notice = "출정 시작 전 기록을 복구했습니다. 예약했던 추가분을 돌려받았습니다." if interrupted.phase == "reserved" else "미정산 출정 기록을 정리했습니다. 가져갔던 추가분은 반환되지 않습니다."
	return true


func _save_hub(candidate: HubState, replace_existing: bool = false) -> bool:
	var data := candidate.to_progress_data()
	if HubState.from_save_data(data, ITEM_CATALOG) == null:
		return false
	var error := _progress_store.save_data(data, replace_existing)
	if error != OK and not data.visit_seed.is_empty():
		GameLog.info(&"GameEntry", &"visit_save_failed", JSON.stringify({"error": error, "visit": data.visit_seed}))
	return error == OK


func _initialize_settings() -> void:
	var error := _settings_store.load_settings()
	if error == ERR_UNAVAILABLE:
		_settings_notice = "다른 버전의 설정입니다. 기본값으로 실행하며 기존 파일은 유지합니다."
	elif error != OK:
		_settings_notice = "설정을 읽지 못해 기본값으로 실행했습니다. 적용하면 다시 저장합니다."
	SettingsRuntime.apply(_settings_store.get_settings(), get_window())
	_title.configure_settings(_settings_store.get_settings(), _settings_notice, _settings_store.is_writable())
	_title.settings_requested.connect(_on_settings_requested)


func _on_settings_requested(settings: GameSettings) -> void:
	if _starting or GameState.get_current_state() != GameState.State.TITLE or not _title.is_options_open():
		return
	if _settings_store.save_settings(settings) != OK:
		_title.set_options_status("설정을 저장하지 못했습니다. 기존 설정을 유지합니다.")
		return
	SettingsRuntime.apply(_settings_store.get_settings(), get_window())
	_settings_notice = ""
	_title.configure_settings(_settings_store.get_settings())
	_title.set_options_status("설정을 적용하고 저장했습니다.")


func configure_continue(has_saved_game: Callable, restore_saved_game: Callable) -> void:
	_continue_overridden = true
	_has_saved_game = has_saved_game
	_restore_saved_game = restore_saved_game
	if is_node_ready():
		refresh_continue()


func refresh_continue() -> void:
	var available := _can_continue()
	_title.set_menu_state(available, _starting)
	if not _continue_overridden and not available and _progress_store.has_file():
		_title.set_status("진행 기록을 읽지 못했습니다. 기존 파일은 유지됩니다.")


func _boot() -> void:
	if GameState.get_current_state() == GameState.State.BOOT:
		GameState.request_transition(GameState.State.TITLE)
	else:
		_on_state_changed(GameState.get_current_state(), GameState.get_current_state())


func _can_continue() -> bool:
	return _has_saved_game.is_valid() and _restore_saved_game.is_valid() and _has_saved_game.call() == true


func _can_start() -> bool:
	return not _starting and not GameState.is_transition_in_progress() \
		and GameState.get_current_state() == GameState.State.TITLE \
		and not _title.is_options_open() and not _title.is_new_game_confirmation_open()


func _on_new_game_requested() -> void:
	if not _can_start():
		return
	if _progress_store.has_file():
		_awaiting_new_game_confirmation = true
		_title.confirm_new_game()
		return
	_start_new_game(false)


func _on_new_game_confirmed() -> void:
	if not _awaiting_new_game_confirmation:
		return
	_awaiting_new_game_confirmation = false
	_start_new_game(true)


func _start_new_game(replace_existing: bool) -> void:
	if not _can_start():
		return
	_starting = true
	_title.set_menu_state(false, true)
	var fresh := HubState.new()
	if not _save_hub(fresh, replace_existing):
		_restore_title("새 게임을 저장하지 못했습니다. 기존 기록을 유지합니다. 다시 시도해 주세요.")
		return
	_hub_state = fresh
	_progress_notice = ""
	_enter_hub()


func _on_continue_requested() -> void:
	if not _can_start():
		return
	_starting = true
	_title.set_menu_state(false, true)
	if not _can_continue():
		_restore_title("이어할 기록이 없습니다.")
		return
	if _restore_saved_game.call() != true:
		_restore_title("기록을 불러오지 못했습니다. 다시 시도해 주세요.")
		return
	_enter_hub()


func _enter_hub() -> void:
	if not GameState.request_transition(GameState.State.HUB):
		_restore_title("게임을 시작하지 못했습니다. 다시 시도해 주세요.")


func _restore_title(message: String) -> void:
	_starting = false
	refresh_continue()
	_title.set_status(message)
	_title.focus_start()


func _on_state_changed(_previous_state: int, current_state: int) -> void:
	_starting = false
	_departure_warning_open = false
	_departure_source.clear()
	_departure_warning.hide()
	_portable_open = false
	_portable_quote = null
	_portable.hide()
	_lures_open = false
	_lure_quote = null
	_lures.hide()
	_upgrade_open = false
	_upgrade_quote = null
	_upgrade.hide()
	_harness_open = false
	_harness_source.clear()
	_harness_selection.clear()
	_harness_panel.hide()
	_appraisal_open = false
	_appraisal_quote = null
	_appraisal.hide()
	_sale_open = false
	_sale_quote = null
	_sale.hide()
	_registration_open = false
	_registration_quote = null
	_registration.hide()
	_repair_open = false
	_repair_quote = null
	_repair.hide()
	_hub.get_node("Center").show()
	_hub.visible = current_state == GameState.State.HUB
	_results.visible = current_state == GameState.State.RESULTS
	if current_state == GameState.State.TITLE:
		refresh_continue()
		_title.present()
	else:
		_title.dismiss()
	if _hub.visible:
		if _settling:
			_pending_outcome = null
			_expedition_id = 0
			_settling = false
		_hub.render_preparation(_hub_state.create_departure_loadout(), _departing)
		_hub.render_objective(_hub_state)
		_hub.render_holdings(_hub_state.get_money(), _hub_state.get_stored_items(), _hub_state.get_preparation_costs(), _hub_state.get_last_costs())
		_hub.render_objective(_hub_state)
		_render_equipment()
		_hub.present()
		_hub.set_status(_progress_notice if not _progress_notice.is_empty() else "진행이 저장되어 있습니다.")
		if _recovery_required:
			_render_recovery_status()
	if current_state == GameState.State.EXPLORATION and _exploration != null:
		var candidate := _hub_state.copy()
		if not _exploration.initialize_exploration() or not candidate.mark_departure_started(_expedition_id) or not _save_hub(candidate):
			_cancel_departure()
			GameState.return_from_failed_departure()
			return
		_hub_state = candidate
		GameLog.info(&"GameEntry", &"visit_started", JSON.stringify(_hub_state.get_visit_seed()))
		_exploration.start_exploration()
		_departing = false
	if _results.visible:
		_discard_exploration()
		_results.set_busy(false)
		_results.present_result(_pending_outcome, _hub_state.get_pending_settlement())


func get_departure_preview() -> ExpeditionLoadout:
	return _hub_state.create_departure_loadout()


func get_pending_outcome() -> ExplorationOutcome:
	return _pending_outcome


func get_hub_money() -> int:
	return _hub_state.get_money()


func get_hub_harness_durability() -> int:
	return _hub_state.get_harness_durability()


func get_hub_stored_items() -> Array[InventoryItem]:
	return _hub_state.get_stored_items()


func get_hub_registered_items() -> Array[InventoryItem]:
	return _hub_state.get_registered_items()


func _on_bag_slots_selected(slots: int) -> void:
	if _departure_warning_open:
		return
	if _portable_open or _preparing_portable or _lures_open or _preparing_lures or _recovery_required or _repair_open or _repairing or _harness_open or _equipping or _upgrade_open or _upgrading:
		return
	if GameState.get_current_state() != GameState.State.HUB or _departing or _appraisal_open or _appraising or _sale_open or _selling or _registration_open or _registering:
		return
	var candidate := _hub_state.copy()
	if not candidate.select_bag_slots(slots):
		return
	var saved := _save_hub(candidate)
	if saved:
		_hub_state = candidate
	_hub.render_preparation(_hub_state.create_departure_loadout(), false)
	_hub.render_objective(_hub_state)
	_hub.set_status("준비 상태를 저장했습니다." if saved else "저장하지 못해 이전 준비 상태를 유지합니다. 다시 선택해 주세요.")


func _on_departure_requested() -> void:
	if _departure_warning_open or GameState.get_current_state() != GameState.State.HUB \
			or GameState.is_transition_in_progress() or get_tree().paused:
		return
	if _recovery_required:
		_retry_departure_recovery()
		return
	_try_departure()


func _can_departure() -> bool:
	if _portable_open or _preparing_portable or _lures_open or _preparing_lures or _recovery_required or _repair_open or _repairing or _harness_open or _equipping or _upgrade_open or _upgrading:
		return false
	if _departing or _appraisal_open or _appraising or _sale_open or _selling or _registration_open or _registering or GameState.get_current_state() != GameState.State.HUB or get_tree().paused:
		return false
	return not GameState.is_transition_in_progress() and not _settling \
		and _exploration == null and _pending_outcome == null


func _on_departure_confirmed(request_id: int) -> void:
	if not _departure_warning_open or request_id != _departure_request_id or not _can_departure():
		return
	var unchanged := not _departure_source.is_empty() and _departure_source == _hub_state.to_save_data()
	_close_departure_warning()
	if not unchanged:
		_hub.render_preparation(_hub_state.create_departure_loadout(), false)
		_hub.render_holdings(_hub_state.get_money(), _hub_state.get_stored_items(), _hub_state.get_preparation_costs(), _hub_state.get_last_costs())
		_hub.render_objective(_hub_state)
		_render_equipment()
		_hub.set_status("준비 상태가 바뀌었습니다. 확인한 뒤 다시 출정해 주세요.")
		return
	_try_departure(true)


func _on_departure_warning_closed(request_id: int) -> void:
	if not _departure_warning_open or request_id != _departure_request_id or not _can_departure():
		return
	_close_departure_warning()


func _close_departure_warning() -> void:
	_departure_warning_open = false
	_departure_source.clear()
	_departure_warning.hide()
	_hub.get_node("Center").show()
	_hub.get_node("%DepartureButton").grab_focus()


func _try_departure(confirmed_zero_durability: bool = false) -> void:
	if _departure_warning_open or not _can_departure():
		return
	if not _hub_state.can_depart(PROTOTYPE_ECONOMY):
		_hub.set_status("장비 상태를 확인하지 못했습니다. 출정하지 않았습니다.")
		return
	if _hub_state.get_harness_durability() == 0 and not confirmed_zero_durability:
		_departure_source = _hub_state.to_save_data()
		if _departure_source.is_empty():
			return
		_departure_request_id += 1
		_departure_warning_open = true
		_hub.get_node("Center").hide()
		_departure_warning.present(_departure_request_id)
		return
	if not _hub_state.has_prepared_appraisals():
		_on_portable_requested()
		_portable.set_status("선택한 감정 도구가 부족합니다. 구매 비용을 다시 확인하거나 0개로 바꾸세요.")
		return
	if not _hub_state.has_prepared_lures():
		_on_lures_requested()
		_lures.set_status("이전 출정의 추가분이 부족합니다. 비용을 확인하거나 무료 2개로 바꾸세요.")
		return
	_departing = true
	var loadout := _hub_state.create_departure_loadout()
	_hub.render_preparation(loadout, true)
	_hub.render_objective(_hub_state)
	_exploration = _create_exploration()
	if _exploration == null:
		_cancel_departure()
		return
	_exploration.exclude_secured_originals(_hub_state.get_excluded_original_ids())
	add_child(_exploration)
	if not _exploration.prepare_departure(loadout, _hub_state.get_objective_offer()):
		_cancel_departure()
		return
	var candidate := _hub_state.copy()
	var reserved_id := candidate.reserve_departure()
	if reserved_id == 0 or not _save_hub(candidate):
		_cancel_departure()
		return
	_hub_state = candidate
	_expedition_id = reserved_id
	GameLog.info(&"GameEntry", &"visit_reserved", JSON.stringify(_hub_state.get_visit_seed()))
	_exploration.exploration_ended.connect(_on_exploration_ended.bind(_expedition_id))
	if not GameState.request_transition(GameState.State.EXPLORATION):
		_cancel_departure()


func _create_exploration() -> PrototypeExploration:
	return EXPLORATION_SCENE.instantiate() as PrototypeExploration


func _cancel_departure() -> void:
	_discard_exploration()
	if _hub_state.has_pending_departure():
		_recovery_required = true
		_retry_departure_recovery()
	_expedition_id = 0
	_departing = false
	_hub.render_preparation(_hub_state.create_departure_loadout(), false)
	_hub.render_objective(_hub_state)
	_render_recovery_status()


func _discard_exploration() -> void:
	if _exploration != null:
		_exploration.queue_free()
		_exploration = null


func _on_exploration_ended(outcome: ExplorationOutcome, expedition_id: int) -> void:
	if GameState.get_current_state() != GameState.State.EXPLORATION or _pending_outcome != null or expedition_id != _expedition_id:
		return
	_pending_outcome = outcome
	_hub_state.prepare_settlement(expedition_id, outcome, PROTOTYPE_ECONOMY)
	GameState.request_transition(GameState.State.RESULTS)


func _on_settlement_requested() -> void:
	if _settling or GameState.get_current_state() != GameState.State.RESULTS or GameState.is_transition_in_progress():
		return
	if _pending_outcome == null or get_tree().paused:
		return
	var pending := _hub_state.get_pending_settlement()
	if pending == null or not pending.matches_current_rule():
		var refreshed := _hub_state.prepare_settlement(_expedition_id, _pending_outcome, PROTOTYPE_ECONOMY, true)
		_results.present_result(_pending_outcome, _hub_state.get_pending_settlement() if refreshed else null)
		_results.set_status("판매 가격이나 회수세가 바뀌었습니다. 새 금액을 확인한 뒤 다시 정산해 주세요." if refreshed else "정산 금액을 확인할 수 없습니다. 물품과 보유금은 그대로입니다.")
		return
	_settling = true
	_results.set_busy(true)
	var candidate := _hub_state.copy()
	if not candidate.apply_settlement(_expedition_id) or not _save_hub(candidate):
		_settling = false
		_results.set_busy(false)
		_results.set_status("정산을 저장하지 못했습니다. 다시 눌러 저장해 주세요. 종료하면 이번 정산은 반영되지 않습니다.")
		return
	_hub_state = candidate
	GameState.request_transition(GameState.State.HUB)


func _on_quit_requested() -> void:
	if _departure_warning_open:
		return
	if _preparing_lures or _appraising or _selling or _registering or _repairing or _equipping or _upgrading:
		return
	GameLog.info(&"GameEntry", &"quit_requested")
	get_tree().quit()


func _can_appraise() -> bool:
	if _departure_warning_open:
		return false
	if _portable_open or _preparing_portable or _lures_open or _preparing_lures or _recovery_required or _repair_open or _repairing or _harness_open or _equipping or _upgrade_open or _upgrading:
		return false
	return GameState.get_current_state() == GameState.State.HUB and not GameState.is_transition_in_progress() \
		and not _departing and not _settling and not _appraising and not _sale_open and not _selling and not _registration_open and not _registering and not get_tree().paused


func _on_appraisal_requested() -> void:
	if not _can_appraise() or _appraisal_open:
		return
	_appraisal_open = true
	_appraisal_quote = null
	_hub.get_node("Center").hide()
	_appraisal.present(_hub_state.get_money(), _hub_state.get_stored_items(), PROTOTYPE_ECONOMY.appraisal_fee_per_item)


func _on_appraisal_review_requested(indices: PackedInt32Array) -> void:
	if not _can_appraise() or not _appraisal_open or _appraisal_quote != null:
		return
	_appraisal_quote = _hub_state.quote_appraisal(indices, PROTOTYPE_ECONOMY)
	_appraisal.set_review(_appraisal_quote)
	if _appraisal_quote == null:
		_appraisal.set_status("감정할 미확인 물품을 선택해 주세요.")


func _on_appraisal_selection_requested() -> void:
	if not _can_appraise() or not _appraisal_open:
		return
	_appraisal_quote = null
	_appraisal.set_review(null)
	_appraisal.get_node("%AppraisalItems").grab_focus()


func _on_appraisal_confirmed() -> void:
	if not _can_appraise() or not _appraisal_open or _appraisal_quote == null:
		return
	_appraising = true
	var candidate := _hub_state.copy()
	if not candidate.apply_appraisal(_appraisal_quote, PROTOTYPE_ECONOMY):
		_appraising = false
		_appraisal.set_status("감정 대상 또는 보유금을 확인해 주세요. 비용은 지불되지 않았습니다.")
		return
	if not _save_hub(candidate):
		_appraising = false
		_appraisal.set_status("저장 실패 · 비용 %d와 감정 상태는 반영되지 않았습니다.\n다시 확정해 저장하거나 선택으로 돌아가 취소할 수 있습니다." % _appraisal_quote.get_cost())
		return
	var count := _appraisal_quote.get_count()
	var cost := _appraisal_quote.get_cost()
	_hub_state = candidate
	_appraisal_quote = null
	_appraising = false
	_hub.render_holdings(_hub_state.get_money(), _hub_state.get_stored_items(), _hub_state.get_preparation_costs(), _hub_state.get_last_costs())
	_hub.render_objective(_hub_state)
	_appraisal.present(_hub_state.get_money(), _hub_state.get_stored_items(), PROTOTYPE_ECONOMY.appraisal_fee_per_item)
	_appraisal.set_status("%d개 감정 완료 · 비용 %d 지불 · 보유금 %d\n결과를 저장했습니다. 감정한 물품은 거점에 보관됩니다." % [count, cost, _hub_state.get_money()])


func _on_appraisal_closed() -> void:
	if not _can_appraise() or not _appraisal_open:
		return
	_appraisal_open = false
	_appraisal_quote = null
	_appraisal.hide()
	_hub.get_node("Center").show()
	_hub.get_node("%AppraisalButton").grab_focus()


func _can_sell() -> bool:
	if _departure_warning_open:
		return false
	if _portable_open or _preparing_portable or _lures_open or _preparing_lures or _recovery_required:
		return false
	if _portable_open or _preparing_portable or _lures_open or _preparing_lures or _recovery_required or _repair_open or _repairing or _harness_open or _equipping or _upgrade_open or _upgrading:
		return false
	return GameState.get_current_state() == GameState.State.HUB and not GameState.is_transition_in_progress() \
		and not _departing and not _settling and not _appraising and not _appraisal_open and not _selling and not _registration_open and not _registering and not get_tree().paused


func _on_sale_requested() -> void:
	if not _can_sell() or _sale_open:
		return
	_sale_open = true
	_sale_quote = null
	_hub.get_node("Center").hide()
	_sale.present(_hub_state.get_money(), _hub_state.get_sale_offers(PROTOTYPE_ECONOMY))


func _on_sale_review_requested(indices: PackedInt32Array) -> void:
	if not _can_sell() or not _sale_open or _sale_quote != null:
		return
	_sale_quote = _hub_state.quote_sale(indices, PROTOTYPE_ECONOMY)
	_sale.set_review(_sale_quote)
	if _sale_quote == null:
		_sale.set_status("판매 대상과 보유금 한도를 확인해 주세요. 물품과 돈은 그대로 유지됩니다.")


func _on_sale_selection_requested() -> void:
	if not _can_sell() or not _sale_open:
		return
	_sale_quote = null
	_sale.set_review(null)
	_sale.get_node("%SaleItems").grab_focus()


func _on_sale_confirmed() -> void:
	if not _can_sell() or not _sale_open or _sale_quote == null:
		return
	_selling = true
	var candidate := _hub_state.copy()
	if not candidate.apply_sale(_sale_quote, PROTOTYPE_ECONOMY):
		_selling = false
		_sale.set_status("판매 대상이나 가격·회수세가 바뀌었습니다. 선택으로 돌아가 다시 확인해 주세요.")
		return
	if not _save_hub(candidate):
		_selling = false
		_sale.set_status("저장 실패 · 물품과 보유금은 그대로 유지됩니다.\n다시 판매를 확정하거나 선택으로 돌아가 취소할 수 있습니다.")
		return
	var count := _sale_quote.get_count()
	var income := _sale_quote.get_net_income()
	_hub_state = candidate
	_sale_quote = null
	_selling = false
	_hub.render_holdings(_hub_state.get_money(), _hub_state.get_stored_items(), _hub_state.get_preparation_costs(), _hub_state.get_last_costs())
	_hub.render_objective(_hub_state)
	_sale.present(_hub_state.get_money(), _hub_state.get_sale_offers(PROTOTYPE_ECONOMY))
	_sale.set_status("%d개 판매 완료 · 실제 입금 +%d · 보유금 %d\n판매한 물품을 보관함에서 제거하고 결과를 저장했습니다." % [count, income, _hub_state.get_money()])


func _on_sale_closed() -> void:
	if not _can_sell() or not _sale_open:
		return
	_sale_open = false
	_sale_quote = null
	_sale.hide()
	_hub.get_node("Center").show()
	_hub.get_node("%SaleButton").grab_focus()


func _can_register() -> bool:
	if _departure_warning_open:
		return false
	if _portable_open or _preparing_portable or _lures_open or _preparing_lures or _recovery_required:
		return false
	if _portable_open or _preparing_portable or _lures_open or _preparing_lures or _recovery_required or _repair_open or _repairing or _harness_open or _equipping or _upgrade_open or _upgrading:
		return false
	return GameState.get_current_state() == GameState.State.HUB and not GameState.is_transition_in_progress() \
		and not _departing and not _settling and not _appraising and not _appraisal_open \
		and not _selling and not _sale_open and not _registering and not get_tree().paused


func _present_registration() -> void:
	var items := _hub_state.get_stored_items()
	var reasons := PackedStringArray()
	for index in items.size():
		reasons.append(_hub_state.get_registration_reason(index))
	var registered := _hub_state.get_registered_items()
	_registration.present(items, reasons, registered, ResearchProgress.get_entries(registered, RESEARCH_CATALOG, ITEM_CATALOG))


func _on_registration_requested() -> void:
	if not _can_register() or _registration_open:
		return
	_registration_open = true
	_registration_quote = null
	_hub.get_node("Center").hide()
	_present_registration()


func _on_registration_review_requested(index: int) -> void:
	if not _can_register() or not _registration_open or _registration_quote != null:
		return
	_registration_quote = _hub_state.quote_registration(index)
	_registration.set_review(_registration_quote)
	if _registration_quote == null:
		_registration.set_status("등록할 수 있는 원본을 선택해 주세요.")


func _on_registration_selection_requested() -> void:
	if not _can_register() or not _registration_open:
		return
	_registration_quote = null
	_registration.set_review(null)
	_registration.get_node("%RegistrationItems").grab_focus()


func _on_registration_confirmed() -> void:
	if not _can_register() or not _registration_open or _registration_quote == null:
		return
	_registering = true
	var candidate := _hub_state.copy()
	if not candidate.apply_registration(_registration_quote):
		_registering = false
		_registration.set_status("보관 상태가 바뀌었습니다. 선택으로 돌아가 다시 확인하세요.")
		return
	if not _save_hub(candidate):
		_registering = false
		_registration.set_status("저장 실패 · 원본과 등록 목록을 그대로 유지합니다.\n다시 확정하거나 선택으로 돌아가 취소할 수 있습니다.")
		return
	_hub_state = candidate
	_registration_quote = null
	_registering = false
	_hub.render_holdings(_hub_state.get_money(), _hub_state.get_stored_items(), _hub_state.get_preparation_costs(), _hub_state.get_last_costs())
	_hub.render_objective(_hub_state)
	_present_registration()
	_registration.set_status("원본 등록과 저장을 마쳤습니다. 등록 목록에서 설명을 다시 읽을 수 있습니다.")


func _on_registration_closed() -> void:
	if not _can_register() or not _registration_open:
		return
	_registration_open = false
	_registration_quote = null
	_registration.hide()
	_hub.get_node("Center").show()
	_hub.get_node("%RegistrationButton").grab_focus()


func _render_equipment() -> void:
	_hub.render_equipment(_hub_state.get_harness_durability(), _hub_state.get_harness_max_durability())


func _can_repair() -> bool:
	if _departure_warning_open:
		return false
	if _portable_open or _preparing_portable or _lures_open or _preparing_lures or _recovery_required:
		return false
	if _harness_open or _equipping or _upgrade_open or _upgrading:
		return false
	return GameState.get_current_state() == GameState.State.HUB and not GameState.is_transition_in_progress() \
		and not get_tree().paused and not _departing and not _settling and not _repairing \
		and not _appraisal_open and not _appraising and not _sale_open and not _selling \
		and not _registration_open and not _registering


func _present_repair() -> void:
	_repair.present(_hub_state.get_harness_durability(), _hub_state.get_harness_max_durability(),
		_hub_state.get_money(), PROTOTYPE_ECONOMY.minimum_recovery_durability, _hub_state.get_repair_offers(PROTOTYPE_ECONOMY))


func _on_repair_requested() -> void:
	if not _can_repair() or _repair_open:
		return
	_repair_open = true
	_repair_quote = null
	_hub.get_node("Center").hide()
	_present_repair()


func _on_repair_review_requested(amount: int, supported: bool) -> void:
	if not _can_repair() or not _repair_open or _repair_quote != null:
		return
	_repair_quote = _hub_state.quote_repair(amount, PROTOTYPE_ECONOMY, supported)
	_repair.set_review(_repair_quote)
	if _repair_quote == null:
		_repair.set_status("복구량과 지원 조건을 확인해 주세요. 비용은 지불하지 않았습니다.")


func _on_repair_selection_requested() -> void:
	if not _can_repair() or not _repair_open:
		return
	_repair_quote = null
	_repair.set_review(null)
	_repair.get_node("%RepairChoice").grab_focus()


func _on_repair_confirmed() -> void:
	if not _can_repair() or not _repair_open or _repair_quote == null:
		return
	_repairing = true
	var candidate := _hub_state.copy()
	if not candidate.apply_repair(_repair_quote, PROTOTYPE_ECONOMY):
		_repairing = false
		_repair.set_status("수리 조건이나 보유금을 확인해 주세요. 내구와 돈은 그대로입니다.")
		return
	if not _save_hub(candidate):
		_repairing = false
		_repair.set_status("저장 실패 · 내구와 보유금은 그대로 유지합니다.\n다시 확정하거나 선택으로 돌아가 취소할 수 있습니다.")
		return
	var cost := _repair_quote.get_cost()
	var supported := _repair_quote.is_supported()
	_hub_state = candidate
	_repair_quote = null
	_repairing = false
	_hub.render_holdings(_hub_state.get_money(), _hub_state.get_stored_items(), _hub_state.get_preparation_costs(), _hub_state.get_last_costs())
	_hub.render_objective(_hub_state)
	_render_equipment()
	_present_repair()
	_repair.set_status("%s 완료 · 이번 지불액 %d · 보유금 %d\n복구 결과를 저장했습니다." % [
		"최소 복구 지원" if supported else "수리", cost, _hub_state.get_money()])


func _on_repair_closed() -> void:
	if not _can_repair() or not _repair_open:
		return
	_repair_open = false
	_repair_quote = null
	_repair.hide()
	_hub.get_node("Center").show()
	_hub.get_node("%RepairButton").grab_focus()


func _can_equip() -> bool:
	if _departure_warning_open:
		return false
	if _portable_open or _preparing_portable or _lures_open or _preparing_lures or _recovery_required:
		return false
	if _upgrade_open or _upgrading:
		return false
	return GameState.get_current_state() == GameState.State.HUB and not GameState.is_transition_in_progress() \
		and not get_tree().paused and not _departing and not _settling and not _equipping \
		and not _appraisal_open and not _appraising and not _sale_open and not _selling \
		and not _registration_open and not _registering and not _repair_open and not _repairing


func _on_harness_requested() -> void:
	if not _can_equip() or _harness_open:
		return
	_harness_open = true
	_harness_source = _hub_state.to_save_data()
	_harness_selection.clear()
	_hub.get_node("Center").hide()
	_harness_panel.present(_hub_state.create_departure_loadout().harness_modules)


func _on_harness_review_requested(modules: Array) -> void:
	if not _can_equip() or not _harness_open or not _harness_selection.is_empty():
		return
	if not _hub_state.copy().select_harness_modules(modules, _harness_source):
		_harness_panel.set_status("현재 구성과 다른 두 기능을 선택하세요.")
		return
	_harness_selection = modules.duplicate()
	_harness_panel.set_review(_harness_selection)


func _on_harness_selection_requested() -> void:
	if not _can_equip() or not _harness_open:
		return
	_harness_source = _hub_state.to_save_data()
	_harness_selection.clear()
	_harness_panel.present(_hub_state.create_departure_loadout().harness_modules)


func _on_harness_confirmed() -> void:
	if not _can_equip() or not _harness_open or _harness_selection.is_empty():
		return
	_equipping = true
	var candidate := _hub_state.copy()
	if not candidate.select_harness_modules(_harness_selection, _harness_source):
		_equipping = false
		_harness_panel.set_status("준비 상태가 바뀌었습니다. 선택으로 돌아가 다시 확인하세요.")
		return
	if not _save_hub(candidate):
		_equipping = false
		_harness_panel.set_status("저장 실패 · 기존 장착과 보유 상태를 유지합니다.\n다시 확정하거나 선택으로 돌아가 취소할 수 있습니다.")
		return
	_hub_state = candidate
	_equipping = false
	_progress_notice = ""
	_harness_source = _hub_state.to_save_data()
	_harness_selection.clear()
	_hub.render_preparation(_hub_state.create_departure_loadout(), false)
	_hub.render_objective(_hub_state)
	_render_equipment()
	_harness_panel.present(_hub_state.create_departure_loadout().harness_modules)
	_harness_panel.set_status("장착 구성을 저장했습니다. 다음 출정부터 적용합니다. 지불액 0.")


func _on_harness_closed() -> void:
	if not _can_equip() or not _harness_open:
		return
	_harness_open = false
	_harness_source.clear()
	_harness_selection.clear()
	_harness_panel.hide()
	_hub.get_node("Center").show()
	_hub.get_node("%HarnessButton").grab_focus()


func _can_upgrade() -> bool:
	if _departure_warning_open:
		return false
	if _portable_open or _preparing_portable or _lures_open or _preparing_lures or _recovery_required:
		return false
	return GameState.get_current_state() == GameState.State.HUB and not GameState.is_transition_in_progress() \
		and not get_tree().paused and not _departing and not _settling and not _upgrading \
		and not _appraisal_open and not _appraising and not _sale_open and not _selling \
		and not _registration_open and not _registering and not _repair_open and not _repairing \
		and not _harness_open and not _equipping


func _present_upgrade() -> void:
	_upgrade.present(_hub_state.get_money(), _hub_state.create_departure_loadout(), HARNESS_UPGRADES)


func _on_upgrade_requested() -> void:
	if not _can_upgrade() or _upgrade_open:
		return
	_upgrade_open = true
	_upgrade_quote = null
	_hub.get_node("Center").hide()
	_present_upgrade()


func _on_upgrade_review_requested(id: String) -> void:
	if not _can_upgrade() or not _upgrade_open or _upgrade_quote != null:
		return
	_upgrade_quote = _hub_state.quote_harness_upgrade(id, HARNESS_UPGRADES)
	_upgrade.set_review(_upgrade_quote)
	if _upgrade_quote == null:
		_upgrade.set_status("보유 상태와 개선 종류를 확인해 주세요. 비용은 지불하지 않았습니다.")


func _on_upgrade_selection_requested() -> void:
	if not _can_upgrade() or not _upgrade_open:
		return
	_upgrade_quote = null
	_present_upgrade()


func _on_upgrade_confirmed() -> void:
	if not _can_upgrade() or not _upgrade_open or _upgrade_quote == null:
		return
	_upgrading = true
	var candidate := _hub_state.copy()
	if not candidate.apply_harness_upgrade(_upgrade_quote, HARNESS_UPGRADES):
		_upgrading = false
		_upgrade_quote = null
		_present_upgrade()
		_upgrade.set_status("가격·보유 상태·잔액이 달라졌습니다. 새 구매 내용을 확인하세요. 돈과 보유 개선은 그대로입니다.")
		return
	if not _save_hub(candidate):
		_upgrading = false
		_upgrade.set_status("저장 실패 · 돈과 보유 개선은 그대로입니다.\n다시 확정하거나 선택으로 돌아가 취소할 수 있습니다.")
		return
	var cost := _upgrade_quote.get_cost()
	var id := _upgrade_quote.get_id()
	_hub_state = candidate
	_upgrade_quote = null
	_upgrading = false
	_hub.render_holdings(_hub_state.get_money(), _hub_state.get_stored_items(), _hub_state.get_preparation_costs(), _hub_state.get_last_costs())
	_hub.render_preparation(_hub_state.create_departure_loadout(), false)
	_hub.render_objective(_hub_state)
	_present_upgrade()
	_upgrade.set_status("%s 보유 · 이번 지불액 %d · 보유금 %d\n관련 기능을 장착하면 다음 출정부터 적용됩니다." % [HarnessUpgradeRule.label(id), cost, _hub_state.get_money()])


func _on_upgrade_closed() -> void:
	if not _can_upgrade() or not _upgrade_open:
		return
	_upgrade_open = false
	_upgrade_quote = null
	_upgrade.hide()
	_hub.get_node("Center").show()
	_hub.get_node("%UpgradeButton").grab_focus()


func _retry_departure_recovery() -> void:
	var candidate := _hub_state.copy()
	if candidate.recover_departure() and _save_hub(candidate):
		_hub_state = candidate
		_recovery_required = false
		_progress_notice = "출정 시작 전 오류를 복구했습니다. 추가분은 보존되었습니다. 다시 출정할 수 있습니다."
	_render_recovery_status()


func _render_recovery_status() -> void:
	_hub.render_preparation(_hub_state.create_departure_loadout(), _recovery_required)
	_hub.render_objective(_hub_state)
	_render_equipment()
	if _recovery_required:
		_hub.get_node("%DepartureButton").disabled = false
		_hub.get_node("%DepartureButton").text = "출정 준비 복구 · 다시 저장"
		_hub.get_node("%HubQuitButton").disabled = false
		_hub.set_status("복구 저장 실패 · 다른 준비는 잠겼습니다. 다시 저장하거나 종료 후 이어하기로 복구하세요.")
	else:
		_hub.set_status(_progress_notice if not _progress_notice.is_empty() else "출정 준비를 저장하지 못했습니다. 다시 시도해 주세요.")


func _can_prepare_lures() -> bool:
	if _departure_warning_open:
		return false
	return GameState.get_current_state() == GameState.State.HUB and not GameState.is_transition_in_progress() \
		and not get_tree().paused and not _departing and not _settling and not _preparing_lures and not _portable_open and not _preparing_portable and not _recovery_required \
		and not _appraisal_open and not _appraising and not _sale_open and not _selling \
		and not _registration_open and not _registering and not _repair_open and not _repairing \
		and not _harness_open and not _equipping and not _upgrade_open and not _upgrading


func _on_lures_requested() -> void:
	if not _can_prepare_lures() or _lures_open:
		return
	_lures_open = true
	_lure_quote = null
	_hub.get_node("Center").hide()
	_lures.present(_hub_state)


func _on_lures_review_requested(count: int) -> void:
	if not _can_prepare_lures() or not _lures_open or _lure_quote != null:
		return
	_lure_quote = _hub_state.quote_lures(count)
	_lures.set_review(_lure_quote)


func _on_lures_selection_requested() -> void:
	if not _can_prepare_lures() or not _lures_open:
		return
	_lure_quote = null
	_lures.present(_hub_state)


func _on_lures_confirmed() -> void:
	if not _can_prepare_lures() or not _lures_open or _lure_quote == null:
		return
	_preparing_lures = true
	var candidate := _hub_state.copy()
	if not candidate.apply_lures(_lure_quote) or not _save_hub(candidate):
		_preparing_lures = false
		_lures.set_status("저장 실패 또는 준비 상태 변경 · 돈과 수량은 그대로입니다.\n다시 확정하거나 선택으로 돌아가 취소하세요.")
		return
	var paid := _lure_quote.get_cost()
	_hub_state = candidate
	_lure_quote = null
	_preparing_lures = false
	_hub.render_holdings(_hub_state.get_money(), _hub_state.get_stored_items(), _hub_state.get_preparation_costs(), _hub_state.get_last_costs())
	_hub.render_preparation(_hub_state.create_departure_loadout(), false)
	_hub.render_objective(_hub_state)
	_lures.present(_hub_state)
	_lures.set_status("준비 저장 완료 · 이번 지불액 %d · 거점 추가분 %d개\n출정할 때 선택한 수량을 가져갑니다." % [paid, _hub_state.get_paid_lures()])


func _on_lures_closed() -> void:
	if not _can_prepare_lures() or not _lures_open:
		return
	_lures_open = false
	_lure_quote = null
	_lures.hide()
	_hub.get_node("Center").show()
	_hub.get_node("%LureButton").grab_focus()


func _on_objective_selected(offer: Dictionary, source: Dictionary) -> void:
	if not _can_prepare_lures() or _lures_open:
		return
	var candidate := _hub_state.copy()
	if not candidate.select_objective(offer, source):
		_hub.render_objective(_hub_state)
		_hub.set_status("준비 상태가 달라졌습니다. 의뢰 조건을 다시 확인해 주세요.")
		return
	if not _save_hub(candidate):
		_hub.set_status("저장 실패 · 이전 목표 선택을 유지했습니다. 다시 적용하거나 선택을 취소하세요.")
		return
	_hub_state = candidate
	_hub.render_objective(_hub_state)
	_hub.set_status("목표 선택을 저장했습니다. 의뢰 없이도 출정할 수 있습니다.")


func _can_prepare_portable() -> bool:
	if _departure_warning_open:
		return false
	return GameState.get_current_state() == GameState.State.HUB and not GameState.is_transition_in_progress() \
		and not get_tree().paused and not _departing and not _settling and not _preparing_portable and not _recovery_required \
		and not _appraisal_open and not _appraising and not _sale_open and not _selling \
		and not _registration_open and not _registering and not _repair_open and not _repairing \
		and not _harness_open and not _equipping and not _upgrade_open and not _upgrading and not _lures_open and not _preparing_lures


func _on_portable_requested() -> void:
	if not _can_prepare_portable() or _portable_open:
		return
	_portable_open = true
	_portable_quote = null
	_hub.get_node("Center").hide()
	_portable.present(_hub_state)


func _on_portable_review_requested(count: int) -> void:
	if not _can_prepare_portable() or not _portable_open or _portable_quote != null:
		return
	_portable_quote = _hub_state.quote_portable_appraisals(count)
	_portable.set_review(_portable_quote)


func _on_portable_selection_requested() -> void:
	if not _can_prepare_portable() or not _portable_open:
		return
	_portable_quote = null
	_portable.present(_hub_state)


func _on_portable_confirmed() -> void:
	if not _can_prepare_portable() or not _portable_open or _portable_quote == null:
		return
	_preparing_portable = true
	var candidate := _hub_state.copy()
	if not candidate.apply_portable_appraisals(_portable_quote) or not _save_hub(candidate):
		_preparing_portable = false
		_portable.set_status("저장 실패 또는 준비 상태 변경 · 돈과 수량은 그대로입니다.\n다시 확정하거나 선택으로 돌아가 취소하세요.")
		return
	var paid := _portable_quote.get_cost()
	_hub_state = candidate
	_portable_quote = null
	_preparing_portable = false
	_hub.render_holdings(_hub_state.get_money(), _hub_state.get_stored_items(), _hub_state.get_preparation_costs(), _hub_state.get_last_costs())
	_hub.render_preparation(_hub_state.create_departure_loadout(), false)
	_hub.render_objective(_hub_state)
	_portable.present(_hub_state)
	_portable.set_status("준비 저장 완료 · 이번 지불액 %d · 거점 감정 도구 %d개\n출정할 때 선택한 수량을 가져갑니다." % [paid, _hub_state.get_paid_appraisals()])


func _on_portable_closed() -> void:
	if not _can_prepare_portable() or not _portable_open:
		return
	_portable_open = false
	_portable_quote = null
	_portable.hide()
	_hub.get_node("Center").show()
	_hub.get_node("%PortableButton").grab_focus()
