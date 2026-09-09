class_name GameEntry
extends Node

const DEV_SCENE := preload("res://src/app/dev_main.tscn")
const EXPLORATION_SCENE := preload("res://src/app/prototype_exploration.tscn")
const PROTOTYPE_ECONOMY := preload("res://src/data/prototype_economy.tres")
const ITEM_CATALOG := preload("res://src/data/prototype_item_catalog.tres")

var _has_saved_game := Callable()
var _restore_saved_game := Callable()
var _starting := false
var _departing := false
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

@onready var _title: TitleScreen = $Interface/TitleScreen
@onready var _hub: HubPanel = $Interface/HubPanel
@onready var _results: ExpeditionResultsScreen = $Interface/Results


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
	_hub.departure_requested.connect(_on_departure_requested)
	_hub.quit_requested.connect(_on_quit_requested)
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
	_hub_state = restored
	return true


func _save_hub(candidate: HubState, replace_existing: bool = false) -> bool:
	var data := candidate.to_save_data()
	if HubState.from_save_data(data, ITEM_CATALOG) == null:
		return false
	return _progress_store.save_data(data, replace_existing) == OK


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
		_hub.render_holdings(_hub_state.get_money(), _hub_state.get_stored_items())
		_hub.present()
		_hub.set_status("진행이 저장되어 있습니다.")
	if current_state == GameState.State.EXPLORATION and _exploration != null:
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


func get_hub_stored_items() -> Array[InventoryItem]:
	return _hub_state.get_stored_items()


func _on_bag_slots_selected(slots: int) -> void:
	if GameState.get_current_state() != GameState.State.HUB or _departing:
		return
	var candidate := _hub_state.copy()
	if not candidate.select_bag_slots(slots):
		return
	var saved := _save_hub(candidate)
	if saved:
		_hub_state = candidate
	_hub.render_preparation(_hub_state.create_departure_loadout(), false)
	_hub.set_status("준비 상태를 저장했습니다." if saved else "저장하지 못해 이전 준비 상태를 유지합니다. 다시 선택해 주세요.")


func _on_departure_requested() -> void:
	if _departing or GameState.get_current_state() != GameState.State.HUB or get_tree().paused:
		return
	if _exploration != null or _pending_outcome != null:
		return
	_departing = true
	var loadout := _hub_state.create_departure_loadout()
	_hub.render_preparation(loadout, true)
	_exploration = EXPLORATION_SCENE.instantiate()
	add_child(_exploration)
	if not _exploration.prepare_departure(loadout):
		_cancel_departure()
		return
	_expedition_id = _hub_state.begin_expedition()
	if _expedition_id == 0:
		_cancel_departure()
		return
	_exploration.exploration_ended.connect(_on_exploration_ended.bind(_expedition_id))
	if not GameState.request_transition(GameState.State.EXPLORATION):
		_cancel_departure()


func _cancel_departure() -> void:
	_discard_exploration()
	_hub_state.cancel_expedition(_expedition_id)
	_expedition_id = 0
	_departing = false
	_hub.render_preparation(_hub_state.create_departure_loadout(), false)
	_hub.set_status("출정 준비를 확인해 주세요.")


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
	GameLog.info(&"GameEntry", &"quit_requested")
	get_tree().quit()
