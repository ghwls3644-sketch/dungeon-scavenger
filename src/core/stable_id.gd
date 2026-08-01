class_name StableId
extends RefCounted


static func is_valid(value: StringName) -> bool:
	var text := String(value)
	return not text.is_empty() and text == text.strip_edges()
