class_name VisitPoolDefinition
extends Resource

@export var stable_id: StringName = &""
@export var region_id: StringName = &""
# Upper bound only. Empty/excluded/conflicting candidates need not fill it.
@export var maximum_count: int = 0
@export var candidates: Array[VisitCandidateDefinition] = []
