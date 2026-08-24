class_name HarnessStatus
extends PanelContainer

@export var source_path: NodePath

var _source: HarnessController
var _prompt_visible := false

@onready var _status: Label = %Status


func _ready() -> void:
	if not source_path.is_empty():
		bind_source(get_node_or_null(source_path) as HarnessController)
	else:
		_render("", false, 0, 0)


func bind_source(source: HarnessController) -> void:
	if _source != null and _source.status_changed.is_connected(_render):
		_source.status_changed.disconnect(_render)

	_source = source
	if _source == null:
		_render("", false, 0, 0)
		return

	_source.status_changed.connect(_render)
	_source.publish_status()


func get_status_text() -> String:
	return _status.text


func is_prompt_visible() -> bool:
	return _prompt_visible


func _render(prompt: String, should_show_prompt: bool, current_charge: int, charge_capacity: int) -> void:
	_prompt_visible = should_show_prompt
	_status.text = "하네스 충전 %d/%d" % [current_charge, charge_capacity]
	if should_show_prompt:
		_status.text += "\n[Q] %s" % prompt
