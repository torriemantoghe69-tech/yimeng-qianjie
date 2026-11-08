extends SceneTree

## 生成界面验收截图：主菜单、转生、游戏、事件、事件结果、终章、轮回殿、尘世录。

var shot_dir: String = "res://screenshots"
var scene: Control

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	if OS.get_environment("DSH_GAME_TEST") != "1":
		printerr("截图工具会重置存档。请设置 DSH_GAME_TEST=1 并使用独立的用户数据目录。")
		quit(1)
		return
	if FileAccess.file_exists("user://display_save.json"):
		DirAccess.remove_absolute(ProjectSettings.globalize_path("user://display_save.json"))
	if FileAccess.file_exists("user://audio_save.json"):
		DirAccess.remove_absolute(ProjectSettings.globalize_path("user://audio_save.json"))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(shot_dir))
	var packed: PackedScene = load("res://scenes/main.tscn")
	scene = packed.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame
	# 使用全新的轮回档案截图，确保菜单呈现初次游玩的状态。
	scene.soul = scene._default_soul()
	scene._save_soul()
	scene._delete_run()
	scene._refresh_menu()
	await process_frame
	await _snap("01_menu")

	scene._start_new_life()
	await process_frame
	await process_frame
	await _snap("02_intro")

	scene._close_modal()
	await process_frame
	scene.state.cultivation = scene.state.threshold() * 0.68
	scene.state.injury = 12
	scene.state.stones = 45
	for item_name: String in ["问天剑", "无名剑刃", "白狐灵毛", "无名玉简", "天外星石"]:
		scene.state.treasures.append(item_name)
		scene.state.treasure_ages[item_name] = 16
	scene.state.equip_item("问天剑")
	scene.state.equip_item("白狐灵毛")
	scene.state.equip_item("天外星石")
	scene._refresh_game_ui()
	await process_frame
	await process_frame
	await _snap("03_game")

	scene._open_treasure_detail("天外星石")
	await process_frame
	await process_frame
	await _snap("11_treasure_detail")
	scene._close_modal()
	await process_frame

	scene._open_equipment_slot("weapon")
	await process_frame
	await process_frame
	await _snap("12_equipment_slot")
	scene._close_modal()
	await process_frame

	scene._open_audio_settings()
	await process_frame
	await process_frame
	await _snap("14_audio_settings")
	scene._close_modal()
	await process_frame

	var event: Dictionary = EventData.EVENTS[0]
	scene._open_event(event)
	await process_frame
	await process_frame
	await _snap("04_event")

	scene._on_event_choice(event, event["choices"][0])
	await process_frame
	await process_frame
	await _snap("05_event_result")
	scene._clear_modal(false)
	await process_frame

	scene._open_help()
	await process_frame
	await process_frame
	await _snap("06_help")
	scene._clear_modal(false)
	await process_frame

	scene._open_display_settings()
	await process_frame
	await process_frame
	await _snap("13_display_settings")
	scene._clear_modal(false)
	await process_frame

	# 构造一份终章画面。
	scene.state.realm = 7
	scene.state.lifespan = 260
	scene.state.age = 211
	scene.state.karma = 18
	scene.state.death_reason = "旧伤复发"
	scene.state.alive = false
	scene.state.death_handled = false
	scene.state.add_log("【破境】一粒金丹吞入腹，始知我命不由天。", "breakthrough")
	scene.state.add_log("【天门】你在云海之上看见一道门，门后是另一个自己。", "epiphany")
	scene._handle_death()
	await process_frame
	await process_frame
	await _snap("07_ending")

	scene._open_upgrade_screen(true)
	await process_frame
	await process_frame
	await _snap("08_rebirth_hall")

	scene._start_new_life()
	await process_frame
	await process_frame
	await _snap("09_reborn_intro")
	scene._clear_modal(false)
	await process_frame

	scene._show_menu()
	await process_frame
	await process_frame
	await _snap("10_menu_progress")
	print("SCREENSHOTS SAVED")
	quit(0)

func _snap(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var image: Image = root.get_texture().get_image()
	if image == null:
		printerr("null image for ", name)
		return
	var path: String = "%s/%s.png" % [shot_dir, name]
	var error: Error = image.save_png(path)
	print("SNAP ", path, " -> ", error, " size=", image.get_size())
