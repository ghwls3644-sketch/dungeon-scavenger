class_name GameLog
extends RefCounted

const PREFIX := "DungeonScavenger"


static func info(source: StringName, event: StringName, details: String = "") -> void:
	print(_format_message(&"INFO", source, event, details))


static func warning(source: StringName, event: StringName, details: String = "") -> void:
	push_warning(_format_message(&"WARNING", source, event, details))


static func error(source: StringName, event: StringName, details: String = "") -> void:
	push_error(_format_message(&"ERROR", source, event, details))


static func _format_message(
	level: StringName,
	source: StringName,
	event: StringName,
	details: String
) -> String:
	var message := "[%s][%s][%s] %s" % [PREFIX, level, source, event]
	if not details.is_empty():
		message += " " + details
	return message
