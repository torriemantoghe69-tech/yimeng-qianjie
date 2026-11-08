class_name GameData
extends RefCounted

## 所有静态设定：境界、出身、灵根、天赋、轮回传承。

const REALMS := [
	{"name": "炼气一层", "short": "炼气", "threshold": 72.0, "life": 2, "major": false,
		"line": "一缕清气落入丹田，如春水初生。"},
	{"name": "炼气四层", "short": "炼气", "threshold": 132.0, "life": 3, "major": false,
		"line": "气行周天，经脉中隐隐有潮声。"},
	{"name": "炼气七层", "short": "炼气", "threshold": 205.0, "life": 4, "major": false,
		"line": "灵台渐明，草木枯荣皆入眼底。"},
	{"name": "炼气圆满", "short": "炼气", "threshold": 300.0, "life": 6, "major": true,
		"line": "气海如镜，只待一线天光破开樊笼。"},
	{"name": "筑基初期", "short": "筑基", "threshold": 420.0, "life": 320, "major": true,
		"line": "道基初成，从此凡骨换仙胎。"},
	{"name": "筑基中期", "short": "筑基", "threshold": 570.0, "life": 90, "major": false,
		"line": "真元凝而不散，举手间已有风雷之意。"},
	{"name": "筑基后期", "short": "筑基", "threshold": 750.0, "life": 80, "major": true,
		"line": "道基圆融，金丹之门在望。"},
	{"name": "金丹初期", "short": "金丹", "threshold": 970.0, "life": 450, "major": true,
		"line": "一粒金丹吞入腹，始知我命不由天。"},
	{"name": "金丹中期", "short": "金丹", "threshold": 1230.0, "life": 140, "major": false,
		"line": "丹火自燃，照见五脏如琉璃。"},
	{"name": "金丹后期", "short": "金丹", "threshold": 1530.0, "life": 110, "major": true,
		"line": "丹成九转，神魂已可离体三寸。"},
	{"name": "元婴初期", "short": "元婴", "threshold": 1890.0, "life": 600, "major": true,
		"line": "紫府中传来婴啼，那是另一个你。"},
	{"name": "元婴中期", "short": "元婴", "threshold": 2300.0, "life": 200, "major": false,
		"line": "元婴睁眼，天地灵气俯首而来。"},
	{"name": "元婴后期", "short": "元婴", "threshold": 2780.0, "life": 150, "major": true,
		"line": "神游千里，一念可渡山海。"},
	{"name": "化神境", "short": "化神", "threshold": 3340.0, "life": 1000, "major": true,
		"line": "神与道合，你在云上，也在尘埃里。"},
	{"name": "炼虚境", "short": "炼虚", "threshold": 3980.0, "life": 85, "major": true,
		"line": "虚空生白，万法如尘。"},
	{"name": "合体境", "short": "合体", "threshold": 4720.0, "life": 100, "major": true,
		"line": "法身与天地相接，呼吸便是风雷。"},
	{"name": "大乘境", "short": "大乘", "threshold": 5560.0, "life": 120, "major": true,
		"line": "大道在前，只差最后一步。"},
	{"name": "渡劫境", "short": "渡劫", "threshold": 6500.0, "life": 150, "major": true,
		"line": "九天雷云低垂，人间再无归路。"},
]

const ORIGINS := [
	{
		"name": "山野弃婴",
		"desc": "你被遗在荒祠前，由一个哑猎户养大。山风与兽骨是你的启蒙。",
		"stats": {"body": 7, "daoheart": 3, "luck": -2},
		"stones": 0,
		"perks": {"attack": 2, "defense": 1},
		"birth": "那年冬天，哑猎户在破庙里听见一声啼哭。他给了你半块饼，也给了你一条命。"
	},
	{
		"name": "药商之家",
		"desc": "你自幼闻百草，认得九十七种药材，也认得人心几分苦。",
		"stats": {"body": 4, "insight": 4, "luck": 2},
		"stones": 30,
		"perks": {"max_hp": 12, "cultivation": 3},
		"birth": "药铺后堂终年浮着甘草与陈皮的气味。你抓过最贵的一副药，也埋过最便宜的穷人。"
	},
	{
		"name": "没落皇族",
		"desc": "旧朝的姓氏还绣在你的衣襟里，宫墙却早已坍成荒丘。",
		"stats": {"luck": 7, "insight": 3, "daoheart": -2},
		"stones": 20,
		"perks": {"critical_rate": 2, "breakthrough": 3},
		"birth": "你出生时，家中只剩一枚旧玉玺和半卷残破族谱。祖母说，我们曾拥有天下。"
	},
	{
		"name": "书香门第",
		"desc": "你三岁识千字，七岁读《南华》。世人皆道那孩子聪慧，却少有人看见你的孤寂。",
		"stats": {"insight": 8, "daoheart": 3, "body": -2},
		"stones": 10,
		"perks": {"skill_power": 5, "max_mp": 8},
		"birth": "春闱放榜那夜，父亲醉倒在书房。你推窗看见一轮极薄的月，忽然觉得功名不如它好看。"
	},
	{
		"name": "猎户之子",
		"desc": "你的手比同龄人粗糙，眼睛也比他们更懂得如何等待。",
		"stats": {"body": 9, "luck": 1, "insight": -2},
		"stones": 5,
		"perks": {"attack": 3, "evasion": 2},
		"birth": "七岁那年，你第一次独自追一头鹿进深山。鹿没追到，却看见崖边有个白衣人踏云而去。"
	},
	{
		"name": "渔家孤女",
		"desc": "你听惯了潮声，知道世间最深的道理都藏在水下。",
		"stats": {"luck": 5, "daoheart": 4, "body": 2},
		"stones": 8,
		"perks": {"evasion": 3, "max_mp": 5},
		"birth": "娘亲说你是从海上漂流来的。每年七月初七，你都会在门前放一盏莲花灯，等一个不会来的人。"
	},
	{
		"name": "道观弃徒",
		"desc": "老道士教你吐纳，却在你十二岁那年不告而别，只留下一句“莫回头”。",
		"stats": {"daoheart": 8, "insight": 3, "luck": -2},
		"stones": 0,
		"perks": {"skill_power": 4, "breakthrough": 2},
		"birth": "观里香火冷清，泥塑的三清脸上落满灰。你曾问老道士，神仙也会死吗。他说，神仙只是不会哭。"
	},
	{
		"name": "边镇流民",
		"desc": "你见过饿殍，也见过一锭银子如何让活人变成鬼。你比谁都想活下去。",
		"stats": {"body": 4, "luck": 4, "daoheart": -2, "insight": 1},
		"stones": 0,
		"perks": {"defense": 2, "max_hp": 8},
		"birth": "那年的雪很大，掩埋了城外的尸体，也掩埋了你的姓。你从尸堆里爬出来时，天刚好亮了。"
	},
]

const ROOT_ELEMENTS := ["金", "木", "水", "火", "土"]
const ROOT_VARIANTS := ["风", "雷", "冰"]

## 灵根只看五行属性多寡，不再分品级。
## 五、四为伪灵根，三为真灵根，二为双灵根，一为天灵根；风、雷、冰为变异灵根。
const ROOTS := [
	{"rank": "伪灵根", "count": 5, "speed": 0.78, "weight": 34.0, "stats": {}, "desc": "五行俱全，灵气入体便互相牵扯。修行最慢，却也最常见。"},
	{"rank": "伪灵根", "count": 4, "speed": 0.90, "weight": 24.0, "stats": {"body": 2}, "desc": "四属性驳杂，仍被称作伪灵根。比五行稍纯，终究难与真灵根相比。"},
	{"rank": "真灵根", "count": 3, "speed": 1.02, "weight": 22.0, "stats": {"insight": 2}, "desc": "三属性同修，是修仙界最常见的可造之材。"},
	{"rank": "双灵根", "count": 2, "speed": 1.18, "weight": 12.0, "stats": {"insight": 3}, "desc": "只余两种属性，灵气提纯快上一截，宗门愿意多看一眼。"},
	{"rank": "天灵根", "count": 1, "variant": false, "speed": 1.42, "weight": 5.5, "stats": {"insight": 4}, "desc": "单一五行属性。灵气毫无杂质，修炼速度远超同阶。"},
	{"rank": "变异灵根", "count": 1, "variant": true, "speed": 1.36, "weight": 2.5, "stats": {"body": 3, "luck": -1}, "desc": "五行异变而成的风、雷或冰。稀有程度不逊天灵根，性情也更烈。"},
]

static func roll_root(rng: RandomNumberGenerator) -> Dictionary:
	var total_weight := 0.0
	for entry: Dictionary in ROOTS:
		total_weight += float(entry.get("weight", 1.0))
	var roll := rng.randf() * total_weight
	var picked: Dictionary = ROOTS[0]
	for entry: Dictionary in ROOTS:
		roll -= float(entry.get("weight", 1.0))
		if roll <= 0.0:
			picked = entry
			break
	return compose_root(picked, rng)

static func compose_root(template: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var root := template.duplicate(true)
	var count := int(root.get("count", 5))
	var elems: Array = []
	if bool(root.get("variant", false)):
		elems.append(ROOT_VARIANTS[rng.randi_range(0, ROOT_VARIANTS.size() - 1)])
	else:
		var pool: Array = ROOT_ELEMENTS.duplicate()
		for _i in range(mini(count, pool.size())):
			var idx := rng.randi_range(0, pool.size() - 1)
			elems.append(pool[idx])
			pool.remove_at(idx)
	return _finish_root(root, elems)

static func force_root(rank: String, current_elements: Array, rng: RandomNumberGenerator) -> Dictionary:
	var template: Dictionary = ROOTS[0]
	for entry: Dictionary in ROOTS:
		if String(entry.get("rank", "")) == rank:
			template = entry
			break
	var root := template.duplicate(true)
	var elems: Array = []
	if rank == "变异灵根":
		var kept := ""
		for item in current_elements:
			if String(item) in ROOT_VARIANTS:
				kept = String(item)
				break
		elems.append(kept if not kept.is_empty() else ROOT_VARIANTS[rng.randi_range(0, ROOT_VARIANTS.size() - 1)])
	elif rank == "天灵根":
		var kept := ""
		for item in current_elements:
			if String(item) in ROOT_ELEMENTS:
				kept = String(item)
				break
		elems.append(kept if not kept.is_empty() else ROOT_ELEMENTS[rng.randi_range(0, ROOT_ELEMENTS.size() - 1)])
	else:
		return compose_root(root, rng)
	return _finish_root(root, elems)

static func purify_root(root: Dictionary) -> Dictionary:
	var elems: Array = []
	for item in root.get("elements", []):
		elems.append(String(item))
	if elems.size() <= 1:
		return root
	elems.pop_back()
	var count := elems.size()
	var rank := "天灵根"
	if count >= 4:
		rank = "伪灵根"
	elif count == 3:
		rank = "真灵根"
	elif count == 2:
		rank = "双灵根"
	var template: Dictionary = ROOTS[0]
	for entry: Dictionary in ROOTS:
		if String(entry.get("rank", "")) == rank and int(entry.get("count", 0)) == count:
			template = entry
			break
	var next := template.duplicate(true)
	return _finish_root(next, elems)

static func _finish_root(root: Dictionary, elems: Array) -> Dictionary:
	var text := ""
	for item in elems:
		text += String(item)
	root["elements"] = elems
	root["element_text"] = text
	root["name"] = text
	root["rank"] = String(root.get("rank", "伪灵根"))
	root["grade_name"] = root["rank"]
	root["grade"] = elems.size()
	root["grade_speed"] = 1.0
	return root

static func legacy_root(old_name: String) -> Dictionary:
	var table := {
		"五灵根": ["伪灵根", ["金", "木", "水", "火", "土"]],
		"四灵根": ["伪灵根", ["金", "木", "水", "火"]],
		"三灵根": ["真灵根", ["金", "木", "水"]],
		"双灵根": ["双灵根", ["金", "木"]],
		"雷灵根": ["变异灵根", ["雷"]],
		"冰灵根": ["变异灵根", ["冰"]],
		"天灵根": ["天灵根", ["火"]],
		"混沌灵根": ["变异灵根", ["风"]],
	}
	var spec: Array = table.get(old_name, table["五灵根"])
	var template: Dictionary = ROOTS[0]
	for entry: Dictionary in ROOTS:
		if String(entry.get("rank", "")) == String(spec[0]) and int(entry.get("count", 0)) == (spec[1] as Array).size():
			template = entry
			break
	return _finish_root(template.duplicate(true), spec[1])

const TALENTS := [
	{"name": "早慧", "stats": {"insight": 7}, "desc": "三岁识千字，七岁通文理。"},
	{"name": "天生神力", "stats": {"body": 8}, "desc": "力能扛鼎，筋骨如铁。"},
	{"name": "福星高照", "stats": {"luck": 7}, "desc": "跌下悬崖，也能落到灵芝上。"},
	{"name": "道心通明", "stats": {"daoheart": 7}, "desc": "尘埃不染，万念不惊。"},
	{"name": "过目不忘", "stats": {"insight": 4, "daoheart": 2}, "desc": "经卷翻过一遍，便住在心里。"},
	{"name": "命硬", "stats": {"body": 3}, "lifespan": 10, "desc": "阎王见了你，都要皱一皱眉。"},
	{"name": "灵台清明", "stats": {"insight": 3, "luck": 3, "daoheart": 2}, "desc": "心湖无波，能照见吉凶。"},
	{"name": "赤子之心", "stats": {"daoheart": 5}, "karma": 5, "desc": "你总愿意先相信别人。"},
	{"name": "天煞孤星", "stats": {"insight": 6, "luck": -6, "daoheart": 4}, "desc": "亲缘寡薄，却更早看清大道无情。"},
	{"name": "铜皮铁骨", "stats": {"body": 6, "luck": -1}, "desc": "刀剑伤你三分，你先伤它七分。"},
	{"name": "心如止水", "stats": {"daoheart": 4, "insight": 4, "body": -2}, "desc": "不以物喜，不以己悲。"},
	{"name": "山野灵童", "stats": {"body": 3, "luck": 4}, "lifespan": 4, "desc": "你听得懂鸟兽说话，山风会替你引路。"},
]

const TREASURES := {
	"无名玉简": {
		"kind": "残卷", "rarity": "灵品", "glyph": "简",
		"desc": "薄如蝉翼的玉简，边角有一道旧裂纹。以神念探入，可见半篇残缺的吐纳法，字迹清瘦，像是临死前匆匆刻下。",
		"lore": "老乞丐留下的东西。玉简末尾被人用指甲刮去一行，只剩一个“舍”字。你至今不知，他要你舍下的是什么。"
	},
	"长生铜钱": {
		"kind": "古钱", "rarity": "玄品", "glyph": "钱",
		"desc": "一枚沾泥的旧铜钱，外圆内方，背面铸着“长生”二字。无论怎样擦拭，铜钱都带着一股潮湿的香火气。",
		"lore": "据说这是某座荒庙的香火钱。庙塌之后，铜钱便在人间流转，等一个愿意分饭给乞丐的人。"
	},
	"白狐灵毛": {
		"kind": "灵材", "rarity": "灵品", "glyph": "狐",
		"desc": "一撮银白狐毛，触手温暖，在月光下会泛起淡淡的青辉。放在枕边，梦里总有狐狸踩过雪地的声音。",
		"lore": "山中白狐谢你一饭之恩。后来你才听说，那片山里的狐仙已经等了一个恩人三百年。"
	},
	"无名剑刃": {
		"kind": "残剑", "rarity": "灵品", "glyph": "刃",
		"desc": "一截清亮的断刃，不过三指长，却锋锐得能割开风。剑身上没有铭文，只有一道被反复摩挲得发亮的旧痕。",
		"lore": "它来自一座无名坟。你替坟中人培了土，断刃便自己裂开，把最锋利的一段留给了你。"
	},
	"悔字断剑": {
		"kind": "残剑", "rarity": "玄品", "glyph": "剑",
		"desc": "半截断剑，剑柄刻着一个“悔”字。入手极沉，握久了掌心会生出寒意，仿佛有人在背后看你。",
		"lore": "坟中人的佩剑。他曾用这把剑做过一件无法挽回的事；你拔走它时，地下传来一声叹息。"
	},
	"染血古玉": {
		"kind": "古玉", "rarity": "玄品", "glyph": "玉",
		"desc": "一块暗红古玉，内里像封着一滴未干的血。贴在眉心时，能听见陌生的剑鸣与许多人的低语。",
		"lore": "鬼市摊主说你前世是个了不得的人物。你没有问，那场关于前世的梦，究竟是真的，还是古玉编给你的。"
	},
	"崖畔剑意": {
		"kind": "剑意", "rarity": "玄品", "glyph": "意",
		"desc": "没有实体的东西，寄在你心口。每当握剑时，你会想起崖边那杯冷茶，和白衣人掷出树枝时的一线天光。",
		"lore": "白衣剑客说，剑不在手上，在心里。你至今没参透，但每次出剑都会比昨天快一点。"
	},
	"青蛟避水珠": {
		"kind": "灵珠", "rarity": "玄品", "glyph": "珠",
		"desc": "一颗青色珠子，内里有一道极细的水纹在游动。含在口中，江水会自动分开三尺，连衣裳都不会沾湿。",
		"lore": "河神案上得来的东西。你不知道那个抱布老虎的女孩后来去了哪里，只知道珠子偶尔会在夜里发出极轻的哭声。"
	},
	"半部道经": {
		"kind": "道经", "rarity": "天品", "glyph": "经",
		"desc": "半部以旧帛装帧的古老道经，纸页泛黄，却没有一丝腐气。读它时，耳边常有潮声。",
		"lore": "洞府遗蜕的遗物。最后一页写着“后来者，莫贪”，你却还是把它收进了袖中。"
	},
	"前世糖人": {
		"kind": "信物", "rarity": "凡品", "glyph": "糖",
		"desc": "一个麦芽糖捏成的小人，眉眼拙朴，穿一件你少年时穿过的旧袍。过了许多年，糖人也没有化。",
		"lore": "卖糖人的老者说，这是上一世的你。你舍不得吃，也舍不得丢，只好把它留在身边，当作另一个自己。"
	},
	"问天剑": {
		"kind": "名剑", "rarity": "天品", "glyph": "剑",
		"desc": "剑身如秋水，映出的不是持剑人的脸，而是一片无垠星河。剑名“问天”，却没有剑鞘。",
		"lore": "万剑冢中央的剑。十万剑鸣送它出鞘，它选中了你，或者只是恰好路过。"
	},
	"无名锈剑": {
		"kind": "残剑", "rarity": "灵品", "glyph": "剑",
		"desc": "一柄从剑冢飞出的锈剑，剑柄上刻满名字。每一个名字都已被锈蚀，只有最新那一行还能认出——是你。",
		"lore": "十万剑冢中，有些剑等主人，有些剑等一个名字。你不确定自己是哪一种。"
	},
	"天外星石": {
		"kind": "奇物", "rarity": "仙品", "glyph": "星",
		"desc": "一块不属于此界的黑色石头，表面浮着银色的星图。凑近听，里面有许多人的诵经声。",
		"lore": "星陨之夜，那个浑身是血的异乡人把它留在了人间。你握住它时，看见一片不属于九州的星河。"
	},
	"灵泉玉鱼": {
		"kind": "灵物", "rarity": "玄品", "glyph": "鱼",
		"desc": "一枚白玉雕成的小鱼，鱼眼嵌着两点灵光。把它放进清水，鱼尾会轻轻摆动。",
		"lore": "灵泉里跃出的白玉小鱼吐出丹药后便沉了回去。你只接住了这个。它不能吃，但能让水保持清甜。"
	},
}

const EQUIP_SLOTS := [
	{"id": "weapon", "name": "兵器", "short": "兵", "desc": "主杀伐。多增根骨、道心与破境之势。"},
	{"id": "guard", "name": "护符", "short": "护", "desc": "主护持。多增气运、护体与临阵生机。"},
	{"id": "heart", "name": "心印", "short": "心", "desc": "主悟道。多增悟性、气机与修行速度。"},
]

const EQUIPMENT := {
	"无名剑刃": {
		"slot": "weapon", "passive_name": "残锋",
		"stats": {"body": 4, "daoheart": 1},
		"mods": {"breakthrough": 2, "attack": 3}
	},
	"悔字断剑": {
		"slot": "weapon", "passive_name": "悔意",
		"stats": {"body": 5, "daoheart": 3, "luck": -1},
		"mods": {"breakthrough": 3, "attack": 5}
	},
	"崖畔剑意": {
		"slot": "weapon", "passive_name": "一线天",
		"stats": {"insight": 3, "daoheart": 5},
		"mods": {"breakthrough": 4, "skill_power": 5}
	},
	"问天剑": {
		"slot": "weapon", "passive_name": "星河在握",
		"stats": {"body": 8, "insight": 3, "daoheart": 4},
		"mods": {"breakthrough": 5, "cultivation": 4, "attack": 8, "skill_power": 4}
	},
	"无名锈剑": {
		"slot": "weapon", "passive_name": "无名之锋",
		"stats": {"body": 3, "insight": 3},
		"mods": {"cultivation": 2, "attack": 2}
	},
	"青锋剑": {
		"kind": "兵器", "rarity": "凡品", "glyph": "剑", "price": 45, "realm": 0,
		"desc": "坊市铁匠以青钢锻成的制式长剑，轻巧锋利，适合初入仙途的修士。",
		"slot": "weapon", "passive_name": "青锋初鸣",
		"stats": {"body": 1}, "mods": {"attack": 4, "speed": 2}
	},
	"玄铁重剑": {
		"kind": "兵器", "rarity": "灵品", "glyph": "重", "price": 150, "realm": 1,
		"desc": "以玄铁百炼而成，剑身沉重，挥动时有破风之声。",
		"slot": "weapon", "passive_name": "势大力沉",
		"stats": {"body": 3}, "mods": {"attack": 10, "speed": -1, "defense": 1}
	},
	"追风灵剑": {
		"kind": "兵器", "rarity": "灵品", "glyph": "风", "price": 260, "realm": 2,
		"desc": "剑脊刻有轻身符纹，出剑如风，收剑无声。",
		"slot": "weapon", "passive_name": "追风逐影",
		"stats": {"daoheart": 1}, "mods": {"attack": 8, "speed": 7, "evasion": 2}
	},
	"赤纹战刀": {
		"kind": "兵器", "rarity": "玄品", "glyph": "刀", "price": 420, "realm": 4,
		"desc": "刀身赤纹如火，适合正面强攻，刀势沉稳凌厉。",
		"slot": "weapon", "passive_name": "赤焰斩",
		"stats": {"body": 3}, "mods": {"attack": 16, "speed": 1, "critical_rate": 3}
	},
	"寒魄飞剑": {
		"kind": "兵器", "rarity": "玄品", "glyph": "寒", "price": 620, "realm": 5,
		"desc": "以寒潭精铁炼制，剑光清冷，催动时能扰乱敌人气机。",
		"slot": "weapon", "passive_name": "寒魄穿云",
		"stats": {"insight": 2}, "mods": {"attack": 19, "speed": 8, "evasion": 3}
	},
	"镇岳长枪": {
		"kind": "兵器", "rarity": "地品", "glyph": "枪", "price": 980, "realm": 8,
		"desc": "枪杆以灵木为骨，枪尖镶嵌地脉精铁，攻守兼备。",
		"slot": "weapon", "passive_name": "镇岳破阵",
		"stats": {"body": 4, "daoheart": 2}, "mods": {"attack": 28, "speed": 3, "defense": 3}
	},
	"紫电雷刃": {
		"kind": "兵器", "rarity": "地品", "glyph": "雷", "price": 1450, "realm": 10,
		"desc": "封存一缕紫霄雷意，出鞘时电光缠绕，迅疾难防。",
		"slot": "weapon", "passive_name": "紫电先声",
		"stats": {"daoheart": 3}, "mods": {"attack": 34, "speed": 12, "critical_rate": 5}
	},
	"斩蛟古剑": {
		"kind": "兵器", "rarity": "天品", "glyph": "蛟", "price": 2600, "realm": 13,
		"desc": "传闻曾斩落深渊蛟龙，剑身残留古老杀伐道纹。",
		"slot": "weapon", "passive_name": "斩蛟",
		"stats": {"body": 5, "insight": 3, "daoheart": 4}, "mods": {"attack": 48, "speed": 10, "critical_rate": 8, "skill_power": 6}
	},
	"白狐灵毛": {
		"slot": "guard", "passive_name": "狐火护心",
		"stats": {"luck": 5, "daoheart": 2},
		"mods": {"injury_reduction": 8, "evasion": 3}
	},
	"长生铜钱": {
		"slot": "guard", "passive_name": "香火长明",
		"stats": {"luck": 4, "daoheart": 3},
		"mods": {"cultivation": 3, "defense": 2}
	},
	"青蛟避水珠": {
		"slot": "guard", "passive_name": "分水",
		"stats": {"body": 3, "luck": 3},
		"mods": {"injury_reduction": 15, "defense": 4}
	},
	"染血古玉": {
		"slot": "guard", "passive_name": "血中剑诀",
		"stats": {"insight": 5, "daoheart": 2, "luck": -1},
		"mods": {"cultivation": 5, "skill_power": 6}
	},
	"灵泉玉鱼": {
		"slot": "guard", "passive_name": "泉息",
		"stats": {"body": 4, "luck": 2, "insight": 1},
		"mods": {"injury_reduction": 10, "defense": 3}
	},
	"无名玉简": {
		"slot": "heart", "passive_name": "残篇",
		"stats": {"insight": 4},
		"mods": {"cultivation": 3, "skill_power": 2}
	},
	"半部道经": {
		"slot": "heart", "passive_name": "观潮",
		"stats": {"insight": 6, "daoheart": 4},
		"mods": {"breakthrough": 3, "cultivation": 4, "skill_power": 4}
	},
	"天外星石": {
		"slot": "heart", "passive_name": "星图低语",
		"stats": {"insight": 5, "luck": 5, "daoheart": 3},
		"mods": {"breakthrough": 4, "cultivation": 5, "skill_power": 7, "critical_rate": 2}
	},
	"前世糖人": {
		"slot": "heart", "passive_name": "旧梦不化",
		"stats": {"daoheart": 4, "luck": 2},
		"mods": {"injury_reduction": 5, "evasion": 2}
	},
	"青岚剑纹灵剑": {"kind":"兵器", "rarity":"玄品", "glyph":"剑", "price":0, "realm":1, "desc":"剑纹石为刃，妖狼獠牙作锋，剑气轻灵。", "slot":"weapon", "passive_name":"青岚剑鸣", "stats":{"body":2,"daoheart":2}, "mods":{"attack":13,"speed":4,"critical_rate":2}},
	"天京赤金护甲": {"kind":"护具", "rarity":"玄品", "glyph":"甲", "price":0, "realm":2, "desc":"赤金砂熔铸甲片，荒古兽骨支撑内衬。", "slot":"guard", "passive_name":"赤金护体", "stats":{"body":3}, "mods":{"defense":8,"injury_reduction":5}},
	"天机阵枢法器": {"kind":"法器", "rarity":"地品", "glyph":"阵", "price":0, "realm":3, "desc":"铜片刻阵，晶石为枢，可稳定神念与灵气周天。", "slot":"heart", "passive_name":"阵枢通明", "stats":{"insight":4}, "mods":{"cultivation":5,"skill_power":3}},
	"幽冥镇魂铃": {"kind":"法器", "rarity":"地品", "glyph":"铃", "price":0, "realm":4, "desc":"魂晶定魄，血煞石为铃舌，专镇阴魂邪祟。", "slot":"heart", "passive_name":"镇魂清音", "stats":{"daoheart":5}, "mods":{"skill_power":6,"evasion":2}},
	"归墟蛟鳞战衣": {"kind":"护具", "rarity":"天品", "glyph":"鳞", "price":0, "realm":5, "desc":"以蛟龙逆鳞为核心，寒潭鳞片层叠成衣。", "slot":"guard", "passive_name":"蛟鳞覆海", "stats":{"body":4,"luck":2}, "mods":{"defense":10,"injury_reduction":8}},
	"赤焰傀儡重锤": {"kind":"兵器", "rarity":"灵品", "glyph":"锤", "price":0, "realm":1, "desc":"赤焰砂淬火，石傀核心作锤心，势大力沉。", "slot":"weapon", "passive_name":"傀力震山", "stats":{"body":3}, "mods":{"attack":16,"defense":2,"speed":-2}},
	"幽血镇邪护符": {"kind":"护具", "rarity":"玄品", "glyph":"符", "price":0, "realm":3, "desc":"阴魂结晶封存残念，魔修血晶压住煞气，护身镇邪。", "slot":"guard", "passive_name":"幽血镇邪", "stats":{"daoheart":4}, "mods":{"injury_reduction":10,"defense":4}},
	"月魄护心铃": {"kind":"法器", "rarity":"地品", "glyph":"铃", "price":0, "realm":3, "desc":"月灵狐留下的月魄凝成铃身，能安抚神魂、驱散邪念。", "slot":"heart", "passive_name":"月魄清音", "stats":{"luck":5,"daoheart":5}, "mods":{"evasion":4,"injury_reduction":8,"skill_power":4}},
	"断岳残锋": {"kind":"兵器", "rarity":"地品", "glyph":"锋", "price":0, "realm":5, "desc":"无名剑冢深处的古剑残锋，剑身虽缺，仍有斩断山岳的锋意。", "slot":"weapon", "passive_name":"断岳剑意", "stats":{"body":5,"daoheart":4}, "mods":{"attack":25,"breakthrough":5,"critical_rate":4}},
	"归潮蛟珠": {"kind":"法器", "rarity":"地品", "glyph":"珠", "price":0, "realm":5, "desc":"青蛟逆鳞孕育的内珠，水行灵力绵长不绝。", "slot":"heart", "passive_name":"归潮", "stats":{"body":3,"luck":4}, "mods":{"cultivation":7,"defense":5,"skill_power":5}},
	"幽市照魂镜": {"kind":"法器", "rarity":"地品", "glyph":"镜", "price":0, "realm":5, "desc":"鬼市深处流出的古镜，可照见伪装与神魂破绽。", "slot":"heart", "passive_name":"照魂破妄", "stats":{"insight":6,"daoheart":3}, "mods":{"critical_rate":5,"skill_power":7}},
	"星门道袍": {"kind":"护具", "rarity":"天品", "glyph":"袍", "price":0, "realm":8, "desc":"洞府星门守护者遗留的道袍，衣上星纹可自行运转护体。", "slot":"guard", "passive_name":"星门护体", "stats":{"body":5,"insight":4}, "mods":{"defense":14,"injury_reduction":12,"cultivation":4}},
	"灵犀兽环": {"kind":"法器", "rarity":"地品", "glyph":"环", "price":0, "realm":4, "desc":"以灵兽心血温养的契约兽环，可令主人与灵宠心意相通。", "slot":"heart", "passive_name":"灵犀共鸣", "stats":{"luck":5,"body":3}, "mods":{"skill_power":5,"evasion":4,"cultivation":3}},
	"九转丹炉印": {"kind":"法器", "rarity":"天品", "glyph":"印", "price":0, "realm":7, "desc":"上古丹师留下的炉心印记，能稳固灵火并提升周天运转。", "slot":"heart", "passive_name":"九转炉心", "stats":{"insight":7,"daoheart":4}, "mods":{"cultivation":9,"breakthrough":5,"skill_power":6}},
	"血月蚀心刃": {"kind":"兵器", "rarity":"天品", "glyph":"刃", "price":0, "realm":9, "desc":"血月魔修以自身精血祭炼的凶刃，威力惊人却杀意难消。", "slot":"weapon", "passive_name":"蚀心血刃", "stats":{"body":6,"daoheart":-2}, "mods":{"attack":38,"critical_rate":8,"skill_power":8}} 
}

const TREASURE_ACTIVES := {
	"无名玉简": {"name": "残篇悟道", "desc": "参悟残缺吐纳法，获得一段修为并提升悟性。", "effect": "cultivation_insight"},
	"长生铜钱": {"name": "长生祈愿", "desc": "以香火愿力延长寿元，并略增气运。", "effect": "lifespan_luck"},
	"半部道经": {"name": "观潮悟道", "desc": "静心研读古经，获得修为并坚定道心。", "effect": "cultivation_daoheart"},
	"前世糖人": {"name": "旧梦回响", "desc": "触摸糖人唤回前世记忆，恢复灵力并坚定道心。", "effect": "restore_mp_daoheart"},
	"天外星石": {"name": "观星参玄", "desc": "借星石感悟天外道韵，获得大量修为与悟性，但会损耗少许气血。", "effect": "star_insight"},
	"灵泉玉鱼": {"name": "灵泉吐息", "desc": "引出玉鱼中的灵泉之息，恢复气血与灵力。", "effect": "restore_both"},
	"念字玉扣": {"name": "故念安神", "desc": "玉扣温润，抚平心神，提升道心与气运。", "effect": "daoheart_luck"},
	"旧剑穗": {"name": "剑穗明心", "desc": "抚过旧剑穗，回想昔日剑意，提升悟性与道心。", "effect": "insight_daoheart"},
	"崖畔剑意": {"name": "剑意参悟", "desc": "重新体悟崖畔剑意，获得修为。佩带时仍可获得其属性加成。", "effect": "cultivation_only"},
}

const RELIC_PASSIVES := {
	"无名玉简": {"name":"残篇悟性", "desc":"持有时悟性 +2，修炼速度 +3%。", "stats":{"insight":2}, "mods":{"cultivation":3}},
	"长生铜钱": {"name":"长生钱纹", "desc":"持有时寿元上限 +12，气运 +2。", "stats":{"luck":2}, "mods":{"lifespan":12}},
	"白狐灵毛": {"name":"狐灵护身", "desc":"持有时气运 +1，闪避率 +3%。", "stats":{"luck":1}, "mods":{"evasion":3}},
	"染血古玉": {"name":"血玉照心", "desc":"持有时道心 +2，突破成功率 +2%。", "stats":{"daoheart":2}, "mods":{"breakthrough":2}},
	"青蛟避水珠": {"name":"蛟珠御水", "desc":"持有时防御 +2，受到的伤害降低 3%。", "stats":{}, "mods":{"defense":2,"injury_reduction":3}},
	"半部道经": {"name":"道经余韵", "desc":"持有时悟性 +2，修炼速度 +5%。", "stats":{"insight":2}, "mods":{"cultivation":5}},
	"前世糖人": {"name":"旧梦护念", "desc":"持有时气血上限 +15，道心 +1。", "stats":{"daoheart":1}, "mods":{"max_hp":15}},
	"天外星石": {"name":"星髓启智", "desc":"持有时悟性 +3，武技威力 +3%。", "stats":{"insight":3}, "mods":{"skill_power":3}},
	"灵泉玉鱼": {"name":"灵泉绵息", "desc":"持有时气血上限 +10，灵力上限 +10。", "stats":{}, "mods":{"max_hp":10,"max_mp":10}},
	"崖畔剑意": {"name":"崖畔剑意", "desc":"持有时攻击 +3，速度 +3，武技威力 +3%。", "stats":{}, "mods":{"attack":3,"speed":3,"skill_power":3}},
	"噬心蛊残壳": {"name":"蛊壳护心", "desc":"残蛊寄于心脉，防御 +3，受到的伤害降低 5%；道心 -1 已在获得时结算。", "stats":{}, "mods":{"defense":3,"injury_reduction":5}},
	"无名剑刃": {"name":"残锋锐意", "desc":"持有时攻击 +3，暴击率 +1%。", "stats":{}, "mods":{"attack":3,"critical_rate":1}},
	"悔字断剑": {"name":"悔剑余势", "desc":"持有时攻击 +4，防御 +1。", "stats":{}, "mods":{"attack":4,"defense":1}},
	"问天剑": {"name":"问天剑魄", "desc":"持有时攻击 +8，武技威力 +5%。", "stats":{}, "mods":{"attack":8,"skill_power":5}},
	"无名锈剑": {"name":"锈剑藏锋", "desc":"持有时攻击 +3，速度 +2。", "stats":{}, "mods":{"attack":3,"speed":2}},
	"旧人皮": {"name":"故人遗温", "desc":"持有时气血上限 +12，闪避率 +1%。", "stats":{}, "mods":{"max_hp":12,"evasion":1}},
	"定海珠": {"name":"定海镇波", "desc":"持有时防御 +4，气血上限 +8。", "stats":{}, "mods":{"defense":4,"max_hp":8}},
	"念字玉扣": {"name":"一念安魂", "desc":"持有时道心 +2，突破成功率 +1%。", "stats":{"daoheart":2}, "mods":{"breakthrough":1}},
	"戏偶": {"name":"戏中真意", "desc":"持有时悟性 +2，闪避率 +1%。", "stats":{"insight":2}, "mods":{"evasion":1}},
	"护字古剑": {"name":"守护剑意", "desc":"持有时攻击 +5，防御 +3。", "stats":{}, "mods":{"attack":5,"defense":3}},
	"无名薄刃": {"name":"薄刃决绝", "desc":"持有时攻击 +4，暴击率 +2%，但气运 -1 已在获得时结算。", "stats":{}, "mods":{"attack":4,"critical_rate":2}},
	"旧剑穗": {"name":"剑穗明心", "desc":"持有时悟性 +1，道心 +1，速度 +2。", "stats":{"insight":1,"daoheart":1}, "mods":{"speed":2}},
	"黑梦瓶": {"name":"梦魇藏息", "desc":"持有时灵力上限 +12，武技威力 +2%。", "stats":{}, "mods":{"max_mp":12,"skill_power":2}},
	"血手经": {"name":"血经残章", "desc":"持有时攻击 +3，武技威力 +3%，道心 -1 已在获得时结算。", "stats":{}, "mods":{"attack":3,"skill_power":3}},
	"旧国虎符": {"name":"虎符余威", "desc":"持有时攻击 +3，防御 +3。", "stats":{}, "mods":{"attack":3,"defense":3}},
	"翻烂旧书": {"name":"百读成识", "desc":"持有时悟性 +3，修炼速度 +2%。", "stats":{"insight":3}, "mods":{"cultivation":2}},
	"小雷印": {"name":"雷印护身", "desc":"持有时速度 +3，暴击率 +1%。", "stats":{}, "mods":{"speed":3,"critical_rate":1}},
	"替身绣像": {"name":"替身挡劫", "desc":"持有时气血上限 +15，闪避率 +2%。", "stats":{}, "mods":{"max_hp":15,"evasion":2}},
	"食梦珠": {"name":"食梦养神", "desc":"持有时悟性 +2，灵力上限 +8。", "stats":{"insight":2}, "mods":{"max_mp":8}},
	"无面人面具": {"name":"无相藏形", "desc":"持有时闪避率 +4%，速度 +2。", "stats":{}, "mods":{"evasion":4,"speed":2}},
	"天妒笔": {"name":"天妒文锋", "desc":"持有时悟性 +3，修炼速度 +3%；气运 -1 已在获得时结算。", "stats":{"insight":3}, "mods":{"cultivation":3}},
	"轮回债契": {"name":"轮回借命", "desc":"持有时气血上限 +18，突破成功率 +2%；因果代价已在获得时结算。", "stats":{}, "mods":{"max_hp":18,"breakthrough":2}},
	"一恨成河": {"name":"恨水滔天", "desc":"持有时攻击 +5，武技威力 +4%；负面因果已在获得时结算。", "stats":{}, "mods":{"attack":5,"skill_power":4}},
	"一念花": {"name":"一念生春", "desc":"持有时道心 +2，气血上限 +8。", "stats":{"daoheart":2}, "mods":{"max_hp":8}},
	"旧神残瞳": {"name":"残瞳窥世", "desc":"持有时悟性 +4，暴击率 +2%；受伤与道心代价已在获得时结算。", "stats":{"insight":4}, "mods":{"critical_rate":2}},
}

static func relic_passive_info(item_name: String) -> Dictionary:
	return RELIC_PASSIVES.get(item_name, {}).duplicate(true)

static func treasure_active_info(item_name: String) -> Dictionary:
	return TREASURE_ACTIVES.get(item_name, {}).duplicate(true)

static func treasure_info(item_name: String) -> Dictionary:
	var info: Dictionary = {}
	if TREASURES.has(item_name):
		info = TREASURES[item_name].duplicate(true)
	else:
		info = {
			"kind": "旧物", "rarity": "凡品", "glyph": "物",
			"desc": "一件来历不明的旧物，边缘已经被年月磨得光滑。你已记不清从何处得来，只记得它很轻，像一段被遗忘的梦。",
			"lore": "有些东西被收进袖中，并不是因为它有用，只是因为在那个时刻，你不想两手空空。"
		}
	if EQUIPMENT.has(item_name):
		info.merge(EQUIPMENT[item_name].duplicate(true), true)
	return info

static func slot_name(slot_id: String) -> String:
	for slot: Dictionary in EQUIP_SLOTS:
		if String(slot["id"]) == slot_id:
			return String(slot["name"])
	return "未知"

static func slot_short(slot_id: String) -> String:
	for slot: Dictionary in EQUIP_SLOTS:
		if String(slot["id"]) == slot_id:
			return String(slot["short"])
	return "器"

const UPGRADES := [
	{"id": "insight", "name": "宿慧", "glyph": "慧", "desc": "前世诵过的经卷化作一点灵光。",
		"effect": "每级初始悟性 +7", "max": 5, "base_cost": 18},
	{"id": "body", "name": "道骨", "glyph": "骨", "desc": "一次次葬下的肉身，重新长出更硬的骨。",
		"effect": "每级初始根骨 +7", "max": 5, "base_cost": 18},
	{"id": "luck", "name": "福缘", "glyph": "缘", "desc": "你在轮回里攒下一些未曾花完的运气。",
		"effect": "每级初始气运 +6", "max": 5, "base_cost": 20},
	{"id": "daoheart", "name": "心印", "glyph": "心", "desc": "有些道理死过一次才真正懂得。",
		"effect": "每级初始道心 +7", "max": 5, "base_cost": 20},
	{"id": "root", "name": "灵根", "glyph": "根", "desc": "灵魂深处那一点灵性，渐渐改变了肉身。",
		"effect": "每级修炼速度 +8%", "max": 5, "base_cost": 24},
	{"id": "stones", "name": "藏金", "glyph": "金", "desc": "埋在旧梦里的金银，醒来仍在手边。",
		"effect": "每级初始灵石 +35", "max": 5, "base_cost": 14},
	{"id": "lifespan", "name": "命树", "glyph": "命", "desc": "你欠地府的寿数，一年一年讨回来。",
		"effect": "每级初始寿元 +8", "max": 5, "base_cost": 22},
	{"id": "breakthrough", "name": "道基", "glyph": "基", "desc": "前世的每一次失败，都替你夯了一层土。",
		"effect": "每级突破成功率 +3%", "max": 5, "base_cost": 24},
]

const SURNAMES := ["沈", "顾", "陆", "苏", "谢", "江", "柳", "白", "秦", "叶", "林", "温", "裴", "宁", "云", "萧", "楚", "姜", "晏", "卫"]
const GIVEN_NAMES := ["青崖", "长歌", "问雪", "无咎", "照月", "含烟", "鹤衣", "知秋", "晚舟", "如玉", "玄", "不归", "疏影", "观澜", "拾薪", "望川", "簪星", "眠风", "归一", "渡", "停云", "折枝", "砚", "朝暮"]

const KARMA_TITLES := [
	{"min": 40, "name": "泽被苍生", "color": "#3f7564"},
	{"min": 15, "name": "侠骨仁心", "color": "#4f7b68"},
	{"min": -14, "name": "尘世凡人", "color": "#7a6b55"},
	{"min": -39, "name": "杀伐果断", "color": "#98613f"},
	{"min": -9999, "name": "魔焰滔天", "color": "#9d3d2f"},
]

const DEATH_EPITAPHS := {
	"low": [
		"你终究没能走出那座山。可山外的风，年年都会经过你的坟。",
		"凡人的一生，不过是仙人袖间落下的一粒灰。但你曾真实地活过。",
		"没有碑，没有名字。只有一株野草，记得你最后躺下的地方。",
	],
	"mid": [
		"你走时，山门里的钟响了三声。没人知道，那是为你。",
		"你曾离大道很近，近得只差一次呼吸。可惜大道从不为谁停留。",
		"人间还有你的传说。说书人添油加醋，却总漏掉你真正在意的那一段。",
	],
	"high": [
		"你死时，方圆百里的灵禽同时沉默。天地像在为一个故人让路。",
		"你已在仙路之上走了太远。远到回望时，人间只剩一盏模糊的灯。",
		"后来的人称你为前辈。他们不知道，你临终前想的，仍是那年檐下的雨。",
	],
	"ascend": [
		"天门开时，你看了一眼身后的人间。只一眼，便抵过万载苦修。",
		"雷云散尽，你在光里回头。这一世的名字，被你轻轻放下了。",
	],
}

static func get_realm(index: int) -> Dictionary:
	var i: int = clampi(index, 0, REALMS.size() - 1)
	return REALMS[i]

static func realm_name(index: int) -> String:
	return String(get_realm(index)["name"])

static func threshold(index: int) -> float:
	return float(get_realm(index)["threshold"])

static func weighted_pick(items: Array, rng: RandomNumberGenerator, weight_key: String = "weight") -> Dictionary:
	var total: float = 0.0
	for item: Dictionary in items:
		total += float(item.get(weight_key, 1.0))
	var roll: float = rng.randf() * total
	for item: Dictionary in items:
		roll -= float(item.get(weight_key, 1.0))
		if roll <= 0.0:
			return item
	return items[items.size() - 1]

static func upgrade_cost(upgrade: Dictionary, level: int) -> int:
	return int(upgrade["base_cost"]) + level * 12

static func karma_title(karma: int) -> Dictionary:
	for item: Dictionary in KARMA_TITLES:
		if karma >= int(item["min"]):
			return item
	return KARMA_TITLES[KARMA_TITLES.size() - 1]

static func random_name(rng: RandomNumberGenerator) -> String:
	return SURNAMES[rng.randi_range(0, SURNAMES.size() - 1)] + GIVEN_NAMES[rng.randi_range(0, GIVEN_NAMES.size() - 1)]

static func random_talent(rng: RandomNumberGenerator) -> Dictionary:
	return TALENTS[rng.randi_range(0, TALENTS.size() - 1)]
