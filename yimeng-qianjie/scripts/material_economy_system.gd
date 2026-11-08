class_name MaterialEconomySystem
extends RefCounted

## 材料分类、炼化与精华消耗。
## 由 GameState 暴露接口，界面层只负责展示和触发。

const ESSENCE_RECIPES := {
	"灵材精华": {"category": "灵材", "points": 6, "label": "灵材精华", "desc": "凝聚草木灵性而成，可直接滋养气血与灵力。"},
	"兽元精华": {"category": "兽元", "points": 6, "label": "兽元精华", "desc": "从兽骨、獠牙与精血中提炼出的本源精华。"},
	"器纹精华": {"category": "器纹", "points": 6, "label": "器纹精华", "desc": "矿砂、铜片与阵纹核心凝成的炼器精华。"},
	"魂煞精华": {"category": "魂煞", "points": 6, "label": "魂煞精华", "desc": "阴魂、幽冥与血煞之气炼出的危险精华。"},
	"沧海精华": {"category": "沧海", "points": 6, "label": "沧海精华", "desc": "潮汐、龙珠与寒水灵韵汇成的海意精华。"}
}

const MATERIAL_CATALOG := {
	"凝露草": {"category": "灵材", "tier": 1, "desc": "常见灵草，可入最基础的丹方。"},
	"灵芝": {"category": "灵材", "tier": 2, "desc": "蕴灵菌芝，药力温和而绵长。"},
	"青岚灵叶": {"category": "灵材", "tier": 2, "desc": "青岚山脉生长的灵叶，适合稳固心神。"},
	"百年灵芝": {"category": "灵材", "tier": 3, "desc": "百年灵芝，药性更为醇厚。"},
	"九叶药草": {"category": "灵材", "tier": 4, "desc": "九叶同生的异种灵草，常用于高阶丹方。"},
	"天京玉露": {"category": "沧海", "tier": 4, "desc": "天京灵泉凝成的玉色露珠，药力清冽。"},
	"妖狼獠牙": {"category": "兽元", "tier": 1, "desc": "妖狼战利品，可熬炼兽骨药引。"},
	"寒潭鳞片": {"category": "兽元", "tier": 2, "desc": "寒潭异兽的鳞片，兼具寒气与韧性。"},
	"荒古兽骨": {"category": "兽元", "tier": 3, "desc": "荒古妖兽遗骨，极适合淬体与炼器。"},
	"妖兽精血": {"category": "兽元", "tier": 3, "desc": "妖兽精血，能迅速补足灵兽本源。"},
	"蛟龙逆鳞": {"category": "兽元", "tier": 4, "desc": "蛟龙逆鳞，极难获得的珍稀血脉材料。"},
	"龙宫珍珠": {"category": "沧海", "tier": 4, "desc": "龙宫深处孕育的珍珠，蕴藏海潮灵意。"},
	"赤焰砂": {"category": "器纹", "tier": 1, "desc": "火山赤砂，适合作为炼器火引。"},
	"赤金砂": {"category": "器纹", "tier": 2, "desc": "沉金赤砂，常用于高阶器胚。"},
	"天机铜片": {"category": "器纹", "tier": 2, "desc": "刻着天机阵纹的铜片。"},
	"玄纹晶石": {"category": "器纹", "tier": 2, "desc": "铭有玄纹的晶石，能稳固器阵。"},
	"石傀核心": {"category": "器纹", "tier": 3, "desc": "石傀的机关核心，最适合嵌入法器。"},
	"剑宗令牌": {"category": "器纹", "tier": 2, "desc": "剑宗信物，可熔入剑器增强锋芒。"},
	"阴魂结晶": {"category": "魂煞", "tier": 2, "desc": "阴魂凝结而成的晶体。"},
	"幽冥魂晶": {"category": "魂煞", "tier": 3, "desc": "幽冥魂火凝出的深色晶石。"},
	"魔修血晶": {"category": "魂煞", "tier": 3, "desc": "魔修精血与煞意凝成的血晶。"},
	"血煞石": {"category": "魂煞", "tier": 2, "desc": "血与煞交融的奇石。"}
}

static func essence_names() -> Array[String]:
	return Array(ESSENCE_RECIPES.keys())

static func category_label(category: String) -> String:
	match category:
		"灵材":
			return "灵材"
		"兽元":
			return "兽元"
		"器纹":
			return "器纹"
		"魂煞":
			return "魂煞"
		"沧海":
			return "沧海"
		_:
			return "杂材"

static func material_info(material_name: String) -> Dictionary:
	if MATERIAL_CATALOG.has(material_name):
		var info: Dictionary = MATERIAL_CATALOG[material_name].duplicate(true)
		var category: String = String(info.get("category", "杂材"))
		var tier: int = maxi(1, int(info.get("tier", 1)))
		info["name"] = material_name
		info["points"] = tier
		info["source"] = MaterialSourceGuide.category_source_text(category, tier)
		info["usage"] = MaterialSourceGuide.category_usage_text(category)
		return info
	for essence_name: String in ESSENCE_RECIPES.keys():
		if essence_name == material_name:
			var essence: Dictionary = ESSENCE_RECIPES[essence_name].duplicate(true)
			var category: String = String(essence.get("category", "杂材"))
			essence["name"] = material_name
			essence["points"] = int(essence.get("points", 6))
			essence["tier"] = 5
			essence["source"] = MaterialSourceGuide.category_source_text(category, 5)
			essence["usage"] = MaterialSourceGuide.category_usage_text(category)
			return essence
	var category: String = material_category(material_name)
	var tier: int = material_tier(material_name)
	return {
		"name": material_name,
		"category": category,
		"tier": tier,
		"points": material_points(material_name),
		"source": MaterialSourceGuide.category_source_text(category, tier),
		"usage": MaterialSourceGuide.category_usage_text(category),
		"desc": "未登记的材料。",
		"label": material_name,
	}

static func material_category(material_name: String) -> String:
	if MATERIAL_CATALOG.has(material_name):
		return String(MATERIAL_CATALOG[material_name].get("category", "杂材"))
	if ESSENCE_RECIPES.has(material_name):
		return String(ESSENCE_RECIPES[material_name].get("category", "杂材"))
	var text := material_name
	if text.contains("珍珠") or text.contains("归墟") or text.contains("龙宫") or text.contains("海"):
		return "沧海"
	if text.contains("草") or text.contains("芝") or text.contains("叶") or text.contains("露") or text.contains("药"):
		return "灵材"
	if text.contains("獠牙") or text.contains("兽骨") or text.contains("精血") or text.contains("鳞片") or text.contains("逆鳞") or text.contains("兽"):
		return "兽元"
	if text.contains("魂") or text.contains("魄") or text.contains("阴") or text.contains("幽") or text.contains("血煞") or text.contains("魔修"):
		return "魂煞"
	if text.contains("砂") or text.contains("石") or text.contains("铜片") or text.contains("晶石") or text.contains("核心") or text.contains("令牌"):
		return "器纹"
	return "灵材"

static func material_tier(material_name: String) -> int:
	if MATERIAL_CATALOG.has(material_name):
		return clampi(int(MATERIAL_CATALOG[material_name].get("tier", 1)), 1, 4)
	if ESSENCE_RECIPES.has(material_name):
		return 5
	var category := material_category(material_name)
	if category == "沧海":
		return 4
	if material_name.contains("百年") or material_name.contains("天京") or material_name.contains("幽冥") or material_name.contains("龙宫") or material_name.contains("蛟龙"):
		return 4
	if material_name.contains("剑宗") or material_name.contains("荒古") or material_name.contains("魔修") or material_name.contains("石傀"):
		return 3
	if material_name.contains("青岚") or material_name.contains("赤金") or material_name.contains("玄纹") or material_name.contains("寒潭") or material_name.contains("血煞"):
		return 2
	return 1

static func material_points(material_name: String) -> int:
	if ESSENCE_RECIPES.has(material_name):
		return int(ESSENCE_RECIPES[material_name].get("points", 6))
	return maxi(1, material_tier(material_name))

static func material_summary(materials: Dictionary) -> Array[Dictionary]:
	var grouped: Dictionary = {}
	for raw_key: Variant in materials.keys():
		var material_name: String = String(raw_key)
		var amount: int = maxi(0, int(materials[raw_key]))
		if amount <= 0:
			continue
		var category: String = material_category(material_name)
		if not grouped.has(category):
			grouped[category] = {"category": category, "count": 0, "points": 0, "materials": []}
		var entry: Dictionary = grouped[category]
		entry["count"] = int(entry.get("count", 0)) + amount
		entry["points"] = int(entry.get("points", 0)) + amount * material_points(material_name)
		var names: Array = Array(entry.get("materials", [])).duplicate(true)
		names.append({"name": material_name, "count": amount, "tier": material_tier(material_name), "points": material_points(material_name)})
		entry["materials"] = names
		grouped[category] = entry
	var result: Array[Dictionary] = []
	for category in ["灵材", "兽元", "器纹", "魂煞", "沧海"]:
		if grouped.has(category):
			result.append(grouped[category])
	for category_key: Variant in grouped.keys():
		var category_name: String = String(category_key)
		if category_name not in ["灵材", "兽元", "器纹", "魂煞", "沧海"]:
			result.append(grouped[category_name])
	return result

static func category_points(materials: Dictionary, category: String) -> int:
	var total := 0
	for raw_key: Variant in materials.keys():
		var material_name: String = String(raw_key)
		if material_category(material_name) == category:
			total += maxi(0, int(materials[raw_key])) * material_points(material_name)
	return total

static func max_refine_amount(materials: Dictionary, essence_name: String) -> int:
	if not ESSENCE_RECIPES.has(essence_name):
		return 0
	var recipe: Dictionary = ESSENCE_RECIPES[essence_name]
	var category: String = String(recipe.get("category", ""))
	var need: int = maxi(1, int(recipe.get("points", 6)))
	return int(category_points(materials, category) / need)

static func can_refine_essence(materials: Dictionary, essence_name: String, amount: int = 1) -> bool:
	return max_refine_amount(materials, essence_name) >= amount

static func _source_pool(materials: Dictionary, category: String) -> Array[Dictionary]:
	var pool: Array[Dictionary] = []
	for raw_key: Variant in materials.keys():
		var material_name: String = String(raw_key)
		var count: int = maxi(0, int(materials[raw_key]))
		if count <= 0 or material_category(material_name) != category:
			continue
		pool.append({"name": material_name, "count": count, "points": material_points(material_name)})
	pool.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("points", 0)) < int(b.get("points", 0))
	)
	return pool

static func _remove_material(materials: Dictionary, material_name: String, amount: int) -> int:
	if amount <= 0:
		return 0
	var current := maxi(0, int(materials.get(material_name, 0)))
	var taken := mini(current, amount)
	if taken > 0:
		materials[material_name] = current - taken
	return taken

static func refine_essence(state: GameState, essence_name: String, amount: int = 1) -> Dictionary:
	if not ESSENCE_RECIPES.has(essence_name):
		return {"ok": false, "message": "未知的精华类型。"}
	amount = maxi(1, amount)
	var recipe: Dictionary = ESSENCE_RECIPES[essence_name]
	var category: String = String(recipe.get("category", ""))
	var need_per_unit: int = maxi(1, int(recipe.get("points", 6)))
	var total_need: int = amount * need_per_unit
	var pool := _source_pool(state.materials, category)
	if pool.is_empty():
		return {"ok": false, "message": "没有可用于炼化%s的材料。" % essence_name}
	var available := category_points(state.materials, category)
	if available < total_need:
		return {"ok": false, "message": "炼化%s还差 %d 点%s材料。" % [essence_name, total_need - available, category_label(category)]}
	var consumed: Array[String] = []
	var points_left := total_need
	for src in pool:
		if points_left <= 0:
			break
		var material_name: String = String(src.get("name", ""))
		var points: int = maxi(1, int(src.get("points", 1)))
		var take_count: int = mini(int(src.get("count", 0)), int(ceil(float(points_left) / float(points))))
		if take_count <= 0:
			continue
		var removed := _remove_material(state.materials, material_name, take_count)
		if removed <= 0:
			continue
		consumed.append("%s×%d" % [material_name, removed])
		points_left -= removed * points
	if points_left > 0:
		return {"ok": false, "message": "炼化%s时材料不足。" % essence_name}
	state.materials[essence_name] = maxi(0, int(state.materials.get(essence_name, 0))) + amount
	var message := "炼化%s ×%d 完成，消耗%s。" % [essence_name, amount, "、".join(PackedStringArray(consumed))]
	if state.has_method("add_log"):
		state.add_log(message, "materials")
	return {"ok": true, "message": message, "essence": essence_name, "amount": amount, "category": category, "consumed": consumed}

static func consume_essence(state: GameState, essence_name: String, amount: int = 1) -> Dictionary:
	if not ESSENCE_RECIPES.has(essence_name):
		return {"ok": false, "message": "未知的精华类型。"}
	amount = maxi(1, amount)
	var current := maxi(0, int(state.materials.get(essence_name, 0)))
	if current < amount:
		return {"ok": false, "message": "精华不足，无法服用%s ×%d。" % [essence_name, amount]}
	state.materials[essence_name] = current - amount
	var category: String = String(ESSENCE_RECIPES[essence_name].get("category", ""))
	var message := "服用%s ×%d。" % [essence_name, amount]
	match category:
		"灵材":
			state.hp = mini(state.max_hp(), state.hp + 10 * amount)
			state.mp = mini(state.max_mp(), state.mp + 8 * amount)
			state.insight = mini(100, state.insight + amount)
			message = "服用%s ×%d，气血与灵力有所恢复。" % [essence_name, amount]
		"兽元":
			state.hp = mini(state.max_hp(), state.hp + 8 * amount)
			state.body = mini(100, state.body + amount)
			state.injury = maxi(0, state.injury - 2 * amount)
			message = "服用%s ×%d，体魄得到淬炼。" % [essence_name, amount]
		"器纹":
			state.stones += 12 * amount
			state.luck = mini(100, state.luck + amount)
			state.breakthrough_bonus = minf(1.0, state.breakthrough_bonus + 0.02 * amount)
			message = "服用%s ×%d，器纹流转，心神与灵石皆有增益。" % [essence_name, amount]
		"魂煞":
			state.hp = mini(state.max_hp(), state.hp + 4 * amount)
			state.daoheart = mini(100, state.daoheart + amount)
			state.insight = mini(100, state.insight + amount)
			message = "服用%s ×%d，魂煞之意令道心更稳。" % [essence_name, amount]
		"沧海":
			state.mp = mini(state.max_mp(), state.mp + 14 * amount)
			state.luck = mini(100, state.luck + amount)
			state.breakthrough_bonus = minf(1.0, state.breakthrough_bonus + 0.03 * amount)
			message = "服用%s ×%d，沧海灵意化作绵长后劲。" % [essence_name, amount]
		_:
			state.hp = mini(state.max_hp(), state.hp + 6 * amount)
			state.mp = mini(state.max_mp(), state.mp + 6 * amount)
			message = "服用%s ×%d。" % [essence_name, amount]
	if state.has_method("add_log"):
		state.add_log(message, "materials")
	return {"ok": true, "message": message, "essence": essence_name, "amount": amount, "category": category}
