extends RefCounted
class_name AIPromptFactory

## 统一管理《一梦千劫》的商汤提示词，方便 NPC、功法、装备、场景和事件复用。

static func npc_profile_prompt(name: String, realm: String = "", personality: String = "", background: String = "", sex: String = "") -> String:
	var lines: Array[String] = []
	lines.append("你是一名中文文字修仙 RPG 的设定编剧。")
	lines.append("请为《一梦千劫》生成一个可直接进入游戏数据库的 NPC 档案，要求简洁、可落地、适合做剧情和关系系统。")
	lines.append("只输出纯文本，不要 Markdown，不要编号，不要解释你的思路。")
	lines.append("字段顺序固定为：姓名、性别、境界、性格、外貌、出身、当前处境、擅长、关系钩子、可触发事件、战斗风格、备注。")
	lines.append("姓名：%s" % name)
	if sex.strip_edges() != "":
		lines.append("性别：%s" % sex)
	if realm.strip_edges() != "":
		lines.append("境界：%s" % realm)
	if personality.strip_edges() != "":
		lines.append("性格：%s" % personality)
	if background.strip_edges() != "":
		lines.append("背景：%s" % background)
	lines.append("要求：符合修仙世界观，避免现代词汇；每个字段控制在一句话内；可作为宗门、散修、皇朝、妖盟或秘境角色。")
	return "\n".join(lines)


static func item_profile_prompt(item_name: String, item_type: String = "装备", grade: String = "", effect_hint: String = "") -> String:
	var lines: Array[String] = []
	lines.append("你是一名中文修仙游戏道具设定编剧。")
	lines.append("请为《一梦千劫》生成一个可直接入库的道具档案。")
	lines.append("只输出纯文本，不要 Markdown，不要编号，不要解释。")
	lines.append("字段顺序固定为：名称、类型、品阶、外观、来历、主要效果、战斗用途、适合对象、备注。")
	lines.append("名称：%s" % item_name)
	lines.append("类型：%s" % item_type)
	if grade.strip_edges() != "":
		lines.append("品阶：%s" % grade)
	if effect_hint.strip_edges() != "":
		lines.append("效果提示：%s" % effect_hint)
	lines.append("要求：风格偏古风、仙侠、水墨或器物感；效果必须可用于 RPG 机制，不要空泛。")
	return "\n".join(lines)


static func skill_profile_prompt(skill_name: String, skill_type: String = "功法", realm: String = "", effect_hint: String = "") -> String:
	var lines: Array[String] = []
	lines.append("你是一名中文修仙游戏技能设定编剧。")
	lines.append("请为《一梦千劫》生成一个技能或功法条目，可用于技能图鉴与战斗数值系统。")
	lines.append("只输出纯文本，不要 Markdown，不要编号，不要解释。")
	lines.append("字段顺序固定为：名称、类型、定位、核心机制、修炼/使用条件、战斗效果、成长方向、备注。")
	lines.append("名称：%s" % skill_name)
	lines.append("类型：%s" % skill_type)
	if realm.strip_edges() != "":
		lines.append("适用境界：%s" % realm)
	if effect_hint.strip_edges() != "":
		lines.append("效果提示：%s" % effect_hint)
	lines.append("要求：尽量给出可实现的数值或机制关键词，例如加伤、护盾、控制、暴击、破防、召唤、持续伤害。")
	return "\n".join(lines)


static func background_prompt(location_name: String, atmosphere: String = "", scene_type: String = "") -> String:
	var lines: Array[String] = []
	lines.append("你是一名中国古风仙侠场景美术提示词编写者。")
	lines.append("请为《一梦千劫》生成一段适合图像生成模型的场景提示词。")
	lines.append("只输出一段适合直接喂给图像模型的中文提示词，不要解释，不要分点。")
	lines.append("地点：%s" % location_name)
	if scene_type.strip_edges() != "":
		lines.append("场景类型：%s" % scene_type)
	if atmosphere.strip_edges() != "":
		lines.append("氛围：%s" % atmosphere)
	lines.append("要求：古风、仙侠、水墨、电影感、留白、层次分明、适合横版背景。")
	lines.append("不要文字、不要水印、不要现代建筑、不要角色遮挡主体。")
	return "\n".join(lines)


static func encounter_prompt(event_name: String, context: String = "") -> String:
	var lines: Array[String] = []
	lines.append("你是一名中文文字修仙 RPG 的剧情编剧。")
	lines.append("请为《一梦千劫》生成一个随机奇遇或事件文本。")
	lines.append("只输出纯文本，不要 Markdown，不要编号，不要解释。")
	lines.append("字段顺序固定为：标题、开场、选择A、选择B、选择C、结果倾向、奖励、风险。")
	lines.append("事件标题：%s" % event_name)
	if context.strip_edges() != "":
		lines.append("背景：%s" % context)
	lines.append("要求：有修仙味、能接入分支选项、避免重复套路、奖励与风险要具体。")
	return "\n".join(lines)
