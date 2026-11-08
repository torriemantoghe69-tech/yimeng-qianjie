class_name PartyCombatSystem
extends RefCounted

## 统一的队伍协战规则。重要 NPC 使用按人物档案配置的本命战技，不再按名字哈希抽取通用技能。
## 每回合最多三名人类伙伴出手，并按名册轮换；出战灵宠随后执行自己的招式。

const SKILL_PROFILES := {
	"old_beggar": {"name":"葫芦纳元","desc":"以残缺葫芦吞吐灵潮，伤敌的同时回流灵力。","effect":"restore","power":1.18,"cooldown":1,"value":0.22},
	"plague_village": {"name":"青禾续命针","desc":"以细密灵针护住心脉，为队伍疗伤并削弱敌势。","effect":"heal","power":0.62,"cooldown":2,"value":0.13},
	"moon_fox": {"name":"月华迷踪步","desc":"阿九借月华折叠身影，扰乱敌人神识并以狐火追击。","effect":"confuse","power":1.16,"cooldown":2,"value":0.62},
	"broken_sword": {"name":"悔字断岳斩","desc":"借无名剑修遗留的悔意斩开护体真元。","effect":"pierce","power":1.72,"cooldown":2,"value":5},
	"ghost_market": {"name":"青灯蚀魂","desc":"鬼市青灯照入识海，使敌人持续受损。","effect":"poison","power":0.92,"cooldown":2,"value":4},
	"cliff_sword": {"name":"崖畔无咎剑","desc":"将剑意凝于一点，施展稳定而凌厉的斩击。","effect":"strike","power":1.92,"cooldown":1,"value":0},
	"demon_teach": {"name":"白骨焚心咒","desc":"阴火附骨，令敌人持续灼烧。","effect":"burn","power":0.88,"cooldown":2,"value":5},
	"river_god": {"name":"沧河缚龙索","desc":"水脉化索缠住敌身，有机会封住其行动。","effect":"bind","power":1.12,"cooldown":3,"value":0.84},
	"sect_gate": {"name":"青岚问剑诀","desc":"以宗门基础剑阵连斩三式，专破灵兽护甲。","effect":"pierce","power":1.48,"cooldown":1,"value":4},
	"mortal_lamplight": {"name":"灯火护命","desc":"以一盏凡灯引来护身灵光，替队伍抵挡下一击。","effect":"ward","power":0.68,"cooldown":2,"value":10},
	"blood_moon": {"name":"血月噬心掌","desc":"以血煞掌力夺取敌方生机，反哺自身。","effect":"leech","power":1.58,"cooldown":2,"value":0.24},
	"familiar_stranger": {"name":"温脉回春手","desc":"医者以温和灵息修复伤势，同时以药劲反制敌人。","effect":"heal","power":0.74,"cooldown":2,"value":0.17},
	"moon_well": {"name":"井月凝神诀","desc":"借井中月华澄澈识海，恢复灵力并造成神念冲击。","effect":"restore","power":0.96,"cooldown":2,"value":0.30},
	"old_debt": {"name":"万宝追债符","desc":"以商会追索灵符锁定敌人，削弱其护体防御。","effect":"mark","power":1.22,"cooldown":2,"value":6},
	"ghost_house": {"name":"并蒂索魂绣","desc":"红线穿影，缠缚敌魂并阻碍其攻势。","effect":"bind","power":1.06,"cooldown":3,"value":0.76},
	"furnace_crisis": {"name":"百炼炉心火","desc":"将丹炉真火化作火线，灼伤敌人经脉。","effect":"burn","power":1.36,"cooldown":2,"value":6},
	"leaf_crossing": {"name":"乌篷破浪式","desc":"船桨化作水刃，绕开正面防御斩击敌人。","effect":"pierce","power":1.44,"cooldown":1,"value":3},
	"mortal_king": {"name":"龙庭敕令","desc":"帝王气运化作无形威压，压低敌方攻势。","effect":"suppress","power":0.72,"cooldown":3,"value":5},
	"butterfly_dream": {"name":"庄周梦蝶","desc":"以真假梦境扰乱敌人神识，使其短暂失去攻势。","effect":"confuse","power":1.03,"cooldown":3,"value":0.58},
	"past_enemy": {"name":"宿仇追命剑","desc":"剑招专取破绽，目标越虚弱，斩杀威力越强。","effect":"execute","power":1.32,"cooldown":2,"value":0.92},
	"dying_immortal": {"name":"残仙焚命印","desc":"燃烧残存仙元打出一次高额爆发。","effect":"nova","power":2.48,"cooldown":4,"value":0},
	"epic_bloody_scholar": {"name":"血书破阵笔","desc":"以血为墨写下破阵符，穿透敌方护体。","effect":"pierce","power":1.66,"cooldown":2,"value":7},
	"epic_demon_saintess": {"name":"红绡摄魂舞","desc":"魔宗秘舞扰动敌心，持续削弱其战力。","effect":"curse","power":1.08,"cooldown":3,"value":5},
	"epic_ancient_sword_cave": {"name":"七剑归墟","desc":"七柄残剑依次落下，对敌人造成连续重创。","effect":"strike","power":2.16,"cooldown":3,"value":0},
	"epic_black_market": {"name":"金算盘锁运","desc":"以因果算盘标记敌人，令其防御出现破绽。","effect":"mark","power":1.32,"cooldown":2,"value":8},
	"epic_mysterious_elder": {"name":"青木长生诀","desc":"古树生机滋养队伍，并以根须绊住敌人。","effect":"heal","power":0.82,"cooldown":2,"value":0.20},
	"new_painted_skin": {"name":"画骨剥皮术","desc":"以画皮妖纹侵蚀敌身，留下难以祛除的毒痕。","effect":"poison","power":1.12,"cooldown":2,"value":5},
	"new_ferryman": {"name":"忘川渡魂篙","desc":"一篙点落忘川水意，打断敌方气机。","effect":"bind","power":1.28,"cooldown":3,"value":0.88},
	"new_fate_pavilion": {"name":"星盘逆演","desc":"推演敌招之后再出手，攻击其最薄弱处。","effect":"foresee","power":1.18,"cooldown":2,"value":0.28},
	"new_dragon_palace": {"name":"青龙覆海印","desc":"龙宫水印化作潮头，压制敌人并造成伤害。","effect":"suppress","power":1.24,"cooldown":2,"value":6},
	"new_peach_grove": {"name":"桃华回生咒","desc":"桃木灵华治愈队伍，令气血与伤势恢复。","effect":"cleanse","power":0.46,"cooldown":3,"value":0.16},
	"new_puppet_troupe": {"name":"提线夺魄","desc":"十指灵线牵动敌身，使其行动受制。","effect":"bind","power":0.94,"cooldown":2,"value":0.82},
	"new_monk_passing": {"name":"枯荣金钟","desc":"禅音化钟护住队伍，并震荡敌方经脉。","effect":"ward","power":1.02,"cooldown":3,"value":13},
	"new_red_thread": {"name":"三生红线结","desc":"红线牵起同伴心念，恢复气血与灵力。","effect":"bond","power":0.52,"cooldown":3,"value":0.12},
	"new2_withered_temple": {"name":"枯荣寂灭掌","desc":"一掌令生机枯荣倒转，伤敌并汲取灵力。","effect":"leech","power":1.48,"cooldown":2,"value":0.18},
	"new2_dream_seller": {"name":"梦市迷魂笛","desc":"笛声将敌人拖入梦境，扰乱其攻势。","effect":"confuse","power":1.10,"cooldown":3,"value":0.66},
	"new2_old_general": {"name":"镇北破军枪","desc":"老将以军阵枪势冲锋，破甲并护住阵脚。","effect":"charge","power":1.72,"cooldown":2,"value":8},
	"new2_thunder_clerk": {"name":"雷部天罚令","desc":"雷部符令引下天雷，有机会打断敌方行动。","effect":"thunder","power":1.62,"cooldown":3,"value":0.78},
	"new2_embroidery": {"name":"金丝缚影针","desc":"金丝刺入影中，削弱防御并持续牵制。","effect":"thread","power":1.02,"cooldown":2,"value":4},
	"new2_failed_tribulation": {"name":"焦雷残躯","desc":"以渡劫残留雷火反噬敌人，代价沉重而威力强大。","effect":"nova","power":2.18,"cooldown":4,"value":0},
	"new2_failed_scholar": {"name":"砚中藏锋","desc":"落笔计算敌招，精准击中其防御空隙。","effect":"strategy","power":1.46,"cooldown":2,"value":0.34},
	"treasure_no_face": {"name":"无相断音","desc":"抹去自身气息后出手，令敌人难以组织反击。","effect":"silence","power":1.18,"cooldown":2,"value":6},
	"treasure_reincarnation_debt": {"name":"轮回偿愿帖","desc":"以旧愿抵消新劫，修复队伍伤势并削弱敌人。","effect":"cleanse","power":0.70,"cooldown":3,"value":0.22},
	"treasure_old_god_eye": {"name":"古神凝视","desc":"残瞳凝视神魂，令敌人畏惧并降低攻势。","effect":"gaze","power":1.38,"cooldown":3,"value":7}
}


static func companion_skill_profile(npc: Dictionary) -> Dictionary:
	var profile_id := String(npc.get("event_id", ""))
	var profile: Dictionary = SKILL_PROFILES.get(profile_id, {}).duplicate(true)
	if profile.is_empty():
		var npc_name := String(npc.get("name", "无名伙伴"))
		profile = {
			"name": npc_name + "·本命绝技",
			"desc": "此人将自身经历融入战技，招式随境界与羁绊成长。",
			"effect": "strike",
			"power": 1.35,
			"cooldown": 2,
			"value": 0
		}
	profile["id"] = profile_id if not profile_id.is_empty() else String(npc.get("name", "unnamed"))
	return profile


static func resolve_companion_support(state: GameState, enemy: Dictionary, rng: RandomNumberGenerator, turn_index: int, max_active: int = 3) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	if int(enemy.get("hp", 0)) <= 0:
		return results
	var candidates: Array[int] = []
	for index in range(state.met_npcs.size()):
		var npc: Dictionary = state.met_npcs[index]
		if bool(npc.get("companion", false)) and bool(npc.get("companion_alive", true)) and int(npc.get("affinity", 0)) >= 10:
			candidates.append(index)
	if candidates.is_empty():
		return results
	# 冷却按真实战斗回合流逝，而不是只有轮到该伙伴时才减少。
	for candidate_index: int in candidates:
		var candidate_npc: Dictionary = state.met_npcs[candidate_index].duplicate(true)
		var candidate_cooldown := maxi(0, int(candidate_npc.get("battle_cooldown", 0)))
		if candidate_cooldown > 0:
			candidate_npc["battle_cooldown"] = candidate_cooldown - 1
			state.met_npcs[candidate_index] = candidate_npc
	var active_count := mini(maxi(1, max_active), candidates.size())
	var start_index := posmod(maxi(0, turn_index - 1) * active_count, candidates.size())
	for slot in range(active_count):
		if int(enemy.get("hp", 0)) <= 0:
			break
		var npc_index := candidates[posmod(start_index + slot, candidates.size())]
		var npc: Dictionary = state.met_npcs[npc_index].duplicate(true)
		var cooldown_left := maxi(0, int(npc.get("battle_cooldown", 0)))
		if cooldown_left > 0:
			continue
		var profile := companion_skill_profile(npc)
		npc["battle_skill_id"] = String(profile.get("id", ""))
		npc["battle_skill"] = String(profile.get("name", "本命绝技"))
		npc["battle_skill_desc"] = String(profile.get("desc", ""))
		var outcome := _cast_companion_skill(state, npc, profile, enemy, rng)
		npc["battle_cooldown"] = maxi(0, int(profile.get("cooldown", 1)))
		npc["support_count"] = int(npc.get("support_count", 0)) + 1
		var old_level := maxi(1, int(npc.get("partner_level", 1)))
		var next_level := old_level
		var bond_exp := int(npc.get("bond_exp", 0)) + 1
		while next_level < 10 and bond_exp >= 2 + next_level * 2:
			bond_exp -= 2 + next_level * 2
			next_level += 1
		npc["bond_exp"] = bond_exp
		npc["partner_level"] = next_level
		var realm_names := ["炼气", "筑基", "金丹", "元婴", "化神", "炼虚", "合体", "大乘", "渡劫"]
		npc["partner_realm"] = realm_names[mini(realm_names.size() - 1, mini(state.realm, int((next_level - 1) / 2)))]
		if next_level > old_level:
			outcome["note"] = String(outcome.get("note", "")) + "；羁绊成长至等级%d" % next_level
		npc["last_battle_note"] = String(outcome.get("note", "施展本命战技"))
		state.met_npcs[npc_index] = npc
		outcome["npc_name"] = String(npc.get("name", "同行伙伴"))
		outcome["skill_name"] = String(profile.get("name", "本命绝技"))
		outcome["partner_level"] = next_level
		results.append(outcome)
	return results


static func _cast_companion_skill(state: GameState, npc: Dictionary, profile: Dictionary, enemy: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var level := maxi(1, int(npc.get("partner_level", 1)))
	var affinity := int(npc.get("affinity", 0))
	var base_damage := maxi(3, 4 + state.realm * 2 + level * 3 + int(affinity / 25))
	var power := float(profile.get("power", 1.0))
	var defense := maxi(0, int(enemy.get("defense", 0)) - int(enemy.get("defense_down", 0)))
	var damage := maxi(1, int(round(float(base_damage) * power)) - defense)
	var note := String(profile.get("desc", "伙伴施展本命战技。"))
	var effect := String(profile.get("effect", "strike"))
	var value := float(profile.get("value", 0))
	var healed := 0
	var restored_mp := 0
	var stunned := false
	match effect:
		"strike":
			pass
		"pierce":
			enemy["defense_down"] = maxi(int(enemy.get("defense_down", 0)), int(value) + level)
			enemy["defense_down_turns"] = maxi(int(enemy.get("defense_down_turns", 0)), 2)
			note += "，破甲%d点" % (int(value) + level)
		"poison", "burn":
			var key := "poison" if effect == "poison" else "burn"
			enemy[key] = maxi(int(enemy.get(key, 0)), int(value) + level)
			enemy[key + "_turns"] = maxi(int(enemy.get(key + "_turns", 0)), 2 + int(level / 3))
			note += "，附加%s持续伤害" % ("毒蚀" if effect == "poison" else "灼烧")
			damage = maxi(1, int(round(float(damage) * 0.62)))
		"bind", "thunder":
			var chance := clampf(value + float(level) * 0.015, 0.55, 0.94)
			stunned = rng.randf() < chance
			if stunned:
				enemy["stun_turns"] = maxi(int(enemy.get("stun_turns", 0)), 1)
				note += "，封锁敌人行动"
			else:
				enemy["attack"] = maxi(1, int(enemy.get("attack", 1)) - 1 - int(level / 3))
				note += "，扰乱敌方气机"
		"heal", "cleanse":
			var heal_ratio := clampf(value, 0.05, 0.35)
			healed = mini(state.max_hp() - state.hp, maxi(1, int(round(float(state.max_hp()) * heal_ratio))))
			state.hp += healed
			if effect == "cleanse":
				var cleared := mini(state.injury, maxi(1, int(round(value * 35.0))))
				state.injury -= cleared
				note += "，恢复气血%d并疗愈伤势%d" % [healed, cleared]
			else:
				note += "，恢复气血%d" % healed
			damage = maxi(1, int(round(float(damage) * float(profile.get("power", 1.0)) * 0.30)))
		"restore":
			restored_mp = mini(state.max_mp() - state.mp, maxi(1, int(round(float(state.max_mp()) * clampf(value, 0.08, 0.45)))))
			state.mp += restored_mp
			note += "，恢复灵力%d" % restored_mp
			damage = maxi(1, int(round(float(damage) * 0.70)))
		"ward":
			var guard := maxi(4, int(round(float(base_damage) * value)))
			state.flags["companion_guard"] = maxi(int(state.flags.get("companion_guard", 0)), guard)
			note += "，凝成护阵，可抵挡下一次攻击%d点" % guard
		"suppress", "curse", "silence", "gaze":
			var reduction := maxi(1, int(value) + int(level / 3))
			enemy["attack"] = maxi(1, int(enemy.get("attack", 1)) - reduction)
			if effect == "curse":
				enemy["defense_down"] = maxi(int(enemy.get("defense_down", 0)), maxi(1, int(value / 2)))
				enemy["defense_down_turns"] = maxi(int(enemy.get("defense_down_turns", 0)), 2)
			note += "，敌方攻击降低%d" % reduction
		"execute":
			var ratio := clampf(float(enemy.get("hp", 0)) / maxf(1.0, float(enemy.get("max_hp", 1))), 0.0, 1.0)
			damage = int(round(float(damage) * (1.0 + (1.0 - ratio) * value)))
			note += "，追击伤害随敌方气血降低而提高"
		"leech", "drain":
			healed = mini(state.max_hp() - state.hp, maxi(0, int(round(float(damage) * value))))
			state.hp += healed
			if effect == "drain":
				restored_mp = mini(state.max_mp() - state.mp, maxi(1, int(round(float(state.max_mp()) * 0.10))))
				state.mp += restored_mp
				note += "，汲取气血%d、灵力%d" % [healed, restored_mp]
			else:
				note += "，汲取气血%d" % healed
		"focus", "foresee", "strategy":
			var bonus := float(state.effective_stat("insight")) / 100.0
			if effect == "foresee":
				bonus += float(state.effective_stat("luck")) / 180.0
			elif effect == "strategy":
				bonus += float(state.effective_stat("insight")) / 160.0
				defense = int(round(float(defense) * 0.35))
			damage = maxi(1, int(round(float(base_damage) * power * (1.0 + bonus) - float(defense))))
			note += "，洞察破绽造成额外伤害"
		"confuse":
			enemy["attack"] = maxi(1, int(enemy.get("attack", 1)) - maxi(2, int(value) + int(level / 2)))
			stunned = rng.randf() < clampf(0.35 + float(level) * 0.025, 0.35, 0.80)
			if stunned:
				enemy["stun_turns"] = maxi(int(enemy.get("stun_turns", 0)), 1)
				note += "，敌人陷入迷乱"
		"nova":
			damage = maxi(1, int(round(float(damage) * 1.55)))
			note += "，爆发残存本源"
		"mark", "thread":
			enemy["defense_down"] = maxi(int(enemy.get("defense_down", 0)), int(value) + 1)
			enemy["defense_down_turns"] = maxi(int(enemy.get("defense_down_turns", 0)), 3)
			note += "，留下破绽标记，防御降低%d" % (int(value) + 1)
		"bond":
			healed = mini(state.max_hp() - state.hp, maxi(1, int(round(float(state.max_hp()) * value))))
			state.hp += healed
			restored_mp = mini(state.max_mp() - state.mp, maxi(1, int(round(float(state.max_mp()) * value))))
			state.mp += restored_mp
			note += "，羁绊共鸣恢复气血%d、灵力%d" % [healed, restored_mp]
			damage = maxi(1, int(round(float(damage) * 0.42)))
		"charge":
			enemy["defense_down"] = maxi(int(enemy.get("defense_down", 0)), int(value))
			enemy["defense_down_turns"] = maxi(int(enemy.get("defense_down_turns", 0)), 2)
			state.flags["companion_guard"] = maxi(int(state.flags.get("companion_guard", 0)), maxi(3, int(value / 2)))
			note += "，冲阵破甲并稳住阵脚"
		"debt", "fortune":
			state.stones += maxi(1, int(value))
			note += "，趁势收拢灵石%d" % maxi(1, int(value))
		_:
			pass
	damage = mini(maxi(0, damage), maxi(0, int(enemy.get("hp", 0))))
	if damage > 0:
		enemy["hp"] = maxi(0, int(enemy.get("hp", 0)) - damage)
	npc["last_battle_note"] = note
	return {
		"damage": damage,
		"healed": healed,
		"restored_mp": restored_mp,
		"stunned": stunned,
		"note": note
	}


static func resolve_turn(state: GameState, enemy: Dictionary, rng: RandomNumberGenerator, turn_index: int) -> Dictionary:
	var companions := resolve_companion_support(state, enemy, rng, turn_index, 3)
	var pet_result: Dictionary = {}
	if int(enemy.get("hp", 0)) > 0:
		var pet_damage := state.pet_battle_strike(enemy, rng)
		if pet_damage > 0:
			var pet := state.active_pet()
			pet_result = {
				"damage": pet_damage,
				"name": String(pet.get("name", "灵宠")),
				"move": String(pet.get("last_skill", "协击")),
				"form": String(pet.get("form", "灵兽形态"))
			}
	return {"companions": companions, "pet": pet_result}
