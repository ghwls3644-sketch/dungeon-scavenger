class_name InteractionTestInput
extends RefCounted


static func wait_for_work(player: PlayerController) -> bool:
	# Some older input helpers leave key events buffered until the next frame.
	Input.flush_buffered_events()
	var controller := player.get_node("InteractionController") as InteractionController
	var tree := player.get_tree()
	for frame in range(240):
		if not is_instance_valid(controller):
			return false
		if not controller.is_working():
			return true
		await tree.physics_frame
	return false
