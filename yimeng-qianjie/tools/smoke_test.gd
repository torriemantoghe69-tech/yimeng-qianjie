extends SceneTree

## 轻量化自动回归测试：验证世界推进、伙伴协战与材料经济是否连通。

var rng := RandomNumberGenerator.new()
var failures: int = 0

func _initialize() -> void:
	rng.seed = 424242
	print("== 世界与人物关系 ==")
	_test_world_relationship_integration()
	print("== 伙伴与灵宠协战 ==")
	_test_party_combat_integration()
	print("== 材料与炼化炉火 ==")
	_test_material_economy_integration()
	if failures == 0:
		print("SMOKE TEST PASSED")
	else:
		print("SMOKE TEST FAILED：%d 项失败" % failures)
	quit(failures)

func _check(condition: bool, message: String) -> void:
	if condition:
		print("PASS: %s" % message)
	else:
		failures += 1
		push_error("FAIL: %s" % message)

func _make_soul() -> Dictionary:
	var upgrades: Dictionary = {}
	for upgrade: Dictionary in GameData.UPGRADES:
		upgrades[String(upgrade["id"])] = 0
	return {"points": 0, "lives": 0, "best_realm": 0, "ascensions": 0, "upgrades": upgrades, "chronicle": []}

func _test_world_relationship_integration() -> void:
	var state := GameState.new_life(_make_soul(), rng)
	state.flags["npc_relations"] = {"顾长渊": {"affinity": 12, "intro": "旧存档中的交谈记录"}}
	var record := state.adjust_npc_affinity("顾长渊", 5, "青岚剑宗", "交谈", "你们谈起各自的修行经历。")
	_check(int(record.get("affinity", 0)) == 17, "旧 NPC 关系可迁移到统一人物记录")
	_check(state.met_npcs.size() == 1, "人物关系统一写入 met_npcs")
	_check(int(state.faction_reputation.get("青岚剑宗", 0)) > 0, "与 NPC 交往会影响所属势力声望")
	var profile := {"name": "顾长渊", "event_id": "test_gu_changyuan", "faction": "青岚剑宗"}
	var notes := state.record_npc_choice(profile, {"title": "故人重逢"}, {"text": "坦诚相待", "tone": "good"}, {"result": "对方记住了你的选择", "effects": {}})
	_check(not notes.is_empty(), "事件选择仍可更新 NPC 关系")
	_check(int(state.met_npcs[0].get("affinity", 0)) == 25, "事件选择与日常交往累积同一好感值")
	var loaded := GameState.from_dict(state.to_dict())
	var loaded_record := loaded.npc_relationship_record("顾长渊", "青岚剑宗")
	_check(int(loaded_record.get("affinity", 0)) == 25, "统一人物关系可往返存档")
	var old_year := state.world_year
	state.turn_count = 2
	WorldSimulation.advance(state, 1)
	_check(state.world_year == old_year + 1, "统一世界时钟会推进年份")
	_check(state.world_conflict > 0 and not state.world_events.is_empty(), "世界时钟会推进势力冲突并留下事件记录")

func _test_party_combat_integration() -> void:
	var state := GameState.new_life(_make_soul(), rng)
	state.realm = 3
	var partner_ids: Array[String] = ["old_beggar", "cliff_sword", "demon_teach", "river_god"]
	for i in range(partner_ids.size()):
		var npc_id := partner_ids[i]
		var profile := PartyCombatSystem.companion_skill_profile({"event_id": npc_id, "name": "测试伙伴%d" % i})
		state.met_npcs.append({
			"name": "测试伙伴%d" % i,
			"event_id": npc_id,
			"identity": "测试身份",
			"faction": "散修",
			"companion": true,
			"companion_alive": true,
			"affinity": 55,
			"partner_level": 1,
			"bond_exp": 0,
			"battle_skill": String(profile.get("name", "")),
			"battle_skill_id": npc_id
		})
	var skill_names: Array[String] = []
	var unique_skill_names: Dictionary = {}
	for npc: Dictionary in state.met_npcs:
		var skill_name := String(PartyCombatSystem.companion_skill_profile(npc).get("name", ""))
		skill_names.append(skill_name)
		unique_skill_names[skill_name] = true
	_check(skill_names.size() == 4 and unique_skill_names.size() == 4, "不同 NPC 拥有各自独立命名的本命战技")
	var all_profile_names: Dictionary = {}
	for npc_id_value: Variant in EventData.NPC_PROFILES.keys():
		var npc_id := String(npc_id_value)
		var profile := PartyCombatSystem.companion_skill_profile({"event_id": npc_id, "name": npc_id})
		all_profile_names[String(profile.get("name", ""))] = true
	_check(all_profile_names.size() == EventData.NPC_PROFILES.size(), "全部重要 NPC 档案均配置了不重复的本命战技")
	var enemy := {"name": "测试强敌", "hp": 3000, "max_hp": 3000, "attack": 24, "defense": 10}
	var first_turn: Dictionary = state.resolve_party_support_turn(enemy, rng, 1)
	var first_results: Array = first_turn.get("companions", [])
	_check(first_results.size() == 3, "单回合最多三名人类伙伴出手")
	_check(int(enemy.get("hp", 3000)) < 3000, "伙伴专属技能真实影响敌方气血")
	var first_names: Array[String] = []
	for result_value: Variant in first_results:
		if result_value is Dictionary:
			first_names.append(String(result_value.get("npc_name", "")))
	var second_turn: Dictionary = state.resolve_party_support_turn(enemy, rng, 2)
	var second_results: Array = second_turn.get("companions", [])
	var second_names: Array[String] = []
	for result_value: Variant in second_results:
		if result_value is Dictionary:
			second_names.append(String(result_value.get("npc_name", "")))
	_check(not second_names.is_empty(), "伙伴会按轮换顺序持续参与后续回合")
	var saw_fourth := first_names.has("测试伙伴3") or second_names.has("测试伙伴3")
	_check(saw_fourth, "超过三名伙伴时会轮换上场")
	var roundtrip := GameState.from_dict(state.to_dict())
	_check(roundtrip.met_npcs.size() == 4, "伙伴等级与战技字段可正常存读档")
	state.pets.append({
		"name": "测试灵宠",
		"species": "测试灵兽",
		"level": 1,
		"power": 8,
		"skills": [],
		"pet_hp": 50,
		"pet_max_hp": 50,
		"exp": 0,
		"form": "幼年形态",
		"bloodline": "凡兽"
	})
	state.active_pet_index = 0
	var pet_turn: Dictionary = state.resolve_party_support_turn(enemy, rng, 3)
	var pet_result: Dictionary = pet_turn.get("pet", {})
	_check(int(pet_result.get("damage", 0)) > 0, "统一队伍回合会调度出战灵宠协击")
	_check(int(state.active_pet().get("exp", 0)) > 0, "灵宠在统一协战流程中正常获得战斗经验")

func _test_material_economy_integration() -> void:
	var state := GameState.new_life(_make_soul(), rng)
	state.materials["凝露草"] = 8
	state.materials["灵芝"] = 3
	state.materials["妖狼獠牙"] = 2
	state.materials["寒潭鳞片"] = 2
	state.materials["赤焰砂"] = 2
	state.materials["剑纹石"] = 2
	state.materials["石傀核心"] = 1
	state.materials["阴魂结晶"] = 2
	state.materials["龙宫珍珠"] = 1
	_check(MaterialEconomySystem.material_category("龙宫珍珠") == "沧海", "材料分类识别正确")
	_check(MaterialEconomySystem.material_category("妖狼獠牙") == "兽元", "兽类材料分类识别正确")
	var summary := MaterialEconomySystem.material_summary(state.materials)
	_check(summary.size() >= 3, "材料会按类别汇总")
	_check(MaterialEconomySystem.max_refine_amount(state.materials, "灵材精华") >= 1, "灵材足够炼化成精华")
	var refine := MaterialEconomySystem.refine_essence(state, "灵材精华", 1)
	_check(bool(refine.get("ok", false)), "精华炼化成功")
	_check(int(state.materials.get("灵材精华", 0)) == 1, "炼化后会得到灵材精华")
	var consume := MaterialEconomySystem.consume_essence(state, "灵材精华")
	_check(bool(consume.get("ok", false)), "精华可直接炼化为实用增益")
	_check(int(state.materials.get("灵材精华", 0)) == 0, "消耗后精华数量减少")
	var pill_ok := state.craft_pill("小还丹")
	_check(pill_ok, "常见丹药仍可正常炼制")
	var forge_ok := state.craft_equipment("青岚剑纹灵剑")
	_check(forge_ok, "炼器配方仍可正常炼制")

func _average(rows: Array, key: String) -> float:
	var total: float = 0.0
	for row: Dictionary in rows:
		total += float(row.get(key, 0))
	return total / maxf(1.0, float(rows.size()))
