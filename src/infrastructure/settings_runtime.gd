class_name SettingsRuntime
extends RefCounted


static func apply(settings: GameSettings, window: Window) -> void:
	if settings == null or not settings.is_valid():
		return
	var master_bus := AudioServer.get_bus_index("Master")
	if master_bus >= 0:
		AudioServer.set_bus_volume_linear(master_bus, float(settings.master_volume) / 100.0)
		AudioServer.set_bus_mute(master_bus, settings.master_volume == 0)
	window.content_scale_size = GameSettings.WINDOW_SIZES[0]
	window.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	window.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	if DisplayServer.get_name() == "headless":
		return
	if settings.screen_mode == "fullscreen":
		window.mode = Window.MODE_FULLSCREEN
	else:
		window.mode = Window.MODE_WINDOWED
		var available := DisplayServer.screen_get_usable_rect(window.current_screen)
		var requested: Vector2i = GameSettings.WINDOW_SIZES[settings.window_size_index]
		# Leave room for the title bar and taskbar when moving to a smaller display.
		window.size = requested.min((available.size - Vector2i(32, 64)).max(Vector2i.ONE))
		window.position = available.position + (available.size - window.size) / 2
