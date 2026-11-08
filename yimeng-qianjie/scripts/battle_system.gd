class_name BattleSystem
extends RefCounted

## 纯文字回合制战斗规则。战斗数据由 Main 管理，规则集中在此处。

static func create_enemy(realm: int, rng: RandomNumberGenerator) -> Dictionary:
	var pool: Array[Dictionary] = [
		{"name":"山野妖狼","kind":"妖兽","desc":"受灵气滋养的妖狼，獠牙间泛着腥红寒光。","hp":48,"attack":8,"defense":1,"stones":12,"cultivation":18},
		{"name":"铁背苍熊","kind":"妖兽","desc":"背生铁甲般的硬毛，步履沉重，力大无穷。","hp":112,"attack":13,"defense":6,"stones":28,"cultivation":30},
		{"name":"噬灵藤妖","kind":"精怪","desc":"藤蔓破土而出，枝叶间流转幽绿妖光。","hp":82,"attack":12,"defense":3,"stones":35,"cultivation":35},
		{"name":"赤焰蝎王","kind":"妖兽","desc":"甲壳赤红如炭，尾针凝聚灼热毒火。","hp":96,"attack":17,"defense":4,"stones":42,"cultivation":42},
		{"name":"山魈妖将","kind":"精英","desc":"山雾中走出高大妖物，胸口护着暗红妖核。","hp":125,"attack":16,"defense":5,"stones":48,"cultivation":48},
		{"name":"拦路散修","kind":"散修","desc":"衣衫旧得发白，手中短刀却磨得锋利。","hp":58,"attack":10,"defense":2,"stones":20,"cultivation":22},
		{"name":"夺宝邪修","kind":"邪修","desc":"周身黑雾翻涌，显然惯于杀人夺宝。","hp":88,"attack":15,"defense":3,"stones":55,"cultivation":40},
		{"name":"血衣魔修","kind":"魔修","desc":"血色灵力缠绕双臂，眼中满是疯狂。","hp":118,"attack":19,"defense":4,"stones":72,"cultivation":58},
		{"name":"叛门弟子","kind":"敌对弟子","desc":"身着残破宗门服饰，招式仍有章法。","hp":76,"attack":13,"defense":4,"stones":32,"cultivation":32},
		{"name":"巡山执法使","kind":"敌对修士","desc":"奉命镇守山道，灵器上刻着禁制符文。","hp":138,"attack":18,"defense":7,"stones":65,"cultivation":60},
		{"name":"古墓阴兵","kind":"亡灵","desc":"腐朽甲胄中燃着幽蓝魂火，不知疲倦。","hp":105,"attack":14,"defense":6,"stones":40,"cultivation":48},
		{"name":"秘境石傀","kind":"秘境守卫","desc":"石躯刻满古老阵纹，行动迟缓却坚不可摧。","hp":175,"attack":17,"defense":11,"stones":90,"cultivation":75},
		{"name":"寒潭蛟影","kind":"精英妖兽","desc":"寒气凝成鳞甲，蛟尾扫过便卷起冰刃。","hp":190,"attack":23,"defense":8,"stones":110,"cultivation":95},
		{"name":"赤霄剑宗长老","kind":"宗门强敌","desc":"剑意如虹，举手投足间皆有凌厉锋芒。","hp":220,"attack":26,"defense":10,"stones":150,"cultivation":120}
	]
	var eligible: Array[Dictionary] = []
	var tier_limit := mini(pool.size(), 5 + maxi(0, realm) * 2)
	for i in range(tier_limit):
		eligible.append(pool[i])
	var enemy: Dictionary = eligible[rng.randi_range(0, eligible.size() - 1)].duplicate(true)
	var scale := 1.0 + float(maxi(0, realm)) * 0.19
	enemy["max_hp"] = int(round(float(enemy["hp"]) * scale))
	enemy["hp"] = int(enemy["max_hp"])
	enemy["attack"] = int(round(float(enemy["attack"]) * (1.0 + float(maxi(0, realm)) * 0.13)))
	enemy["defense"] = int(enemy["defense"]) + int(realm / 5)
	enemy["stones"] = int(round(float(enemy["stones"]) * scale))
	enemy["cultivation"] = int(round(float(enemy["cultivation"]) * scale))
	# 精英变异：同一种敌人也可能拥有不同战斗强度与掉落收益。
	if rng.randf() < 0.20:
		var affixes: Array[Dictionary] = [
			{"prefix":"嗜血","hp":1.12,"attack":1.22,"defense":0,"reward":1.35,"desc":"攻击更强，战利品也更丰厚。"},
			{"prefix":"玄甲","hp":1.35,"attack":1.05,"defense":3,"reward":1.30,"desc":"身披异化甲壳，防御大幅提高。"},
			{"prefix":"迅影","hp":0.92,"attack":1.32,"defense":1,"reward":1.28,"desc":"身法迅疾，出手凌厉。"},
			{"prefix":"噬魂","hp":1.08,"attack":1.18,"defense":2,"reward":1.45,"desc":"魂火缠身，灵压令人心悸。"}
		]
		var affix: Dictionary = affixes[rng.randi_range(0, affixes.size() - 1)]
		enemy["name"] = String(affix["prefix"]) + String(enemy["name"])
		enemy["desc"] = String(enemy.get("desc", "")) + String(affix["desc"])
		enemy["max_hp"] = maxi(1, int(round(float(enemy["max_hp"]) * float(affix["hp"]))))
		enemy["hp"] = enemy["max_hp"]
		enemy["attack"] = maxi(1, int(round(float(enemy["attack"]) * float(affix["attack"]))))
		enemy["defense"] = int(enemy["defense"]) + int(affix["defense"])
		enemy["stones"] = int(round(float(enemy["stones"]) * float(affix["reward"])))
		enemy["cultivation"] = int(round(float(enemy["cultivation"]) * float(affix["reward"])))
		enemy["elite"] = true
	# 首批具备独立阶段机制的首领。
	var base_name := String(enemy.get("name", ""))
	enemy["boss"] = base_name.contains("秘境石傀") or base_name.contains("寒潭蛟影") or base_name.contains("赤霄剑宗长老")
	if bool(enemy.get("boss", false)):
		enemy["boss_phase"] = 1
		enemy["boss_phase_two_done"] = false
		enemy["boss_phase_three_done"] = false
		enemy["boss_telegraph"] = ""
		enemy["boss_adds_turns"] = 0
	return enemy


static func tick_enemy_status(enemy: Dictionary) -> Dictionary:
	var damage: int = 0
	var notes: Array[String] = []
	# 显式声明状态键为 String，避免 Variant 拼接导致 Godot 无法推断类型。
	for status_key: String in ["poison", "burn"]:
		var turns_key: String = status_key + "_turns"
		var turns: int = maxi(0, int(enemy.get(turns_key, 0)))
		if turns > 0:
			var tick: int = maxi(0, int(enemy.get(status_key, 0)))
			damage += tick
			enemy[turns_key] = turns - 1
			if tick > 0:
				var status_name: String = "毒素" if status_key == "poison" else "灼烧"
				notes.append(status_name + "造成%d点伤害" % tick)
			if turns == 1:
				# 持续回合耗尽后清除伤害值，避免残留状态被后续逻辑误用。
				enemy[status_key] = 0
	var defense_turns: int = maxi(0, int(enemy.get("defense_down_turns", 0)))
	if defense_turns > 0:
		defense_turns -= 1
		enemy["defense_down_turns"] = defense_turns
		if defense_turns == 0:
			enemy["defense_down"] = 0
	var stun_turns: int = maxi(0, int(enemy.get("stun_turns", 0)))
	var stunned: bool = stun_turns > 0
	if stunned:
		enemy["stun_turns"] = stun_turns - 1
		notes.append("敌人行动受制")
	if damage > 0:
		enemy["hp"] = maxi(0, int(enemy.get("hp", 0)) - damage)
	return {"damage": damage, "stunned": stunned, "notes": notes}

static func player_attack(state: GameState, enemy: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var base := state.attack_power()
	var critical := rng.randf() < state.critical_rate()
	var damage := maxi(1, base - int(enemy.get("defense", 0)) + rng.randi_range(-2, 3))
	if critical:
		damage = int(round(float(damage) * 1.7))
	enemy["hp"] = maxi(0, int(enemy.get("hp", 0)) - damage)
	state.gain_equipped_method_mastery(3)
	return {"damage": damage, "critical": critical}

static func skill_attack(state: GameState, enemy: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var cost := 12
	if state.mp < cost:
		return {"ok": false, "message": "灵力不足，无法施展引气剑诀。"}
	state.mp -= cost
	var base := 18 + int(state.effective_stat("insight") * 0.85) + state.realm * 3
	var damage := maxi(1, int(round(float(base) * (1.0 + state.skill_power_bonus()))) - int(enemy.get("defense", 0)))
	if rng.randf() < 0.08:
		damage = int(round(float(damage) * 1.5))
		enemy["hp"] = maxi(0, int(enemy.get("hp", 0)) - damage)
		return {"ok": true, "damage": damage, "message": "你并指引气，剑芒破空而出，灵光暴涨！"}
	enemy["hp"] = maxi(0, int(enemy.get("hp", 0)) - damage)
	return {"ok": true, "damage": damage, "message": "你运转引气剑诀，一道凝练剑气直取敌身。"}

static func enemy_turn(state: GameState, enemy: Dictionary, defending: bool, rng: RandomNumberGenerator) -> Dictionary:
	## 敌人会按种族与战斗风格选择招式；精英敌人的技能倾向更明显。
	var name := String(enemy.get("name", "敌人"))
	var style := String(enemy.get("ai_style", ""))
	if style.is_empty():
		if name.contains("狼") or name.contains("迅影"):
			style = "assault"
		elif name.contains("熊") or name.contains("傀") or name.contains("玄甲"):
			style = "brute"
		elif name.contains("藤") or name.contains("蝎") or name.contains("毒"):
			style = "poison"
		elif name.contains("邪修") or name.contains("魔修") or name.contains("血"):
			style = "drain"
		elif name.contains("剑") or name.contains("执法") or name.contains("弟子"):
			style = "technique"
		elif name.contains("阴兵") or name.contains("魂") or name.contains("噬魂"):
			style = "soul"
		else:
			style = "balanced"
	# 首领阶段转换：阈值只触发一次，并给玩家一个观察与应对的回合。
	if bool(enemy.get("boss", false)):
		var phase_hp_ratio := float(enemy.get("hp", 1)) / maxf(1.0, float(enemy.get("max_hp", 1)))
		if phase_hp_ratio <= 0.70 and not bool(enemy.get("boss_phase_two_done", false)):
			enemy["boss_phase_two_done"] = true
			enemy["boss_phase"] = 2
			enemy["boss_adds_turns"] = 3
			return {"damage": 0, "target": "none", "action": "召唤援兵", "note": name + "仰天长啸，召来妖影/护卫助阵！接下来两回合攻势增强。", "phase_change": true}
		var pending_telegraph := String(enemy.get("boss_telegraph", ""))
		if not pending_telegraph.is_empty():
			enemy["boss_telegraph"] = ""
			var telegraph_attack := int(enemy.get("attack", 5))
			enemy["attack"] = maxi(1, int(round(float(telegraph_attack) * 2.05)))
			var charged := enemy_attack(state, enemy, defending, rng)
			enemy["attack"] = telegraph_attack
			charged["action"] = "首领蓄力重击"
			charged["note"] = name + "引动全身灵力，蓄势已久的杀招轰然落下！"
			return charged
		var telegraph_chance := 0.22 if int(enemy.get("boss_phase", 1)) == 1 else 0.34
		if bool(enemy.get("boss_enraged", false)):
			telegraph_chance = 0.42
		if rng.randf() < telegraph_chance:
			enemy["boss_telegraph"] = "heavy"
			return {"damage": 0, "target": "none", "action": "首领蓄势", "note": name + "灵力汇聚于一点，正在准备强力杀招！下回合将发动重击，及时防御或打断。", "telegraph": true}
		if int(enemy.get("boss_adds_turns", 0)) > 0:
			enemy["boss_adds_turns"] = int(enemy.get("boss_adds_turns", 0)) - 1
		if phase_hp_ratio <= 0.35 and not bool(enemy.get("boss_phase_three_done", false)):
			enemy["boss_phase_three_done"] = true
			enemy["boss_phase"] = 3
			enemy["boss_enraged"] = true
			return {"damage": 0, "target": "none", "action": "首领狂暴", "note": name + "气息骤然暴涨，进入狂暴阶段！攻击大幅提升，出招更加频繁。", "phase_change": true}
	var cooldown := maxi(0, int(enemy.get("ai_cooldown", 0)))
	if cooldown > 0:
		enemy["ai_cooldown"] = cooldown - 1
		var basic := enemy_attack(state, enemy, defending, rng)
		basic["action"] = "普通攻击"
		return basic
	var hp_ratio := float(enemy.get("hp", 1)) / maxf(1.0, float(enemy.get("max_hp", 1)))
	var skill_chance := 0.42 if bool(enemy.get("elite", false)) else 0.28
	if hp_ratio < 0.35:
		skill_chance += 0.16
	if rng.randf() >= skill_chance:
		var basic := enemy_attack(state, enemy, defending, rng)
		basic["action"] = "普通攻击"
		return basic
	var skill_name := "灵压冲击"
	var note := ""
	var attack_scale := 1.0
	match style:
		"assault":
			skill_name = "裂风连袭"
			attack_scale = 1.48
			note = "身形骤然化作残影，连续扑杀！"
		"brute":
			skill_name = "崩山重击"
			attack_scale = 1.75
			note = "沉重身躯蓄力砸下，地面随之震裂！"
		"poison":
			skill_name = "蚀脉毒击"
			attack_scale = 1.22
			note = "毒针/妖藤裹挟阴毒灵力袭来！"
		"drain":
			skill_name = "噬灵邪术"
			attack_scale = 1.18
			note = "黑色灵力侵入经脉，试图吞噬你的灵力！"
		"technique":
			skill_name = "破势剑诀"
			attack_scale = 1.42
			note = "对手踏罡运剑，剑锋直取招式破绽！"
		"soul":
			skill_name = "摄魂鬼啸"
			attack_scale = 1.12
			note = "凄厉鬼啸直刺识海，神魂为之一震！"
		_:
			skill_name = "妖灵震荡"
			attack_scale = 1.32
			note = "敌人催动体内妖力，爆发出凶猛一击！"
	# 重击通过临时调整攻击力复用原有闪避、格挡、灵宠护主逻辑。
	var original_attack := int(enemy.get("attack", 5))
	if bool(enemy.get("boss", false)):
		if bool(enemy.get("boss_enraged", false)):
			attack_scale *= 1.30
		elif int(enemy.get("boss_adds_turns", 0)) > 0:
			attack_scale *= 1.15
	enemy["attack"] = maxi(1, int(round(float(original_attack) * attack_scale)))
	var result := enemy_attack(state, enemy, defending, rng)
	enemy["attack"] = original_attack
	result["action"] = skill_name
	result["note"] = note
	if String(result.get("target", "player")) == "player" and int(result.get("damage", 0)) > 0:
		if style == "poison":
			state.injury = mini(100, state.injury + 1)
			result["note"] = note + "，毒劲侵体，伤势加重"
		elif style == "drain":
			var drained := mini(state.mp, maxi(2, int(round(float(state.max_mp()) * 0.08))))
			state.mp -= drained
			result["note"] = note + "，被夺去%d点灵力" % drained
		elif style == "soul":
			var drained := mini(state.mp, maxi(2, int(round(float(state.max_mp()) * 0.06))))
			state.mp -= drained
			result["note"] = note + "，神魂震荡，灵力损失%d" % drained
	enemy["ai_cooldown"] = 1 if style in ["assault", "poison"] or (bool(enemy.get("boss", false)) and bool(enemy.get("boss_enraged", false))) else 2
	return result


static func enemy_attack(state: GameState, enemy: Dictionary, defending: bool, rng: RandomNumberGenerator) -> Dictionary:
	var companion := state.active_pet()
	var companion_alive := not companion.is_empty() and int(companion.get("pet_hp", 1)) > 0
	var companion_skills: Array = Array(companion.get("skills", [])) if companion_alive else []
	if rng.randf() < state.evasion_rate():
		return {"damage": 0, "target": "none", "evaded": true}
	var damage := maxi(1, int(enemy.get("attack", 5)) - state.defense_power() + rng.randi_range(-2, 2))
	if defending:
		damage = maxi(1, int(ceil(float(damage) * 0.35)))
	var companion_guard := maxi(0, int(state.flags.get("companion_guard", 0)))
	if companion_guard > 0:
		damage = maxi(1, damage - companion_guard)
		state.flags["companion_guard"] = 0
	# 灵宠会主动护主，也可能被敌人识别为威胁；倒地后不再成为目标。
	var pet_target_chance := 0.30
	if companion_skills.has("灵甲"):
		pet_target_chance = 0.48
	if companion_alive and rng.randf() < pet_target_chance:
		if companion_skills.has("灵甲"):
			damage = maxi(1, int(ceil(float(damage) * 0.80)))
		if int(companion.get("bloodline_stage", 0)) >= 2:
			damage = maxi(1, int(ceil(float(damage) * 0.90)))
		var pet_damage := state.active_pet_take_damage(damage)
		return {"damage": pet_damage, "target": "pet", "evaded": false, "pet_down": int(state.active_pet().get("pet_hp", 0)) <= 0}
	state.hp = maxi(0, state.hp - damage)
	return {"damage": damage, "target": "player", "evaded": false}

## 可学习典籍目录。realm 为最低境界，cost 为学习所需灵石。
const SKILLS := {
	"qi_sword": {"name":"引气剑诀","rank":"黄阶下品","type":"攻击","realm":0,"cost":0,"mp":12,"cooldown":0,"power":1.0,"desc":"凝聚灵气化作剑芒，造成稳定伤害。"},
	"wind_step": {"name":"追风步","rank":"黄阶下品","type":"防御","realm":0,"cost":18,"mp":0,"cooldown":1,"power":0.18,"desc":"调整重心与步幅，侧身卸力避开锋芒；不消耗法力。"},
	"stone_skin": {"name":"磐石护体","rank":"黄阶中品","type":"防御","realm":1,"cost":35,"mp":10,"cooldown":2,"power":0.55,"desc":"灵力覆体，本回合大幅减伤。"},
	"wood_breath": {"name":"青木回春诀","rank":"黄阶上品","type":"恢复","realm":2,"cost":55,"mp":16,"cooldown":3,"power":0.22,"desc":"引木灵滋养经脉，恢复气血。"},
	"frost_needles": {"name":"寒芒针","rank":"黄阶极品","type":"攻击","realm":3,"cost":78,"mp":15,"cooldown":1,"power":1.35,"desc":"凝水成针，连续寒芒穿透敌身。"},
	"flame_burst": {"name":"赤焰指","rank":"玄阶下品","type":"攻击","realm":4,"cost":120,"mp":22,"cooldown":1,"power":1.65,"desc":"凝火为刃，造成高额伤害。"},
	"spirit_gather": {"name":"聚灵术","rank":"玄阶下品","type":"辅助","realm":4,"cost":110,"mp":0,"cooldown":3,"power":0.28,"desc":"调息聚灵，恢复灵力。"},
	"iron_wall": {"name":"玄甲真诀","rank":"玄阶中品","type":"防御","realm":5,"cost":155,"mp":18,"cooldown":2,"power":0.7,"desc":"真元凝甲，抵御强敌攻势。"},
	"soul_heal": {"name":"清心养魂篇","rank":"玄阶中品","type":"恢复","realm":5,"cost":165,"mp":24,"cooldown":3,"power":0.32,"desc":"安定神魂，修复肉身创伤。"},
	"thunder_seal": {"name":"掌心雷","rank":"玄阶上品","type":"攻击","realm":6,"cost":210,"mp":30,"cooldown":2,"power":2.15,"desc":"以雷意轰击敌人，威力强横。"},
	"shadow_blade": {"name":"幻影分光斩","rank":"玄阶极品","type":"攻击","realm":7,"cost":260,"mp":34,"cooldown":1,"power":2.35,"desc":"身化数道幻影，从不同角度斩击。"},
	"azure_dragon": {"name":"青龙吐息","rank":"地阶下品","type":"攻击","realm":8,"cost":330,"mp":42,"cooldown":2,"power":2.7,"desc":"引动青龙之气，吐息化作苍青洪流。"},
	"void_guard": {"name":"虚空护身印","rank":"地阶下品","type":"防御","realm":8,"cost":320,"mp":32,"cooldown":3,"power":0.82,"desc":"借虚空之力偏转来袭攻击。"},
	"phoenix_rebirth": {"name":"涅槃回生诀","rank":"地阶中品","type":"恢复","realm":9,"cost":390,"mp":48,"cooldown":4,"power":0.48,"desc":"以涅槃真火疗愈伤势。"},
	"star_absorb": {"name":"摘星纳元术","rank":"地阶中品","type":"辅助","realm":10,"cost":420,"mp":0,"cooldown":3,"power":0.48,"desc":"牵引星辉入体，快速恢复灵力。"},
	"sword_domain": {"name":"万剑归宗","rank":"地阶上品","type":"攻击","realm":11,"cost":520,"mp":58,"cooldown":2,"power":3.15,"desc":"剑意化作万千剑影，席卷敌阵。"},
	"heaven_thunder": {"name":"九霄神雷","rank":"地阶极品","type":"攻击","realm":12,"cost":680,"mp":70,"cooldown":3,"power":3.8,"desc":"引九霄雷霆降世，威震邪魔。"},
	"immortal_body": {"name":"不灭金身","rank":"天阶下品","type":"防御","realm":13,"cost":820,"mp":62,"cooldown":3,"power":0.92,"desc":"凝练不灭道躯，护体真元坚不可摧。"},
	"life_spring": {"name":"造化生生篇","rank":"天阶中品","type":"恢复","realm":14,"cost":980,"mp":78,"cooldown":4,"power":0.62,"desc":"引造化之力滋养本源，恢复大量气血。"},
	"chaos_refine": {"name":"混沌炼天诀","rank":"天阶上品","type":"攻击","realm":16,"cost":1250,"mp":90,"cooldown":3,"power":4.6,"desc":"演化混沌气旋，炼化眼前强敌。"},
	"dao_origin": {"name":"太初无极经","rank":"天阶极品","type":"辅助","realm":17,"cost":1600,"mp":0,"cooldown":4,"power":0.8,"desc":"返本归元，调动太初灵机恢复灵力。"},
	"venom_mist": {"name":"碧磷毒雾诀","rank":"黄阶极品","type":"控制","realm":2,"cost":72,"mp":16,"cooldown":3,"power":7,"effect":"poison","duration":3,"desc":"散出碧磷毒雾，使敌人连续数回合损失气血。"},
	"ember_brand": {"name":"焚心印","rank":"玄阶下品","type":"控制","realm":4,"cost":135,"mp":22,"cooldown":3,"power":10,"effect":"burn","duration":2,"desc":"以真火烙印敌身，造成持续灼烧。"},
	"frost_seal": {"name":"玄冰封脉","rank":"玄阶中品","type":"控制","realm":5,"cost":175,"mp":25,"cooldown":4,"power":0,"effect":"freeze","duration":1,"desc":"寒气封锁经脉，有机会令敌人一回合无法行动。"},
	"armor_shatter": {"name":"破甲剑诀","rank":"玄阶上品","type":"控制","realm":6,"cost":225,"mp":28,"cooldown":3,"power":3,"effect":"shatter","duration":3,"desc":"剑气专破护体真元，降低敌方防御。"},
	"blood_siphon": {"name":"噬血魔功","rank":"玄阶极品","type":"攻击","realm":7,"cost":290,"mp":38,"cooldown":3,"power":1.65,"lifesteal":0.28,"desc":"攻击敌人的同时汲取部分气血，恢复自身。"},
	"thunder_chain": {"name":"雷锁九幽","rank":"地阶下品","type":"控制","realm":8,"cost":355,"mp":44,"cooldown":4,"power":15,"effect":"stun","duration":1,"desc":"雷链锁敌，造成伤害并有机会打断敌方攻势。"},
	"mirror_body": {"name":"水月镜身","rank":"地阶中品","type":"防御","realm":9,"cost":410,"mp":38,"cooldown":3,"power":0.78,"desc":"凝出镜身抵挡攻击，并反照部分伤害。"},
	"soul_lance": {"name":"裂魂刺","rank":"地阶上品","type":"攻击","realm":11,"cost":550,"mp":60,"cooldown":3,"power":2.9,"desc":"神念凝为无形魂刺，直击敌方识海。"},
	"five_elements": {"name":"五行轮转诀","rank":"地阶极品","type":"辅助","realm":12,"cost":700,"mp":0,"cooldown":4,"power":0.58,"desc":"五行灵气周天轮转，大幅恢复灵力。"},
	"starfall": {"name":"星陨天击","rank":"天阶下品","type":"攻击","realm":13,"cost":850,"mp":72,"cooldown":3,"power":4.0,"desc":"引星辰坠落，造成毁灭性打击。"},
	"immortal_chain": {"name":"长生锁","rank":"天阶中品","type":"控制","realm":14,"cost":1020,"mp":80,"cooldown":4,"power":18,"effect":"stun","duration":2,"desc":"以长生道纹封锁敌人行动。"},
	"world_sunder": {"name":"开天一式","rank":"天阶上品","type":"攻击","realm":16,"cost":1320,"mp":95,"cooldown":4,"power":5.2,"desc":"一式开天，斩断敌方护体灵机。"},
	"eternal_cycle": {"name":"万古轮回诀","rank":"天阶极品","type":"恢复","realm":17,"cost":1750,"mp":88,"cooldown":5,"power":0.85,"desc":"引轮回生机重塑肉身，恢复大量气血。"},
	"iron_fist": {"name":"崩山拳","rank":"黄阶下品","type":"攻击","realm":0,"cost":20,"mp":0,"cooldown":0,"power":1.12,"desc":"沉肩坠肘，以腰胯发力轰出刚猛一拳，纯粹锻体发力。"},
	"mountain_breaker": {"name":"裂石掌","rank":"黄阶中品","type":"攻击","realm":1,"cost":42,"mp":0,"cooldown":1,"power":1.32,"desc":"掌根聚劲，专攻敌方破绽，不借灵力也能震荡筋骨。"},
	"swift_shadow": {"name":"踏影连步","rank":"黄阶上品","type":"攻击","realm":2,"cost":65,"mp":0,"cooldown":1,"power":1.48,"desc":"以步法切入近身，连续变向后迅速打击。"},
	"sweeping_leg": {"name":"横江扫腿","rank":"玄阶下品","type":"攻击","realm":4,"cost":125,"mp":0,"cooldown":2,"power":1.85,"desc":"下盘发力横扫，破坏敌人重心并造成强力钝击。"},
	"tiger_pounce": {"name":"伏虎擒拿","rank":"玄阶中品","type":"防御","realm":5,"cost":160,"mp":0,"cooldown":2,"power":1.25,"desc":"以擒拿卸去来势，再借敌力反制，纯粹近身格斗技。"}
}

## 传统修炼典籍与战斗武技分开管理。旧存档中的 skill_id 保持不变。
const CULTIVATION_METHOD_IDS: Array[String] = [
	"wood_breath", "spirit_gather", "star_absorb", "immortal_body",
	"life_spring", "dao_origin", "five_elements", "eternal_cycle"
]

## 武技只锻炼筋骨、身法与发力，不消耗法力。
const MARTIAL_SKILL_IDS: Array[String] = [
	"wind_step", "iron_fist", "mountain_breaker", "swift_shadow", "sweeping_leg", "tiger_pounce"
]
const DIVINE_SKILL_IDS: Array[String] = [
	"sword_domain", "heaven_thunder",
	"azure_dragon", "thunder_chain", "soul_lance", "chaos_refine",
	"starfall", "immortal_chain", "world_sunder"
]

## 功法传承体系：借鉴传统修仙世界的五行灵根、功法传承、法术神通与炼体神识分支；
## 所有名称、描述与设定均为本作原创，不照搬原著具体文本。
const SKILL_DISCIPLINES := {
	"qi_sword": {"element":"金","discipline":"剑诀","style":"近身剑修","lineage":"庚金剑脉","root_affinity":["金"],"effect_tag":"破锋"},
	"stone_skin": {"element":"土","discipline":"炼体","style":"护体硬功","lineage":"厚土一脉","root_affinity":["土"],"effect_tag":"护体"},
	"wood_breath": {"element":"木","discipline":"木系功法","style":"生机疗愈","lineage":"青木一脉","root_affinity":["木"],"effect_tag":"生息"},
	"frost_needles": {"element":"冰","discipline":"冰系法术","style":"远程穿透","lineage":"寒魄一脉","root_affinity":["冰","水"],"effect_tag":"寒针"},
	"flame_burst": {"element":"火","discipline":"火系法术","style":"爆发灼烧","lineage":"赤炎一脉","root_affinity":["火"],"effect_tag":"焚灼"},
	"spirit_gather": {"element":"无","discipline":"吐纳心法","style":"聚气回灵","lineage":"基础吐纳","root_affinity":[],"effect_tag":"纳气"},
	"iron_wall": {"element":"金","discipline":"炼体功法","style":"真元护甲","lineage":"玄甲一脉","root_affinity":["金","土"],"effect_tag":"铁壁"},
	"soul_heal": {"element":"木","discipline":"神识秘法","style":"安魂疗伤","lineage":"清心一脉","root_affinity":["木"],"effect_tag":"养魂"},
	"thunder_seal": {"element":"雷","discipline":"雷系法术","style":"单体爆发","lineage":"天雷一脉","root_affinity":["雷"],"effect_tag":"雷击"},
	"shadow_blade": {"element":"风","discipline":"幻影剑诀","style":"高速连斩","lineage":"幻锋一脉","root_affinity":["风","金"],"effect_tag":"残影"},
	"azure_dragon": {"element":"木","discipline":"木系神通","style":"范围吐息","lineage":"苍木龙脉","root_affinity":["木","水"],"effect_tag":"龙息"},
	"void_guard": {"element":"空间","discipline":"空间秘术","style":"偏转防御","lineage":"虚空一脉","root_affinity":[],"effect_tag":"偏空"},
	"phoenix_rebirth": {"element":"火","discipline":"火系疗法","style":"涅槃恢复","lineage":"离火一脉","root_affinity":["火"],"effect_tag":"涅槃"},
	"star_absorb": {"element":"星辰","discipline":"星象功法","style":"吸纳星辉","lineage":"观星一脉","root_affinity":[],"effect_tag":"引星"},
	"sword_domain": {"element":"金","discipline":"剑道神通","style":"群体剑阵","lineage":"万剑一脉","root_affinity":["金"],"effect_tag":"剑域"},
	"heaven_thunder": {"element":"雷","discipline":"雷道神通","style":"天雷轰击","lineage":"九霄雷脉","root_affinity":["雷"],"effect_tag":"天罚"},
	"immortal_body": {"element":"土","discipline":"炼体秘典","style":"金身防御","lineage":"不坏体脉","root_affinity":["土","金"],"effect_tag":"金身"},
	"life_spring": {"element":"木","discipline":"造化功法","style":"本源恢复","lineage":"长生木脉","root_affinity":["木"],"effect_tag":"造化"},
	"chaos_refine": {"element":"混沌","discipline":"混沌秘术","style":"吞炼爆发","lineage":"太初一脉","root_affinity":[],"effect_tag":"归墟"},
	"dao_origin": {"element":"无","discipline":"本源心法","style":"周天调息","lineage":"太初道统","root_affinity":[],"effect_tag":"归元"},
	"venom_mist": {"element":"毒","discipline":"毒经","style":"持续侵蚀","lineage":"碧磷毒脉","root_affinity":[],"effect_tag":"蚀骨"},
	"ember_brand": {"element":"火","discipline":"火系禁制","style":"持续灼烧","lineage":"焚心一脉","root_affinity":["火"],"effect_tag":"火印"},
	"frost_seal": {"element":"冰","discipline":"冰系禁制","style":"封脉控制","lineage":"玄冰一脉","root_affinity":["冰","水"],"effect_tag":"封脉"},
	"armor_shatter": {"element":"金","discipline":"破甲剑诀","style":"削弱护体","lineage":"裂甲一脉","root_affinity":["金"],"effect_tag":"破甲"},
	"blood_siphon": {"element":"血","discipline":"血道秘术","style":"伤害汲取","lineage":"血煞一脉","root_affinity":[],"effect_tag":"噬血"},
	"thunder_chain": {"element":"雷","discipline":"雷系禁术","style":"雷锁控制","lineage":"伏雷一脉","root_affinity":["雷"],"effect_tag":"雷缚"},
	"mirror_body": {"element":"水","discipline":"水系幻术","style":"镜身反击","lineage":"水月一脉","root_affinity":["水"],"effect_tag":"镜返"},
	"soul_lance": {"element":"神识","discipline":"神识攻击","style":"识海穿刺","lineage":"凝神一脉","root_affinity":[],"effect_tag":"裂魂"},
	"five_elements": {"element":"五行","discipline":"五行周天功","style":"五行调和","lineage":"五行道统","root_affinity":["金","木","水","火","土"],"effect_tag":"轮转"},
	"starfall": {"element":"星辰","discipline":"星辰法术","style":"陨星重击","lineage":"天星一脉","root_affinity":[],"effect_tag":"星陨"},
	"immortal_chain": {"element":"空间","discipline":"封禁秘术","style":"束缚镇压","lineage":"长生禁脉","root_affinity":[],"effect_tag":"镇封"},
	"world_sunder": {"element":"金","discipline":"斩道剑诀","style":"极限破防","lineage":"开天剑脉","root_affinity":["金"],"effect_tag":"断界"},
	"eternal_cycle": {"element":"木","discipline":"轮回疗法","style":"气血重塑","lineage":"轮回一脉","root_affinity":["木"],"effect_tag":"轮回"},
	"wind_step": {"element":"无","discipline":"轻身步法","style":"闪避卸力","lineage":"凡俗身法","root_affinity":[],"effect_tag":"轻身"},
	"iron_fist": {"element":"无","discipline":"拳法","style":"刚猛近战","lineage":"外家拳宗","root_affinity":[],"effect_tag":"崩劲"},
	"mountain_breaker": {"element":"无","discipline":"掌法","style":"破防重击","lineage":"碎岳掌脉","root_affinity":[],"effect_tag":"裂石"},
	"swift_shadow": {"element":"无","discipline":"步法","style":"迅捷连击","lineage":"游侠一脉","root_affinity":[],"effect_tag":"踏影"},
	"sweeping_leg": {"element":"无","discipline":"腿法","style":"下盘扫击","lineage":"横江腿门","root_affinity":[],"effect_tag":"扫堂"},
	"tiger_pounce": {"element":"无","discipline":"擒拿术","style":"卸力反制","lineage":"伏虎武馆","root_affinity":[],"effect_tag":"擒制"}
}

static func mastery_info(experience: int) -> Dictionary:
	var xp := clampi(experience, 0, 1400)
	var thresholds: Array[int] = [0, 100, 300, 700, 1400]
	var names: Array[String] = ["入门", "熟练", "精通", "大成", "圆满"]
	var stage := 0
	for i in range(thresholds.size()):
		if xp >= thresholds[i]:
			stage = i
	var next_xp := 1400 if stage >= 4 else thresholds[stage + 1]
	var current_xp := thresholds[stage]
	return {
		"stage": stage,
		"name": names[stage],
		"xp": xp,
		"next_xp": next_xp,
		"progress": 1.0 if stage >= 4 else float(xp - current_xp) / float(next_xp - current_xp),
		"power_multiplier": 1.0 + float(stage) * 0.08
	}

static func _record_skill_use(state: GameState, skill_id: String) -> void:
	state.gain_skill_mastery(skill_id, 25)
	state.gain_equipped_method_mastery(5)

static func skill_data(skill_id: String) -> Dictionary:
	var info: Dictionary = SKILLS.get(skill_id, {}).duplicate(true)
	if info.is_empty():
		return info
	info["category"] = "功法" if skill_id in CULTIVATION_METHOD_IDS else ("武技" if skill_id in MARTIAL_SKILL_IDS else ("神通秘术" if skill_id in DIVINE_SKILL_IDS else "法术"))
	var discipline: Dictionary = SKILL_DISCIPLINES.get(skill_id, {})
	for key: Variant in discipline.keys():
		info[String(key)] = discipline[key]
	info["attribute"] = String(discipline.get("element", "无"))
	info["discipline_name"] = String(discipline.get("discipline", "基础术法"))
	return info

static func all_skills() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for skill_id: String in SKILLS.keys():
		var entry: Dictionary = skill_data(skill_id)
		entry["id"] = skill_id
		result.append(entry)
	return result

static func use_skill(skill_id: String, state: GameState, enemy: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var info := skill_data(skill_id)
	if info.is_empty() or not state.learned_skills.has(skill_id) or not state.equipped_martial.has(skill_id):
		return {"ok": false, "message": "尚未学习或装备这门技艺。"}
	var mastery: Dictionary = mastery_info(state.skill_mastery_xp(skill_id))
	var mastery_power := float(mastery.get("power_multiplier", 1.0))
	var cost := int(info.get("mp", 0))
	if state.mp < cost:
		return {"ok": false, "message": "灵力不足，无法施展%s。" % String(info.get("name", "武技"))}
	state.mp -= cost
	var kind := String(info.get("type", "攻击"))
	match kind:
		"攻击":
			var base := (8.0 + float(state.effective_stat("body")) * 0.90 + float(state.realm) * 2.0) if String(info.get("category", "")) == "武技" else (12.0 + float(state.effective_stat("insight")) * 0.72 + float(state.realm) * 3.0)
			var element_bonus := 1.0 if String(info.get("category", "")) == "武技" else _element_affinity_bonus(state, info)
			var damage := maxi(1, int(round(base * float(info.get("power", 1.0)) * mastery_power * (1.0 + state.skill_power_bonus()) * element_bonus)) - maxi(0, int(enemy.get("defense", 0)) - int(enemy.get("defense_down", 0))))
			var critical := rng.randf() < state.critical_rate()
			if critical:
				damage = int(round(float(damage) * 1.5))
			enemy["hp"] = maxi(0, int(enemy.get("hp", 0)) - damage)
			_record_skill_use(state, skill_id)
			var healed := 0
			if float(info.get("lifesteal", 0.0)) > 0.0:
				healed = mini(state.max_hp() - state.hp, int(round(float(damage) * float(info["lifesteal"]))))
				state.hp += healed
			return {"ok": true, "damage": damage, "critical": critical, "healed": healed, "defend": false, "message": "你施展%s" % String(info.get("name", "武技"))}
		"防御":
			_record_skill_use(state, skill_id)
			return {"ok": true, "damage": 0, "critical": false, "defend": true, "reflect": float(info.get("power", 0.0)) * mastery_power * 0.22, "message": "你运转%s，护住周身" % String(info.get("name", "武技"))}
		"控制":
			var effect := String(info.get("effect", "poison"))
			var duration := int(info.get("duration", 2))
			var power := int(info.get("power", 0))
			if effect == "shatter":
				power = int(round(float(power) * mastery_power))
				_record_skill_use(state, skill_id)
				enemy["defense_down"] = maxi(int(enemy.get("defense_down", 0)), power)
				enemy["defense_down_turns"] = duration
				return {"ok": true, "damage": 0, "critical": false, "defend": false, "message": "%s击碎敌方护体，防御降低%d点" % [String(info.get("name", "武技")), power]}
			if effect in ["poison", "burn"]:
				power = maxi(1, int(round(float(power) * mastery_power)))
				_record_skill_use(state, skill_id)
				var status_key := "poison" if effect == "poison" else "burn"
				enemy[status_key] = maxi(int(enemy.get(status_key, 0)), power)
				enemy[status_key + "_turns"] = maxi(int(enemy.get(status_key + "_turns", 0)), duration)
				return {"ok": true, "damage": 0, "critical": false, "defend": false, "message": "%s命中，敌人陷入%s状态" % [String(info.get("name", "武技")), "中毒" if effect == "poison" else "灼烧"]}
			if effect in ["freeze", "stun"]:
				var chance := minf(0.95, (0.72 if effect == "freeze" else 0.82) + float(int(mastery.get("stage", 0)) * 0.03))
				_record_skill_use(state, skill_id)
				var success := rng.randf() < chance
				var impact := maxi(0, power + int(state.realm * 2))
				if impact > 0:
					enemy["hp"] = maxi(0, int(enemy.get("hp", 0)) - impact)
				if success:
					enemy["stun_turns"] = maxi(int(enemy.get("stun_turns", 0)), duration)
				return {"ok": true, "damage": impact, "critical": false, "defend": false, "message": "%s%s" % [String(info.get("name", "武技")), "封住了敌人行动" if success else "未能完全限制敌人"]}
		"恢复":
			var heal := maxi(1, int(round(float(state.max_hp()) * float(info.get("power", 0.2)) * mastery_power)))
			_record_skill_use(state, skill_id)
			var actual := mini(heal, state.max_hp() - state.hp)
			state.hp += actual
			return {"ok": true, "damage": 0, "critical": false, "defend": false, "message": "%s生效，恢复气血 %d" % [String(info.get("name", "武技")), actual]}
		"辅助":
			var restore := maxi(1, int(round(float(state.max_mp()) * float(info.get("power", 0.2)) * mastery_power)))
			_record_skill_use(state, skill_id)
			var actual_mp := mini(restore, state.max_mp() - state.mp)
			state.mp += actual_mp
			return {"ok": true, "damage": 0, "critical": false, "defend": false, "message": "%s运转，恢复灵力 %d" % [String(info.get("name", "武技")), actual_mp]}
	return {"ok": false, "message": "这门功法暂不支持战斗施展。"}


static func _element_affinity_bonus(state: GameState, info: Dictionary) -> float:
	var element := String(info.get("element", "无"))
	if element in ["无", "空间", "星辰", "混沌", "血", "神识", "五行", "毒"]:
		return 1.0
	var root_elements: Array = Array(state.root.get("elements", []))
	if root_elements.has(element):
		return 1.15
	var affinities: Array = Array(info.get("root_affinity", []))
	for affinity: Variant in affinities:
		if root_elements.has(String(affinity)):
			return 1.08
	return 1.0
