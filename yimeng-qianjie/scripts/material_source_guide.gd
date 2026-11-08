class_name MaterialSourceGuide
extends RefCounted

## 材料来源与用途提示的统一说明表。
## 以后可以直接给材料界面、掉落提示、任务奖励和图鉴共用。

static func category_source_text(category: String, tier: int = 1) -> String:
	var base := ""
	match category:
		"灵材":
			base = "常见于灵田、山野药圃、秘境草木区和宗门药园。"
		"兽元":
			base = "击败妖兽、灵兽、荒古兽类后最容易得到。"
		"器纹":
			base = "多来自矿脉、机关遗迹、炼器副产与宗门宝库。"
		"魂煞":
			base = "常见于阴冥区域、鬼市、魔修敌人和怨煞秘境。"
		"沧海":
			base = "多见于海域、龙宫、水系秘境、灵泉与潮汐事件。"
		_:
			base = "可在探索、战斗、采集或事件奖励中获得。"
	if tier >= 4:
		return base + " 属于高阶稀有材料，通常来自精英首领、深层秘境或特殊任务。"
	if tier == 3:
		return base + " 适合中高阶区域、精英战斗与稀有掉落。"
	return base + " 常在日常探索和基础战斗中出现。"

static func category_usage_text(category: String) -> String:
	match category:
		"灵材":
			return "主要用于炼丹、恢复气血、稳固根骨与心神。"
		"兽元":
			return "适合淬体、灵宠喂养、兽系丹方与炼器兽骨引。"
		"器纹":
			return "主要用于炼器、器胚强化、法宝铭纹与阵器拼装。"
		"魂煞":
			return "多用于邪修器具、阴煞丹方、魂系法术与特殊事件。"
		"沧海":
			return "常用于海系丹药、灵泉修复、水法器与灵力调和。"
		_:
			return "可作为探索材料、事件奖励或特殊交易资源。"

static func category_spot_text(category: String) -> String:
	match category:
		"灵材":
			return "示例州域：东境·青岚山、南境·药王岭、宗门药园与灵田。"
		"兽元":
			return "示例州域：北荒·万妖原、地域妖兽巢穴与灵兽栖地。"
		"器纹":
			return "示例州域：西境·天机城、矿脉、机关遗迹与宗门器坊。"
		"魂煞":
			return "示例州域：北境·葬魂渊、魔宗、鬼市与阴冥秘境。"
		"沧海":
			return "示例州域：海外·归墟海、龙宫、水系秘境与灵泉潮汐。"
		_:
			return "示例来源：探索、战斗、采集与机缘事件。"

static func material_hint(material_name: String, category: String, tier: int, desc: String) -> Dictionary:
	return {
		"name": material_name,
		"category": category,
		"tier": tier,
		"source": category_source_text(category, tier),
		"usage": category_usage_text(category),
		"spot": category_spot_text(category),
		"desc": desc,
	}

static func region_drop_text(region_name: String, material_name: String, category: String, tier: int = 1) -> String:
	return "%s常产出【%s】。%s" % [region_name, material_name, category_source_text(category, tier)]

static func secret_realm_text(region_name: String, material_name: String, category: String, tier: int = 1) -> String:
	return "秘境【%s】往往藏有【%s】。%s" % [region_name, material_name, category_source_text(category, tier)]

static func battle_drop_text(enemy_name: String, material_name: String, category: String, tier: int = 1) -> String:
	return "击败【%s】后常能取得【%s】。%s" % [enemy_name, material_name, category_source_text(category, tier)]

static func region_event_text(region_name: String, event_text: String) -> String:
	return "【%s】%s" % [region_name, event_text]
