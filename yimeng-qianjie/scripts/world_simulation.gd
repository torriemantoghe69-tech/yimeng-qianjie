class_name WorldSimulation
extends RefCounted

## 世界推进的唯一入口。玩家行动、远行与探索最终都通过 GameState._advance() 调用这里。

static func advance(state: GameState, years: int) -> void:
	if years <= 0:
		return
	state.age += years
	state.turn_count += 1
	simulate_turn(state)


## 统一记录世界事件，供天下风云、人物因果与后续剧情系统共同读取。
static func record_event(state: GameState, event_type: String, event_text: String, metadata: Dictionary = {}) -> void:
	var entry: Dictionary = {
		"year": state.world_year,
		"age": state.age,
		"type": event_type,
		"text": event_text
	}
	for key: Variant in metadata.keys():
		entry[String(key)] = metadata[key]
	state.world_events.append(entry)
	while state.world_events.size() > 12:
		state.world_events.pop_front()


static func simulate_turn(state: GameState) -> void:
	state.world_year += 1
	# 每三次行动推进一次天下局势；使用回合数保证读档后结果稳定。
	if posmod(state.turn_count, 3) != 0:
		return
	var faction_names: Array[String] = []
	for faction: Dictionary in GameState.WORLD_FACTIONS:
		faction_names.append(String(faction.get("name", "")))
	if faction_names.size() < 2:
		return
	var a_index := posmod(state.turn_count * 7 + state.world_year, faction_names.size())
	var b_index := posmod(state.turn_count * 11 + 3, faction_names.size())
	if a_index == b_index:
		b_index = posmod(b_index + 1, faction_names.size())
	var faction_a := faction_names[a_index]
	var faction_b := faction_names[b_index]
	var a_power := int(state.faction_power_state.get(faction_a, 50))
	var b_power := int(state.faction_power_state.get(faction_b, 50))
	var a_momentum := posmod(state.turn_count * 5 + state.world_year, 11)
	var b_momentum := posmod(state.turn_count * 3 + state.world_year, 11)
	var winner := faction_a if a_power + a_momentum >= b_power + b_momentum else faction_b
	var loser := faction_b if winner == faction_a else faction_a
	state.faction_power_state[winner] = mini(100, int(state.faction_power_state.get(winner, 50)) + 2)
	state.faction_power_state[loser] = maxi(10, int(state.faction_power_state.get(loser, 50)) - 1)
	var event_text := "%s与%s因灵脉归属发生摩擦，%s暂占上风。" % [faction_a, faction_b, winner]
	record_event(state, "势力冲突", event_text, {
		"winner": winner,
		"loser": loser,
		"faction_a": faction_a,
		"faction_b": faction_b
	})
	state.world_conflict += 1
	if not state.faction_relations.has(faction_a):
		state.faction_relations[faction_a] = "中立"
	if not state.faction_relations.has(faction_b):
		state.faction_relations[faction_b] = "中立"
	if posmod(state.turn_count, 6) == 0:
		state.faction_relations[faction_a] = "敌对"
		state.faction_relations[faction_b] = "敌对"
	state.add_log("【天下风云】" + event_text, "world")
	# 同时代修士随岁月缓慢成长，不会永远停留在初见时。
	for rival: Dictionary in state.rival_npcs:
		if not bool(rival.get("alive", true)) or int(rival.get("realm", 0)) >= 17:
			continue
		var aptitude := int(rival.get("aptitude", 40))
		var progress := int(rival.get("cultivation", 0)) + maxi(1, int(aptitude / 18))
		if progress >= 100:
			progress -= 100
			rival["realm"] = mini(17, int(rival.get("realm", 0)) + 1)
			state.add_log("【同代天骄】%s历经苦修，突破至%s。" % [String(rival.get("name", "某修士")), GameData.realm_name(int(rival["realm"]))], "world")
		rival["cultivation"] = progress
		rival["last_seen"] = state.age
