extends GameEntry

# Only the scene creation varies; the real app owns every lifecycle/transaction.
var review_scene: PackedScene


func _create_exploration() -> PrototypeExploration:
	if review_scene == null:
		return super._create_exploration()
	var world := review_scene.instantiate() as PrototypeExploration
	world.auto_start = false
	return world
