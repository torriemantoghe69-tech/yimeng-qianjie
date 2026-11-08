extends SceneTree

## 粗略模拟“专注修炼 + 持续购买传承”的玩家，观察多少世可以飞升。

var rng := RandomNumberGenerator.new()

func _initialize() -> void:
	rng.seed = 424242
	var soul := _make_soul()
	var priority: Array = ["root", "breakthrough", "insight", "lifespan", "daoheart", "luck", "body", "stones"]
	var max_realm_seen: int = 0
	for life: int in range(1, 61):
		var state := GameState.new_life(soul, rng)
		var turns: int = 0
		while state.alive and turns < 400:
			turns += 1
			if state.injury > 55:
				state.recover(rng)
			elif state.is_peak():
				state.attempt_breakthrough(rng)
			else:
				state.cultivate(rng)
			if not state.alive:
				break
			# 约两成回合触发事件，选择第一个可用的选项。
			if rng.randf() < 0.22:
				var ev: Dictionary = EventData.pick_event(state, rng)
				if not ev.is_empty():
					for choice: Dictionary in ev.get("choices", []):
						var cost: int = int(choice.get("cost", 0))
						var req: Dictionary = choice.get("req", {})
						if state.meets_requirement(req) and (cost <= 0 or state.can_afford(cost)):
							if cost > 0:
								state.pay_stones(cost)
							var outcome: Dictionary = choice
							if choice.has("outcomes"):
								outcome = GameData.weighted_pick(choice["outcomes"], rng)
							state.apply_effects(outcome.get("effects", {}))
							state.seen_events.append(String(ev.get("id", "")))
							break
			state.check_death()
		if state.alive:
			state.die("模拟结束")
		max_realm_seen = maxi(max_realm_seen, state.realm)
		var points: int = 8 + state.realm * 4
		points += mini(30, int(maxi(0, state.age - 16) / 10))
		if state.karma > 0:
			points += int(state.karma / 12)
		elif state.karma < 0:
			points += int(-state.karma / 25)
		points += state.treasures.size() * 2
		var ascended: bool = state.ascended
		if ascended:
			points += 150
		points = maxi(10, points)
		soul["points"] = int(soul["points"]) + points
		soul["lives"] = int(soul["lives"]) + 1
		soul["best_realm"] = maxi(int(soul["best_realm"]), state.realm)
		if ascended:
			soul["ascensions"] = int(soul["ascensions"]) + 1
		print("第 %2d 世：%-6s 享年 %3d，回合 %2d，得点 %3d，现有 %4d，飞升=%s" % [life, GameData.realm_name(state.realm), state.age, turns, points, int(soul["points"]), str(ascended)])
		# 购买传承
		while true:
			var bought := false
			for id: String in priority:
				var upgrade: Dictionary = _get_upgrade(id)
				var level: int = int(soul["upgrades"].get(id, 0))
				if level >= int(upgrade["max"]):
					continue
				var cost: int = GameData.upgrade_cost(upgrade, level)
				if int(soul["points"]) >= cost:
					soul["points"] = int(soul["points"]) - cost
					soul["upgrades"][id] = level + 1
					bought = true
					break
			if not bought:
				break
		if ascended:
			print(">>> 共用 %d 世飞升，最高境界 %s" % [life, GameData.realm_name(state.realm)])
			break
	print("结束：最高境界 %s，总世数 %d，剩余点 %d，传承=%s" % [GameData.realm_name(max_realm_seen), int(soul["lives"]), int(soul["points"]), str(soul["upgrades"])])
	quit(0)

func _make_soul() -> Dictionary:
	var upgrades: Dictionary = {}
	for upgrade: Dictionary in GameData.UPGRADES:
		upgrades[String(upgrade["id"])] = 0
	return {"points": 0, "lives": 0, "best_realm": 0, "ascensions": 0, "upgrades": upgrades, "chronicle": []}

func _get_upgrade(id: String) -> Dictionary:
	for upgrade: Dictionary in GameData.UPGRADES:
		if String(upgrade["id"]) == id:
			return upgrade
	return {}
