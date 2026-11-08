class_name GameState
extends RefCounted

## 一世的全部状态与核心判定。界面只负责呈现与调度。

var player_name: String = "无名"
var origin: Dictionary = {}
var root: Dictionary = {}
var talents: Array = []
var realm: int = 0
var cultivation: float = 0.0
var age: int = 16
var lifespan: int = 80
var body: int = 32
var insight: int = 32
var luck: int = 32
var daoheart: int = 32
var stones: int = 0
var injury: int = 0
var hp: int = 100
var mp: int = 40
var learned_skills: Array[String] = []
var skill_mastery: Dictionary = {} # 按技能 ID 保存熟练度经验
var equipped_skills: Array[String] = [] # 旧存档兼容字段，不再作为实际装备栏
var equipped_methods: Array[String] = []
var equipped_martial: Array[String] = []
var pets: Array = []
var active_pet_index: int = -1
var mounts: Array = []
var active_mount_index: int = -1
var materials: Dictionary = {"凝露草": 0, "灵芝": 0, "妖狼獠牙": 0, "赤焰砂": 0, "寒潭鳞片": 0, "阴魂结晶": 0, "石傀核心": 0, "魔修血晶": 0, "蛟龙逆鳞": 0, "剑宗令牌": 0, "青岚灵叶": 0, "剑纹石": 0, "天京玉露": 0, "赤金砂": 0, "百年灵芝": 0, "九叶药草": 0, "天机铜片": 0, "玄纹晶石": 0, "荒古兽骨": 0, "妖兽精血": 0, "幽冥魂晶": 0, "血煞石": 0, "龙宫珍珠": 0}
var pills: Dictionary = {"小还丹": 0, "聚气散": 0, "大还丹": 0, "归元丹": 0, "青岚清心丹": 0, "天京玉露丹": 0, "药王续命丹": 0, "荒古血魄丹": 0, "归墟龙元丹": 0, "青岚剑心丹": 0, "天京玉髓丹": 0, "天机破障丹": 0, "荒古淬体丹": 0, "幽冥凝魂丹": 0}
var karma: int = 0
var treasures: Array = []
var treasure_ages: Dictionary = {}
var equipment: Dictionary = {}
var seen_events: Array = []
var met_npcs: Array[Dictionary] = []
var wander_seen_lines: Array[String] = []
var flags: Dictionary = {}
var logs: Array = []
var log_seq: int = 0
var alive: bool = true
var ascended: bool = false
var death_reason: String = ""
var death_handled: bool = false
var breakthrough_bonus: float = 0.0
var turn_count: int = 0
var faction_name: String = "散修"
var faction_rank: String = "无门无派"
var faction_contribution: int = 0
var sect_merit: int = 0
var sect_facility_level: int = 0
var sect_task_claimed_turn: int = -99
var sect_disciples: Array[Dictionary] = []
var sect_recruit_count: int = 0
var sect_tournament_turn: int = -99
var sect_tournament_wins: int = 0
var faction_reputation: Dictionary = {}
var faction_relations: Dictionary = {}
var world_conflict: int = 0
# 天下探索与动态世界（新增字段均带默认值，兼容旧存档）
var current_region: String = "东境·青岚山"
var discovered_regions: Array[String] = ["东境·青岚山"]
var faction_power_state: Dictionary = {}
var world_events: Array = []
var rival_npcs: Array[Dictionary] = []
var world_year: int = 1

const WORLD_FACTIONS := [
	{"name":"青岚剑宗", "kind":"宗门", "rank":"三品宗门", "style":"剑修", "power":78, "region":"东境·青岚山"},
	{"name":"大虞皇朝", "kind":"皇朝", "rank":"皇朝", "style":"皇权", "power":92, "region":"中州·天京"},
	{"name":"百草谷", "kind":"宗门", "rank":"四品宗门", "style":"丹道", "power":61, "region":"南境·药王岭"},
	{"name":"天机世家", "kind":"世家", "rank":"一流世家", "style":"阵法与推演", "power":73, "region":"西境·天机城"},
	{"name":"万妖盟", "kind":"妖族联盟", "rank":"妖族大盟", "style":"妖修", "power":84, "region":"北荒·万妖原"},
	{"name":"九幽魔宗", "kind":"魔道", "rank":"二品魔宗", "style":"魔道", "power":81, "region":"北境·葬魂渊"},
	{"name":"散修盟", "kind":"联盟", "rank":"跨境联盟", "style":"散修互助", "power":55, "region":"各地坊市"},
]

const ACTION_CULTIVATE := "cultivate"
const ACTION_COMPREHEND := "comprehend"
const ACTION_WANDER := "wander"
const ACTION_RECOVER := "recover"

const WORLD_REGIONS := [
	{"name":"东境·青岚山", "realm":0, "danger":1, "faction":"青岚剑宗", "desc":"群峰如剑，灵气清正，常有剑修遗迹与低阶妖兽出没。", "materials":["凝露草", "妖狼獠牙"], "specialty":"青岚灵叶、剑纹石", "beasts":[{"name":"青岚剑齿狼", "kind":"地域妖兽", "desc":"常年吞吐剑气，獠牙边缘生出细密剑纹。", "hp":68,"attack":11,"defense":3,"stones":24,"cultivation":28,"drop":"剑纹石"},{"name":"守山藤妖", "kind":"地域精怪", "desc":"扎根灵脉的古藤化妖，藤蔓间缠绕青色剑气。", "hp":88,"attack":10,"defense":5,"stones":30,"cultivation":34,"drop":"青岚灵叶"}], "events":["你在断崖石壁发现一段残缺剑痕，观摩许久，剑意略有精进。", "青岚剑宗弟子正在清剿山妖，你出手相助，获赠一包灵叶。", "山泉旁有剑修遗落的纳气心得，你读后心有所悟。"]},
	{"name":"中州·天京", "realm":1, "danger":2, "faction":"大虞皇朝", "desc":"皇城万坊林立，商旅、官修与各方使节云集。", "materials":["灵芝", "赤焰砂"], "specialty":"天京玉露、赤金砂", "beasts":[{"name":"金甲镇门兽", "kind":"地域灵兽", "desc":"皇城阵法孕育的守门灵兽，金甲坚实，攻守有度。", "hp":112,"attack":16,"defense":8,"stones":52,"cultivation":48,"drop":"赤金砂"},{"name":"皇陵噬金鼠", "kind":"地域妖兽", "desc":"啃食皇陵金属灵材长大，双爪能撕开护体灵光。", "hp":90,"attack":17,"defense":4,"stones":48,"cultivation":42,"drop":"天京玉露"}], "events":["你恰逢天京坊市开市，以合理价格购得一份天京玉露。", "大虞皇朝张榜悬赏，你协助追查线索，获得官府酬谢。", "一场小型拍卖会正在举行，你从旧物中辨出一块罕见赤金砂。"]},
	{"name":"南境·药王岭", "realm":1, "danger":2, "faction":"百草谷", "desc":"灵雾缭绕，药田与古木遍布，盛产疗伤和炼丹灵材。", "materials":["凝露草", "灵芝"], "specialty":"百年灵芝、九叶药草", "beasts":[{"name":"药王守山蟒", "kind":"地域妖兽", "desc":"吞食灵药蜕变的青鳞巨蟒，毒雾中带着浓郁药香。", "hp":106,"attack":16,"defense":6,"stones":46,"cultivation":46,"drop":"九叶药草"},{"name":"百草药灵", "kind":"地域精怪", "desc":"由千年药气凝成的小小灵物，受惊后会催生荆棘护身。", "hp":76,"attack":13,"defense":4,"stones":42,"cultivation":52,"drop":"百年灵芝"}], "events":["一片药田恰逢灵药成熟，你辨认出其中的九叶药草并采下一株。", "百草谷发布药王试炼，你完成辨药考验，得到灵芝奖励。", "山谷毒瘴忽然扩散，你以灵力护住口鼻，反而在瘴气边缘找到珍贵药材。"]},
	{"name":"西境·天机城", "realm":2, "danger":3, "faction":"天机世家", "desc":"阵纹刻入城墙，古阵、机关与天机残卷隐于坊市深处。", "materials":["赤焰砂", "石傀核心"], "specialty":"天机铜片、玄纹晶石", "beasts":[{"name":"巡城机关傀", "kind":"地域傀儡", "desc":"由天机世家遗弃的巡城傀儡改造而成，招式严谨。", "hp":142,"attack":19,"defense":11,"stones":66,"cultivation":60,"drop":"天机铜片"},{"name":"阵眼灵兽", "kind":"地域灵兽", "desc":"古阵阵眼中诞生的灵兽，能借阵纹短暂强化自身。", "hp":126,"attack":21,"defense":8,"stones":70,"cultivation":64,"drop":"玄纹晶石"}], "events":["你破解一座废弃小阵，阵眼中弹出一枚天机铜片。", "天机世家招募外客检修机关，你协助排除故障，获得酬劳。", "古城墙上的阵纹忽然亮起，你循着灵光找到一处隐藏储物匣。"]},
	{"name":"北荒·万妖原", "realm":3, "danger":4, "faction":"万妖盟", "desc":"妖族部落逐水草而居，强大妖兽守护着古老血脉与宝材。", "materials":["妖狼獠牙", "寒潭鳞片"], "specialty":"荒古兽骨、妖兽精血", "beasts":[{"name":"裂地蛮熊", "kind":"地域妖兽", "desc":"体内流淌荒古血脉，一掌落下便能震裂地面。", "hp":190,"attack":27,"defense":10,"stones":112,"cultivation":96,"drop":"荒古兽骨"},{"name":"万妖狼王", "kind":"地域妖兽", "desc":"统御狼群的妖王，额间有一道古老妖纹。", "hp":174,"attack":29,"defense":8,"stones":120,"cultivation":104,"drop":"妖兽精血"}], "events":["你遇见妖族部落举行易物集会，以灵石换得一份荒古兽骨。", "草原突发小规模兽潮，你协助部落守住营地，获得妖兽精血。", "狼王留下的古老足迹指向一处兽穴，你在外围寻得珍贵材料。"]},
	{"name":"北境·葬魂渊", "realm":4, "danger":5, "faction":"九幽魔宗", "desc":"阴气终年不散，魔修洞府与古战场遗骸沉于深渊。", "materials":["阴魂结晶", "魔修血晶"], "specialty":"幽冥魂晶、血煞石", "beasts":[{"name":"葬魂鬼将", "kind":"地域亡灵", "desc":"古战场残魂凝成的鬼将，锈甲之下魂火不灭。", "hp":220,"attack":31,"defense":12,"stones":148,"cultivation":126,"drop":"幽冥魂晶"},{"name":"血煞噬心兽", "kind":"地域魔兽", "desc":"吞噬修士精血成长的凶兽，血雾能侵蚀护体灵力。", "hp":208,"attack":34,"defense":9,"stones":156,"cultivation":132,"drop":"血煞石"}], "events":["古战场残碑显露一段战诀，你承受住煞气侵袭后有所领悟。", "你发现一处废弃魔宗洞府，在外围石室寻得幽冥魂晶。", "阴魂夜哭引来游荡亡灵，你布下简易阵法脱身，并拾得血煞石。"]},
	{"name":"海外·归墟海", "realm":5, "danger":6, "faction":"散修盟", "desc":"万里海域暗藏龙宫遗迹，潮汐深处偶见蛟龙逆鳞。", "materials":["寒潭鳞片", "蛟龙逆鳞"], "specialty":"龙宫珍珠、蛟龙逆鳞", "beasts":[{"name":"归墟海蛟", "kind":"地域海妖", "desc":"盘踞深海裂谷的蛟类，吐息可冻结海面。", "hp":270,"attack":39,"defense":13,"stones":190,"cultivation":164,"drop":"蛟龙逆鳞"},{"name":"玄潮镇海龟", "kind":"地域灵兽", "desc":"背负古老海纹的巨龟，能引动潮汐形成护盾。", "hp":310,"attack":33,"defense":18,"stones":205,"cultivation":172,"drop":"龙宫珍珠"}], "events":["退潮时一艘古船露出海面，你在船舱中找到龙宫珍珠。", "海底遗迹传来龙吟，你循声找到一片蛟龙蜕下的逆鳞。", "散修盟商船遭遇海妖袭击，你助其脱险，获得海贸谢礼。"]}
]

const CULTIVATE_LINES := [
	"你盘膝而坐，引天地灵气入体。丹田如一口深井，缓慢而坚定地涨潮。",
	"晨露未干，你已运转了三个周天。灵气洗过经脉，像一场极细的春雨。",
	"你守着丹田里那一点微光，一坐便是一年。窗外花开花落，与你无关。",
	"山风穿过洞府，你吐出一口浊气。气机又凝实了一分。",
	"你以神念为犁，一寸寸翻耕经脉。枯燥，却是这世上最诚实的路。",
]

const COMPREHEND_LINES := [
	"你观一叶落，忽觉生死不过一场循环。那点灵光落进识海，无声无息。",
	"你读前人残卷，读到“大道无情”四字，停了很久。书页被风吹动，像谁在替你翻页。",
	"雨打芭蕉，你听了一夜。忽然明白，心若不动，万物都只是万物。",
	"你试着把一缕灵气拆解、重组、再拆解。每明白一层，便觉得自己更小一点。",
	"你在溪边看水，看见的不是水，是时间。那一刻，你忘了自己身在何处。",
]

const WANDER_LINES := [
	"清晨薄雾未散，你沿着青石小径走进山村。炊烟从屋檐间升起，孩童追着一只黄狗跑过田埂。",
	"你在古桥下避雨，听卖伞的老人讲起三十年前的洪水。桥洞里水声潺潺，仿佛仍记得当年的惊涛。",
	"一队行脚商人邀你同行。途中有人谈起远方的仙山，有人只惦记家中刚出生的孩子。",
	"你经过一片收割后的稻田，帮独自劳作的农妇搬完最后几捆稻谷。她塞给你一只热腾腾的杂粮饼。",
	"夜宿荒寺，檐角铜铃被风吹得轻响。你在残缺壁画前坐了片刻，想起许多已经模糊的旧事。",
	"渡船缓缓离岸，江面映着两岸灯火。船上少年问你何处是仙乡，你没有给出答案。",
	"你走进一座热闹的集镇，药铺飘出草木清香，铁匠铺传来叮当声，街头说书人正讲一段古修传奇。",
	"山道旁有株老梅开得正盛，几片花瓣落在你的肩头。采药人说这树每逢寒冬都会开花，从未失约。",
	"你在边城客栈听见几名旅人争论天下局势。有人忧心战事，有人盼着归乡，桌上的酒渐渐凉了。",
	"一场大雨过后，你帮村民清理被冲毁的木桥。夕阳落在新架起的桥板上，照得水面一片金红。",
	"你沿着溪流走了很久，遇见一位正在洗药的年轻医者。她说山中百草各有性情，和世人并无不同。",
	"傍晚经过牧场，成群灵鹿从远处山坡缓缓走过。牧童吹起短笛，笛声随着晚风飘向云间。",
	"你在旧书摊翻到一本残缺游记，里面记着一座地图上早已消失的小城。摊主说，那地方如今只剩风声。",
	"清晨的集市刚刚开张，卖花姑娘把一枝不知名的野花插在你衣襟上，笑说愿它替你带来好天气。",
	"你经过一处废弃驿站，墙上还留着许多旅人的刻字。有人盼归，有人求仙，也有人只写下了一个名字。",
]

static func new_life(soul: Dictionary, rng: RandomNumberGenerator) -> GameState:
	var state := GameState.new()
	var upgrades: Dictionary = soul.get("upgrades", {})

	state.origin = GameData.ORIGINS[rng.randi_range(0, GameData.ORIGINS.size() - 1)].duplicate(true)
	state.root = GameData.roll_root(rng)
	state.root["speed"] = float(state.root.get("speed", 1.0)) + float(upgrades.get("root", 0)) * 0.08
	state.player_name = GameData.random_name(rng)
	state.learned_skills = ["qi_sword"]
	state.equipped_skills = ["qi_sword"]
	state.equipped_methods = []
	state.equipped_martial = ["qi_sword"]

	state.talents.append(GameData.random_talent(rng).duplicate(true))
	if rng.randf() < 0.16:
		var second: Dictionary = GameData.random_talent(rng).duplicate(true)
		if String(second["name"]) != String(state.talents[0]["name"]):
			state.talents.append(second)

	state.body = 30 + rng.randi_range(-4, 5)
	state.insight = 30 + rng.randi_range(-4, 5)
	state.luck = 30 + rng.randi_range(-4, 5)
	state.daoheart = 30 + rng.randi_range(-4, 5)

	_apply_birth_stats(state, state.origin, "stats")
	_apply_birth_stats(state, state.root, "stats")
	for talent: Dictionary in state.talents:
		_apply_birth_stats(state, talent, "stats")

	state.body += int(upgrades.get("body", 0)) * 7
	state.insight += int(upgrades.get("insight", 0)) * 7
	state.luck += int(upgrades.get("luck", 0)) * 6
	state.daoheart += int(upgrades.get("daoheart", 0)) * 7

	state.body = clampi(state.body, 12, 100)
	state.insight = clampi(state.insight, 12, 100)
	state.luck = clampi(state.luck, 12, 100)
	state.daoheart = clampi(state.daoheart, 12, 100)

	state.stones = int(state.origin.get("stones", 0)) + int(upgrades.get("stones", 0)) * 35
	state.hp = state.max_hp()
	state.mp = state.max_mp()
	state.karma = int(upgrades.get("karma", 0)) * 6
	for talent: Dictionary in state.talents:
		state.karma += int(talent.get("karma", 0))

	state.lifespan = 72 + int(state.body * 0.38) + int(upgrades.get("lifespan", 0)) * 8 + rng.randi_range(-4, 6)
	for talent: Dictionary in state.talents:
		state.lifespan += int(talent.get("lifespan", 0))
	state.breakthrough_bonus = float(upgrades.get("breakthrough", 0)) * 3.0
	state.equipment = empty_equipment()
	state.age = 16
	state.faction_name = "散修"
	state.faction_rank = "无门无派"
	for faction: Dictionary in WORLD_FACTIONS:
		state.faction_reputation[String(faction["name"])] = 0
		state.faction_relations[String(faction["name"])] = "中立"
	state.world_conflict = rng.randi_range(1, 3)
	for faction: Dictionary in WORLD_FACTIONS:
		state.faction_power_state[String(faction["name"])] = int(faction.get("power", 50))
	state.current_region = "东境·青岚山"
	state.discovered_regions = [state.current_region]

	state.add_log("【入世】" + String(state.origin["birth"]), "birth")
	state.add_log("十六岁这年，你在静坐时照见丹田中一点微光。村口的老槐树无风自动，你第一次听见天地之间那种极轻的呼吸。", "story")
	state.add_log("你决定离开故土，去寻一条看不见尽头的路。", "story")
	state.add_log("【灵根测定】你身具%s·%s。属性越杂，灵气越难提纯。" % [String(state.root.get("grade_name", "伪灵根")), String(state.root.get("name", "五行"))], "birth")
	state.add_log("【天下大势】宗门、皇朝、世家、妖盟与魔道并立，诸方势力争夺灵脉与秘境。", "world")
	state._seed_rival_npc(rng)
	return state

static func _apply_birth_stats(state: GameState, source: Dictionary, key: String) -> void:
	var stats: Dictionary = source.get(key, {})
	state.body += int(stats.get("body", 0))
	state.insight += int(stats.get("insight", 0))
	state.luck += int(stats.get("luck", 0))
	state.daoheart += int(stats.get("daoheart", 0))

static func empty_equipment() -> Dictionary:
	var slots: Dictionary = {}
	for slot: Dictionary in GameData.EQUIP_SLOTS:
		slots[String(slot["id"])] = ""
	return slots

func _ensure_equipment_slots() -> void:
	for slot: Dictionary in GameData.EQUIP_SLOTS:
		var id: String = String(slot["id"])
		if not equipment.has(id):
			equipment[id] = ""

func equipped_item(slot_id: String) -> String:
	return String(equipment.get(slot_id, ""))

func is_equipped(item_name: String) -> bool:
	for slot_id: Variant in equipment.keys():
		if String(equipment[slot_id]) == item_name:
			return true
	return false

func equipment_bonus(stat_key: String) -> int:
	var total: int = 0
	for slot: Dictionary in GameData.EQUIP_SLOTS:
		var slot_id: String = String(slot["id"])
		var item_name: String = equipped_item(slot_id)
		if item_name.is_empty():
			continue
		var info: Dictionary = GameData.treasure_info(item_name)
		if String(info.get("slot", "")) != slot_id:
			continue
		var stats: Dictionary = info.get("stats", {})
		total += int(stats.get(stat_key, 0))
	return total

func origin_mod(mod_key: String) -> float:
	var perks: Dictionary = origin.get("perks", {})
	return float(perks.get(mod_key, 0.0))

func relic_mod(mod_key: String) -> float:
	var total: float = 0.0
	for item_value: Variant in treasures:
		var item_name: String = String(item_value)
		var passive: Dictionary = GameData.relic_passive_info(item_name)
		var mods: Dictionary = passive.get("mods", {})
		total += float(mods.get(mod_key, 0.0))
	return total

func relic_stat_bonus(stat_key: String) -> int:
	var total: int = 0
	for item_value: Variant in treasures:
		var passive: Dictionary = GameData.relic_passive_info(String(item_value))
		var stats: Dictionary = passive.get("stats", {})
		total += int(stats.get(stat_key, 0))
	return total

func max_hp() -> int:
	return maxi(1, 80 + effective_stat("body") * 2 + realm * 14 + int(round(origin_mod("max_hp") + root_combat_mod("max_hp") + method_bonus("max_hp") + relic_mod("max_hp"))))

## 战斗衍生属性：根骨偏向肉身攻防，气运偏向暴击与闪避。
func root_combat_mod(key: String) -> float:
	# 灵根不只决定修炼速度，也形成各自的战斗倾向。
	var root_name := String(root.get("rank", root.get("grade_name", "")))
	var mods := {
		"伪灵根": {"defense": 2.0, "max_hp": 8.0},
		"真灵根": {"skill_power": 0.04, "max_mp": 6.0},
		"双灵根": {"skill_power": 0.06, "critical_rate": 1.0},
		"天灵根": {"skill_power": 0.10, "max_mp": 12.0},
		"变异灵根": {"attack": 2.0, "skill_power": 0.10, "critical_rate": 3.0},
	}
	return float(mods.get(root_name, {}).get(key, 0.0))

func attack_power() -> int:
	return maxi(1, 6 + int(round(effective_stat("body") * 0.42)) + realm * 2 + int(round(equipment_mod("attack") + origin_mod("attack") + root_combat_mod("attack") + relic_mod("attack"))))

func defense_power() -> int:
	return maxi(0, int(round(effective_stat("body") * 0.16 + effective_stat("daoheart") * 0.08)) + int(round(equipment_mod("defense") + origin_mod("defense") + root_combat_mod("defense") + method_bonus("defense") + relic_mod("defense"))))

func critical_rate() -> float:
	return clampf(0.04 + float(effective_stat("luck")) * 0.002 + (equipment_mod("critical_rate") + origin_mod("critical_rate") + root_combat_mod("critical_rate") + relic_mod("critical_rate")) / 100.0, 0.04, 0.45)

func speed_power() -> int:
	# 速度决定身法与战斗反应；装备速度会直接计入闪避判定。
	return maxi(1, 20 + int(round(effective_stat("body") * 0.18 + effective_stat("daoheart") * 0.12)) + int(round(equipment_mod("speed") + origin_mod("speed") + root_combat_mod("speed") + relic_mod("speed"))))

func evasion_rate() -> float:
	var speed_bonus: float = float(maxi(0, speed_power() - 20)) * 0.0015
	return clampf(0.01 + float(effective_stat("luck")) * 0.001 + speed_bonus + (equipment_mod("evasion") + origin_mod("evasion") + root_combat_mod("evasion") + relic_mod("evasion")) / 100.0, 0.01, 0.35)

func skill_power_bonus() -> float:
	return (equipment_mod("skill_power") + origin_mod("skill_power") + relic_mod("skill_power")) / 100.0 + root_combat_mod("skill_power")

func max_mp() -> int:
	return maxi(1, 25 + effective_stat("insight") + realm * 10 + int(round(origin_mod("max_mp") + root_combat_mod("max_mp") + method_bonus("max_mp") + relic_mod("max_mp"))))

func effective_stat(stat_key: String) -> int:
	var base: int = int(get(stat_key))
	return clampi(base + equipment_bonus(stat_key) + relic_stat_bonus(stat_key), 1, 120)

func equipment_mod(mod_key: String) -> float:
	var total: float = 0.0
	for slot: Dictionary in GameData.EQUIP_SLOTS:
		var slot_id: String = String(slot["id"])
		var item_name: String = equipped_item(slot_id)
		if item_name.is_empty():
			continue
		var info: Dictionary = GameData.treasure_info(item_name)
		if String(info.get("slot", "")) != slot_id:
			continue
		var mods: Dictionary = info.get("mods", {})
		total += float(mods.get(mod_key, 0.0))
	return total

func _cultivation_multiplier() -> float:
	var grade_bonus := float(root.get("grade_speed", 1.0))
	var sect_bonus := float(sect_facility_level) * 0.025 if is_faction_member() else 0.0
	return (1.0 + (equipment_mod("cultivation") + origin_mod("cultivation") + relic_mod("cultivation")) / 100.0 + sect_bonus + method_bonus("cultivation")) * grade_bonus

func is_faction_member() -> bool:
	return faction_name != "散修"

func is_sect_member() -> bool:
	var kind := String(faction_info().get("kind", ""))
	return kind == "宗门" or kind == "魔道"

func _sect_promote_if_ready() -> String:
	if not is_sect_member():
		return ""
	var ranks := [
		{"name":"外门弟子", "merit":0, "realm":0},
		{"name":"内门弟子", "merit":80, "realm":1},
		{"name":"真传弟子", "merit":220, "realm":2},
		{"name":"执事", "merit":420, "realm":3},
		{"name":"长老", "merit":750, "realm":4},
		{"name":"太上长老", "merit":1250, "realm":6},
		{"name":"宗主", "merit":2000, "realm":8}
	]
	var best := "外门弟子"
	for entry: Dictionary in ranks:
		if sect_merit >= int(entry["merit"]) and realm >= int(entry["realm"]):
			best = String(entry["name"])
	if best != faction_rank:
		var old := faction_rank
		faction_rank = best
		add_log("【宗门晋升】你在%s的身份由%s晋升为%s。" % [faction_name, old, best], "world")
		return "恭喜晋升为%s！" % best
	return ""

func _faction_promote_if_ready() -> String:
	if not is_faction_member(): return ""
	var thresholds := [0, 80, 220, 420, 750, 1250, 2000]
	var kind := String(faction_info().get("kind", ""))
	var rank_sets := {
		"皇朝":["从九品供奉", "九品校尉", "八品统领", "七品都尉", "六品将军", "五品镇守", "四品统帅"],
		"妖族联盟":["外围妖将", "部族勇士", "百夫妖长", "千夫妖将", "部族统领", "大部妖王", "万妖盟主"],
		"世家":["外姓门客", "家族供奉", "执事", "客卿长老", "家族长老", "太上供奉", "家主"],
		"联盟":["外围执事", "正式成员", "资深成员", "分舵管事", "分舵长老", "总坛护法", "盟主"]
	}
	var ranks: Array = rank_sets.get(kind, ["初阶成员", "正式成员", "精英成员", "执事", "长老", "护法", "首领"])
	var best := String(ranks[0])
	for i in range(thresholds.size()):
		if faction_contribution >= thresholds[i] and realm >= mini(8, i): best = String(ranks[i])
	if best != faction_rank:
		var old := faction_rank
		faction_rank = best
		add_log("【势力晋升】你在%s的身份由%s晋升为%s。" % [faction_name, old, best], "world")
		return "身份晋升为%s！" % best
	return ""

func sect_donate(amount: int) -> Dictionary:
	if not is_faction_member(): return {"ok":false, "message":"加入势力后方可上缴资源。"}
	if amount < 50 or stones < amount: return {"ok":false, "message":"灵石不足，至少需要五十枚灵石。"}
	stones -= amount
	var gained := maxi(1, int(amount / 2))
	faction_contribution += gained
	sect_merit += gained
	faction_reputation[faction_name] = int(faction_reputation.get(faction_name, 0)) + maxi(1, int(amount / 25))
	var sect_promotion_text := _sect_promote_if_ready() if is_sect_member() else _faction_promote_if_ready()
	add_log("【势力供奉】你向%s上缴%d枚灵石，获得%d点贡献。" % [faction_name, amount, gained], "world")
	return {"ok":true, "message":"供奉成功，获得%d点贡献。%s" % [gained, sect_promotion_text]}

func sect_claim_task() -> Dictionary:
	if not is_faction_member(): return {"ok":false, "message":"加入势力后方可领取势力差事。"}
	if turn_count - sect_task_claimed_turn < 3: return {"ok":false, "message":"执事告知：每隔三次行动方可再领一份宗门差事。"}
	sect_task_claimed_turn = turn_count
	var task_index := posmod(turn_count + realm + faction_contribution, 3)
	var task_names := ["巡山除妖", "采集灵药", "护送商队"]
	var task_desc := ["你循山道斩杀作乱妖兽，带回了妖狼獠牙。", "你在灵谷采得几株药草，按时交回药堂。", "你护送商队穿过险道，商队管事奉上酬劳。"]
	var contribution_gain := 28 + realm * 3
	var stone_gain := 18 + realm * 5
	faction_contribution += contribution_gain
	sect_merit += contribution_gain
	stones += stone_gain
	if task_index == 0: materials["妖狼獠牙"] = int(materials.get("妖狼獠牙", 0)) + 1
	elif task_index == 1: materials["凝露草"] = int(materials.get("凝露草", 0)) + 2
	else: karma += 1
	var sect_promotion_text := _sect_promote_if_ready() if is_sect_member() else _faction_promote_if_ready()
	add_log("【势力差事】%s %s 获得%d枚灵石与%d点贡献。" % [task_names[task_index], task_desc[task_index], stone_gain, contribution_gain], "world")
	return {"ok":true, "message":"完成势力差事：%s\n获得%d枚灵石、%d点贡献。%s" % [task_names[task_index], stone_gain, contribution_gain, sect_promotion_text]}

func sect_upgrade_facility() -> Dictionary:
	if not is_faction_member(): return {"ok":false, "message":"加入势力后方可使用专属修炼设施。"}
	if sect_facility_level >= 3: return {"ok":false, "message":"势力专属设施已提升至当前最高等级。"}
	var stone_cost := 120 + sect_facility_level * 100
	var contribution_cost := 40 + sect_facility_level * 30
	if stones < stone_cost or faction_contribution < contribution_cost:
		return {"ok":false, "message":"升级需要%d枚灵石与%d点宗门贡献。" % [stone_cost, contribution_cost]}
	stones -= stone_cost
	faction_contribution -= contribution_cost
	sect_facility_level += 1
	add_log("【势力建设】你协助提升%s专属修炼设施至%d级，修炼效率提高。" % [faction_name, sect_facility_level], "world")
	return {"ok":true, "message":"专属修炼设施升至%d级，修炼效率额外提高%.1f%%。" % [sect_facility_level, float(sect_facility_level) * 2.5]}

func sect_enter_tournament() -> Dictionary:
	if not is_sect_member(): return {"ok":false, "message":"只有宗门弟子可以参加宗门大比。"}
	if turn_count - sect_tournament_turn < 10: return {"ok":false, "message":"宗门大比每十次行动举办一次，距离下一届尚需%d次行动。" % (10 - (turn_count - sect_tournament_turn))}
	sect_tournament_turn = turn_count
	var opponents := ["外门首席·林惊鸿", "内门剑修·顾长风", "真传弟子·苏照雪", "执法堂弟子·周无咎", "同门强者·沈青禾"]
	var opponent_index := posmod(turn_count + realm + sect_tournament_wins, opponents.size())
	var opponent_name: String = opponents[opponent_index]
	var opponent_power := 24 + opponent_index * 9 + realm * 8 + posmod(turn_count, 13)
	var player_power := body + insight / 2 + daoheart + realm * 15 + equipped_martial.size() * 8 + equipped_methods.size() * 5
	var margin := player_power - opponent_power
	if margin >= 0:
		var stone_reward := 35 + realm * 12
		var merit_reward := 25 + realm * 8
		stones += stone_reward
		faction_contribution += merit_reward
		sect_merit += merit_reward
		sect_tournament_wins += 1
		var promotion := _sect_promote_if_ready()
		add_log("【宗门大比】你在擂台上胜过%s，夺得本届魁首。" % opponent_name, "gain")
		return {"ok":true, "message":"宗门大比获胜！\n你以%d点战力胜过%s（对手%d点），夺得魁首。\n奖励：灵石%d、宗门贡献%d。\n累计夺魁：%d次。%s" % [player_power, opponent_name, opponent_power, stone_reward, merit_reward, sect_tournament_wins, promotion]}
	var consolation := 12 + realm * 4
	faction_contribution += consolation
	sect_merit += consolation
	add_log("【宗门大比】你惜败于%s，仍凭表现获得同门认可。" % opponent_name, "world")
	return {"ok":true, "message":"宗门大比惜败。\n你以%d点战力不敌%s（对手%d点），但仍获得参与奖励：宗门贡献%d。\n十次行动后可再参加。" % [player_power, opponent_name, opponent_power, consolation]}

func sect_recruit_disciple() -> Dictionary:
	if not is_sect_member(): return {"ok":false, "message":"只有宗门或魔宗成员可以招收弟子。"}
	if faction_rank not in ["执事", "长老", "太上长老", "宗主"]: return {"ok":false, "message":"你的身份尚不足以招收弟子，至少需要晋升为执事。"}
	if sect_disciples.size() >= 5: return {"ok":false, "message":"名下弟子已达五人上限，请先培养现有弟子。"}
	var cost := 30 + sect_disciples.size() * 20
	if stones < cost: return {"ok":false, "message":"招收弟子需要%d枚灵石作为安置费用。" % cost}
	stones -= cost
	var names := ["沈青禾", "顾长风", "苏小棠", "陆沉", "叶知秋", "林照雪", "周不疑", "许星河", "秦若水", "陈默"]
	var roots := ["伪灵根·五行", "伪灵根·金木水火", "真灵根·金木水", "双灵根·水火", "天灵根·木", "变异灵根·雷"]
	var index: int = posmod(int(turn_count) + int(sect_recruit_count) * 3 + int(realm), names.size())
	var root_label: String = roots[posmod(turn_count + sect_recruit_count, roots.size())]
	var disciple := {"id": "disciple_%d_%d" % [turn_count, sect_recruit_count], "name": names[index], "root_type": "", "root_grade": root_label, "realm": 0, "cultivation": 0, "loyalty": 70 + posmod(turn_count + sect_recruit_count, 26), "aptitude": 30 + posmod(turn_count * 7 + sect_recruit_count * 11, 61), "training": 0}
	sect_recruit_count += 1
	sect_disciples.append(disciple)
	sect_merit += 8
	add_log("【宗门收徒】你为%s录入名册：%s，%s。" % [faction_name, disciple["name"], root_label], "world")
	return {"ok":true, "message":"新弟子%s已入门！\n灵根：%s\n资质：%d · 忠诚：%d\n安置消耗：%d灵石。" % [disciple["name"], root_label, disciple["aptitude"], disciple["loyalty"], cost]}

func sect_train_disciple(index: int) -> Dictionary:
	if not is_sect_member() or index < 0 or index >= sect_disciples.size(): return {"ok":false, "message":"弟子信息无效。"}
	var disciple: Dictionary = sect_disciples[index]
	var cost := 20 + int(disciple.get("training", 0)) * 10
	if stones < cost: return {"ok":false, "message":"培养需要%d枚灵石。" % cost}
	stones -= cost
	var gain := maxi(1, int(int(disciple.get("aptitude", 30)) / 20.0))
	disciple["training"] = int(disciple.get("training", 0)) + 1
	disciple["cultivation"] = int(disciple.get("cultivation", 0)) + gain * 10
	disciple["loyalty"] = mini(100, int(disciple.get("loyalty", 50)) + 3)
	if int(disciple["cultivation"]) >= 100:
		disciple["cultivation"] = int(disciple["cultivation"]) - 100
		disciple["realm"] = int(disciple.get("realm", 0)) + 1
	sect_disciples[index] = disciple
	add_log("【弟子教导】你亲自指点%s，修为有所精进。" % disciple["name"], "world")
	return {"ok":true, "message":"指点%s成功，修炼进度增加%d，忠诚度提升。" % [disciple["name"], gain * 10]}

func sect_scripture_learn(skill_id: String) -> Dictionary:
	if not is_sect_member(): return {"ok":false, "message":"加入宗门后方可进入藏经阁。"}
	var info := BattleSystem.skill_data(skill_id)
	if info.is_empty(): return {"ok":false, "message":"未找到此典籍。"}
	var rank_gate := {"黄阶":0, "玄阶":1, "地阶":2, "天阶":3}
	var rank_name := String(info.get("rank", "黄阶下品"))
	var major := rank_name.substr(0, 2)
	var identity_gate := {"外门弟子":0, "内门弟子":1, "真传弟子":2, "执事":2, "长老":3, "太上长老":3, "宗主":3}
	if int(rank_gate.get(major, 0)) > int(identity_gate.get(faction_rank, 0)):
		return {"ok":false, "message":"身份权限不足，%s暂不可阅览%s典籍。" % [faction_rank, rank_name]}
	if learned_skills.has(skill_id): return {"ok":false, "message":"你已经掌握此门典籍。"}
	var cost := int(info.get("cost", 0))
	var merit_cost := 15 + int(info.get("realm", 0)) * 5
	if realm < int(info.get("realm", 0)) or stones < cost or faction_contribution < merit_cost:
		return {"ok":false, "message":"研习需要境界%d、灵石%d枚、宗门贡献%d点。" % [int(info.get("realm", 0)), cost, merit_cost]}
	stones -= cost
	faction_contribution -= merit_cost
	learned_skills.append(skill_id)
	add_log("【藏经阁】你在%s藏经阁参悟%s。" % [faction_name, info["name"]], "world")
	return {"ok":true, "message":"参悟成功，已学会%s（%s）。记得前往对应典籍界面装备。" % [info["name"], rank_name]}

func sect_exchange_pill() -> Dictionary:
	if not is_faction_member(): return {"ok":false, "message":"加入势力后方可兑换专属资源。"}
	if faction_contribution < 35: return {"ok":false, "message":"兑换聚气散需要35点宗门贡献。"}
	faction_contribution -= 35
	pills["聚气散"] = int(pills.get("聚气散", 0)) + 1
	add_log("【宗门宝库】你以35点贡献兑换了一份聚气散。", "world")
	return {"ok":true, "message":"兑换成功，获得聚气散×1。"}

func faction_info() -> Dictionary:
	for faction: Dictionary in WORLD_FACTIONS:
		if String(faction["name"]) == faction_name:
			var info := faction.duplicate(true)
			info["power"] = int(faction_power_state.get(faction_name, faction.get("power", 50)))
			return info
	return {"name":"散修", "kind":"散修", "rank":"无门无派", "style":"自由修行", "power":0, "region":"天下各处"}

func join_faction(target_name: String) -> Dictionary:
	if faction_name != "散修":
		return {"ok":false, "message":"你已身在%s，若要另投他方，须先处理原有身份。" % faction_name}
	for faction: Dictionary in WORLD_FACTIONS:
		if String(faction["name"]) != target_name:
			continue
		var required_realm := 0
		if target_name == "青岚剑宗" or target_name == "九幽魔宗" or target_name == "大虞皇朝":
			required_realm = 1
		if realm < required_realm:
			return {"ok":false, "message":"对方要求至少踏入筑基境，方可正式收录门墙。"}
		faction_name = target_name
		var kind := String(faction["kind"])
		match kind:
			"宗门", "魔道": faction_rank = "外门弟子"
			"皇朝": faction_rank = "从九品供奉"
			"妖族联盟": faction_rank = "外围妖将"
			"世家": faction_rank = "外姓门客"
			"联盟": faction_rank = "外围执事"
			_: faction_rank = "客卿成员"
		faction_reputation[target_name] = int(faction_reputation.get(target_name, 0)) + 10
		add_log("【势力归属】你经引荐加入%s，身份为%s。从此修行不再只是独行。" % [target_name, faction_rank], "world")
		return {"ok":true, "message":"你已加入%s。" % target_name}
	return {"ok":false, "message":"未找到该势力。"}

func faction_leave() -> Dictionary:
	if faction_name == "散修":
		return {"ok":false, "message":"你本就是散修，无需退出。"}
	var old_name := faction_name
	faction_name = "散修"
	faction_rank = "无门无派"
	faction_contribution = 0
	sect_merit = 0
	sect_facility_level = 0
	sect_task_claimed_turn = -99
	sect_disciples.clear()
	sect_recruit_count = 0
	sect_tournament_turn = -99
	sect_tournament_wins = 0
	add_log("【脱离势力】你离开%s，重新成为一名散修。" % old_name, "world")
	return {"ok":true, "message":"已脱离%s。" % old_name}

func _mitigated_injury(amount: int) -> int:
	if amount <= 0:
		return amount
	var reduction: float = clampf(equipment_mod("injury_reduction") + relic_mod("injury_reduction"), 0.0, 60.0) / 100.0
	return maxi(1, int(round(float(amount) * (1.0 - reduction))))

func equip_item(item_name: String) -> String:
	if not treasures.has(item_name):
		return ""
	var info: Dictionary = GameData.treasure_info(item_name)
	var slot_id: String = String(info.get("slot", ""))
	if slot_id.is_empty():
		return ""
	_ensure_equipment_slots()
	var previous: String = equipped_item(slot_id)
	equipment[slot_id] = item_name
	return previous

func activate_treasure(item_name: String) -> Dictionary:
	if not treasures.has(item_name):
		return {"ok": false, "message": "你并未持有此物。"}
	var active: Dictionary = GameData.treasure_active_info(item_name)
	if active.is_empty():
		return {"ok": false, "message": "此物暂未发现可主动施展的用途。"}
	var used: Array = flags.get("used_treasures", [])
	if used.has(item_name):
		return {"ok": false, "message": "此物中的灵韵已经耗尽，本世无法再次启用。"}
	var effect: String = String(active.get("effect", ""))
	var gain: int = 0
	match effect:
		"cultivation_insight":
			gain = maxi(1, int(round(threshold() * 0.12)))
			cultivation += gain
			insight += 2
		"lifespan_luck":
			lifespan += 5
			luck += 1
		"cultivation_daoheart":
			gain = maxi(1, int(round(threshold() * 0.18)))
			cultivation += gain
			daoheart += 2
		"restore_mp_daoheart":
			mp = mini(max_mp(), mp + maxi(1, int(round(max_mp() * 0.5))))
			daoheart += 1
		"star_insight":
			gain = maxi(1, int(round(threshold() * 0.25)))
			cultivation += gain
			insight += 3
			hp = maxi(1, hp - maxi(1, int(round(max_hp() * 0.08))))
		"restore_both":
			hp = mini(max_hp(), hp + maxi(1, int(round(max_hp() * 0.30))))
			mp = mini(max_mp(), mp + maxi(1, int(round(max_mp() * 0.30))))
		"daoheart_luck":
			daoheart += 2
			luck += 2
		"insight_daoheart":
			insight += 2
			daoheart += 2
		"cultivation_only":
			gain = maxi(1, int(round(threshold() * 0.10)))
			cultivation += gain
	if not used.has(item_name):
		used.append(item_name)
	flags["used_treasures"] = used
	var message: String = "启用了【%s】· %s" % [item_name, String(active.get("name", "灵韵发动"))]
	if gain > 0:
		message += "，修为 +%d" % gain
	return {"ok": true, "message": message}

func unequip_item(item_name: String) -> bool:
	_ensure_equipment_slots()
	for slot: Dictionary in GameData.EQUIP_SLOTS:
		var slot_id: String = String(slot["id"])
		if equipped_item(slot_id) == item_name:
			equipment[slot_id] = ""
			return true
	return false

func equipment_lines() -> PackedStringArray:
	var lines := PackedStringArray()
	for slot: Dictionary in GameData.EQUIP_SLOTS:
		var item_name: String = equipped_item(String(slot["id"]))
		if not item_name.is_empty():
			lines.append("%s：%s" % [String(slot["name"]), item_name])
	return lines

func threshold() -> float:
	return GameData.threshold(realm)

func is_peak() -> bool:
	return cultivation >= threshold() - 0.01

func realm_name() -> String:
	return GameData.realm_name(realm)

func realm_data() -> Dictionary:
	return GameData.get_realm(realm)

func progress_ratio() -> float:
	return clampf(cultivation / threshold(), 0.0, 1.0)

func karma_info() -> Dictionary:
	return GameData.karma_title(karma)

func alignment_text() -> String:
	return String(karma_info()["name"])

func add_log(text: String, kind: String = "normal") -> void:
	logs.append({"age": age, "text": text, "kind": kind, "turn": turn_count})
	log_seq += 1
	if logs.size() > 260:
		logs.pop_front()

func region_info(region_name: String = "") -> Dictionary:
	var wanted := current_region if region_name.is_empty() else region_name
	for region: Dictionary in WORLD_REGIONS:
		if String(region.get("name", "")) == wanted:
			return region.duplicate(true)
	return WORLD_REGIONS[0].duplicate(true)

func travel_to_region(region_name: String) -> Dictionary:
	if region_name == current_region:
		return {"ok":false, "message":"你已身处此地，无需重复赶路。"}
	for region: Dictionary in WORLD_REGIONS:
		if String(region.get("name", "")) != region_name:
			continue
		var required := int(region.get("realm", 0))
		if realm < required:
			return {"ok":false, "message":"此地灵压凶险，至少需要%s方可安全前往。" % GameData.realm_name(required)}
		var travel_cost := 8 + required * 4
		if active_mount_index >= 0 and active_mount_index < mounts.size():
			var mount_speed := int(mounts[active_mount_index].get("speed", 1))
			var discount := clampf(0.10 + float(mount_speed) * 0.05, 0.15, 0.25)
			travel_cost = maxi(1, int(round(float(travel_cost) * (1.0 - discount))))
		if stones < travel_cost:
			return {"ok":false, "message":"长途传送与舟车费用需要%d枚灵石。" % travel_cost}
		stones -= travel_cost
		current_region = region_name
		if not discovered_regions.has(region_name):
			discovered_regions.append(region_name)
		add_log("【远行】你耗费%d枚灵石，历经数月抵达%s。%s" % [travel_cost, region_name, String(region.get("desc", ""))], "world")
		_advance(1)
		return {"ok":true, "message":"已抵达%s。\n%s\n此地危险：%d级。" % [region_name, String(region.get("desc", "")), int(region.get("danger", 1))]}
	return {"ok":false, "message":"未找到目的地。"}

func explore_current_region(rng: RandomNumberGenerator) -> Dictionary:
	var region := region_info()
	var danger := int(region.get("danger", 1))
	var materials_here: Array = region.get("materials", ["凝露草"])
	var specialty := String(region.get("specialty", "地方灵材"))
	var outcome := ""
	var roll := rng.randf()
	# 地域妖兽遭遇：各州只会出现本地特有妖兽，击败后额外掉落本地特产。
	if roll < 0.24:
		var beasts: Array = region.get("beasts", [])
		if not beasts.is_empty():
			var beast: Dictionary = beasts[rng.randi_range(0, beasts.size() - 1)].duplicate(true)
			var scale := 1.0 + float(realm) * 0.16
			beast["max_hp"] = int(round(float(beast.get("hp", 60)) * scale))
			beast["hp"] = beast["max_hp"]
			beast["attack"] = int(round(float(beast.get("attack", 10)) * (1.0 + float(realm) * 0.10)))
			beast["defense"] = int(beast.get("defense", 2)) + int(realm / 4)
			beast["stones"] = int(round(float(beast.get("stones", 20)) * scale))
			beast["cultivation"] = int(round(float(beast.get("cultivation", 20)) * scale))
			beast["regional"] = true
			beast["region_name"] = current_region
			beast["region_material"] = String(beast.get("drop", materials_here[0]))
			outcome = "你在%s深入探索时，惊动了当地特有妖兽【%s】！" % [current_region, String(beast.get("name", "未知妖兽"))]
			add_log("【地域遭遇】" + outcome, "danger")
			_advance(1)
			return {"ok":true, "message":outcome, "enemy":beast}
	# 地域专属事件：每州独立事件池，事件奖励与特产挂钩。
	if roll < 0.49:
		var events: Array = region.get("events", [])
		if not events.is_empty():
			outcome = String(events[rng.randi_range(0, events.size() - 1)])
			var event_reward := 18 + danger * 7 + realm * 5
			stones += event_reward
			var bonus_material := specialty.split("、")[rng.randi_range(0, specialty.split("、").size() - 1)]
			add_material(bonus_material, 1)
			if rng.randf() < 0.30:
				cultivation = minf(threshold(), cultivation + 12 + danger * 4)
				outcome += "\n你从经历中有所感悟，修为略有精进。"
			outcome += "\n获得灵石%d枚、%s×1。" % [event_reward, bonus_material]
			add_log("【州域奇遇】" + outcome, "gain")
			_advance(1)
			return {"ok":true, "message":outcome}
	# 普通采集仍然保留原有材料，并有机会取得当地专属特产。
	var picked := String(materials_here[rng.randi_range(0, materials_here.size() - 1)])
	var reward := 12 + realm * 4 + danger * 3
	if rng.randf() < clampf(0.72 - float(danger) * 0.045 + float(luck) / 500.0, 0.35, 0.85):
		var amount := rng.randi_range(1, 2 + int(danger / 3))
		add_material(picked, amount)
		stones += reward
		outcome = "你沿着灵脉搜寻，在%s发现%s×%d，并拾得灵石%d枚。" % [current_region, picked, amount, reward]
		if rng.randf() < 0.42:
			var local_items: PackedStringArray = specialty.split("、")
			var local_item := String(local_items[rng.randi_range(0, local_items.size() - 1)])
			add_material(local_item, 1)
			outcome += "\n还采得本地特产%s×1。" % local_item
		if rng.randf() < 0.035 + float(luck) / 1800.0:
			var treasure_pool := ["白狐灵毛", "无名剑刃", "长生铜钱", "青蛟避水珠", "灵泉玉鱼"]
			for item: String in treasure_pool:
				if not treasures.has(item):
					treasures.append(item)
					treasure_ages[item] = age
					outcome += "\n还意外寻得遗物【%s】！" % item
					break
	else:
		var damage := rng.randi_range(5, 9) + danger * 3
		hp = maxi(1, hp - damage)
		injury = mini(99, injury + 2 + danger)
		outcome = "你深入%s时触发险地禁制，气血-%d，伤势加重。" % [current_region, damage]
	add_log("【区域探索】" + outcome, "gain" if outcome.contains("发现") else "danger")
	_advance(1)
	return {"ok":true, "message":outcome}

func _seed_rival_npc(rng: RandomNumberGenerator) -> void:
	if not rival_npcs.is_empty():
		return
	var rival_name := GameData.random_name(rng)
	rival_npcs.append({"name":rival_name, "realm":0, "cultivation":rng.randi_range(0, 35), "aptitude":rng.randi_range(35, 85), "temper":"好胜", "alive":true, "last_seen":age, "relationship":"未曾谋面"})
	add_log("【天命际会】你隐约听闻同一州域还有一位名为%s的年轻修士，资质不俗。" % rival_name, "world")

func _simulate_world_turn() -> void:
	WorldSimulation.simulate_turn(self)

func _advance(years: int) -> void:
	WorldSimulation.advance(self, years)

func cultivate(rng: RandomNumberGenerator) -> Dictionary:
	var before: float = cultivation
	if is_peak():
		add_log("你试图继续引气入体，经脉却像一只已经盛满的碗。再倒，只会溢出来。是时候叩问境界了。", "action")
		_advance(1)
		return {"event_chance": 0.12, "line": "cultivate"}
	var factor: float = (0.70 + float(effective_stat("insight")) / 150.0) * float(root.get("speed", 1.0))
	factor *= 1.0 - float(injury) / 420.0
	factor *= _cultivation_multiplier()
	var pct: float = rng.randf_range(0.17, 0.23) * factor
	cultivation = minf(threshold(), cultivation + threshold() * pct)
	var gained: int = int(round(cultivation - before))
	var line: String = CULTIVATE_LINES[rng.randi_range(0, CULTIVATE_LINES.size() - 1)]
	add_log(line + "\n[color=#3f7564]修为 +%d[/color]" % gained, "action")
	if is_peak():
		add_log("气海已满，一线瓶颈横在眼前。你可以尝试冲击下一重境界。", "hint")
	if rng.randf() < 0.09:
		daoheart = mini(100, daoheart + 1)
		add_log("静坐修行后，你心中那点浮躁也慢慢沉了下去。[color=#4f7b68]道心 +1[/color]", "gain")
	gain_equipped_method_mastery(20)
	_advance(1)
	return {"event_chance": 0.16, "line": "cultivate"}

func comprehend(rng: RandomNumberGenerator) -> Dictionary:
	var before: float = cultivation
	var pct: float = rng.randf_range(0.06, 0.095) * float(root.get("speed", 1.0)) * _cultivation_multiplier()
	cultivation = minf(threshold(), cultivation + threshold() * pct)
	var gained: int = int(round(cultivation - before))
	var insight_gain: int = rng.randi_range(1, 2)
	var line: String = COMPREHEND_LINES[rng.randi_range(0, COMPREHEND_LINES.size() - 1)]
	var notes: String = "[color=#3f7564]悟性 +%d[/color]" % insight_gain
	insight = mini(100, insight + insight_gain)
	if rng.randf() < 0.55:
		daoheart = mini(100, daoheart + 1)
		notes += "  [color=#4f7b68]道心 +1[/color]"
	add_log(line + "\n" + notes, "action")
	if rng.randf() < 0.10:
		insight = mini(100, insight + 2)
		cultivation = minf(threshold(), cultivation + threshold() * 0.06)
		add_log("忽然有一线灵光自识海深处亮起，如暗室点灯。你明白了从前百思不得其解的一处关窍。[color=#a23a2a]顿悟：悟性 +2，修为小进[/color]", "epiphany")
	gain_equipped_method_mastery(15)
	_advance(1)
	return {"event_chance": 0.24, "line": "comprehend"}

func wander(rng: RandomNumberGenerator) -> Dictionary:
	var before: float = cultivation
	var pct: float = rng.randf_range(0.025, 0.055) * _cultivation_multiplier()
	cultivation = minf(threshold(), cultivation + threshold() * pct)
	var gained: int = int(round(cultivation - before))
	var available_lines: Array[String] = []
	for scene_line: String in WANDER_LINES:
		if not wander_seen_lines.has(scene_line):
			available_lines.append(scene_line)
	var line: String
	if not available_lines.is_empty():
		line = available_lines[rng.randi_range(0, available_lines.size() - 1)]
		wander_seen_lines.append(line)
	else:
		line = "你继续行走在山川城郭之间，沿途见闻渐渐沉淀为修行路上的一段寻常岁月。"
	add_log(line + ("\n[color=#3f7564]修为 +%d[/color]" % gained if gained > 0 else ""), "action")
	_advance(1)
	# 红尘历练只负责游历与正式奇遇；战斗由独立的寻敌斗法入口开启。
	return {"event_chance": 0.42, "line": "wander"}

func recover(rng: RandomNumberGenerator) -> Dictionary:
	hp = mini(max_hp(), hp + int(max_hp() * 0.28))
	mp = mini(max_mp(), mp + int(max_mp() * 0.35))
	var before_injury: int = injury
	injury = maxi(0, injury - rng.randi_range(24, 38) - int(effective_stat("body") * 0.12))
	var healed: int = before_injury - injury
	var before_cult: float = cultivation
	cultivation = minf(threshold(), cultivation + threshold() * rng.randf_range(0.045, 0.07) * _cultivation_multiplier())
	var gained: int = int(round(cultivation - before_cult))
	if healed > 0:
		add_log("你寻了一处安静的山洞，以真气温养伤处。淤血一点点化开，断骨处传来细密的痒。[color=#3f7564]伤势 -%d[/color]" % healed, "action")
	else:
		add_log("你焚香静坐，将纷杂的念头一缕缕收拢。身体未曾受伤，心却像被清水洗过。", "action")
	body = mini(100, body + 1)
	add_log("筋骨在静养中愈发柔韧。[color=#4f7b68]根骨 +1[/color]" + ("  [color=#3f7564]修为 +%d[/color]" % gained if gained > 0 else ""), "gain")
	_advance(1)
	return {"event_chance": 0.12, "line": "recover"}

func breakthrough_chance() -> float:
	var next_realm: int = realm + 1
	var target_major: bool = true
	if next_realm < GameData.REALMS.size():
		target_major = bool(GameData.get_realm(next_realm).get("major", false))
	var chance: float = 45.0 \
		+ float(effective_stat("insight")) * 0.22 \
		+ float(effective_stat("daoheart")) * 0.24 \
		+ float(effective_stat("luck")) * 0.08 \
		- float(realm) * 1.6 \
		- float(injury) * 0.18 \
		+ breakthrough_bonus \
		+ equipment_mod("breakthrough") \
		+ origin_mod("breakthrough") \
		+ relic_mod("breakthrough")
	if target_major:
		chance -= 7.0
	# 高品灵根更易洞悉瓶颈，但不保证突破成功。
	chance += float(9 - int(root.get("grade", 9))) * 0.65
	if realm >= 15:
		chance -= 5.0
	if realm == 17:
		chance -= 8.0
	return clampf(chance, 18.0, 92.0)

func attempt_breakthrough(rng: RandomNumberGenerator) -> Dictionary:
	if not is_peak():
		return {"ok": false, "reason": "气机未满，尚不能冲击境界。"}
	var chance: float = breakthrough_chance()
	var success: bool = rng.randf() * 100.0 < chance
	var result: Dictionary = {"ok": true, "success": success, "chance": chance, "ascended": false}
	_advance(1)

	if success:
		if realm >= GameData.REALMS.size() - 1:
			ascended = true
			alive = false
			death_reason = "白日飞升"
			add_log("最后一道天雷落在你身上，却没有痛。你听见体内有什么东西轻轻碎了，又有什么东西正在打开。\n\n[color=#a23a2a][font_size=22]天门开了。[/font_size][/color]", "ascension")
			result["ascended"] = true
			return result

		realm += 1
		var sect_promotion := _sect_promote_if_ready()
		if not sect_promotion.is_empty():
			add_log("【宗门晋升】" + sect_promotion, "world")
		cultivation = 0.0
		var data: Dictionary = GameData.get_realm(realm)
		var life_gain: int = int(data.get("life", 0))
		lifespan += life_gain
		body = mini(100, body + 1)
		daoheart = mini(100, daoheart + 1)
		# 破境后天地灵气倒灌，气血与灵力完全恢复。
		hp = max_hp()
		mp = max_mp()
		add_log("【破境】" + String(data.get("line", "境界更上一层。")), "breakthrough")
		add_log("你成功踏入[color=#a23a2a][font_size=20]%s[/font_size][/color]。天地灵气倒灌周身，气血与灵力尽数恢复。[color=#3f7564]寿元 +%d · 气血、灵力回满[/color]" % [realm_name(), life_gain], "breakthrough")
		if bool(data.get("major", false)):
			insight = mini(100, insight + 1)
			luck = mini(100, luck + 1)
			add_log("这是一道大门槛。你的神魂与肉身都经历了重塑，气机比从前辽阔许多。", "gain")
		result["realm"] = realm
		return result

	# 冲关失败
	var loss: float = threshold() * rng.randf_range(0.18, 0.30)
	cultivation = maxf(0.0, cultivation - loss)
	var hurt: int = _mitigated_injury(rng.randi_range(7, 15) + int(realm / 3.0))
	injury = mini(100, injury + hurt)
	daoheart = maxi(1, daoheart - 1)
	if rng.randf() < 0.35:
		var life_loss: int = rng.randi_range(1, 3)
		lifespan = maxi(age + 1, lifespan - life_loss)
		add_log("强行冲关时，你听见经脉深处传来一声闷响。气机倒卷，一口血染红了前襟。[color=#9d3d2f]修为 -%d · 伤势 +%d · 寿元 -%d[/color]" % [int(loss), hurt, life_loss], "danger")
	else:
		add_log("瓶颈比你想的更硬。真元在经脉中横冲直撞，你咬紧牙关撑到最后，还是被反噬之力掀翻在地。[color=#9d3d2f]修为 -%d · 伤势 +%d[/color]" % [int(loss), hurt], "danger")
	if injury >= 100:
		die("冲关反噬，经脉尽断")
	result["injury"] = injury
	return result

func meets_requirement(req: Dictionary) -> bool:
	for key: String in req.keys():
		var needed: int = int(req[key])
		match key:
			"body":
				if effective_stat("body") < needed: return false
			"insight":
				if effective_stat("insight") < needed: return false
			"luck":
				if effective_stat("luck") < needed: return false
			"daoheart":
				if effective_stat("daoheart") < needed: return false
			"realm":
				if realm < needed: return false
			"karma_min":
				if karma < needed: return false
			"karma_max":
				if karma > needed: return false
			"stones":
				if stones < needed: return false
	return true

func method_slot_count() -> int:
	return clampi(1 + int(realm / 6), 1, 3)

func martial_slot_count() -> int:
	return clampi(2 + int(realm / 5), 2, 5)

func skill_slot_count() -> int:
	return method_slot_count() + martial_slot_count()

func skill_category(skill_id: String) -> String:
	return String(BattleSystem.skill_data(skill_id).get("category", "法术"))

func skill_mastery_xp(skill_id: String) -> int:
	return maxi(0, int(skill_mastery.get(skill_id, 0)))

func gain_skill_mastery(skill_id: String, amount: int) -> void:
	if not learned_skills.has(skill_id) or amount <= 0:
		return
	skill_mastery[skill_id] = mini(1400, skill_mastery_xp(skill_id) + amount)

func gain_equipped_method_mastery(amount: int) -> void:
	if amount <= 0:
		return
	for method_id: String in equipped_methods:
		gain_skill_mastery(method_id, amount)

func is_skill_equipped(skill_id: String) -> bool:
	return equipped_methods.has(skill_id) or equipped_martial.has(skill_id)

func learn_skill(skill_id: String) -> bool:
	var info: Dictionary = BattleSystem.skill_data(skill_id)
	if info.is_empty() or learned_skills.has(skill_id):
		return false
	if realm < int(info.get("realm", 0)) or stones < int(info.get("cost", 0)):
		return false
	stones -= int(info.get("cost", 0))
	learned_skills.append(skill_id)
	return true

func equip_skill(skill_id: String) -> bool:
	if not learned_skills.has(skill_id) or is_skill_equipped(skill_id):
		return false
	if skill_category(skill_id) == "功法":
		if equipped_methods.size() >= method_slot_count():
			return false
		equipped_methods.append(skill_id)
	else:
		if equipped_martial.size() >= martial_slot_count():
			return false
		equipped_martial.append(skill_id)
	_sync_legacy_equipped_skills()
	hp = mini(hp, max_hp())
	mp = mini(mp, max_mp())
	return true

func unequip_skill(skill_id: String) -> bool:
	var removed := false
	if equipped_methods.has(skill_id):
		equipped_methods.erase(skill_id)
		removed = true
	if equipped_martial.has(skill_id):
		equipped_martial.erase(skill_id)
		removed = true
	if removed:
		_sync_legacy_equipped_skills()
		hp = mini(hp, max_hp())
		mp = mini(mp, max_mp())
	return removed

func _sync_legacy_equipped_skills() -> void:
	equipped_skills.clear()
	for skill_id: String in equipped_methods:
		if not equipped_skills.has(skill_id): equipped_skills.append(skill_id)
	for skill_id: String in equipped_martial:
		if not equipped_skills.has(skill_id): equipped_skills.append(skill_id)

func method_bonus(stat_key: String) -> float:
	var bonuses := {
		"wood_breath": {"cultivation": 0.08}, "stone_skin": {"defense": 2.0}, "spirit_gather": {"max_mp": 8.0},
		"soul_heal": {"max_hp": 8.0}, "iron_wall": {"defense": 3.0},
		"star_absorb": {"cultivation": 0.12}, "phoenix_rebirth": {"max_hp": 14.0},
		"void_guard": {"defense": 5.0}, "immortal_body": {"max_hp": 18.0, "defense": 5.0},
		"life_spring": {"max_hp": 24.0}, "dao_origin": {"cultivation": 0.18, "max_mp": 16.0},
		"five_elements": {"cultivation": 0.10, "max_mp": 12.0}, "eternal_cycle": {"max_hp": 30.0}
	}
	var total := 0.0
	for method_id: String in equipped_methods:
		var base_bonus := float(bonuses.get(method_id, {}).get(stat_key, 0.0))
		var mastery: Dictionary = BattleSystem.mastery_info(skill_mastery_xp(method_id))
		total += base_bonus * float(mastery.get("power_multiplier", 1.0))
	return total

func add_material(material_name: String, amount: int = 1) -> void:
	if amount <= 0:
		return
	materials[material_name] = int(materials.get(material_name, 0)) + amount



const DIVINE_BEAST_CODEX := [
	{"id":"azure_dragon","title":"苍龙·青龙神君","kind":"真龙","region":"海外·归墟海","materials":{"蛟龙逆鳞":2,"龙宫珍珠":2},"bloodline":"青龙祖脉","skill":"苍龙破海","story":"归墟海底沉睡着一截龙骨。蛟龙若肯以自身逆鳞补全龙骨，便能听见苍龙祖灵的回应。","quest":"携带灵宠前往归墟海，寻得两枚蛟龙逆鳞与两颗龙宫珍珠，在潮汐龙台完成认祖仪式。","effect":"战斗中有概率发动破海龙息，造成巨额伤害。"},
	{"id":"vermillion_bird","title":"离火·朱雀圣灵","kind":"朱雀","region":"南境·药王岭","materials":{"赤焰砂":3,"百年灵芝":2},"bloodline":"朱雀真羽","skill":"九霄涅槃","story":"药王岭深处有一株不灭火木。以灵药滋养火种，才能令凡羽浴火重生。","quest":"在药王岭集齐赤焰砂与百年灵芝，于不灭火木前守护灵宠完成涅槃。","effect":"战斗中有概率释放涅槃真火，并恢复主人生命。"},
	{"id":"white_tiger","title":"西庚·白虎战尊","kind":"白虎","region":"北荒·万妖原","materials":{"荒古兽骨":3,"妖兽精血":2},"bloodline":"白虎杀伐血脉","skill":"庚金裂天","story":"万妖原古战场埋着白虎战尊的断牙。唯有经历百兽围猎而不退，方能承接杀伐之意。","quest":"前往万妖原，带来荒古兽骨与妖兽精血，在古战场举行百兽试炼。","effect":"战斗中有概率触发连环猛击，大幅提升伤害。"},
	{"id":"black_tortoise","title":"北冥·玄武真君","kind":"玄武","region":"海外·归墟海","materials":{"寒潭鳞片":3,"龙宫珍珠":2},"bloodline":"玄武镇海血脉","skill":"玄冥天幕","story":"归墟海眼封存着玄武龟甲的一角。以潮汐之力补全龟甲，便能唤醒镇海真君。","quest":"深入归墟海，集齐寒潭鳞片与龙宫珍珠，在海眼为灵宠重铸玄甲。","effect":"战斗中有概率生成护体玄甲，减轻伤害并回复生命。"},
	{"id":"qilin","title":"中央·祥瑞麒麟","kind":"麒麟","region":"中州·天京","materials":{"天京玉露":2,"赤金砂":3},"bloodline":"麒麟祥瑞祖脉","skill":"瑞光镇邪","story":"天京旧皇陵的祥瑞石碑记载着麒麟遗愿。以玉露洗去尘垢，才能令祥瑞重临人间。","quest":"前往天京寻得天京玉露与赤金砂，在皇陵祥瑞碑前完成镇邪仪式。","effect":"战斗中有概率发动祥瑞震击，并提升主人灵力。"},
	{"id":"chaos","title":"太初·混沌祖兽","kind":"混沌神兽","region":"北境·葬魂渊","materials":{"幽冥魂晶":3,"血煞石":2},"bloodline":"混沌祖脉","skill":"太初归墟","story":"葬魂渊最深处没有生死，只有太初未分的混沌。凡兽若能承受魂火洗礼，便有一线返本归元的机会。","quest":"前往葬魂渊收集幽冥魂晶与血煞石，在古战场尽头完成太初试炼。","effect":"战斗中有概率释放混沌冲击，对敌造成强力伤害。"}
]

func divine_beast_codex() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry_value: Variant in DIVINE_BEAST_CODEX:
		if entry_value is Dictionary:
			var entry: Dictionary = entry_value.duplicate(true)
			var owned_count := 0
			for pet_value: Variant in pets:
				if pet_value is Dictionary and (String(pet_value.get("divine_beast", "")) == String(entry.get("id", "")) or Array(pet_value.get("divine_quests", [])).has(String(entry.get("id", "")))):
					owned_count += 1
			entry["owned_count"] = owned_count
			result.append(entry)
	return result

func divine_beast_quest_status(pet_index: int, beast_id: String) -> Dictionary:
	if pet_index < 0 or pet_index >= pets.size():
		return {"ok":false,"message":"请先收服一只灵宠。"}
	var entry: Dictionary = {}
	for item: Dictionary in DIVINE_BEAST_CODEX:
		if String(item.get("id", "")) == beast_id:
			entry = item
			break
	if entry.is_empty():
		return {"ok":false,"message":"图鉴中没有这条神兽血脉。"}
	var pet: Dictionary = pets[pet_index]
	_pet_normalize(pet)
	if Array(pet.get("divine_quests", [])).has(beast_id):
		return {"ok":false,"done":true,"message":"这只灵宠已经完成该神兽血脉任务。"}
	if int(pet.get("level", 1)) < 12:
		return {"ok":false,"message":"灵宠至少需要达到12级。"}
	if int(pet.get("evolution", 0)) < 2:
		return {"ok":false,"message":"灵宠至少需要完成二阶进化。"}
	if not discovered_regions.has(String(entry.get("region", ""))):
		return {"ok":false,"message":"尚未探索%s，神兽遗迹仍未显现。" % String(entry.get("region", ""))}
	var costs: Dictionary = entry.get("materials", {})
	for mat: String in costs:
		if int(materials.get(mat, 0)) < int(costs[mat]):
			return {"ok":false,"message":"材料不足：%s ×%d。" % [mat, int(costs[mat])]}
	return {"ok":true,"message":"条件已满足，可以开启神兽血脉试炼。"}

func complete_divine_beast_quest(pet_index: int, beast_id: String) -> Dictionary:
	var status := divine_beast_quest_status(pet_index, beast_id)
	if not bool(status.get("ok", false)):
		return status
	var entry: Dictionary = {}
	for item: Dictionary in DIVINE_BEAST_CODEX:
		if String(item.get("id", "")) == beast_id:
			entry = item
			break
	var pet: Dictionary = pets[pet_index]
	var costs: Dictionary = entry.get("materials", {})
	for mat: String in costs:
		materials[mat] = int(materials.get(mat, 0)) - int(costs[mat])
	var completed: Array = Array(pet.get("divine_quests", [])).duplicate()
	completed.append(beast_id)
	pet["divine_quests"] = completed
	pet["divine_beast"] = beast_id
	pet["divine_skill"] = String(entry.get("skill", "神兽绝技"))
	pet["bloodline"] = String(entry.get("bloodline", "神兽祖脉"))
	pet["bloodline_stage"] = maxi(4, int(pet.get("bloodline_stage", 0)))
	pet["evolution"] = maxi(4, int(pet.get("evolution", 0)))
	pet["visual_stage"] = 3
	pet["form"] = String(entry.get("kind", "神兽")) + "·神君真身"
	pet["name"] = String(pet.get("species", "灵兽")) + "·" + String(entry.get("kind", "神兽"))
	pet["power"] = int(pet.get("power", 10)) + 100
	pet["max_hp"] = int(pet.get("max_hp", 50)) + 200
	pet["last_skill"] = String(entry.get("skill", "神兽绝技"))
	pets[pet_index] = pet
	add_log("【万兽神谱】%s完成血脉试炼，觉醒为%s！专属神通：%s。" % [String(pet.get("name", "灵宠")), String(entry.get("title", "神兽")), String(entry.get("skill", "神通"))], "gain")
	return {"ok":true,"message":"神兽血脉觉醒！%s已成为%s，习得专属神通【%s】。\n%s" % [String(pet.get("name", "灵宠")), String(entry.get("title", "神兽")), String(entry.get("skill", "神通")), String(entry.get("story", "古老血脉已然苏醒。"))]}

func pet_capture_options() -> Array[Dictionary]:
	var region := region_info()
	var beasts: Array = region.get("beasts", [])
	var options: Array[Dictionary] = []
	for beast_value: Variant in beasts:
		if not beast_value is Dictionary:
			continue
		var beast: Dictionary = beast_value
		var base_power := int(beast.get("attack", 10)) + int(beast.get("defense", 2))
		options.append({"name":String(beast.get("name", "灵兽")), "region":current_region, "power":base_power, "gather":String(beast.get("drop", "凝露草")), "cost":0 if pets.is_empty() else 40 + base_power * 2, "desc":String(beast.get("desc", "可缔结灵契的异兽。"))})
	return options

func capture_pet(option: Dictionary) -> Dictionary:
	var pet_name := String(option.get("name", ""))
	if pet_name.is_empty():
		return {"ok":false, "message":"未找到可缔结灵契的灵兽。"}
	for pet_value: Variant in pets:
		if pet_value is Dictionary and String(pet_value.get("species", pet_value.get("name", ""))) == pet_name:
			return {"ok":false, "message":"你已与这只灵兽缔结灵契。"}
	var cost := int(option.get("cost", 60))
	if stones < cost:
		return {"ok":false, "message":"缔结灵契需要%d枚灵石，你目前不足。" % cost}
	stones -= cost
	var pet := {"name":pet_name, "species":pet_name, "region":String(option.get("region", current_region)), "level":1, "exp":0, "power":int(option.get("power", 10)), "gather":String(option.get("gather", "凝露草")), "bond":1, "evolution":0, "bloodline":"凡兽", "bloodline_stage":0, "skills":[], "breed_count":0, "generation":1, "mutation":false, "form":"幼年·" + pet_name, "visual_seed": randi_range(0, 999999), "pet_max_hp": 80, "pet_hp": 80, "talent_affinity":"野性"}
	pets.append(pet)
	if active_pet_index < 0:
		active_pet_index = pets.size() - 1
	add_log("【灵契】你耗费%d枚灵石，与%s结下灵契。" % [cost, pet_name], "gain")
	return {"ok":true, "message":"灵契缔结成功！%s已成为你的灵宠，将协助战斗与采集。" % pet_name}

func _pet_normalize(pet: Dictionary) -> void:
	pet["species"] = String(pet.get("species", pet.get("name", "灵兽")))
	pet["evolution"] = maxi(0, int(pet.get("evolution", 0)))
	pet["visual_stage"] = clampi(int(pet.get("evolution", 0)), 0, 3)
	pet["bloodline"] = String(pet.get("bloodline", "凡兽"))
	pet["bloodline_stage"] = maxi(0, int(pet.get("bloodline_stage", 0)))
	pet["skills"] = Array(pet.get("skills", [])).duplicate(true)
	pet["breed_count"] = maxi(0, int(pet.get("breed_count", 0)))
	pet["generation"] = maxi(1, int(pet.get("generation", 1)))
	pet["mutation"] = bool(pet.get("mutation", false))
	pet["visual_seed"] = int(pet.get("visual_seed", hash(String(pet.get("species", "灵兽"))) & 0x7fffffff))
	pet["pet_max_hp"] = maxi(30, int(pet.get("pet_max_hp", 70 + int(pet.get("level", 1)) * 8 + int(pet.get("evolution", 0)) * 25)))
	pet["pet_hp"] = clampi(int(pet.get("pet_hp", pet["pet_max_hp"])), 0, int(pet["pet_max_hp"]))
	pet["form"] = String(pet.get("form", _pet_route_form(pet) + "·初生形态" if int(pet.get("evolution", 0)) > 0 else "幼年·" + String(pet.get("species", "灵兽"))))
	pet["talent_affinity"] = String(pet.get("talent_affinity", "野性"))
	pet["divine_quests"] = Array(pet.get("divine_quests", [])).duplicate()
	pet["divine_beast"] = String(pet.get("divine_beast", ""))
	pet["divine_skill"] = String(pet.get("divine_skill", ""))
	pet["last_skill"] = String(pet.get("last_skill", "普通协击"))

func _pet_route_form(pet: Dictionary) -> String:
	var text := String(pet.get("bloodline", "")) + String(pet.get("species", "")) + String(pet.get("name", ""))
	if text.contains("龙") or text.contains("蛟") or text.contains("蛇"):
		return "真龙"
	if text.contains("鸟") or text.contains("鹤") or text.contains("凤"):
		return "朱雀"
	if text.contains("龟") or text.contains("玄武"):
		return "玄武"
	if text.contains("狼") or text.contains("虎") or text.contains("熊"):
		return "白虎"
	if text.contains("麒麟") or text.contains("鹿") or text.contains("狮"):
		return "麒麟"
	var routes := ["麒麟", "白虎", "玄武", "朱雀", "真龙"]
	return String(routes[int(pet.get("visual_seed", 0)) % routes.size()])

func evolve_pet(index: int) -> Dictionary:
	if index < 0 or index >= pets.size(): return {"ok":false,"message":"未找到这只灵宠。"}
	var pet: Dictionary = pets[index]
	_pet_normalize(pet)
	var stage := int(pet.evolution)
	if stage >= 4: return {"ok":false,"message":"已达到当前进化终点，需先完成血脉觉醒。"}
	var need_level := 5 + stage * 8
	var costs := [{"妖兽精血":2,"凝露草":3},{"妖兽精血":4,"荒古兽骨":2},{"妖兽精血":6,"幽冥魂晶":2},{"妖兽精血":10,"龙宫珍珠":2}]
	var cost: Dictionary = costs[stage]
	var stone_cost := 50 + stage * 100
	if int(pet.get("level",1)) < need_level: return {"ok":false,"message":"灵宠需达到%d级方可进化。" % need_level}
	if stones < stone_cost: return {"ok":false,"message":"进化仪式需要%d枚灵石。" % stone_cost}
	for mat: String in cost:
		if int(materials.get(mat,0)) < int(cost[mat]): return {"ok":false,"message":"进化材料不足：%s ×%d。" % [mat,int(cost[mat])]}
	for mat: String in cost: materials[mat] = int(materials.get(mat,0)) - int(cost[mat])
	stones -= stone_cost
	pet.evolution = stage + 1
	pet["visual_stage"] = clampi(stage + 1, 0, 3)
	pet.power = int(pet.get("power",10)) + 12 + stage * 8
	pet.max_hp = int(pet.get("max_hp",50)) + 30 + stage * 20
	var pet_hp_gain := 15 + stage * 10
	pet["pet_max_hp"] = int(pet.get("pet_max_hp", 80)) + pet_hp_gain
	pet["pet_hp"] = mini(int(pet.pet_max_hp), int(pet.get("pet_hp", 80)) + pet_hp_gain)
	var route := _pet_route_form(pet)
	var stage_names := ["灵体", "妖灵", "古灵", "神兽"]
	pet["form"] = route + "·" + stage_names[stage]
	pet.name = String(pet.get("species", pet.get("name","灵兽"))) + "·" + stage_names[stage]
	pet.bloodline = String(pet.get("bloodline","凡兽"))
	pets[index] = pet
	return {"ok":true,"message":"进化成功！%s的形态与力量得到蜕变。" % String(pet.name)}

func awaken_pet_bloodline(index: int) -> Dictionary:
	if index < 0 or index >= pets.size(): return {"ok":false,"message":"未找到这只灵宠。"}
	var pet: Dictionary = pets[index]
	_pet_normalize(pet)
	var stage := int(pet.bloodline_stage)
	if stage >= 4: return {"ok":false,"message":"血脉已觉醒至上古神兽层次。"}
	var need_evolution := mini(4, stage + 1)
	if int(pet.evolution) < need_evolution: return {"ok":false,"message":"需先完成%d阶进化。" % need_evolution}
	var mats: Array[String] = ["妖兽精血", "荒古兽骨", "幽冥魂晶", "龙宫珍珠"]
	var mat: String = mats[stage]
	var amount := 2 + stage * 2
	if int(materials.get(mat,0)) < amount: return {"ok":false,"message":"血脉觉醒需要%s ×%d。" % [mat,amount]}
	materials[mat] = int(materials.get(mat,0)) - amount
	var bloodlines := ["远古血脉","太古血脉","洪荒血脉","上古神兽血脉"]
	var chosen: String = bloodlines[stage]
	if randf() < 0.08 and stage >= 1:
		chosen = ["真龙血脉","凤凰血脉","麒麟血脉","混沌血脉"][randi_range(0,3)]
		pet.mutation = true
	pet.bloodline_stage = stage + 1
	pet.bloodline = chosen
	var awakened_route := ""
	if chosen.contains("龙"):
		awakened_route = "真龙"
	elif chosen.contains("凤凰") or chosen.contains("凤"):
		awakened_route = "朱雀"
	elif chosen.contains("麒麟"):
		awakened_route = "麒麟"
	elif chosen.contains("混沌"):
		awakened_route = "混沌神兽"
	else:
		awakened_route = _pet_route_form(pet)
	pet["form"] = awakened_route + ["·血脉初醒", "·远古真形", "·太古神躯", "·上古神兽"][stage]
	pet.power = int(pet.get("power",10)) + 20 + stage * 15
	pet.max_hp = int(pet.get("max_hp",50)) + 50 + stage * 25
	pets[index] = pet
	return {"ok":true,"message":"血脉觉醒成功！%s觉醒为%s。" % [String(pet.get("name","灵宠")),chosen]}

func teach_pet_skill(index: int, skill_id: String) -> Dictionary:
	if index < 0 or index >= pets.size(): return {"ok":false,"message":"未找到这只灵宠。"}
	var catalog := {"裂爪":"攻击技能","灵甲":"防御技能","回春":"治疗技能","寻宝":"采集技能","雷袭":"攻击技能","御风":"辅助技能","龙吟":"攻击技能","涅槃":"治疗技能"}
	if not catalog.has(skill_id): return {"ok":false,"message":"没有这种技能秘卷。"}
	var pet: Dictionary = pets[index]
	_pet_normalize(pet)
	var skills: Array = pet.skills
	if skills.has(skill_id): return {"ok":false,"message":"灵宠已经学会该技能。"}
	if skills.size() >= 4: return {"ok":false,"message":"灵宠最多掌握四种技能，请先调整技能栏。"}
	var costs := {"裂爪":30,"灵甲":30,"回春":40,"寻宝":25,"雷袭":80,"御风":60,"龙吟":120,"涅槃":120}
	var cost := int(costs[skill_id])
	if stones < cost: return {"ok":false,"message":"学习该技能需要%d枚灵石。" % cost}
	stones -= cost
	skills.append(skill_id)
	pet.skills = skills
	pets[index] = pet
	return {"ok":true,"message":"%s学会了%s（%s）。" % [String(pet.get("name","灵宠")),skill_id,String(catalog[skill_id])]}

func breed_pets(first_index: int, second_index: int) -> Dictionary:
	if first_index < 0 or second_index < 0 or first_index >= pets.size() or second_index >= pets.size() or first_index == second_index:
		return {"ok":false,"message":"请选择两只不同的灵宠作为繁殖伴侣。"}
	if pets.size() >= 30: return {"ok":false,"message":"灵宠数量已达上限（30只）。"}
	var a: Dictionary = pets[first_index]
	var b: Dictionary = pets[second_index]
	_pet_normalize(a); _pet_normalize(b)
	if int(a.get("level",1)) < 3 or int(b.get("level",1)) < 3: return {"ok":false,"message":"双方灵宠均需达到3级才能繁殖。"}
	if stones < 100: return {"ok":false,"message":"繁殖仪式需要100枚灵石。"}
	stones -= 100
	var child_name := "幼" + String(a.get("species",a.get("name","灵兽")))
	var child := {"name":child_name,"species":String(a.get("species",a.get("name","灵兽"))),"region":current_region,"level":1,"exp":0,"power":maxi(8,int((int(a.get("power",10))+int(b.get("power",10)))/4)),"gather":String(a.get("gather",b.get("gather","凝露草"))),"bond":1,"evolution":0,"bloodline":"凡兽","bloodline_stage":0,"skills":[],"breed_count":0,"generation":maxi(int(a.generation),int(b.generation))+1,"mutation":false,"form":"幼年·" + String(a.get("species", "灵兽")),"visual_seed":randi_range(0,999999),"pet_max_hp":80,"pet_hp":80,"talent_affinity":"野性"}
	var inherited: Array = []
	var parent_skills: Array = Array(a.get("skills", []))
	parent_skills.append_array(Array(b.get("skills", [])))
	for skill: Variant in parent_skills:
		if not inherited.has(skill): inherited.append(skill)
	if not inherited.is_empty() and randf() < 0.65: child.skills = [inherited[randi_range(0,inherited.size()-1)]]
	if randf() < 0.12:
		child.mutation = true
		child.power = int(child.power) + 15
		child.bloodline = "变异灵脉"
	var inherited_parent: Dictionary = a if String(a.get("bloodline", "凡兽")) != "凡兽" else b
	if (String(a.get("bloodline", "凡兽")) != "凡兽" or String(b.get("bloodline", "凡兽")) != "凡兽") and randf() < 0.40:
		child.bloodline = String(inherited_parent.get("bloodline", "凡兽"))
		child.bloodline_stage = maxi(0, int(inherited_parent.get("bloodline_stage", 0)) - 1)
		child.form = _pet_route_form(child) + "·遗传幼兽"
	if randf() < 0.08:
		child.form = ["真龙幼体", "朱雀雏鸟", "麒麟幼崽", "玄武灵龟"][randi_range(0, 3)]
	a.breed_count = int(a.breed_count) + 1
	b.breed_count = int(b.breed_count) + 1
	pets[first_index] = a; pets[second_index] = b
	pets.append(child)
	return {"ok":true,"message":"繁殖成功！诞生了%s，第%d代%s。" % [child_name,int(child.generation),"变异幼兽" if bool(child.mutation) else "灵兽幼崽"]}

func acquire_mount(mount_name: String) -> Dictionary:
	var catalog := {
		"青风灵鹿":{"cost":120,"speed":1,"desc":"温顺灵鹿，善走山道。"},
		"踏云灵鹤":{"cost":260,"speed":2,"desc":"可踏云而行，长途远行更为轻便。"},
		"玄甲地龙":{"cost":520,"speed":3,"desc":"披覆玄甲的地龙，能在险地护持主人。"}
	}
	if not catalog.has(mount_name):
		return {"ok":false,"message":"未找到该坐骑。"}
	for mount: Dictionary in mounts:
		if String(mount.get("name", "")) == mount_name:
			return {"ok":false,"message":"你已拥有这匹坐骑。"}
	var info: Dictionary = catalog[mount_name]
	var cost := int(info.cost)
	if stones < cost:
		return {"ok":false,"message":"购置%s需要%d枚灵石。" % [mount_name, cost]}
	stones -= cost
	mounts.append({"name":mount_name,"speed":int(info.speed),"desc":String(info.desc)})
	if active_mount_index < 0:
		active_mount_index = mounts.size() - 1
	return {"ok":true,"message":"你已获得坐骑%s，并自动设为当前乘骑。" % mount_name}

func set_active_pet(index: int) -> void:
	active_pet_index = index if index >= 0 and index < pets.size() else -1

func set_active_mount(index: int) -> void:
	active_mount_index = index if index >= 0 and index < mounts.size() else -1

func active_pet() -> Dictionary:
	if active_pet_index >= 0 and active_pet_index < pets.size():
		return pets[active_pet_index]
	return {}

func companion_skill_profile(npc: Dictionary) -> Dictionary:
	return PartyCombatSystem.companion_skill_profile(npc)

func npc_battle_support(enemy: Dictionary, rng: RandomNumberGenerator, turn_index: int) -> Array[Dictionary]:
	return PartyCombatSystem.resolve_companion_support(self, enemy, rng, turn_index, 3)

func resolve_party_support_turn(enemy: Dictionary, rng: RandomNumberGenerator, turn_index: int) -> Dictionary:
	return PartyCombatSystem.resolve_turn(self, enemy, rng, turn_index)

func npc_battle_strike(enemy: Dictionary) -> int:
	# 旧调用兼容：仍返回一名伙伴的伤害总值。
	var local_rng := RandomNumberGenerator.new()
	local_rng.randomize()
	var results := PartyCombatSystem.resolve_companion_support(self, enemy, local_rng, 1, 1)
	var total := 0
	for result: Dictionary in results:
		total += int(result.get("damage", 0))
	return total

func npc_personal_quest_info(npc: Dictionary) -> Dictionary:
	var stage := int(npc.get("personal_quest_stage", 0))
	var skill_id := String(npc.get("battle_skill", ""))
	var quest_titles := {
		"剑心共鸣": ["寻回断剑", "重铸剑心", "并肩问剑"],
		"丹心渡厄": ["采集灵药", "救治故人", "共守药庐"],
		"葫芦纳元": ["铜钱古篆", "道观旧影", "长生一问"],
		"月华迷踪步": ["白狐族地", "月潭寻踪", "狐族盟约"],
		"青禾续命针": ["药庐遗方", "疫脉真相", "青禾医道"],
		"阵纹封脉": ["寻访古阵", "修复阵眼", "共绘护宗阵"],
		"妖魂震慑": ["平息兽怨", "追查妖纹", "订立妖盟契约"],
		"皇朝龙威": ["查明旧案", "护送密诏", "共赴天京"]
	}
	var quest_stories := {
		"剑心共鸣": ["伙伴想寻回师门遗失的断剑。", "断剑重铸在即，伙伴希望你见证剑心归一。", "最后一场问剑将决定伙伴能否继承师门剑意。"],
		"丹心渡厄": ["伙伴想采齐灵药，救治曾帮助过自己的人。", "故人病势反复，需要你们一同守护药庐。", "药庐风波平息，伙伴愿将独门丹术传授给你。"],
		"葫芦纳元": ["陆玄机让你寻回铜钱背面的三道古篆，借此查明葫芦封存的旧愿。", "道观中的影子开始独自行走，你们必须找出它与陆玄机旧日道侣之间的因果。", "陆玄机终于讲出长生钱的来历，并以一段残缺道诀回应你一路以来的选择。"],
		"月华迷踪步": ["阿九收到族中密信，邀你前往白狐族地查探月脉异动。", "月潭灵脉遭人盗采，阿九必须在族人与外来修士之间作出抉择。", "你们平息月脉之争，阿九获得族中认可，并与你缔结真正的同行之约。"],
		"青禾续命针": ["沈青禾发现旧药方缺少一味关键灵草，想请你陪她重走疫村旧路。", "疫村地下瘴脉再度翻涌，沈青禾必须决定是否以自身灵脉封住毒源。", "瘴脉封印完成，沈青禾立下医道誓言，并将独门续命针法传授给你。"],
		"阵纹封脉": ["伙伴发现一座与故乡有关的残阵。", "修复阵眼需要你们共同寻找阵材与旧图。", "护宗大阵即将重启，你们将完成最后一笔。"],
		"妖魂震慑": ["伙伴察觉旧日兽群异动，想查清源头。", "妖纹背后藏着一段被掩埋的族群往事。", "族群愿与你们缔结盟约，伙伴终于放下旧怨。"],
		"皇朝龙威": ["伙伴收到一封来自故地的密信。", "旧案牵涉皇朝权贵，需要你们护送证据。", "真相大白，伙伴决定与你共享家族信物。"]
	}
	var titles: Array = quest_titles.get(skill_id, ["故人旧事", "未了因果", "同行之约"])
	var stories: Array = quest_stories.get(skill_id, ["伙伴有一桩未了心愿。", "这段往事逐渐显露真相。", "你们终于解开了旧日心结。"])
	var requirements := ["战斗援护达到2次", "与伙伴好感达到35", "伙伴成长至3级"]
	var progress := [
		int(npc.get("support_count", 0)) >= 2,
		int(npc.get("affinity", 0)) >= 35,
		int(npc.get("partner_level", 1)) >= 3
	]
	if stage >= 3:
		return {"title":"个人剧情已完结", "story":"你与%s的因果已写入共同经历。" % String(npc.get("name", "伙伴")), "requirement":"已完成", "ready":false, "done":true}
	return {"title":String(titles[stage]), "story":String(stories[stage]), "requirement":String(requirements[stage]), "ready":bool(progress[stage]), "done":false}

func claim_npc_personal_quest(npc_id: String) -> Dictionary:
	for index in range(met_npcs.size()):
		var npc: Dictionary = met_npcs[index]
		if String(npc.get("event_id", "")) != npc_id or not bool(npc.get("companion", false)):
			continue
		var quest := npc_personal_quest_info(npc)
		if bool(quest.get("done", false)):
			return {"ok":false, "message":"这段个人剧情已经圆满。"}
		if not bool(quest.get("ready", false)):
			return {"ok":false, "message":"尚未满足条件："+String(quest.get("requirement", "条件未达成"))}
		var stage := int(npc.get("personal_quest_stage", 0))
		npc["personal_quest_stage"] = stage + 1
		var story_log: Array = Array(npc.get("personal_story_log", [])).duplicate(true)
		story_log.append(String(quest.get("story", "")))
		npc["personal_story_log"] = story_log
		npc["affinity"] = clampi(int(npc.get("affinity", 0)) + 8, -100, 100)
		var reward_stones := 35 + stage * 35
		stones += reward_stones
		var faction := String(npc.get("faction", ""))
		if not faction.is_empty() and faction != "不详" and faction != "来历不明":
			faction_reputation[faction] = clampi(int(faction_reputation.get(faction, 0)) + 3, -100, 100)
			if is_faction_member() and faction == faction_name:
				faction_contribution += 2
				if is_sect_member():
					sect_merit += 2
		if stage == 2:
			npc["signature_skill_unlocked"] = true
		met_npcs[index] = npc
		return {"ok":true, "message":"个人剧情「%s」完成。%s好感 +8，获得灵石 %d。%s" % [String(quest.get("title", "个人剧情")), String(npc.get("name", "伙伴")), reward_stones, "解锁专属神通！" if stage == 2 else ""]}
	return {"ok":false, "message":"未找到这位同行伙伴。"}

func pet_battle_strike(enemy: Dictionary, rng: RandomNumberGenerator = null) -> int:
	var roll_rng := rng
	if roll_rng == null:
		roll_rng = RandomNumberGenerator.new()
		roll_rng.randomize()
	var pet := active_pet()
	if pet.is_empty() or int(pet.get("pet_hp", 1)) <= 0:
		return 0
	var level := int(pet.get("level", 1))
	var damage := maxi(1, int(pet.get("power", 8)) + level * 3 + realm * 2)
	var skills: Array = Array(pet.get("skills", []))
	var divine_skill := String(pet.get("divine_skill", ""))
	var divine_triggered := not divine_skill.is_empty() and roll_rng.randf() < 0.35
	pet["last_skill"] = "普通协击"
	if divine_triggered:
		pet["last_skill"] = divine_skill
		damage = int(damage * 2.4)
		if divine_skill == "九霄涅槃" or divine_skill == "玄冥天幕":
			hp = mini(max_hp(), hp + maxi(12, level * 4))
		elif divine_skill == "瑞光镇邪":
			mp = mini(max_mp(), mp + maxi(4, level))
	if skills.has("裂爪"):
		damage = int(damage * 1.25)
		pet["last_skill"] = "裂爪"
	if skills.has("雷袭") and roll_rng.randf() < 0.35:
		damage = int(damage * 1.8)
		pet["last_skill"] = "雷袭"
	if skills.has("龙吟") and roll_rng.randf() < 0.20:
		damage = int(damage * 2.2)
		pet["last_skill"] = "龙吟"
	if skills.has("回春") and roll_rng.randf() < 0.25:
		hp = mini(max_hp(), hp + maxi(3, level * 2))
		pet["last_skill"] = "回春"
	if skills.has("涅槃") and roll_rng.randf() < 0.08:
		hp = mini(max_hp(), hp + maxi(10, level * 5))
		pet["last_skill"] = "涅槃"
	if skills.has("御风") and roll_rng.randf() < 0.2:
		mp = mini(max_mp(), mp + 3)
		pet["last_skill"] = "御风"
	if skills.has("灵甲") and roll_rng.randf() < 0.25:
		hp = mini(max_hp(), hp + maxi(2, level))
		pet["last_skill"] = "灵甲"
	if skills.has("寻宝") and roll_rng.randf() < 0.08:
		stones += 2 + level
		pet["last_skill"] = "寻宝"
	if String(pet.get("bloodline", "")).contains("龙") and roll_rng.randf() < 0.18:
		damage = int(damage * 1.35)
		pet["last_skill"] = "龙息"
	if String(pet.get("bloodline", "")).contains("凤凰") and roll_rng.randf() < 0.12:
		hp = mini(max_hp(), hp + maxi(5, level * 3))
		pet["last_skill"] = "涅槃真火"
	if String(pet.get("bloodline", "")).contains("麒麟") and roll_rng.randf() < 0.18:
		damage = int(damage * 1.2)
		pet["last_skill"] = "祥瑞震击"
	if divine_triggered:
		pet["last_skill"] = divine_skill
	enemy["hp"] = maxi(0, int(enemy.get("hp", 0)) - damage)
	pet["exp"] = int(pet.get("exp", 0)) + 1
	if int(pet.get("exp", 0)) >= int(pet.get("level", 1)) * 3:
		pet["exp"] = 0
		pet["level"] = int(pet.get("level", 1)) + 1
		pet["power"] = int(pet.get("power", 8)) + 2
	pets[active_pet_index] = pet
	return damage

func active_pet_take_damage(amount: int) -> int:
	var pet := active_pet()
	if pet.is_empty() or int(pet.get("pet_hp", 1)) <= 0:
		return 0
	var actual := mini(maxi(0, amount), int(pet.get("pet_hp", 1)))
	pet["pet_hp"] = maxi(0, int(pet.get("pet_hp", 1)) - actual)
	pets[active_pet_index] = pet
	return actual

func recover_active_pet_after_battle() -> void:
	var pet := active_pet()
	if pet.is_empty():
		return
	var maximum := maxi(30, int(pet.get("pet_max_hp", 80)))
	var recovery := int(ceil(float(maximum) * (0.50 if int(pet.get("pet_hp", 0)) <= 0 else 0.25)))
	pet["pet_hp"] = mini(maximum, int(pet.get("pet_hp", 0)) + maxi(1, recovery))
	pets[active_pet_index] = pet

func pet_gather(rng: RandomNumberGenerator) -> String:
	var pet := active_pet()
	if pet.is_empty():
		return ""
	var chance := 0.35
	if Array(pet.get("skills", [])).has("寻宝"): chance += 0.25
	if rng.randf() > chance:
		return ""
	var material := String(pet.get("gather", "凝露草"))
	add_material(material, 1)
	return material

func get_pill_recipes() -> Array[Dictionary]:
	# 炼丹只使用灵草、灵露与可入药的兽类精华；矿石与机关材料留给炼器。
	var recipes: Array[Dictionary] = [
		{"name":"小还丹", "cost":{"凝露草":2,"灵芝":1}, "recipe":"凝露草 ×2 · 灵芝 ×1", "effect":"恢复 45 气血", "price":35},
		{"name":"聚气散", "cost":{"凝露草":2}, "recipe":"凝露草 ×2", "effect":"恢复 35 灵力", "price":40},
		{"name":"大还丹", "cost":{"灵芝":2,"妖狼獠牙":1}, "recipe":"灵芝 ×2 · 妖狼獠牙 ×1", "effect":"恢复 90 气血", "price":85},
		{"name":"归元丹", "cost":{"灵芝":1,"寒潭鳞片":1}, "recipe":"灵芝 ×1 · 寒潭鳞片 ×1", "effect":"恢复 35 气血与 35 灵力", "price":100},
		{"name":"青岚清心丹", "cost":{"青岚灵叶":2,"凝露草":1}, "recipe":"青岚灵叶 ×2 · 凝露草 ×1", "effect":"恢复 90 灵力", "price":110},
		{"name":"天京玉露丹", "cost":{"天京玉露":1,"灵芝":2}, "recipe":"天京玉露 ×1 · 灵芝 ×2", "effect":"恢复 130 气血", "price":240},
		{"name":"药王续命丹", "cost":{"百年灵芝":1,"九叶药草":2}, "recipe":"百年灵芝 ×1 · 九叶药草 ×2", "effect":"恢复 180 气血", "price":420},
		{"name":"荒古血魄丹", "cost":{"妖兽精血":1,"九叶药草":1}, "recipe":"妖兽精血 ×1 · 九叶药草 ×1", "effect":"恢复 120 气血与 60 灵力", "price":300},
		{"name":"归墟龙元丹", "cost":{"龙宫珍珠":2,"灵芝":1}, "recipe":"龙宫珍珠 ×2 · 灵芝 ×1", "effect":"恢复 120 气血与 120 灵力", "price":260},
		{"name":"清瘴丹", "cost":{"九叶药草":2,"幽冥魂晶":1}, "recipe":"九叶药草 ×2 · 幽冥魂晶 ×1", "effect":"清除瘴毒，伤势 -35", "price":180, "realm":2},
		{"name":"洗髓丹", "cost":{"百年灵芝":1,"荒古兽骨":1}, "recipe":"百年灵芝 ×1 · 荒古兽骨 ×1", "effect":"淬炼根骨，根骨永久 +2（上限 100）", "price":520, "realm":5},
		{"name":"悟道丹", "cost":{"青岚灵叶":2,"百年灵芝":1}, "recipe":"青岚灵叶 ×2 · 百年灵芝 ×1", "effect":"启迪神识，悟性永久 +2（上限 100）", "price":560, "realm":5},
		{"name":"破障丹", "cost":{"九叶药草":2,"龙宫珍珠":1}, "recipe":"九叶药草 ×2 · 龙宫珍珠 ×1", "effect":"药力助道，突破成功率加成 +8", "price":760, "realm":8},
		{"name":"凝神丹", "cost":{"灵芝":2,"青岚灵叶":1}, "recipe":"灵芝 ×2 · 青岚灵叶 ×1", "effect":"凝神静气，灵力恢复 80、伤势 -12", "price":240, "realm":2}
	]
	return recipes

func get_forge_recipes() -> Array[Dictionary]:
	return [
		{"name":"青岚剑纹灵剑", "cost":{"剑纹石":2,"妖狼獠牙":1}, "recipe":"剑纹石 ×2 · 妖狼獠牙 ×1", "slot":"weapon", "effect":"攻击 +13 · 速度 +4", "desc":"剑纹石为刃，妖狼獠牙作锋，剑气轻灵。"},
		{"name":"天京赤金护甲", "cost":{"赤金砂":2,"荒古兽骨":1}, "recipe":"赤金砂 ×2 · 荒古兽骨 ×1", "slot":"guard", "effect":"防御 +8 · 伤害减免 +5", "desc":"赤金砂熔铸甲片，荒古兽骨支撑内衬。"},
		{"name":"天机阵枢法器", "cost":{"天机铜片":2,"玄纹晶石":1}, "recipe":"天机铜片 ×2 · 玄纹晶石 ×1", "slot":"heart", "effect":"悟性 +4 · 修炼效率 +5", "desc":"铜片刻阵，晶石为枢，可稳定神念与灵气周天。"},
		{"name":"幽冥镇魂铃", "cost":{"幽冥魂晶":1,"血煞石":2}, "recipe":"幽冥魂晶 ×1 · 血煞石 ×2", "slot":"heart", "effect":"道心 +5 · 技能威力 +6", "desc":"魂晶定魄，血煞石为铃舌，专镇阴魂邪祟。"},
		{"name":"归墟蛟鳞战衣", "cost":{"蛟龙逆鳞":1,"寒潭鳞片":2}, "recipe":"蛟龙逆鳞 ×1 · 寒潭鳞片 ×2", "slot":"guard", "effect":"根骨 +4 · 防御 +10", "desc":"以蛟龙逆鳞为核心，寒潭鳞片层叠成衣。"},
		{"name":"赤焰傀儡重锤", "cost":{"赤焰砂":2,"石傀核心":1}, "recipe":"赤焰砂 ×2 · 石傀核心 ×1", "slot":"weapon", "effect":"攻击 +16 · 防御 +2", "desc":"赤焰砂淬火，石傀核心作锤心，势大力沉。"},
		{"name":"幽血镇邪护符", "cost":{"阴魂结晶":1,"魔修血晶":2}, "recipe":"阴魂结晶 ×1 · 魔修血晶 ×2", "slot":"guard", "effect":"道心 +4 · 伤害减免 +10", "desc":"阴魂结晶封存残念，魔修血晶压住煞气，护身镇邪。"}
	]

func can_craft_equipment(item_name: String) -> bool:
	if treasures.has(item_name):
		return false
	for recipe: Dictionary in get_forge_recipes():
		if String(recipe.get("name", "")) != item_name:
			continue
		var cost: Dictionary = recipe.get("cost", {})
		for material: Variant in cost.keys():
			if int(materials.get(String(material), 0)) < int(cost[material]):
				return false
		return true
	return false

func craft_equipment(item_name: String) -> bool:
	if not can_craft_equipment(item_name):
		return false
	for recipe: Dictionary in get_forge_recipes():
		if String(recipe.get("name", "")) != item_name:
			continue
		var cost: Dictionary = recipe.get("cost", {})
		for material: Variant in cost.keys():
			materials[String(material)] = int(materials.get(String(material), 0)) - int(cost[material])
		treasures.append(item_name)
		return true
	return false

func can_craft_pill(pill_name: String) -> bool:
	for recipe: Dictionary in get_pill_recipes():
		if String(recipe.get("name", "")) != pill_name:
			continue
		var cost: Dictionary = recipe.get("cost", {})
		for material: Variant in cost.keys():
			if int(materials.get(String(material), 0)) < int(cost[material]):
				return false
		return true
	return false

func craft_pill(pill_name: String) -> bool:
	if not can_craft_pill(pill_name):
		return false
	for recipe: Dictionary in get_pill_recipes():
		if String(recipe.get("name", "")) != pill_name:
			continue
		var cost: Dictionary = recipe.get("cost", {})
		for material: Variant in cost.keys():
			materials[String(material)] = int(materials.get(String(material), 0)) - int(cost[material])
		pills[pill_name] = int(pills.get(pill_name, 0)) + 1
		return true
	return false

func use_pill(pill_name: String) -> Dictionary:
	if int(pills.get(pill_name, 0)) <= 0:
		return {"ok": false, "message": "没有这类丹药。"}
	var healed := 0
	var restored := 0
	var extra_message := ""
	match pill_name:
		"小还丹":
			healed = mini(45, max_hp() - hp)
		"聚气散":
			restored = mini(35, max_mp() - mp)
		"大还丹":
			healed = mini(90, max_hp() - hp)
		"归元丹":
			healed = mini(35, max_hp() - hp)
			restored = mini(35, max_mp() - mp)
		"青岚清心丹": restored = mini(90, max_mp() - mp)
		"天京玉露丹": healed = mini(130, max_hp() - hp)
		"药王续命丹": healed = mini(180, max_hp() - hp)
		"荒古血魄丹":
			healed = mini(120, max_hp() - hp)
			restored = mini(60, max_mp() - mp)
		# 旧版本已经炼出的地域丹药仍可正常服用，兼容旧存档。
		"青岚剑心丹": restored = mini(90, max_mp() - mp)
		"天京玉髓丹": healed = mini(130, max_hp() - hp)
		"天机破障丹": restored = mini(120, max_mp() - mp)
		"荒古淬体丹": healed = mini(220, max_hp() - hp)
		"幽冥凝魂丹": restored = mini(180, max_mp() - mp)
		"归墟龙元丹":
			healed = mini(120, max_hp() - hp)
			restored = mini(120, max_mp() - mp)
		"清瘴丹":
			var injury_before_cleanse := injury
			injury = maxi(0, injury - 35)
			if injury_before_cleanse > injury:
				extra_message = "伤势减轻 %d" % (injury_before_cleanse - injury)
		"洗髓丹":
			var body_before := body
			body = mini(100, body + 2)
			if body > body_before:
				extra_message = "根骨永久提升 %d" % (body - body_before)
		"悟道丹":
			var insight_before := insight
			insight = mini(100, insight + 2)
			if insight > insight_before:
				extra_message = "悟性永久提升 %d" % (insight - insight_before)
		"破障丹":
			breakthrough_bonus += 8.0
			extra_message = "突破成功率加成 +8（永久）"
		"凝神丹":
			restored = mini(80, max_mp() - mp)
			var injury_before_focus := injury
			injury = maxi(0, injury - 12)
			if injury_before_focus > injury:
				extra_message = "伤势减轻 %d" % (injury_before_focus - injury)
		_:
			return {"ok": false, "message": "不认识这类丹药。"}
	if healed <= 0 and restored <= 0 and extra_message.is_empty():
		return {"ok": false, "message": "当前气血与灵力充足，不必服丹。"}
	pills[pill_name] = int(pills.get(pill_name, 0)) - 1
	hp += healed
	mp += restored
	var result_parts: Array[String] = []
	if healed > 0: result_parts.append("气血恢复 %d" % healed)
	if restored > 0: result_parts.append("灵力恢复 %d" % restored)
	if not extra_message.is_empty(): result_parts.append(extra_message)
	return {"ok": true, "hp": healed, "mp": restored, "message": "服下%s，%s。" % [pill_name, "，".join(PackedStringArray(result_parts))]}

func can_afford(cost: int) -> bool:
	return stones >= cost

func pay_stones(cost: int) -> bool:
	if stones < cost:
		return false
	stones -= cost
	return true

func record_npc_choice(profile: Dictionary, event: Dictionary, choice: Dictionary, outcome: Dictionary) -> Array:
	return NpcRelationshipSystem.record_choice(self, profile, event, choice, outcome)

func npc_relationship_record(npc_name: String, faction_name: String = "") -> Dictionary:
	return NpcRelationshipSystem.get_record(self, npc_name, faction_name)

func save_npc_relationship_record(npc_name: String, record: Dictionary) -> void:
	NpcRelationshipSystem.save_record(self, npc_name, record)

func adjust_npc_affinity(npc_name: String, delta: int, faction_name: String, reason: String, intro: String = "") -> Dictionary:
	return NpcRelationshipSystem.adjust_affinity(self, npc_name, delta, faction_name, reason, intro)

func apply_effects(effects: Dictionary) -> Array:
	var notes: Array = []
	for raw_key: Variant in effects.keys():
		var key: String = String(raw_key)
		var value: Variant = effects[raw_key]
		match key:
			"root_grade_up":
				var before := "%s·%s" % [String(root.get("grade_name", "伪灵根")), String(root.get("name", ""))]
				if int(root.get("grade", 1)) <= 1:
					notes.append("灵根已是%s，洗不掉更多杂属性。" % String(root.get("grade_name", "天灵根")))
				else:
					var old_stats: Dictionary = root.get("stats", {})
					var purified: Dictionary = GameData.purify_root(root)
					var new_stats: Dictionary = purified.get("stats", {})
					for stat_key: String in ["body", "insight", "luck", "daoheart"]:
						set(stat_key, clampi(int(get(stat_key)) - int(old_stats.get(stat_key, 0)) + int(new_stats.get(stat_key, 0)), 1, 100))
					root = purified
					notes.append("灵根洗去一重杂气：%s → %s·%s" % [before, String(root.get("grade_name", "")), String(root.get("name", ""))])
			"root_type":
				var new_root_name := String(value)
				var old_stats: Dictionary = root.get("stats", {})
				var rebuilt: Dictionary = GameData.force_root(new_root_name, root.get("elements", []), RandomNumberGenerator.new())
				var new_stats: Dictionary = rebuilt.get("stats", {})
				for stat_key: String in ["body", "insight", "luck", "daoheart"]:
					set(stat_key, clampi(int(get(stat_key)) - int(old_stats.get(stat_key, 0)) + int(new_stats.get(stat_key, 0)), 1, 100))
				root = rebuilt
				notes.append("灵根蜕变为%s·%s" % [String(root.get("grade_name", "")), String(root.get("name", ""))])
			"body":
				var delta_body: int = _bounded_delta(body, int(value), 1, 100)
				body += delta_body
				if delta_body != 0: notes.append("根骨 %+d" % delta_body)
			"insight":
				var delta_insight: int = _bounded_delta(insight, int(value), 1, 100)
				insight += delta_insight
				if delta_insight != 0: notes.append("悟性 %+d" % delta_insight)
			"luck":
				var delta_luck: int = _bounded_delta(luck, int(value), 1, 100)
				luck += delta_luck
				if delta_luck != 0: notes.append("气运 %+d" % delta_luck)
			"daoheart":
				var delta_heart: int = _bounded_delta(daoheart, int(value), 1, 100)
				daoheart += delta_heart
				if delta_heart != 0: notes.append("道心 %+d" % delta_heart)
			"karma":
				var old_karma: int = karma
				karma = clampi(karma + int(value), -100, 100)
				if karma != old_karma: notes.append("因果 %+d" % (karma - old_karma))
			"stones":
				var old_stones: int = stones
				stones = maxi(0, stones + int(value))
				if stones != old_stones: notes.append("灵石 %+d" % (stones - old_stones))
			"lifespan":
				lifespan += int(value)
				notes.append("寿元 %+d" % int(value))
			"injury":
				var old_injury: int = injury
				var injury_change: int = int(value)
				if injury_change > 0:
					injury_change = _mitigated_injury(injury_change)
				injury = clampi(injury + injury_change, 0, 100)
				if injury != old_injury:
					notes.append("伤势 %+d" % (injury - old_injury))
			"cult_pct":
				var pct: float = float(value) / 100.0
				var before: float = cultivation
				cultivation = clampf(cultivation + threshold() * pct, 0.0, threshold())
				var delta: int = int(round(cultivation - before))
				if delta != 0: notes.append("修为 %+d" % delta)
				if delta == 0 and pct > 0.0 and is_peak(): notes.append("气机已满")
			"treasure":
				var treasure_name: String = String(value)
				if not treasures.has(treasure_name):
					treasures.append(treasure_name)
					treasure_ages[treasure_name] = age
					notes.append("获得【%s】" % treasure_name)
			"flag":
				flags[String(value)] = true
			"materials":
				if value is Dictionary:
					for material_value: Variant in value.keys():
						var material_reward_name := String(material_value)
						var material_reward_count := int(value[material_value])
						if material_reward_count > 0:
							add_material(material_reward_name, material_reward_count)
							notes.append("材料 %s ×%d" % [material_reward_name, material_reward_count])
			"add_material":
				if value is Dictionary:
					for material_value: Variant in value.keys():
						var single_material_name := String(material_value)
						var single_material_count := int(value[material_value])
						if single_material_count > 0:
							add_material(single_material_name, single_material_count)
							notes.append("材料 %s ×%d" % [single_material_name, single_material_count])
			"add_pet":
				var pet_data: Dictionary = value.duplicate(true) if value is Dictionary else {"name":String(value), "species":String(value)}
				var pet_name := String(pet_data.get("name", pet_data.get("species", "奇遇灵兽")))
				var exists := false
				for owned_pet: Variant in pets:
					if owned_pet is Dictionary and String(owned_pet.get("species", owned_pet.get("name", ""))) == String(pet_data.get("species", pet_name)):
						exists = true
						break
				if not exists and not pet_name.is_empty():
					pet_data["name"] = pet_name
					pet_data["species"] = String(pet_data.get("species", pet_name))
					pet_data["region"] = String(pet_data.get("region", current_region))
					pet_data["level"] = maxi(1, int(pet_data.get("level", 1)))
					pet_data["power"] = maxi(1, int(pet_data.get("power", 12)))
					pet_data["bond"] = maxi(1, int(pet_data.get("bond", 10)))
					_pet_normalize(pet_data)
					pets.append(pet_data)
					if active_pet_index < 0:
						active_pet_index = pets.size() - 1
					notes.append("结识灵宠：%s" % pet_name)
				else:
					notes.append("已拥有这只灵兽，未重复添加")
			"add_mount":
				var mount_data: Dictionary = value.duplicate(true) if value is Dictionary else {"name":String(value), "speed":10, "desc":"奇遇所得坐骑"}
				var mount_name := String(mount_data.get("name", "奇遇坐骑"))
				var mount_exists := false
				for owned_mount: Variant in mounts:
					if owned_mount is Dictionary and String(owned_mount.get("name", "")) == mount_name:
						mount_exists = true
						break
				if not mount_exists and not mount_name.is_empty():
					mount_data["name"] = mount_name
					mount_data["speed"] = maxi(1, int(mount_data.get("speed", 10)))
					mount_data["desc"] = String(mount_data.get("desc", "奇遇所得坐骑"))
					mounts.append(mount_data)
					if active_mount_index < 0:
						active_mount_index = mounts.size() - 1
					notes.append("获得坐骑：%s" % mount_name)
				else:
					notes.append("已拥有坐骑%s，未重复添加" % mount_name)
			"learn_skill":
				var skill_id := String(value)
				var skill_info: Dictionary = BattleSystem.skill_data(skill_id)
				if not skill_info.is_empty() and not learned_skills.has(skill_id):
					learned_skills.append(skill_id)
					notes.append("领悟功法/招式：%s" % String(skill_info.get("name", skill_id)))
				elif not skill_info.is_empty():
					notes.append("已经掌握%s" % String(skill_info.get("name", skill_id)))
				else:
					notes.append("未找到功法编号：%s" % skill_id)
			"faction_contribution":
				if is_faction_member():
					var contribution_gain := int(value)
					faction_contribution = maxi(0, faction_contribution + contribution_gain)
					if is_sect_member():
						sect_merit = maxi(0, sect_merit + contribution_gain)
						var sect_promotion_text := _sect_promote_if_ready()
						if not sect_promotion_text.is_empty(): notes.append(sect_promotion_text)
					else:
						var faction_promotion_text := _faction_promote_if_ready()
						if not faction_promotion_text.is_empty(): notes.append(faction_promotion_text)
					notes.append("势力贡献 %+d" % contribution_gain)
				else:
					notes.append("尚未加入势力，未获得势力贡献")
			"faction_reputation":
				if value is Dictionary:
					for faction_value: Variant in value.keys():
						var faction_key := String(faction_value)
						faction_reputation[faction_key] = int(faction_reputation.get(faction_key, 0)) + int(value[faction_value])
						notes.append("%s声望 %+d" % [faction_key, int(value[faction_value])])
			"unlock_region":
				var region_name := String(value)
				for region_data: Dictionary in WORLD_REGIONS:
					if String(region_data.get("name", "")) == region_name:
						if not discovered_regions.has(region_name):
							discovered_regions.append(region_name)
							notes.append("解锁九州区域：%s" % region_name)
						else:
							notes.append("已探索区域：%s" % region_name)
						break
			"start_quest":
				var quest_data: Dictionary = value.duplicate(true) if value is Dictionary else {"id":String(value), "title":String(value), "stage":0, "status":"active"}
				var new_quest_id := String(quest_data.get("id", quest_data.get("title", "")))
				var active_quests: Array = Array(flags.get("active_quests", [])).duplicate(true)
				var quest_exists := false
				for active_quest: Variant in active_quests:
					if active_quest is Dictionary and String(active_quest.get("id", "")) == new_quest_id:
						quest_exists = true
						break
				if not new_quest_id.is_empty() and not quest_exists:
					quest_data["id"] = new_quest_id
					quest_data["stage"] = maxi(0, int(quest_data.get("stage", 0)))
					quest_data["status"] = "active"
					active_quests.append(quest_data)
					flags["active_quests"] = active_quests
					notes.append("开启奇遇任务：%s" % String(quest_data.get("title", new_quest_id)))
				elif quest_exists:
					notes.append("任务已在进行中：%s" % new_quest_id)
			"quest_stage":
				if value is Dictionary:
					var stage_quest_id := String(value.get("id", ""))
					var stage_value := int(value.get("stage", 0))
					var stage_active_quests: Array = Array(flags.get("active_quests", [])).duplicate(true)
					for quest_index in range(stage_active_quests.size()):
						if stage_active_quests[quest_index] is Dictionary and String(stage_active_quests[quest_index].get("id", "")) == stage_quest_id:
							stage_active_quests[quest_index]["stage"] = maxi(0, stage_value)
							flags["active_quests"] = stage_active_quests
							notes.append("任务%s推进至阶段%d" % [stage_quest_id, stage_value])
							break
			"world_event":
				var world_event_text := String(value)
				if not world_event_text.is_empty():
					world_events.append({"year":world_year, "text":world_event_text, "source":"adventure"})
					if world_events.size() > 12: world_events.pop_front()
					notes.append("世界传闻：%s" % world_event_text)
			"death_cause":
				die(String(value))
				notes.append("身死道消")
			_:
				pass
	return notes

func _bounded_delta(current: int, amount: int, low: int, high: int) -> int:
	var target: int = clampi(current + amount, low, high)
	return target - current

func check_death() -> bool:
	if not alive:
		return true
	if ascended:
		die("白日飞升")
		return true
	if hp <= 0:
		die("战斗中气血耗尽")
		return true
	if injury >= 100:
		die("伤重不治")
		return true
	if age >= lifespan + int(round(relic_mod("lifespan"))):
		die("寿元耗尽")
		return true
	return false

func die(reason: String) -> void:
	if not alive:
		return
	alive = false
	death_reason = reason
	if reason == "白日飞升":
		return
	var line: String
	match reason:
		"寿元耗尽":
			line = "这一日，你照例在洞府中打坐。晨光落在膝头，你却再没有睁开眼睛。\n\n[color=#6f6250]寿元已尽，此生如灯灭。[/color]"
		"伤重不治":
			line = "伤势终于压不住了。你靠在石壁上，听见自己的心跳一点点变慢。最后映入眼帘的，是洞口那线天光。\n\n[color=#6f6250]道途未尽，身先死。[/color]"
		_:
			line = "你的气机如退潮般散去，眼前的一切慢慢变暗。\n\n[color=#6f6250]%s。[/color]" % reason
	add_log(line, "death")

func snapshot() -> Dictionary:
	return {
		"name": player_name,
		"origin": String(origin.get("name", "无名出身")),
		"root": "%s·%s" % [String(root.get("grade_name", "伪灵根")), String(root.get("name", "五行"))],
		"realm": realm,
		"realm_name": realm_name(),
		"age": age,
		"lifespan": lifespan,
		"karma": karma,
		"karma_title": alignment_text(),
		"death_reason": death_reason,
		"ascended": ascended,
		"treasures": treasures.duplicate(),
	}

func to_dict() -> Dictionary:
	return {
		"version": 3,
		"name": player_name,
		"origin": origin.duplicate(true),
		"root": root.duplicate(true),
		"talents": talents.duplicate(true),
		"realm": realm,
		"cultivation": cultivation,
		"age": age,
		"lifespan": lifespan,
		"body": body,
		"insight": insight,
		"luck": luck,
		"daoheart": daoheart,
		"stones": stones,
		"injury": injury,
		"hp": hp,
		"mp": mp,
		"learned_skills": learned_skills.duplicate(),
		"skill_mastery": skill_mastery.duplicate(true),
		"equipped_skills": equipped_skills.duplicate(),
		"equipped_methods": equipped_methods.duplicate(),
		"equipped_martial": equipped_martial.duplicate(),
		"materials": materials.duplicate(true),
		"pets": pets.duplicate(true),
		"active_pet_index": active_pet_index,
		"mounts": mounts.duplicate(true),
		"active_mount_index": active_mount_index,
		"pills": pills.duplicate(true),
		"karma": karma,
		"treasures": treasures.duplicate(),
		"treasure_ages": treasure_ages.duplicate(true),
		"equipment": equipment.duplicate(true),
		"seen_events": seen_events.duplicate(),
		"met_npcs": met_npcs.duplicate(true),
		"wander_seen_lines": wander_seen_lines.duplicate(),
		"flags": flags.duplicate(true),
		"logs": logs.duplicate(true),
		"log_seq": log_seq,
		"alive": alive,
		"ascended": ascended,
		"death_reason": death_reason,
		"death_handled": death_handled,
		"breakthrough_bonus": breakthrough_bonus,
		"turn_count": turn_count,
		"faction_name": faction_name,
		"faction_rank": faction_rank,
		"faction_contribution": faction_contribution,
		"sect_merit": sect_merit,
		"sect_facility_level": sect_facility_level,
		"sect_task_claimed_turn": sect_task_claimed_turn,
		"sect_disciples": sect_disciples.duplicate(true),
		"sect_recruit_count": sect_recruit_count,
		"sect_tournament_turn": sect_tournament_turn,
		"sect_tournament_wins": sect_tournament_wins,
		"faction_reputation": faction_reputation.duplicate(true),
		"faction_relations": faction_relations.duplicate(true),
		"world_conflict": world_conflict,
		"current_region": current_region,
		"discovered_regions": discovered_regions.duplicate(),
		"faction_power_state": faction_power_state.duplicate(true),
		"world_events": world_events.duplicate(true),
		"rival_npcs": rival_npcs.duplicate(true),
		"world_year": world_year,
	}

static func from_dict(data: Dictionary) -> GameState:
	var state := GameState.new()
	state.player_name = String(data.get("name", "无名"))
	state.origin = data.get("origin", {}).duplicate(true) if data.get("origin", {}) is Dictionary else {}
	state.root = data.get("root", {}).duplicate(true) if data.get("root", {}) is Dictionary else {}
	state.talents = Array(data.get("talents", [])).duplicate(true)
	state.realm = int(data.get("realm", 0))
	state.cultivation = float(data.get("cultivation", 0.0))
	state.age = int(data.get("age", 16))
	state.lifespan = int(data.get("lifespan", 80))
	state.body = int(data.get("body", 32))
	state.insight = int(data.get("insight", 32))
	state.luck = int(data.get("luck", 32))
	state.daoheart = int(data.get("daoheart", 32))
	state.stones = int(data.get("stones", 0))
	state.injury = int(data.get("injury", 0))
	state.materials = data.get("materials", state.materials).duplicate(true) if data.get("materials", state.materials) is Dictionary else state.materials
	state.pets = data.get("pets", []).duplicate(true) if data.get("pets", []) is Array else []
	for pet_value: Variant in state.pets:
		if pet_value is Dictionary: state._pet_normalize(pet_value)
	state.active_pet_index = int(data.get("active_pet_index", 0 if not state.pets.is_empty() else -1))
	if state.active_pet_index < -1 or state.active_pet_index >= state.pets.size(): state.active_pet_index = -1
	state.mounts = data.get("mounts", []).duplicate(true) if data.get("mounts", []) is Array else []
	state.active_mount_index = int(data.get("active_mount_index", 0 if not state.mounts.is_empty() else -1))
	if state.active_mount_index < -1 or state.active_mount_index >= state.mounts.size(): state.active_mount_index = -1
	state.pills = data.get("pills", state.pills).duplicate(true) if data.get("pills", state.pills) is Dictionary else state.pills
	for material_name: String in ["凝露草", "灵芝", "妖狼獠牙", "赤焰砂"]:
		state.materials[material_name] = maxi(0, int(state.materials.get(material_name, 0)))
	for pill_name: String in ["小还丹", "聚气散", "大还丹", "归元丹", "清瘴丹", "洗髓丹", "悟道丹", "破障丹", "凝神丹"]:
		state.pills[pill_name] = maxi(0, int(state.pills.get(pill_name, 0)))
	for scene_line: Variant in data.get("wander_seen_lines", []):
		state.wander_seen_lines.append(String(scene_line))
	state.met_npcs = []
	for npc_value: Variant in data.get("met_npcs", []):
		if npc_value is Dictionary:
			state.met_npcs.append(npc_value.duplicate(true))
	state.karma = int(data.get("karma", 0))
	state.treasures = Array(data.get("treasures", []))
	state.treasure_ages = data.get("treasure_ages", {}).duplicate(true) if data.get("treasure_ages", {}) is Dictionary else {}
	state.equipment = empty_equipment()
	if data.get("equipment") is Dictionary:
		var saved_equipment: Dictionary = data["equipment"]
		for slot: Dictionary in GameData.EQUIP_SLOTS:
			var slot_id: String = String(slot["id"])
			var item_name: String = String(saved_equipment.get(slot_id, ""))
			if item_name.is_empty() or not state.treasures.has(item_name):
				continue
			var info: Dictionary = GameData.treasure_info(item_name)
			if String(info.get("slot", "")) == slot_id:
				state.equipment[slot_id] = item_name
	state.hp = clampi(int(data.get("hp", state.max_hp())), 1, state.max_hp())
	state.mp = clampi(int(data.get("mp", state.max_mp())), 0, state.max_mp())
	state.learned_skills.clear()
	for skill_id: Variant in data.get("learned_skills", ["qi_sword"]):
		if BattleSystem.skill_data(String(skill_id)).size() > 0 and not state.learned_skills.has(String(skill_id)):
			state.learned_skills.append(String(skill_id))
	state.skill_mastery.clear()
	var saved_mastery: Dictionary = data.get("skill_mastery", {}) if data.get("skill_mastery", {}) is Dictionary else {}
	for mastery_id: Variant in saved_mastery.keys():
		var mastery_key := String(mastery_id)
		if state.learned_skills.has(mastery_key):
			state.skill_mastery[mastery_key] = clampi(int(saved_mastery[mastery_id]), 0, 1400)
	state.equipped_skills.clear()
	state.equipped_methods.clear()
	state.equipped_martial.clear()
	# 新版优先读取独立栏位；旧存档则按典籍类别自动迁移。
	var saved_methods: Array = data.get("equipped_methods", []).duplicate()
	var saved_martial: Array = data.get("equipped_martial", []).duplicate()
	# 新分类上线后，把旧版误放在功法栏的主动防御/恢复/秘术迁移到主动技艺栏。
	var still_methods: Array = []
	for old_method_value: Variant in saved_methods:
		var old_method_id := String(old_method_value)
		if state.skill_category(old_method_id) == "功法":
			still_methods.append(old_method_id)
		elif not saved_martial.has(old_method_id):
			saved_martial.append(old_method_id)
	saved_methods = still_methods
	# 迁移旧版混合装备栏；也兼容只保存了其中一个新版栏位的中间版本。
	for legacy_id: Variant in data.get("equipped_skills", ["qi_sword"]):
		var legacy_key := String(legacy_id)
		if state.skill_category(legacy_key) == "功法" and not saved_methods.has(legacy_key):
			saved_methods.append(legacy_key)
		elif state.skill_category(legacy_key) != "功法" and not saved_martial.has(legacy_key):
			saved_martial.append(legacy_key)
	for skill_id: Variant in saved_methods:
		var method_id := String(skill_id)
		if state.learned_skills.has(method_id) and state.skill_category(method_id) == "功法" and not state.equipped_methods.has(method_id) and state.equipped_methods.size() < state.method_slot_count():
			state.equipped_methods.append(method_id)
	for skill_id: Variant in saved_martial:
		var martial_id := String(skill_id)
		if state.learned_skills.has(martial_id) and state.skill_category(martial_id) != "功法" and not state.equipped_martial.has(martial_id) and state.equipped_martial.size() < state.martial_slot_count():
			state.equipped_martial.append(martial_id)
	if state.equipped_martial.is_empty() and state.learned_skills.has("qi_sword"):
		state.equipped_martial.append("qi_sword")
	state._sync_legacy_equipped_skills()
	state.hp = clampi(state.hp, 1, state.max_hp())
	state.mp = clampi(state.mp, 0, state.max_mp())
	state.seen_events = Array(data.get("seen_events", []))
	state.flags = data.get("flags", {}).duplicate(true) if data.get("flags", {}) is Dictionary else {}
	state.logs = Array(data.get("logs", [])).duplicate(true)
	state.log_seq = int(data.get("log_seq", state.logs.size()))
	state.alive = bool(data.get("alive", true))
	state.ascended = bool(data.get("ascended", false))
	state.death_reason = String(data.get("death_reason", ""))
	state.death_handled = bool(data.get("death_handled", false))
	state.breakthrough_bonus = float(data.get("breakthrough_bonus", 0.0))
	state.turn_count = int(data.get("turn_count", 0))
	state.faction_name = String(data.get("faction_name", "散修"))
	state.faction_rank = String(data.get("faction_rank", "无门无派"))
	state.faction_contribution = int(data.get("faction_contribution", 0))
	state.sect_merit = int(data.get("sect_merit", state.faction_contribution))
	state.sect_facility_level = clampi(int(data.get("sect_facility_level", 0)), 0, 3)
	state.sect_task_claimed_turn = int(data.get("sect_task_claimed_turn", -99))
	state.sect_disciples.clear()
	for disciple: Variant in data.get("sect_disciples", []):
		if disciple is Dictionary: state.sect_disciples.append(disciple.duplicate(true))
	state.sect_recruit_count = int(data.get("sect_recruit_count", state.sect_disciples.size()))
	state.sect_tournament_turn = int(data.get("sect_tournament_turn", -99))
	state.sect_tournament_wins = int(data.get("sect_tournament_wins", 0))
	state.faction_reputation = data.get("faction_reputation", {}).duplicate(true) if data.get("faction_reputation", {}) is Dictionary else {}
	state.faction_relations = data.get("faction_relations", {}).duplicate(true) if data.get("faction_relations", {}) is Dictionary else {}
	state.world_conflict = int(data.get("world_conflict", 1))
	state.current_region = String(data.get("current_region", "东境·青岚山"))
	var current_region_valid := false
	for region: Dictionary in WORLD_REGIONS:
		if String(region.get("name", "")) == state.current_region:
			current_region_valid = true
			break
	if not current_region_valid:
		state.current_region = "东境·青岚山"
	state.discovered_regions.clear()
	for region_name: Variant in data.get("discovered_regions", [state.current_region]):
		var candidate := String(region_name)
		for region: Dictionary in WORLD_REGIONS:
			if String(region.get("name", "")) == candidate and not state.discovered_regions.has(candidate):
				state.discovered_regions.append(candidate)
				break
	if state.discovered_regions.is_empty(): state.discovered_regions.append(state.current_region)
	if not state.discovered_regions.has(state.current_region): state.discovered_regions.append(state.current_region)
	state.faction_power_state = data.get("faction_power_state", {}).duplicate(true) if data.get("faction_power_state", {}) is Dictionary else {}
	state.world_events = Array(data.get("world_events", [])).duplicate(true)
	state.rival_npcs.clear()
	for rival: Variant in data.get("rival_npcs", []):
		if rival is Dictionary: state.rival_npcs.append(rival.duplicate(true))
	state.world_year = int(data.get("world_year", maxi(1, state.turn_count + 1)))
	if state.rival_npcs.is_empty():
		var fallback_name := String(GameData.SURNAMES[posmod(state.turn_count + 3, GameData.SURNAMES.size())]) + String(GameData.GIVEN_NAMES[posmod(state.turn_count * 5 + 1, GameData.GIVEN_NAMES.size())])
		state.rival_npcs.append({"name":fallback_name, "realm":0, "cultivation":0, "aptitude":55, "temper":"好胜", "alive":true, "last_seen":state.age, "relationship":"未曾谋面"})
	for faction: Dictionary in WORLD_FACTIONS:
		var faction_key := String(faction["name"])
		if not state.faction_reputation.has(faction_key): state.faction_reputation[faction_key] = 0
		if not state.faction_relations.has(faction_key): state.faction_relations[faction_key] = "中立"
		if not state.faction_power_state.has(faction_key): state.faction_power_state[faction_key] = int(faction.get("power", 50))
	if state.root.is_empty():
		var fallback_rng := RandomNumberGenerator.new()
		fallback_rng.seed = state.turn_count + 17
		state.root = GameData.roll_root(fallback_rng)
	else:
		var saved_name := String(state.root.get("name", ""))
		var saved_grade := String(state.root.get("grade_name", ""))
		if saved_grade.ends_with("品") or saved_name in ["五灵根", "四灵根", "三灵根", "双灵根", "雷灵根", "冰灵根", "天灵根", "混沌灵根"]:
			var legacy_name := saved_name if saved_name in ["五灵根", "四灵根", "三灵根", "双灵根", "雷灵根", "冰灵根", "天灵根", "混沌灵根"] else "五灵根"
			var legacy: Dictionary = GameData.legacy_root(legacy_name)
			legacy["speed"] = float(legacy.get("speed", 1.0))
			state.root = legacy
		elif not state.root.has("rank"):
			state.root["rank"] = String(state.root.get("grade_name", "伪灵根"))
			state.root["grade_speed"] = 1.0
	if state.origin.is_empty():
		state.origin = GameData.ORIGINS[0].duplicate(true)
	return state
