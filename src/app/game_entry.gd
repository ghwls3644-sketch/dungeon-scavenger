class_name GameEntry
extends Node

const DEV_SCENE := preload("res://src/app/dev_main.tscn")
const EXPLORATION_SCENE := preload("res://src/app/prototype_exploration.tscn")
const PROTOTYPE_ECONOMY := preload("res://src/data/prototype_economy.tres")

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
	_title.new_game_requested.connect(_on_new_game_requested)
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
	_has_saved_game = has_saved_game
	_restore_saved_game = restore_saved_game
	if is_node_ready():
		refresh_continue()


func refresh_continue() -> void:
	_title.set_menu_state(_can_continue(), _starting)


func _boot() -> void:
	if GameState.get_current_state() == GameState.State.BOOT:
		GameState.request_transition(GameState.State.TITLE)
	else:
		_on_state_changed(GameState.get_current_state(), GameState.get_current_state())


func _can_continue() -> bool:
	return _has_saved_game.is_valid() and _restore_saved_game.is_valid() and _has_saved_game.call() == true


func _can_start() -> bool:
	return not _starting and GameState.get_current_state() == GameState.State.TITLE and not _title.is_options_open()


func _on_new_game_requested() -> void:
	if not _can_start():
		return
	_starting = true
	_hub_state = HubState.new()
	_title.set_menu_state(false, true)
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
	_hub_state.select_bag_slots(slots)
	_hub.render_preparation(_hub_state.create_departure_loadout(), false)


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
	if not _hub_state.apply_settlement(_expedition_id):
		_settling = false
		_results.set_busy(false)
		return
	GameState.request_transition(GameState.State.HUB)


func _on_quit_requested() -> void:
	GameLog.info(&"GameEntry", &"quit_requested")
	get_tree().quit()
