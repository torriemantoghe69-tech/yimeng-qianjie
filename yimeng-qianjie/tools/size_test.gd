extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	print("PROJECT viewport=", ProjectSettings.get_setting("display/window/size/viewport_width"), "x", ProjectSettings.get_setting("display/window/size/viewport_height"))
	print("PROJECT override=", ProjectSettings.get_setting("display/window/size/window_width_override"), "x", ProjectSettings.get_setting("display/window/size/window_height_override"))
	print("PROJECT mode=", ProjectSettings.get_setting("display/window/size/mode"))
	var packed: PackedScene = load("res://scenes/main.tscn")
	var scene: Control = packed.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame
	print("WINDOW=", DisplayServer.window_get_size(), " MODE=", DisplayServer.window_get_mode())
	print("ROOT size=", root.size, " content_scale=", root.content_scale_size, " factor=", root.content_scale_factor)
	print("SCENE size=", scene.size)
	await create_timer(1.0).timeout
	print("AFTER_WINDOW=", DisplayServer.window_get_size(), " MODE=", DisplayServer.window_get_mode())
	print("AFTER_ROOT=", root.size)
	var image: Image = root.get_texture().get_image()
	print("IMAGE=", image.get_size())
	scene.queue_free()
	await process_frame
	quit(0)
