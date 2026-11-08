extends RefCounted

## 独立材料经济回归测试：验证材料分类、炼化与精华消耗是否闭环。
## 这个文件先独立存在，后续可接入现有 smoke_test 执行入口。

const RNG_SEED := 114514

static func run() -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = RNG_SEED
	var soul := {"name": "材料测试", "lives": 0, "points": 0, "best_realm": 0, "ascensions": 0, "chronicle": []}
	var state := GameState.new_life(soul, rng)
	state.hp = 50
	state.mp = 20
	state.body = 30
	state.insight = 30
	state.luck = 30
	state.daoheart = 30
	state.stones = 0
	state.materials = {
		"凝露草": 8,
		"灵芝": 4,
		"妖狼獠牙": 6,
		"赤焰砂": 4,
		"阴魂结晶": 4,
		"天京玉露": 3
	}
	var summary := MaterialEconomySystem.material_summary(state.materials)
	var summary_categories: Array[String] = []
	for entry: Dictionary in summary:
		summary_categories.append(String(entry.get("category", "")))
	var can_refine := MaterialEconomySystem.can_refine_essence(state.materials, "灵材精华", 2)
	var refine_result := MaterialEconomySystem.refine_essence(state, "灵材精华", 2)
	var consume_result := MaterialEconomySystem.consume_essence(state, "灵材精华")
	var forge_result := state.craft_equipment("青岚剑纹灵剑")
	return {
		"summary_categories": summary_categories,
		"can_refine": can_refine,
		"refine_result": refine_result,
		"consume_result": consume_result,
		"hp": state.hp,
		"mp": state.mp,
		"body": state.body,
		"insight": state.insight,
		"luck": state.luck,
		"daoheart": state.daoheart,
		"stones": state.stones,
		"forge_result": forge_result,
		"materials": state.materials.duplicate(true)
	}

static func verify() -> void:
	var result := run()
	assert(result["summary_categories"].has("灵材"))
	assert(result["summary_categories"].has("兽元"))
	assert(result["summary_categories"].has("器纹"))
	assert(bool(result["can_refine"]))
	assert(bool(result["refine_result"].get("ok", false)))
	assert(bool(result["consume_result"].get("ok", false)))
	assert(int(result["hp"]) > 50)
	assert(int(result["mp"]) >= 20)
	assert(int(result["stones"]) >= 0)
	assert(result["forge_result"] is Dictionary)
