class_name NpcRelationshipSystem
extends RefCounted

## NPC 的关系资料统一保存在 GameState.met_npcs。
## flags.npc_relations 仅作为旧存档兼容镜像，不再作为第二套独立数据源。

static func relationship_title(affinity: int) -> String:
	if affinity >= 70:
		return "挚友"
	if affinity >= 35:
		return "知交"
	if affinity >= 10:
		return "友善"
	if affinity <= -60:
		return "仇敌"
	if affinity <= -25:
		return "敌视"
	return "陌路"


static func _find_record_index(state: GameState, npc_id: String, npc_name: String) -> int:
	if not npc_id.is_empty():
		for index in range(state.met_npcs.size()):
			if String(state.met_npcs[index].get("event_id", "")) == npc_id:
				return index
	if not npc_name.is_empty():
		for index in range(state.met_npcs.size()):
			if String(state.met_npcs[index].get("name", "")) == npc_name:
				return index
	return -1


static func get_record(state: GameState, npc_name: String, faction_name: String = "") -> Dictionary:
	var legacy_relations: Dictionary = state.flags.get("npc_relations", {}) if state.flags.get("npc_relations", {}) is Dictionary else {}
	var legacy: Dictionary = legacy_relations.get(npc_name, {}) if legacy_relations.get(npc_name, {}) is Dictionary else {}
	var index := _find_record_index(state, "", npc_name)
	if index >= 0:
		var record: Dictionary = state.met_npcs[index].duplicate(true)
		if not legacy.is_empty():
			for key: Variant in legacy.keys():
				if not record.has(key) or (record[key] is String and String(record[key]).is_empty()):
					record[String(key)] = legacy[key]
			var current_affinity := int(record.get("affinity", 0))
			var legacy_affinity := int(legacy.get("affinity", 0))
			var current_turn := int(record.get("last_relation_turn", record.get("last_seen_turn", -999)))
			var legacy_turn := int(legacy.get("last_relation_turn", legacy.get("last_talk_turn", -999)))
			if legacy_turn > current_turn or (legacy_turn == -999 and current_turn == -999 and absi(legacy_affinity) > absi(current_affinity)):
				record["affinity"] = legacy_affinity
		if faction_name != "" and String(record.get("faction", "")).is_empty():
			record["faction"] = faction_name
		record["relationship_id"] = String(record.get("relationship_id", "npc:" + npc_name))
		record["relationship"] = relationship_title(int(record.get("affinity", 0)))
		if not legacy.is_empty():
			save_record(state, npc_name, record)
		return record
	if legacy.is_empty():
		return {"name":npc_name, "relationship_id":"npc:" + npc_name, "affinity":0, "relationship":relationship_title(0), "faction":faction_name}
	var record: Dictionary = legacy.duplicate(true)
	record["name"] = npc_name
	record["relationship_id"] = "npc:" + npc_name
	if faction_name != "" and String(record.get("faction", "")).is_empty():
		record["faction"] = faction_name
	record["affinity"] = clampi(int(record.get("affinity", 0)), -100, 100)
	record["relationship"] = relationship_title(int(record["affinity"]))
	save_record(state, npc_name, record)
	return record

static func save_record(state: GameState, npc_name: String, source_record: Dictionary) -> void:
	if npc_name.is_empty():
		return
	var record: Dictionary = source_record.duplicate(true)
	record["name"] = npc_name
	record["relationship_id"] = String(record.get("relationship_id", "npc:" + npc_name))
	record["affinity"] = clampi(int(record.get("affinity", 0)), -100, 100)
	record["relationship"] = relationship_title(int(record["affinity"]))
	var index := _find_record_index(state, String(record.get("event_id", "")), npc_name)
	if index >= 0:
		var merged: Dictionary = state.met_npcs[index].duplicate(true)
		merged.merge(record, true)
		state.met_npcs[index] = merged
		record = merged
	else:
		state.met_npcs.append(record.duplicate(true))
	# 保留旧字段以便旧版本仍能读档；之后所有新逻辑均以 met_npcs 为准。
	var legacy_relations: Dictionary = state.flags.get("npc_relations", {}) if state.flags.get("npc_relations", {}) is Dictionary else {}
	legacy_relations[npc_name] = record.duplicate(true)
	state.flags["npc_relations"] = legacy_relations


static func adjust_affinity(state: GameState, npc_name: String, delta: int, faction_name: String, reason: String, intro: String = "") -> Dictionary:
	var record := get_record(state, npc_name, faction_name)
	var old_affinity := int(record.get("affinity", 0))
	var old_title := relationship_title(old_affinity)
	var new_affinity := clampi(old_affinity + delta, -100, 100)
	record["affinity"] = new_affinity
	record["relationship"] = relationship_title(new_affinity)
	if faction_name != "":
		record["faction"] = faction_name
	if intro != "":
		record["intro"] = intro
	record["last_relation_reason"] = reason
	record["last_relation_age"] = state.age
	record["last_relation_turn"] = state.turn_count
	var history: Array = Array(record.get("relationship_history", [])).duplicate(true)
	history.append({
		"reason": reason,
		"intro": intro,
		"age": state.age,
		"delta": new_affinity - old_affinity,
		"affinity": new_affinity
	})
	if history.size() > 30:
		history.pop_front()
	record["relationship_history"] = history
	save_record(state, npc_name, record)
	if faction_name != "" and new_affinity != old_affinity:
		state.faction_reputation[faction_name] = clampi(int(state.faction_reputation.get(faction_name, 0)) + int(sign(new_affinity - old_affinity)), -100, 100)
		if state.is_faction_member() and faction_name == state.faction_name and new_affinity > old_affinity:
			state.faction_contribution += 1
			if state.is_sect_member():
				state.sect_merit += 1
	if old_title != relationship_title(new_affinity):
		WorldSimulation.record_event(state, "人物关系", "%s与你的关系变为%s。" % [npc_name, relationship_title(new_affinity)], {
			"npc": npc_name,
			"faction": faction_name,
			"affinity": new_affinity
		})
	return record


static func companion_skill_profile(npc: Dictionary) -> Dictionary:
	return PartyCombatSystem.companion_skill_profile(npc)

static func record_choice(state: GameState, profile: Dictionary, event: Dictionary, choice: Dictionary, outcome: Dictionary) -> Array:
	var notes: Array = []
	if profile.is_empty():
		return notes
	var npc_id := String(profile.get("event_id", ""))
	if npc_id.is_empty():
		return notes
	var npc_name := String(profile.get("name", ""))
	if npc_name.is_empty():
		return notes
	var faction_hint := String(profile.get("faction", ""))
	var npc := get_record(state, npc_name, faction_hint)
	npc.merge(profile, false)
	npc["event_id"] = npc_id
	if faction_hint != "" and String(npc.get("faction", "")).is_empty():
		npc["faction"] = faction_hint
	var npc_index := _find_record_index(state, npc_id, npc_name)
	if npc_index < 0:
		state.met_npcs.append(npc.duplicate(true))
		npc_index = state.met_npcs.size() - 1
	else:
		state.met_npcs[npc_index] = npc.duplicate(true)
	var effects: Dictionary = outcome.get("effects", choice.get("effects", {}))
	var tone := String(choice.get("tone", "neutral"))
	var karma_delta := int(effects.get("karma", 0))
	var affinity_delta := 2
	if tone == "good":
		affinity_delta = 8
	elif tone == "evil":
		affinity_delta = -8
	elif karma_delta > 0:
		affinity_delta = 5
	elif karma_delta < 0:
		affinity_delta = -5
	var affinity_before := int(npc.get("affinity", 0))
	var previous_title := relationship_title(affinity_before)
	var affinity_after := clampi(affinity_before + affinity_delta, -100, 100)
	npc["affinity"] = affinity_after
	npc["relationship"] = relationship_title(affinity_after)
	var history: Array = Array(npc.get("choice_history", [])).duplicate(true)
	history.append({
		"event_title": String(event.get("title", "机缘")),
		"choice": String(choice.get("text", "未记载")),
		"result": String(outcome.get("result", outcome.get("text", ""))),
		"age": state.age,
		"affinity_delta": affinity_delta
	})
	if history.size() > 20:
		history.pop_front()
	npc["choice_history"] = history
	npc["last_seen_age"] = state.age
	npc["last_seen_turn"] = state.turn_count
	npc["last_choice"] = String(choice.get("text", ""))
	if effects.has("npc_recruit") and affinity_after >= 10:
		npc["companion"] = true
		npc["companion_since"] = state.age
		npc["partner_level"] = maxi(1, int(npc.get("partner_level", 1)))
		npc["bond_exp"] = int(npc.get("bond_exp", 0))
		npc["personal_quest_stage"] = int(npc.get("personal_quest_stage", 0))
		var personal_skill := companion_skill_profile(npc)
		npc["battle_skill_id"] = String(personal_skill.get("id", npc_id))
		npc["battle_skill"] = String(personal_skill.get("name", "本命绝技"))
		npc["battle_skill_desc"] = String(personal_skill.get("desc", ""))
		npc["battle_cooldown"] = 0
		if String(npc.get("partner_realm", "")).is_empty():
			npc["partner_realm"] = "炼气"
		notes.append("%s答应成为你的同行伙伴，觉醒专属战技：%s" % [npc_name, String(npc.get("battle_skill", "协战"))])
	elif effects.has("npc_recruit"):
		notes.append("%s尚不信任你，暂不愿同行" % npc_name)
	var faction := String(npc.get("faction", ""))
	if not faction.is_empty() and faction not in ["不详", "来历不明"]:
		state.faction_reputation[faction] = clampi(int(state.faction_reputation.get(faction, 0)) + int(sign(affinity_delta)) * 2, -100, 100)
		if state.is_faction_member() and faction == state.faction_name and affinity_delta > 0:
			state.faction_contribution += 1
			if state.is_sect_member():
				state.sect_merit += 1
			notes.append("与%s的交情为所属势力带来少许声望" % faction)
	state.met_npcs[npc_index] = npc
	save_record(state, npc_name, npc)
	if previous_title != relationship_title(affinity_after):
		WorldSimulation.record_event(state, "人物关系", "%s对你的态度转为%s。" % [npc_name, relationship_title(affinity_after)], {
			"npc": npc_name,
			"faction": faction,
			"affinity": affinity_after
		})
	if effects.has("npc_recruit") and affinity_after >= 10:
		WorldSimulation.record_event(state, "伙伴结缘", "%s决定与你同行。" % npc_name, {
			"npc": npc_name,
			"faction": faction
		})
	if affinity_after != affinity_before:
		notes.push_front("%s对你的态度：%s（好感 %s%d）" % [npc_name, String(npc["relationship"]), "+" if affinity_delta > 0 else "", affinity_delta])
	return notes
