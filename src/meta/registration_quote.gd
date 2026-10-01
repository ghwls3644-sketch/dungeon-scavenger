class_name RegistrationQuote
extends RefCounted

var _source: Dictionary
var _index: int


func _init(source: Dictionary, index: int) -> void:
	_source = source.duplicate(true)
	_index = index


func get_index() -> int:
	return _index


func matches(source: Dictionary) -> bool:
	return not source.is_empty() and source == _source
