class_name ExplorationMapDefinition
extends Resource

# Fixed, public route information only. Hidden areas and live entities do not belong here.
@export var bounds: Rect2
@export var entrance_position: Vector2
@export var regions: Array[MapRegionDefinition] = []
@export var routes: Array[PackedVector2Array] = []


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if not bounds.position.is_finite() or not bounds.size.is_finite() or bounds.size.x <= 0.0 or bounds.size.y <= 0.0:
		errors.append("Map bounds must be finite and positive.")
	if not entrance_position.is_finite() or not bounds.has_point(entrance_position):
		errors.append("Entrance must be inside the map.")
	if regions.is_empty():
		errors.append("Map needs at least one public region.")
	var ids: Dictionary = {}
	for region in regions:
		if region == null:
			errors.append("Map region must not be null.")
			continue
		errors.append_array(region.get_validation_errors())
		if ids.has(region.stable_id):
			errors.append("Map region IDs must be unique.")
		ids[region.stable_id] = true
		if not bounds.encloses(region.bounds):
			errors.append("Map region must be inside the map.")
	for route in routes:
		if route.size() < 2:
			errors.append("Map route needs at least two points.")
		for point in route:
			if not point.is_finite() or not bounds.has_point(point):
				errors.append("Map route point must be inside the map.")
	return errors
