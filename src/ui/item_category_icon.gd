class_name ItemCategoryIcon
extends RefCounted

const UNKNOWN := preload("res://src/ui/icons/item_unknown.svg")
const IDENTIFIED := {
	ItemDefinition.CATEGORY_SCRAP: preload("res://src/ui/icons/item_scrap.svg"),
	ItemDefinition.CATEGORY_RESIDUE: preload("res://src/ui/icons/item_residue.svg"),
	ItemDefinition.CATEGORY_UNIQUE_ARTIFACT: preload("res://src/ui/icons/item_artifact.svg"),
	ItemDefinition.CATEGORY_CORE_RECORD: preload("res://src/ui/icons/item_record.svg"),
}


static func for_item(item: InventoryItem) -> Texture2D:
	# Identification is the only gate; price and protection must not distinguish hidden items.
	if item == null or not item.is_identified() or not item.is_valid():
		return UNKNOWN
	return IDENTIFIED.get(item.get_definition().category, UNKNOWN)
