extends SceneTree

## 临时显示设置测试：验证窗口/全屏切换与持久化。

var failures: int = 0

func _initialize() -> void:
	call_deferred("_run")

func _check(ok: bool, message: String) -> void:
	if ok:
		print("  ok  ", message)
	else:
		failures += 1
		printerr("  FAIL  ", message)

func _run() -> void:
	if OS.get_environment("DSH_GAME_TEST") != "1":
		quitterr()
		return
	var packed: PackedScene = load("res://scenes/main.tscn")
	var scene: Control = packed.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame
	print("START mode=", DisplayServer.window_get_mode(), " size=", DisplayServer.window_get_size())
	scene._choose_display_window(Vector2i(1600, 900))
	await process_frame
	await process_frame
	print("WINDOW mode=", DisplayServer.window_get_mode(), " size=", DisplayServer.window_get_size())
	_check(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED, "可切换到窗口模式")
	_check(DisplayServer.window_get_size() == Vector2i(1600, 900), "窗口分辨率变为 1600x900")
	_check(FileAccess.file_exists("user://display_save.json"), "显示设置已保存")
	scene._choose_display_fullscreen()
	await process_frame
	await process_frame
	print("FULL mode=", DisplayServer.window_get_mode(), " size=", DisplayServer.window_get_size())
	_check(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN, "可切换到全屏")
	scene._toggle_fullscreen()
	await process_frame
	await process_frame
	print("TOGGLE mode=", DisplayServer.window_get_mode(), " size=", DisplayServer.window_get_size())
	_check(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED, "F11 可回到窗口")
	_check(DisplayServer.window_get_size() == Vector2i(1600, 900), "F11 恢复上次窗口大小")
	scene.queue_free()
	await process_frame
	print("DISPLAY TESTS PASSED" if failures == 0 else "DISPLAY TESTS FAILED")
	quit(0 if failures == 0 else 1)

func quitterr() -> void:
	printerr("请设置 DSH_GAME_TEST=1 并使用独立用户目录。")
	quit(1)
