class_name ResearchProgress
extends RefCounted


# Registration is permanent. Read-only projections share its existing save lifetime.
# Locked views contain no definition IDs, titles, text or prerequisite names.
static func get_entries(registered: Array[InventoryItem], catalog: ResearchCatalog, items: ItemCatalog) -> Array[Dictionary]:
	var views: Array[Dictionary] = []
	if catalog == null or not catalog.is_valid(items):
		return views
	var ids := {}
	for item in registered:
		if item != null and item.is_valid() and item.is_identified() and item.get_definition().is_original():
			ids[item.get_definition().stable_id] = true
	for entry in catalog.entries:
		var unlocked := true
		for id in entry.required_registered_ids:
			if not ids.has(id):
				unlocked = false
		views.append({
			"unlocked": unlocked,
			"title": entry.display_name if unlocked else "잠긴 연구 해설",
			"text": entry.explanation if unlocked else "관련 발견물을 등록하면 추가 해설을 읽을 수 있습니다.",
		})
	return views
