extends SceneTree

## 临时音乐播放测试：用真实音频驱动验证播放器状态与场景切换。

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
		printerr("请设置 DSH_GAME_TEST=1 并使用独立用户目录。")
		quit(1)
		return
	var scene: Control = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame
	await create_timer(1.5).timeout
	_check(scene.music.current_key() == "menu", "主菜单选中轮回之门")
	_check(scene.music._active != null and scene.music._active.playing, "主菜单音乐播放器正在播放")
	_check(scene.music._active.volume_db > -40.0, "音乐淡入到可听音量")
	print("MENU position=", scene.music._active.get_playback_position(), " volume_db=", scene.music._active.volume_db)
	scene._start_new_life()
	await process_frame
	await create_timer(1.5).timeout
	scene._clear_modal(false)
	_check(scene.music.current_key() == "cultivation", "进入游戏切换到云山静修")
	_check(scene.music._active != null and scene.music._active.playing, "修行音乐正在播放")
	scene._open_event(EventData.EVENTS[0])
	await process_frame
	await create_timer(1.2).timeout
	_check(scene.music.current_key() == "event", "打开事件切换到红尘机缘")
	_check(scene.music._active != null and scene.music._active.playing, "事件音乐正在播放")
	scene._clear_modal(false)
	scene._show_menu()
	await create_timer(1.0).timeout
	_check(scene.music.current_key() == "menu", "返回主菜单恢复轮回之门")
	scene.queue_free()
	await process_frame
	print("AUDIO TESTS PASSED" if failures == 0 else "AUDIO TESTS FAILED")
	quit(0 if failures == 0 else 1)
