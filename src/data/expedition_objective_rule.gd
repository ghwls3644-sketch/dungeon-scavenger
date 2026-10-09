class_name ExpeditionObjectiveRule
extends ContentDefinition

@export var version := 1
@export var required_count := 2
@export var reward := 10


func is_valid() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := super.get_validation_errors()
	if version <= 0 or required_count <= 0 or required_count > 3 or reward < 0:
		errors.append("Invalid objective version, count or reward.")
	return errors


func offer() -> Dictionary:
	return {"id": String(stable_id), "version": version, "required": required_count, "reward": str(reward)}
