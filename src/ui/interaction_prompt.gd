class_name InteractionPrompt
extends Label

@export var interaction_source_path: NodePath
@export var prefix_text := "상호작용: "

var _source: InteractionController


func _ready() -> void:
	hide()
	if not interaction_source_path.is_empty():
		bind_source(get_node_or_null(interaction_source_path) as InteractionController)


func bind_source(source: InteractionController) -> void:
	if _source != null and _source.prompt_changed.is_connected(_on_prompt_changed):
		_source.prompt_changed.disconnect(_on_prompt_changed)

	_source = source
	if _source == null:
		_on_prompt_changed("", false)
		return

	_source.prompt_changed.connect(_on_prompt_changed)
	var prompt := _source.get_current_prompt()
	_on_prompt_changed(prompt, not prompt.is_empty())


func _on_prompt_changed(prompt: String, should_show: bool) -> void:
	text = prefix_text + prompt if should_show else ""
	visible = should_show
