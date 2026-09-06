class_name HarnessStatus
extends PanelContainer

@export var source_path: NodePath

var _source: HarnessController
var _prompt_visible := false

@onready var _status: Label = %Status
@onready var _analysis: Label = %Analysis
@onready var _analyze_button: Button = %AnalyzeButton
@onready var _feedback: Label = %Feedback


func _ready() -> void:
	_analyze_button.pressed.connect(_on_analyze_pressed)
	if not source_path.is_empty():
		bind_source(get_node_or_null(source_path) as HarnessController)
	else:
		_render("", false, 0, 0)


func bind_source(source: HarnessController) -> void:
	if is_instance_valid(_source):
		if _source.status_changed.is_connected(_render):
			_source.status_changed.disconnect(_render)
		if _source.action_rejected.is_connected(_on_action_rejected):
			_source.action_rejected.disconnect(_on_action_rejected)
		if _source.charge_changed.is_connected(_on_charge_changed):
			_source.charge_changed.disconnect(_on_charge_changed)

	_source = source
	_feedback.hide()
	if _source == null:
		_render("", false, 0, 0)
		return

	_source.status_changed.connect(_render)
	_source.action_rejected.connect(_on_action_rejected)
	_source.charge_changed.connect(_on_charge_changed)
	_source.publish_status()


func get_status_text() -> String:
	return _status.text


func get_analysis_text() -> String:
	return _analysis.text


func is_prompt_visible() -> bool:
	return _prompt_visible


func _render(prompt: String, should_show_prompt: bool, current_charge: int, charge_capacity: int) -> void:
	_prompt_visible = should_show_prompt
	_status.text = "하네스 충전 %d/%d" % [current_charge, charge_capacity]
	if should_show_prompt:
		_status.text += "\n[Q] %s" % prompt

	var basic := _source.get_basic_analysis() if is_instance_valid(_source) else ""
	_analysis.visible = not basic.is_empty()
	_analyze_button.visible = _analysis.visible
	_analysis.text = ""
	if basic.is_empty():
		return

	_analysis.text = "기본 분석 · 무료\n%s" % basic
	var precise := _source.get_precise_analysis()
	var cost := _source.get_analysis_charge_cost()
	_analyze_button.disabled = not _source.can_analyze_current_target()
	_analyze_button.text = "정밀 분석 · 충전 %d" % cost
	if not precise.is_empty():
		_analysis.text += "\n정밀 분석\n%s" % precise
		_analyze_button.text = "현재 상태 분석 완료"
	elif cost > current_charge:
		_analyze_button.text += " · 충전 부족"


func _on_analyze_pressed() -> void:
	if is_instance_valid(_source):
		_feedback.hide()
		_source.analyze_current_target()


func _on_charge_changed(_current_charge: int, _capacity: int) -> void:
	_feedback.hide()


func _on_action_rejected(reason: StringName) -> void:
	match reason:
		HarnessController.REJECT_INSUFFICIENT_CHARGE:
			_feedback.text = "충전이 부족합니다."
		HarnessController.REJECT_ALREADY_ANALYZED:
			_feedback.text = "현재 상태는 이미 분석했습니다."
		HarnessController.REJECT_NO_TARGET:
			_feedback.text = "가까운 하네스 대상이 없습니다."
		HarnessController.REJECT_INVALID_COST:
			_feedback.text = "이 행동의 충전 비용을 확인할 수 없습니다."
		_:
			_feedback.text = "지금은 이 행동을 할 수 없습니다."
	_feedback.show()
