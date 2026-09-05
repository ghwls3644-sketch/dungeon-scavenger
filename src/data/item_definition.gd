class_name ItemDefinition
extends ContentDefinition

const CATEGORY_SCRAP: StringName = &"scrap"
const CATEGORY_RESIDUE: StringName = &"residue"
const CATEGORY_UNIQUE_ARTIFACT: StringName = &"unique_artifact"
const CATEGORY_CORE_RECORD: StringName = &"core_record"

const CATEGORY_IDS := [
	CATEGORY_SCRAP,
	CATEGORY_RESIDUE,
	CATEGORY_UNIQUE_ARTIFACT,
	CATEGORY_CORE_RECORD,
]

@export var category: StringName = &""
@export var weight: float = 0.0
@export var slot_size: int = 0
@export var value_min: int = 0
@export var value_max: int = 0
@export var sale_protected := false


func has_monetary_value() -> bool:
	return category not in [CATEGORY_UNIQUE_ARTIFACT, CATEGORY_CORE_RECORD]


func is_protected() -> bool:
	return sale_protected or category in [CATEGORY_UNIQUE_ARTIFACT, CATEGORY_CORE_RECORD]


func get_validation_errors() -> PackedStringArray:
	var errors := super.get_validation_errors()

	if category not in CATEGORY_IDS:
		errors.append("category must be one of the defined item category IDs.")
	if weight < 0.0:
		errors.append("weight must not be negative.")
	if slot_size < 0:
		errors.append("slot_size must not be negative.")
	if value_min < 0 or value_max < 0:
		errors.append("value range must not be negative.")
	if value_min > value_max:
		errors.append("value_min must not be greater than value_max.")

	return errors
