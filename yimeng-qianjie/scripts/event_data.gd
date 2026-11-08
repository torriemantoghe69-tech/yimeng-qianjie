class_name EventData
extends RefCounted

## 事件库。每个选项可包含无条件结果，或按权重抽取的多种结果。
## effects 支持：body / insight / luck / daoheart / karma / stones / lifespan /
## injury / cult_pct / treasure / flag / death_cause。

const EVENTS := [
	{
		"id": "old_beggar", "title": "破庙逢仙", "weight": 11.0, "min_realm": 0, "max_realm": 5,
		"text": "夜雨打穿破庙的瓦，一个浑身湿透的老乞丐蜷在神像脚下。他怀里抱着一只缺口的葫芦，说自己已经三天没吃东西。\n\n庙外雷声滚过，你忽然注意到：雨水落到他身前三寸，便自行偏开。",
		"choices": [
			{
				"text": "把干粮分他一半", "hint": "善 · 或有仙缘", "tone": "good",
				"outcomes": [
					{"weight": 58, "text": "老乞丐接过干粮，笑得露出两颗黄牙。临走时，他把破葫芦塞进你手里。葫芦里没有酒，只有一卷薄如蝉翼的玉简。", "effects": {"karma": 3, "insight": 3, "luck": 2, "treasure": "无名玉简"}},
					{"weight": 42, "text": "老乞丐吃得很慢，吃完便靠在神像边睡着了。第二天雨停，人已不见，地上留着一枚沾泥的铜钱，翻过来，背面铸着“长生”二字。", "effects": {"karma": 3, "stones": 8, "luck": 3, "treasure": "长生铜钱"}}
				]
			},
			{
				"text": "闭目打坐，不惹因果", "hint": "稳 · 道心 +1", "tone": "neutral",
				"result": "你闭目调息，任雨水从梁上滴落。天亮时老乞丐已经走了，神像的嘴角似乎比昨夜弯了弯。你不知那是不是错觉。",
				"effects": {"daoheart": 1}
			},
			{
				"text": "夺下他的葫芦", "hint": "恶 · 得财，损道心", "tone": "evil",
				"result": "老乞丐没有反抗，只是在你夺走葫芦时叹了口气。葫芦里只有酸涩的劣酒。你回头时，他已经不见了，而你的影子在墙上多出了一道。",
				"effects": {"karma": -5, "stones": 28, "daoheart": -2, "injury": 4}
			}
		]
	},
	{
		"id": "moon_fox", "title": "月下白狐", "weight": 9.0, "min_realm": 0, "max_realm": 8,
		"text": "山道的月色很白。一只白狐被兽夹咬住后腿，血渗进雪里，像落了一地梅花。它抬头看你，眼睛里有不属于野兽的清明。\n\n山风里飘着若有若无的檀香。",
		"choices": [
			{
				"text": "蹲下，替它掰开兽夹", "hint": "善 · 福缘", "tone": "good",
				"outcomes": [
					{"weight": 62, "text": "白狐舔了舔你的手背，一瘸一拐地消失在林中。你掌心多了一枚温热的狐毛，触之如握着一团月光。", "effects": {"karma": 4, "luck": 4, "body": 2, "treasure": "白狐灵毛"}},
					{"weight": 38, "text": "白狐化作一个白衣女子，向你盈盈一拜：“此恩，阿九记下了。”她吐出一枚内丹放在你手心，转身没入月色。内丹入腹，暖意经年不散。", "effects": {"karma": 4, "luck": 3, "body": 4, "lifespan": 3, "cult_pct": 6, "add_pet": {"name":"月灵狐·阿九", "species":"月灵狐", "power":24, "level":1, "bond":35, "gather":"百年灵芝", "talent_affinity":"月华"}}}
				]
			},
			{
				"text": "剥下这张皮，能卖好价", "hint": "恶 · 灵石，受伤", "tone": "evil",
				"result": "刀锋落下时，白狐没有叫，只是看着你。你卖了一张好皮，换回一袋沉甸甸的灵石。此后很多个夜里，你都梦见一双清明的人眼。",
				"effects": {"karma": -6, "stones": 42, "daoheart": -2, "injury": 7}
			},
			{
				"text": "绕道而行", "hint": "静 · 悟性 +1", "tone": "neutral",
				"result": "你从另一条路下了山。身后传来一声极轻的狐鸣，像叹息，也像道别。你忽然想起一句旧话：万物有灵，各渡其劫。",
				"effects": {"insight": 1}
			}
		]
	},
	{
		"id": "plague_village", "title": "疫村", "weight": 8.0, "min_realm": 1, "max_realm": 12,
		"text": "你路过一个被瘟疫掐住喉咙的村子。村口堆着来不及烧的尸体，活着的人把最后一口水喂给孩子。\n\n一个妇人跪在你面前，磕头磕出了血：“仙师，救救他们。”",
		"choices": [
			{
				"text": "留下，以灵力熬药救人", "hint": "善 · 耗损修为", "tone": "good",
				"result": "你在村里住了七日。第七日清晨，最后一个病人退了烧。你走出村口时，全村人跪在泥地里送你。你的修为损耗不少，丹田却前所未有地静。",
				"effects": {"karma": 8, "daoheart": 4, "luck": 2, "injury": 4, "cult_pct": -4}
			},
			{
				"text": "一把火烧了疫村", "hint": "恶 · 杜绝后患", "tone": "evil",
				"result": "火光冲天，哭声渐渐低下去。你站在村外，看着自己的影子被火拉得很长。没有人能证明你是错的，连你自己也不能。",
				"effects": {"karma": -11, "daoheart": -4, "stones": 35, "injury": 4}
			},
			{
				"text": "留下药方，转身离开", "hint": "凡人自有凡人的命", "tone": "neutral",
				"result": "你写下药方，放在井边。走出很远后，你仍能听见村子的哭声。大道无情，可你发现自己的脚步比来时慢了一些。",
				"effects": {"karma": 2, "daoheart": 1}
			}
		]
	},
	{
		"id": "broken_sword", "title": "断剑埋骨", "weight": 8.0, "min_realm": 0, "max_realm": 10,
		"text": "荒野里立着一座无名的土坟，坟前插着半截锈剑。风吹过剑身，发出类似呜咽的轻鸣。你走近时，剑身忽然震了一下。\n\n土里似乎埋着一个人，也埋着一句没说完的话。",
		"choices": [
			{
				"text": "替他培土，立一块无字碑", "hint": "善 · 剑意相赠", "tone": "good",
				"outcomes": [
					{"weight": 65, "text": "土盖过剑柄时，一道苍老的剑意从坟中升起，绕着你转了三圈，最终没入眉心。你仿佛看见一个年轻人，在雪中练了一辈子的剑。", "effects": {"karma": 3, "insight": 2, "body": 3, "cult_pct": 8}},
					{"weight": 35, "text": "你培好土，那柄断剑忽然自行断裂，锈屑落尽，露出一小段清亮剑刃。你将它收进袖中，觉得太重，又觉得刚刚好。", "effects": {"karma": 3, "daoheart": 3, "treasure": "无名剑刃", "materials": {"剑纹石": 2}, "start_quest": {"id":"ancient_sword_grave", "title":"无名剑冢", "stage":0, "description":"追查断剑主人留下的剑冢线索。"}, "world_event":"东境荒野出现无名剑修遗迹的传闻。"}}
				]
			},
			{
				"text": "拔出断剑带走", "hint": "贪婪 · 得剑，沾因果", "tone": "neutral",
				"result": "断剑入手极沉，剑柄上刻着一个模糊的“悔”字。你拔剑时听见地下传来一声叹息。此后每次握剑，你的手都会无端地冷。",
				"effects": {"karma": -2, "body": 3, "injury": 6, "daoheart": -1, "treasure": "悔字断剑"}
			},
			{
				"text": "鞠一躬，继续赶路", "hint": "敬 · 道心 +2", "tone": "neutral",
				"result": "你朝无名坟鞠了一躬。走出半里，身后传来一声剑鸣，清越悠长，像是在送别一个素不相识的人。",
				"effects": {"daoheart": 2, "luck": 1}
			}
		]
	},
	{
		"id": "ghost_market", "title": "鬼市", "weight": 10.0, "min_realm": 1, "max_realm": 14,
		"text": "子时，你在山阴处看见一串青灯。灯下有人在卖东西：卖自己的影子，卖未说出口的话，也卖一颗还在跳的心。\n\n一个蒙面摊主朝你招手，摊上摆着三样东西。",
		"choices": [
			{
				"text": "买下那枚护脉丹", "hint": "需 25 灵石 · 疗伤固本", "tone": "neutral", "cost": 25,
				"result": "丹药入口即化，一股暖流从丹田淌到四肢百骸。你听见自己骨节深处传来细碎的轻响，像春天解冻的河。",
				"effects": {"body": 3, "injury": -20, "lifespan": 3, "cult_pct": 5}
			},
			{
				"text": "买下那块染血古玉", "hint": "需 15 灵石 · 福祸难料", "tone": "neutral", "cost": 15,
				"outcomes": [
					{"weight": 55, "text": "古玉贴上眉心，一段陌生的剑诀涌入识海。摊主啧啧称奇：“你的前世，竟是个了不得的人物。”", "effects": {"insight": 5, "cult_pct": 12, "treasure": "染血古玉"}},
					{"weight": 45, "text": "古玉冰得像一口井。你刚握住，耳边便响起无数人的惨叫。你猛地松手，玉已碎成粉末，掌心多了一道焦黑的印子。", "effects": {"injury": 11, "luck": -3, "daoheart": -1}}
				]
			},
			{
				"text": "割腕，卖一盅精血", "hint": "恶 · 灵石，伤身", "tone": "evil",
				"result": "摊主凑近闻了闻，露出满意的神情。他给了你一大袋灵石。你按住手腕离开，觉得鬼市里的每一盏灯都在看你。",
				"effects": {"karma": -3, "stones": 45, "injury": 13, "body": -2}
			}
		]
	},
	{
		"id": "heart_demon", "title": "心魔叩门", "weight": 7.0, "min_realm": 2, "max_realm": 17,
		"text": "闭关至第七日，你听见有人在门外叫你。那声音像母亲，像故人，也像另一个更年轻的自己。\n\n“你修的是什么道？”它问，“你敢说自己从未后悔？”\n\n蒲团下的影子正在缓缓站起。",
		"choices": [
			{
				"text": "睁眼，直面心魔", "hint": "险 · 明心见性", "tone": "neutral",
				"outcomes": [
					{"weight": 60, "text": "你看着那个由悔恨凝成的自己，忽然笑了：“你也是我。”心魔怔住，如雪消融。灵台从此澄澈，一尘不染。", "effects": {"daoheart": 6, "insight": 3, "cult_pct": 12}},
					{"weight": 40, "text": "你看见自己杀过的人、负过的人、来不及救的人。气血翻涌，一口血喷在蒲团上。心魔退去时，你已分不清哪一部分才是自己。", "effects": {"daoheart": -3, "injury": 12, "cult_pct": -5}}
				]
			},
			{
				"text": "默诵清心诀，不理它", "hint": "稳 · 道心 -1，修为 +6%", "tone": "neutral",
				"result": "你一遍遍默诵清心诀。那声音在门外站了一整夜，天亮时才散去。你没有开门，可你知道，它下次还会来。",
				"effects": {"daoheart": -1, "cult_pct": 6}
			},
			{
				"text": "推门，随它去看执念", "hint": "危 · 或有所悟", "tone": "evil",
				"outcomes": [
					{"weight": 50, "text": "门后是你前世的家。桌上有一碗还冒着热气的面，母亲在灶边喊你的乳名。你站了很久，最终没有走进去。醒来时泪湿衣襟，修为却暴涨。", "effects": {"daoheart": 2, "insight": 4, "cult_pct": 20}},
					{"weight": 50, "text": "门后是无间地狱。你在里面经历了一千次死亡，每一次都记得。醒来时，你忘了自己是谁，只记得要变强。", "effects": {"karma": -5, "daoheart": -4, "cult_pct": 24, "injury": 10}}
				]
			}
		]
	},
	{
		"id": "cliff_sword", "title": "崖畔问剑", "weight": 6.0, "min_realm": 2, "max_realm": 12,
		"text": "悬崖边坐着一个白衣剑客，面前摆着两杯茶。一杯还冒着热气，另一杯早已凉透。\n\n“来。”他没有回头，“说说看，剑是什么？”\n\n山风把你的衣袖吹得猎猎作响。",
		"choices": [
			{
				"text": "剑是杀人的器", "hint": "直 · 根骨 +3", "tone": "neutral",
				"result": "白衣剑客终于回头，看了你很久。“诚实。”他说，“大道也怕诚实的人。”他饮尽冷茶，化作一线剑光没入云海。你捡起他留下的茶杯，杯底刻着“无咎”。",
				"effects": {"body": 3, "daoheart": 2, "insight": 2}
			},
			{
				"text": "剑是我自己", "hint": "玄 · 道心 +4，悟性 +2", "tone": "good",
				"result": "他大笑，笑得山谷回响。“好一个剑是我自己。”他抬手，将你腰间的树枝折下，轻轻一掷。树梢钉入石壁，入石三寸，尾端还在颤动。\n\n“记住这一剑。它不在手上，在心里。”",
				"effects": {"daoheart": 4, "insight": 2, "cult_pct": 8, "treasure": "崖畔剑意"}
			},
			{
				"text": "剑是斩断因果的刀", "hint": "锋 · 气运 +2，因果 -2", "tone": "evil",
				"result": "白衣剑客沉默片刻，将热茶泼在地上。“斩因果的人，最后都成了因果。”他起身离去。你端起那杯冷茶，发现茶面映出的自己，眉眼锋利得有些陌生。",
				"effects": {"karma": -2, "luck": 2, "body": 3, "daoheart": -1}
			}
		]
	},
	{
		"id": "spirit_rain", "title": "天降灵雨", "weight": 7.0, "min_realm": 0, "max_realm": 17,
		"text": "云层忽然裂开一道缝，金色的雨落下来。雨珠落在草叶上，草叶竟以肉眼可见的速度抽长。\n\n山下村子的人跪了一地，以为是神迹。",
		"choices": [
			{
				"text": "就地盘坐，引灵雨入体", "hint": "机缘 · 修为大涨", "tone": "good",
				"result": "灵雨浸透衣衫，你像一株久旱的草木般贪婪地吸纳。经脉被冲刷得微微发疼，但每一寸血肉都在欢呼。雨停时，你睁开眼，觉得天地比从前亮了一分。",
				"effects": {"body": 3, "cult_pct": 16, "luck": 2}
			},
			{
				"text": "收集雨露，下山售卖", "hint": "得 35 灵石", "tone": "neutral",
				"result": "你用玉瓶接了满满三瓶灵雨，在坊市卖了个好价。买主说这雨能延寿，你笑笑没说话。你当然知道，延寿的从来不是雨。",
				"effects": {"stones": 35, "cult_pct": 4, "karma": -1}
			},
			{
				"text": "引雨入村，替枯田解渴", "hint": "善 · 福缘", "tone": "good",
				"result": "你以灵力引着灵雨落入村中枯田。老农跪在泥水里，捧起一捧水，哭着笑了。你不知道这算不算修行，只觉得丹田里那口气，比来时更暖。",
				"effects": {"karma": 5, "daoheart": 3, "luck": 3, "cult_pct": 6}
			}
		]
	},
	{
		"id": "demon_teach", "title": "邪修传法", "weight": 7.0, "min_realm": 1, "max_realm": 15,
		"text": "一个披着人皮的邪修拦住你。他脚下踩着一具还在抽搐的妖兽，笑得极温和。\n\n“正道太慢了。”他说，“我有一门功法，可让你十年抵百年。代价嘛……只是一点点人性。”",
		"choices": [
			{
				"text": "听他讲完", "hint": "恶 · 修为暴涨，心性受损", "tone": "evil",
				"outcomes": [
					{"weight": 70, "text": "他的功法像一把钥匙，打开了你从未察觉的门。你一夜之间明悟了修炼的本质：吞夺。修为暴涨，可你再看山下的灯火，觉得它们很远。", "effects": {"karma": -6, "cult_pct": 24, "daoheart": -3, "body": 2}},
					{"weight": 30, "text": "你听了三句便觉不对，可身体已经先一步运转起功法。邪气冲入识海，你咬破舌尖才挣脱。邪修笑道：“可惜，差一点。”", "effects": {"karma": -4, "injury": 15, "cult_pct": 8, "daoheart": -2}}
				]
			},
			{
				"text": "拔剑，替天行道", "hint": "战 · 以命搏名", "tone": "good",
				"outcomes": [
					{"weight": 55, "text": "这一战从黄昏打到天明。你斩下他的头颅时，自己的肋骨也断了三根。他死前说：“你我，其实是一种人。”你不信。", "effects": {"karma": 5, "body": 5, "injury": 20, "stones": 30, "daoheart": 3}},
					{"weight": 45, "text": "你高估了自己。邪修一掌拍在你胸口，把你打进崖壁。他俯身看你，像看一只不自量力的虫。你活了下来，可那份屈辱比伤口更疼。", "effects": {"injury": 24, "daoheart": -2, "luck": -2}}
				]
			},
			{
				"text": "抱拳告辞", "hint": "守 · 道心 +3", "tone": "neutral",
				"result": "你抱拳，后退三步，转身离开。邪修在身后笑：“你会回来找我的。”你没有回头。山风把你的衣角吹得很直。",
				"effects": {"daoheart": 3, "karma": 1}
			}
		]
	},
	{
		"id": "river_god", "title": "河神娶亲", "weight": 6.0, "min_realm": 0, "max_realm": 10,
		"text": "村里正在办喜事。一个十三四岁的女孩被穿上红嫁衣，抬上竹筏。人们说河神发怒了，需以新娘平息。\n\n女孩没有哭，只死死攥着一只旧布老虎。",
		"choices": [
			{
				"text": "踏水而出，救下女孩", "hint": "善 · 战河神", "tone": "good",
				"outcomes": [
					{"weight": 62, "text": "河水掀起三丈高浪，一条黑鳞蛟龙探出头来。你与它在河上斗了一夜，最终以一道雷法劈开它的逆鳞。蛟龙沉入水底，女孩抱着布老虎，第一次哭出了声。", "effects": {"karma": 7, "body": 4, "injury": 12, "luck": 4, "daoheart": 3}},
					{"weight": 38, "text": "你救下了女孩，却被河水的暗流卷走。三天后你从下游的浅滩醒来，怀里多了一颗青色的珠子。女孩已不知去向。", "effects": {"karma": 5, "injury": 10, "luck": 3, "treasure": "青蛟避水珠"}}
				]
			},
			{
				"text": "收下谢礼，不蹚浑水", "hint": "恶 · 灵石", "tone": "evil",
				"result": "村长塞给你一袋灵石，求你别说出去。你收了。竹筏漂向河心时，女孩回头看了你一眼。那一眼没有恨，比恨更重。",
				"effects": {"karma": -4, "stones": 40, "daoheart": -2}
			},
			{
				"text": "揭穿河神骗局", "hint": "智 · 悟性", "tone": "neutral",
				"result": "你潜入河底，发现所谓河神不过是条吞了灵珠的水蛇。你将它斩了，把灵珠还给村子。原来这些年被献祭的女孩，都沉在河底的一处暗洞里。你替她们点了三炷香。",
				"effects": {"karma": 5, "insight": 4, "luck": 3, "stones": 15}
			}
		]
	},
	{
		"id": "cave_estate", "title": "洞府遗蜕", "weight": 7.0, "min_realm": 2, "max_realm": 16,
		"text": "地震震开了一处山腹。石门上刻着八卦，门后传来风声，像有人在你耳边低低地呼吸。\n\n门缝里透出一线幽蓝的光。",
		"choices": [
			{
				"text": "推门而入", "hint": "险 · 机缘与杀阵", "tone": "neutral",
				"outcomes": [
					{"weight": 55, "text": "洞府里盘坐着一具玉化的遗蜕，膝上摊着半部道经。你刚拿起道经，遗蜕便化作飞灰。经书最后一页写着：“后来者，莫贪。”", "effects": {"insight": 5, "cult_pct": 18, "daoheart": 2, "treasure": "半部道经"}},
					{"weight": 45, "text": "你踏入洞府的一瞬，四周亮起杀阵。剑气纵横，你拼死退出，衣袖已被削成碎片，肩头多了一道深可见骨的伤口。洞门在你身后缓缓合拢。", "effects": {"injury": 20, "luck": -2, "body": 2}}
				]
			},
			{
				"text": "在门外叩首三拜", "hint": "敬 · 得前辈遗泽", "tone": "good",
				"result": "三拜之后，石门开了一线，一枚玉简滚到你脚边。玉简里没有功法，只有一句：“修行百年，最悔杀一人。”你收好玉简，替前辈把石门重新掩上。",
				"effects": {"karma": 2, "daoheart": 4, "insight": 3, "cult_pct": 5}
			},
			{
				"text": "记下位置，日后再来", "hint": "稳 · 气运 +1", "tone": "neutral",
				"result": "你记下洞口方位，在附近做了记号。离开时，你听见洞中传来一声轻笑。也许是风。你回头看了一眼，山腹已经合拢，像什么都没发生过。",
				"effects": {"luck": 1, "insight": 1}
			}
		]
	},
	{
		"id": "spirit_beast", "title": "幼兽衔芝", "weight": 7.0, "min_realm": 0, "max_realm": 10,
		"text": "一只巴掌大的幼兽倒在溪边，后腿被捕兽夹咬穿。它嘴里还紧紧衔着一株紫灵芝，看见你，喉咙里发出虚弱的低吼。\n\n灵芝的香气让丹田微微发热。",
		"choices": [
			{
				"text": "替它疗伤，放它归山", "hint": "善 · 灵兽报恩", "tone": "good",
				"result": "你替它处理好伤口，又掰下半株灵芝喂它。幼兽舔了舔你的手指，一瘸一拐地钻进林子。三天后，你门口多了几株值钱的灵草。此后每月，都是如此。",
				"effects": {"karma": 5, "body": 3, "luck": 4, "stones": 18, "lifespan": 2}
			},
			{
				"text": "抢下灵芝", "hint": "恶 · 灵芝入腹", "tone": "neutral",
				"result": "幼兽不肯松口，你掰开它的牙。灵芝入口，一股清气直冲百会。幼兽呜咽着逃进林子。那株灵芝确实值钱，只是你后来每次突破，都会莫名想起那双眼睛。",
				"effects": {"karma": -2, "body": 5, "cult_pct": 8, "daoheart": -1}
			},
			{
				"text": "远远跟着它", "hint": "好奇 · 寻得灵脉", "tone": "neutral",
				"result": "幼兽叼着灵芝一路向山里走，最后钻进一处隐蔽的山缝。山缝深处有一条细细的灵脉，足够你修炼数月。你没有惊动它，悄悄退了出去。",
				"effects": {"luck": 3, "cult_pct": 12, "insight": 2}
			}
		]
	},
	{
		"id": "sect_gate", "title": "仙门开山", "weight": 8.0, "min_realm": 0, "max_realm": 4,
		"text": "青云宗的山门在晨雾中打开。青石阶从山脚一直铺到云里，上千少年跪在阶前，等待测灵。\n\n一个执事看了你一眼：“根骨尚可。可愿入我山门？”",
		"choices": [
			{
				"text": "叩首，拜入青云宗", "hint": "门派 · 得功法与灵石", "tone": "good",
				"result": "你随执事踏上青石阶。山门里的钟响了一声，惊起满山白鹤。外门弟子每月有二十灵石，可入藏经阁一层。你领到一枚青色的弟子牌，牌上刻着你的名字。",
				"effects": {"stones": 28, "insight": 3, "daoheart": 1, "cult_pct": 6, "flag": "sect"}
			},
			{
				"text": "请求测一测根骨", "hint": "自信 · 福祸自招", "tone": "neutral",
				"outcomes": [
					{"weight": 55, "text": "测灵柱亮起三道青光。执事的态度客气了三分，将你分入内门。你得到更好的功法与更多的资源，也从此有了必须追赶的人。", "effects": {"insight": 4, "stones": 45, "luck": 2, "cult_pct": 12, "flag": "sect"}},
					{"weight": 45, "text": "测灵柱亮了一下便灭了。人群中有人笑出声。执事摆手让你去外门。你站在阶下，把手心掐出了血。没关系，你想，来日方长。", "effects": {"daoheart": 3, "stones": 10, "flag": "sect"}}
				]
			},
			{
				"text": "转身下山，散修自在", "hint": "独行 · 福缘", "tone": "neutral",
				"result": "你转身下山，身后传来执事的一声冷笑。山门再高，也是别人修的。你走自己的路，天地便是你的山门。",
				"effects": {"luck": 3, "daoheart": 3}
			}
		]
	},
	{
		"id": "mortal_lamplight", "title": "人间灯火", "weight": 6.0, "min_realm": 1, "max_realm": 9,
		"text": "你借宿在一户人家。夜里，主人家的小女儿趴在窗边数星星，问你：“仙人也吃饭吗？仙人也会想家吗？”\n\n灶里的火噼啪作响，锅里温着一碗甜粥。",
		"choices": [
			{
				"text": "留下，过一段凡人的日子", "hint": "情 · 寿元增，道心乱", "tone": "neutral",
				"result": "你在此住了三年。春天插秧，冬天酿酒，教小姑娘认字。你始终没有告诉她自己是修士。离开那日，她塞给你一双纳得歪歪扭扭的鞋。你走出很远才敢回头。",
				"effects": {"lifespan": 8, "karma": 4, "daoheart": 2, "insight": 2, "cult_pct": -4}
			},
			{
				"text": "为她讲一个仙人的故事", "hint": "善 · 心念通达", "tone": "good",
				"result": "你讲了很久，讲山上的鹤，讲云里的城，讲一个再也回不去的人。小姑娘听着听着睡着了。你替她掖好被角，窗外的月亮很圆。",
				"effects": {"karma": 3, "daoheart": 4, "luck": 2, "insight": 1}
			},
			{
				"text": "留一锭银子，连夜离去", "hint": "断 · 道心 +2", "tone": "neutral",
				"result": "银子放在灶台上，压着一张字条。你没有留名。走出很远，回头看见那户人家的灯还亮着，像茫茫人海里的一粒红豆。",
				"effects": {"daoheart": 2, "luck": 1}
			}
		]
	},
	{
		"id": "blood_moon", "title": "血月魔功", "weight": 5.0, "min_realm": 4, "max_realm": 17,
		"text": "血月当空，一具无头尸体忽然睁开了腹部的眼睛。它用你的声音说：“我可以教你吞月。”\n\n“只要你肯，把这具身体借我三日。”",
		"choices": [
			{
				"text": "与它做交易", "hint": "魔 · 修为暴涨，寿元受损", "tone": "evil",
				"result": "三日之后，你从一片血泊里醒来。身体还是你的，可你发现自己再也尝不出甜味。修为暴涨，丹田里却多了一轮缓缓转动的血月，日夜不息。",
				"effects": {"karma": -10, "cult_pct": 30, "body": 5, "lifespan": -6, "daoheart": -3, "injury": 8}
			},
			{
				"text": "以道心镇之", "hint": "正 · 道心坚定", "tone": "good",
				"outcomes": [
					{"weight": 65, "text": "你结印，诵经，一坐便是七夜。血月退去时，那具尸体已经化作灰烬。你睁开眼，东方既白，道心比从前更稳。", "effects": {"karma": 5, "daoheart": 5, "insight": 3}},
					{"weight": 35, "text": "血月的力量超出你的想象。你保住了一条命，却被它咬去一口精气。那轮月亮至今仍会在你梦里升起。", "effects": {"injury": 16, "daoheart": -2, "luck": -2}}
				]
			},
			{
				"text": "遁走", "hint": "退 · 气运 -1", "tone": "neutral",
				"result": "你转身就走，身后传来那东西的笑声，像许多人的声音叠在一起。走出很远，你才发现后背上全是冷汗。",
				"effects": {"luck": -1, "injury": 3}
			}
		]
	},
	{
		"id": "familiar_stranger", "title": "似曾相识", "weight": 5.0, "min_realm": 3, "max_realm": 17,
		"text": "坊市里，一个卖糖人的老者叫住你。他缺了半只耳朵，笑起来却让你莫名眼熟。\n\n“小友，我们是不是在哪儿见过？”他问。你搜遍记忆，确认此生从未见过他。",
		"choices": [
			{
				"text": "坐下来，与他聊聊", "hint": "缘 · 宿慧苏醒", "tone": "good",
				"outcomes": [
					{"weight": 60, "text": "聊着聊着，你忽然想起一个画面：上一世的你，也曾在这个摊位前买过糖人。老者听完大笑：“原来你也记得。”他送了你一个糖人，形状是前世的你。", "effects": {"insight": 5, "luck": 3, "daoheart": 2, "treasure": "前世糖人"}},
					{"weight": 40, "text": "老者絮絮叨叨讲了一下午，全是些不相干的旧事。临走时他忽然说：“下次轮回，别走那么快。”你回头，摊位已经空了。", "effects": {"insight": 2, "luck": 2, "karma": 1}}
				]
			},
			{
				"text": "买下他所有糖人", "hint": "需 20 灵石 · 善缘", "tone": "good", "cost": 20,
				"result": "你把糖人分给了坊市里的孩子。老者看着你，眼睛忽然有些湿。他什么也没说，只朝你拱了拱手。那天夜里，你梦见了许多张模糊的脸。",
				"effects": {"karma": 5, "luck": 4, "daoheart": 2}
			},
			{
				"text": "摇头走开", "hint": "断 · 无", "tone": "neutral",
				"result": "你摇头走开。走出十几步，听见身后传来一声轻轻的叹息：“也罢，也罢。”你脚步顿了一下，终究没有回头。",
				"effects": {}
			}
		]
	},
	{
		"id": "thunder_pool", "title": "雷池残响", "weight": 5.0, "min_realm": 6, "max_realm": 17,
		"text": "群山之间有一处天雷劈出的深谷，谷底电光翻涌，百年不熄。传说曾有修士在此淬体，最终渡劫飞升；也有人说，那只是他死前放的一个屁。\n\n电光映亮了你的脸。",
		"choices": [
			{
				"text": "跃入雷池，借雷淬体", "hint": "险 · 根骨大增", "tone": "neutral",
				"outcomes": [
					{"weight": 55, "text": "雷光灌体，你的血肉一次次焦黑，又一次次重生。三天后你爬出深谷，皮肤下隐隐有电纹流动。你活下来了。", "effects": {"body": 8, "cult_pct": 20, "luck": 2}},
					{"weight": 45, "text": "你只撑了半个时辰。一道紫雷劈碎了你的护体灵光，把你掀出谷外。你在雨里躺了一夜，醒来时发现自己的头发全白了。", "effects": {"injury": 24, "body": 3, "lifespan": -4}}
				]
			},
			{
				"text": "在谷边观雷悟法", "hint": "静 · 悟性大增", "tone": "good",
				"result": "你在谷边坐了九日，看雷霆生灭，忽然明白了“刚极易折”四个字。你起身时，衣袍无风自动，丹田里的真元多了一丝雷意。",
				"effects": {"insight": 6, "daoheart": 2, "cult_pct": 10}
			},
			{
				"text": "太危险，绕路", "hint": "稳 · 无", "tone": "neutral",
				"result": "你绕开了雷池。走出很远，仍能听见山谷里的雷鸣，像一头困兽在低吼。你忽然有点想知道，里面到底是什么。",
				"effects": {"daoheart": 1}
			}
		]
	},
	{
		"id": "moon_well", "title": "井中月", "weight": 6.0, "min_realm": 2, "max_realm": 17,
		"text": "荒寺后院有一口井。你探头去看，井水里没有你的倒影，只有一轮极小、极亮的月亮。\n\n月光在井壁上缓缓游动，像一条银色的鱼。",
		"choices": [
			{
				"text": "伸手去捞那轮月亮", "hint": "玄 · 悟性与风险", "tone": "neutral",
				"outcomes": [
					{"weight": 58, "text": "指尖触到水面的瞬间，你看见了无数个自己。有的在飞升，有的在乞讨，有的已经死了。你收回手，掌心里握着一小片月光，凉得像一句真话。", "effects": {"insight": 6, "daoheart": 3, "luck": 2, "cult_pct": 8}},
					{"weight": 42, "text": "你被拽入井中，坠落了很久。醒来时躺在井边，天已大亮。你浑身湿透，记不清发生了什么，只记得井下有人在叫你的名字。", "effects": {"injury": 12, "insight": 3, "luck": -2}}
				]
			},
			{
				"text": "投一颗石子进去", "hint": "疑 · 无甚收获", "tone": "neutral",
				"result": "石子落水，月亮碎了又圆。你盯着井水看了很久，忽然觉得自己有点可笑。走出荒寺时，夕阳正好。",
				"effects": {"luck": 1, "insight": 1}
			},
			{
				"text": "封住井口，转身离开", "hint": "慎 · 道心", "tone": "neutral",
				"result": "你搬来石板，把井口封死。你不知道那是不是多此一举，但你觉得，有些东西还是别看太清楚为好。",
				"effects": {"daoheart": 2}
			}
		]
	},
	{
		"id": "old_debt", "title": "旧债", "weight": 5.0, "min_realm": 4, "max_realm": 17,
		"text": "一个满身血污的女修拦住你，说你是她三百年前的杀父仇人。你确定自己此生从未见过她。\n\n她递来一枚留影石。石中那个人的脸，确实与你一模一样。",
		"choices": [
			{
				"text": "认下这笔前世债，偿还灵石", "hint": "需 40 灵石 · 善", "tone": "good", "cost": 40,
				"result": "你双手奉上灵石，向她深深一揖。她愣住了，握剑的手在发抖。最终她没有杀你，只留下一句：“你和他，不一样。”你望着她的背影，心里那块石头轻了一些。",
				"effects": {"karma": 6, "daoheart": 4, "luck": 3}
			},
			{
				"text": "前世不是我，拒不相认", "hint": "争 · 因果反噬", "tone": "neutral",
				"result": "她冷笑拔剑。你与她斗了三十招，最终两败俱伤。她走时留下一句话：“轮回不改债，只改债主。”你的伤口很深，但更疼的是，你开始怀疑她说得对。",
				"effects": {"karma": -2, "injury": 16, "daoheart": -1, "insight": 2}
			},
			{
				"text": "问她：“他为何杀你父亲？”", "hint": "智 · 探寻真相", "tone": "neutral",
				"outcomes": [
					{"weight": 60, "text": "她怔住，慢慢讲了一个故事：她父亲为了炼一炉丹，杀了整整一个村的人。那个与你容貌相同的人，是来讨债的。你听完，两人在风里沉默了很久。", "effects": {"karma": 4, "insight": 4, "daoheart": 3}},
					{"weight": 40, "text": "她什么也答不上来，只说“他们都说他是恶人”。你明白了，她恨的也许不是那个人，而是自己这些年无处安放的恨。", "effects": {"insight": 3, "daoheart": 2, "karma": 2}}
				]
			}
		]
	},
	{
		"id": "ghost_house", "title": "荒宅红烛", "weight": 5.0, "min_realm": 0, "max_realm": 9,
		"text": "山中一座荒宅，门楣上的喜字褪成了白色。推门进去，堂中竟点着两支红烛，供桌上摆着一对没喝完的合卺酒。\n\n内室传来女子低低的啜泣。",
		"choices": [
			{
				"text": "听她讲完那个故事", "hint": "怜 · 悟道", "tone": "good",
				"result": "她等的人是个赶考的书生，一去三十年，杳无音信。她等到死，死后又等。你替她把那杯冷酒洒在门前，说：“他大概早就忘了。”她怔了很久，终于笑了，红烛随之熄灭。",
				"effects": {"karma": 4, "daoheart": 4, "insight": 3, "luck": 2}
			},
			{
				"text": "喝下那杯合卺酒", "hint": "险 · 阴缘缠身", "tone": "evil",
				"result": "酒入喉，冷得像一条蛇。你看见她掀开盖头，脸还是生前的模样。她说：“你答应过会回来。”你成了第二个没有回来的人。此后多年，你的梦里总有一对红烛。",
				"effects": {"luck": 5, "lifespan": -5, "karma": -2, "daoheart": -1, "cult_pct": 8}
			},
			{
				"text": "一把火烧了这座宅子", "hint": "破 · 伤身，得财", "tone": "neutral",
				"result": "火起时，哭声变得尖利。你从灰烬里扒出几件陪葬的银器，卖了二十多块灵石。后来你听说，那宅子所在的村子，从此再没闹过鬼。",
				"effects": {"karma": -3, "injury": 8, "stones": 24, "daoheart": -1}
			}
		]
	},
	{
		"id": "furnace_crisis", "title": "丹炉将倾", "weight": 5.0, "min_realm": 2, "max_realm": 14,
		"text": "你路过一座丹房，里面传来沉闷的轰鸣。一个年轻丹师满脸是灰地冲出来，喊道：“炉要炸了！”\n\n他身后还有个更小的学徒，正被压在倒下的药架下。",
		"choices": [
			{
				"text": "冲进去救学徒", "hint": "善 · 受伤，得报", "tone": "good",
				"result": "你掀开药架，把学徒拖了出来。身后丹炉炸开，热浪掀飞了半间屋子。你护着学徒滚出门外，后背一片焦黑。丹师跪在你面前，把仅有的灵石和丹药都塞给了你。",
				"effects": {"karma": 6, "injury": 14, "stones": 20, "lifespan": 2, "daoheart": 3}
			},
			{
				"text": "先抢出那炉丹药", "hint": "贪 · 得丹，失德", "tone": "evil",
				"result": "你以灵力护体，从火中抢出三枚成色极好的丹药。学徒的哭声在浓烟里断断续续。丹师看着你，什么也没说。你走了很远，仍觉得手里的丹药烫得厉害。",
				"effects": {"karma": -5, "body": 4, "cult_pct": 12, "stones": 15, "daoheart": -2}
			},
			{
				"text": "施法压住炉火", "hint": "智 · 悟性", "tone": "neutral",
				"result": "你以水行灵力裹住丹炉，炉温骤降，轰鸣声渐歇。丹师愣了半天，才想起向你道谢。你摆摆手，却在他摊开的丹方上，看见了一味从未听过的药。",
				"effects": {"insight": 4, "karma": 2, "luck": 2}
			}
		]
	},
	{
		"id": "leaf_crossing", "title": "一叶渡江", "weight": 4.0, "min_realm": 5, "max_realm": 17,
		"text": "江边有个戴斗笠的老人，正把一片芦苇叶放进江里。叶子落在水面，竟变得像船一样大。\n\n“过江吗？”他问，“不收钱，只收一个故事。”",
		"choices": [
			{
				"text": "登上叶舟", "hint": "玄 · 悟性大涨", "tone": "neutral",
				"outcomes": [
					{"weight": 65, "text": "叶舟行在雾里，两岸山河像画卷般展开。老人听你讲完故事，点了点头：“你的道，还差一点。”他用桨在江面写了一个字，水痕久久不散。", "effects": {"insight": 6, "daoheart": 3, "cult_pct": 14, "luck": 2}},
					{"weight": 35, "text": "舟到江心，忽然打了个旋。你低头一看，脚下不是江水，而是万丈深渊。等你回过神来，已经躺在对岸，老人不见了，衣袋里多了三枚铜钱。", "effects": {"luck": -3, "injury": 8, "stones": 13}}
				]
			},
			{
				"text": "岸上答话，不上船", "hint": "稳 · 道心 +2", "tone": "neutral",
				"result": "你站在岸边，把自己的故事说给老人听。他听完哈哈大笑，一苇渡江而去。江风送来一句话：“不敢上船的人，故事都讲不长。”",
				"effects": {"daoheart": 2, "insight": 2}
			}
		]
	},
	{
		"id": "sword_tomb", "title": "万剑冢", "weight": 4.0, "min_realm": 8, "max_realm": 17,
		"text": "荒原上插着十万柄剑，剑柄朝向同一片天空。风过时，剑鸣如潮。\n\n最中央那柄剑，剑身上刻着两个古字：问天。",
		"choices": [
			{
				"text": "走到中央，拔出问天", "hint": "需 根骨 55 · 极险", "tone": "neutral", "req": {"body": 55},
				"outcomes": [
					{"weight": 55, "text": "你握住剑柄，十万柄剑同时铮鸣。剑意入体，你七窍流血，却站得笔直。问天出鞘，剑身映出的不是你的脸，而是一片无垠的星河。", "effects": {"body": 8, "cult_pct": 22, "injury": 12, "daoheart": 3, "treasure": "问天剑"}},
					{"weight": 45, "text": "你高估了自己。剑意反噬，将你钉在原地三天三夜。醒来时，身上插着七柄断剑，问天依旧纹丝不动。", "effects": {"injury": 26, "body": 2, "daoheart": -1}}
				]
			},
			{
				"text": "向十万剑冢行一礼", "hint": "敬 · 悟剑意", "tone": "good",
				"result": "你郑重行礼。十万剑鸣忽然齐歇，天地安静得能听见心跳。一柄锈剑自行飞出，落在你脚边。你捡起它，发现剑柄上刻着许多名字，最新的一行，是你的。",
				"effects": {"daoheart": 4, "insight": 4, "cult_pct": 10, "treasure": "无名锈剑"}
			},
			{
				"text": "绕行", "hint": "稳 · 无", "tone": "neutral",
				"result": "你绕开剑冢，继续赶路。走出很远，剑鸣仍在身后，像一场没有下完的雨。",
				"effects": {"insight": 1}
			}
		]
	},
	{
		"id": "mortal_king", "title": "帝王求长生", "weight": 4.0, "min_realm": 5, "max_realm": 17,
		"text": "皇帝跪在你面前，身后是金碧辉煌的宫殿，和三千个低着头的臣子。\n\n“朕愿以半壁江山，换仙师一粒长生丹。”他的眼中有火，那是将死之人最后的火。",
		"choices": [
			{
				"text": "告诉他：长生不在丹里", "hint": "正 · 善缘，灵石", "tone": "good",
				"result": "你与皇帝谈了整整一夜。第二天，他下旨减免了三年赋税。你不知道他听懂了多少，但城外跪着谢恩的百姓，是真的。他赠你黄金百两，你只取了一袋灵石。",
				"effects": {"karma": 6, "stones": 70, "daoheart": 4, "luck": 3}
			},
			{
				"text": "收下江山，给他一颗假丹", "hint": "恶 · 巨财，损道心", "tone": "evil",
				"result": "你拿走了半个国库的灵石。那颗丹不过是一味安神的丸药。皇帝服下后精神大好，以为自己真的能活到万岁。你离开皇城时，听见钟声，不知是庆典，还是丧钟。",
				"effects": {"karma": -8, "stones": 120, "daoheart": -4, "luck": -2}
			},
			{
				"text": "拒绝，转身离去", "hint": "淡 · 道心", "tone": "neutral",
				"result": "你没有回头。身后传来皇帝暴怒的吼声，瓷器碎裂的声音一直追到宫门外。你抬头看天，云很高，很淡，和宫墙上的琉璃瓦是两种东西。",
				"effects": {"daoheart": 3, "insight": 1}
			}
		]
	},
	{
		"id": "butterfly_dream", "title": "庄周梦蝶", "weight": 5.0, "min_realm": 1, "max_realm": 17,
		"text": "午睡醒来，你分不清自己是人还是蝴蝶。枕边落着一片蝶翼，薄如纸，闪着不属于人间的蓝光。\n\n窗外，一只蝴蝶正撞向你的窗纸，一下，又一下。",
		"choices": [
			{
				"text": "开窗，让它进来", "hint": "玄 · 悟性", "tone": "neutral",
				"outcomes": [
					{"weight": 65, "text": "蝴蝶落在你指尖，化作一点光没入识海。你忽然明白了：所谓修行，不过是梦中做梦。醒来那一刻，你的悟性长了一截，心却轻了许多。", "effects": {"insight": 5, "luck": 2, "cult_pct": 6}},
					{"weight": 35, "text": "蝴蝶飞进来，绕着你转了三圈，停在你心口。你感到一阵困意，又睡了过去。再醒来已是三日后，修为莫名增长，却忘了梦里见过谁。", "effects": {"insight": 2, "cult_pct": 12, "lifespan": 2}}
				]
			},
			{
				"text": "继续睡，把梦做完", "hint": "逸 · 寿元，道心", "tone": "neutral",
				"result": "你闭上眼，回到梦里。梦里你是一只蝴蝶，飞过沧海，飞过雪山，最后落在一扇熟悉的窗前。窗里坐着一个和你一模一样的人。你看着他，他也在看你。",
				"effects": {"lifespan": 5, "daoheart": 3, "insight": 2}
			},
			{
				"text": "拍死它", "hint": "断 · 心念不宁", "tone": "evil",
				"result": "蝶翼碎在掌心，一抹蓝色渗进皮肤。那天之后，你偶尔会在镜子里看见自己长出一对蝶翼。眨了眨眼，又没有了。",
				"effects": {"karma": -2, "daoheart": -2, "luck": -1, "insight": 2}
			}
		]
	},
	{
		"id": "star_fall", "title": "星陨", "weight": 4.0, "min_realm": 3, "max_realm": 17,
		"text": "深夜，一颗星坠入西山。大地震了三次，天边亮如白昼。\n\n你赶到时，陨坑里坐着一个浑身是血的人。他抬头看你，说了一句不属于人间的语言。然后他死了。",
		"choices": [
			{
				"text": "取走他留下的东西", "hint": "险 · 天外遗物", "tone": "neutral",
				"result": "他怀里有一块冰凉的黑色石头，上面刻着星图。你刚握住它，脑海中便响起无数人的诵经声。你吐出一口血，修为却暴涨。此后每逢星夜，你都能听见石头在轻轻呼吸。",
				"effects": {"cult_pct": 22, "injury": 12, "insight": 4, "treasure": "天外星石"}
			},
			{
				"text": "替他葬了，立碑", "hint": "善 · 道心", "tone": "good",
				"result": "你不知道他的名字，便在碑上刻了“天上人”三字。填土时，一颗光点从他眉心飘出，绕你一圈，没入你的眉心。你看见一片陌生的星空，和一个正在远去的人。",
				"effects": {"karma": 4, "daoheart": 4, "insight": 3, "luck": 2}
			},
			{
				"text": "远远看一会儿，离开", "hint": "退 · 无", "tone": "neutral",
				"result": "你站在坑边，看着那个死去的星外来客。他的血是银色的，在月光下慢慢渗进土里。你转身离开，觉得今晚的星星比往常少了一颗。",
				"effects": {"insight": 1}
			}
		]
	},
	{
		"id": "past_enemy", "title": "前世仇敌", "weight": 4.0, "min_realm": 5, "max_realm": 17,
		"text": "一个独臂男人挡在山道上。他看了你很久，忽然笑了：“我找了你七世。”\n\n他拔刀。刀身上刻满了名字，每一个都是你曾经用过的。",
		"choices": [
			{
				"text": "拔剑，做个了断", "hint": "战 · 生死一线", "tone": "neutral",
				"outcomes": [
					{"weight": 52, "text": "这一战打了三天。最终你的剑穿过他的胸膛，他的刀也停在你颈侧。他倒下时说：“终于……结束了。”你坐在血泊里，第一次觉得轮回这么累。", "effects": {"karma": -2, "body": 5, "injury": 18, "insight": 4, "stones": 40}},
					{"weight": 48, "text": "你败了。他本可以杀你，却在最后一刻收刀。“杀你太容易了。”他说，“我要你带着这份记忆，再活一世。”他走了，你在地上躺了很久。", "effects": {"injury": 22, "daoheart": -2, "insight": 3}}
				]
			},
			{
				"text": "收剑，问他愿不愿意放下", "hint": "善 · 化解因果", "tone": "good",
				"outcomes": [
					{"weight": 55, "text": "他愣住了，刀锋在风里发抖。最终他收刀入鞘，说：“七世了，我也累了。”你们在山道上对坐饮酒，像两个刚认识的人。", "effects": {"karma": 7, "daoheart": 5, "luck": 4, "insight": 2}},
					{"weight": 45, "text": "他狂笑着挥刀：“放下？你说得轻巧。”你接下他三刀，没有还手。第四刀停在你额前。他看了你很久，转身走了。你知道，他还会再来。", "effects": {"karma": 3, "injury": 12, "daoheart": 3}}
				]
			},
			{
				"text": "不战，逃", "hint": "退 · 道心受挫", "tone": "neutral",
				"result": "你转身就跑。他在身后大笑，笑声像一把钝刀，追了你半座山。你甩掉了他，却甩不掉那句“我找了你七世”。",
				"effects": {"luck": -2, "daoheart": -2, "injury": 4}
			}
		]
	},
	{
		"id": "mountain_spring", "title": "灵泉洗髓", "weight": 6.0, "min_realm": 1, "max_realm": 15,
		"text": "你在深山发现一汪温泉，水面浮着薄薄的白气。泉边有一具鹿骨，骨质如玉，显然不是凡物。\n\n你蹲下身，发现泉水深处似乎有光在游动。",
		"choices": [
			{
				"text": "宽衣入泉", "hint": "机缘 · 洗髓疗伤", "tone": "good",
				"result": "泉水漫过胸口，你感到一股温和的灵力从毛孔钻入，冲刷经脉里的暗伤。鹿骨在你身后轻轻震动，像是在替你护法。你闭上眼，再睁开时，水已经凉了。",
				"effects": {"body": 4, "injury": -22, "cult_pct": 8, "luck": 1}
			},
			{
				"text": "以玉瓶收集灵泉", "hint": "财 · 灵石", "tone": "neutral",
				"result": "你装了满满三瓶。到坊市一问，才知这是极其稀罕的洗髓泉，三瓶卖了四十块灵石。你有些后悔没多带几个瓶子。",
				"effects": {"stones": 40, "karma": -1}
			},
			{
				"text": "守在泉边，等灵物现身", "hint": "险 · 未知", "tone": "neutral",
				"outcomes": [
					{"weight": 55, "text": "入夜时分，泉中浮起一尾白玉般的小鱼。它看了你一眼，吐出一个泡泡，泡泡里是一枚丹药。你接住丹药，小鱼摆了摆尾，沉回泉底。", "effects": {"luck": 4, "body": 3, "cult_pct": 10, "treasure": "灵泉玉鱼"}},
					{"weight": 45, "text": "你等来了一头黑熊。它显然把灵泉视为自己的地盘，扑上来就是一掌。你打退了它，却被拍断了两根肋骨。灵泉也被血迹染红。", "effects": {"injury": 16, "body": 3}}
				]
			}
		]
	},
	{
		"id": "heaven_gate", "title": "天门虚影", "weight": 3.0, "min_realm": 12, "max_realm": 17,
		"text": "云海之上，隐隐立着一道门。门框由光构成，门后什么也看不清，只有一阵阵古老的风吹出来。\n\n你离那道门，似乎只差一步。可这一步，却像隔着整个人间。",
		"choices": [
			{
				"text": "向天门迈出一步", "hint": "险 · 道心与雷劫", "tone": "neutral",
				"outcomes": [
					{"weight": 55, "text": "你踏出一步，天地倒转。无数雷光在你身边炸开，你咬紧牙关，看见门里伸出一只手。那手和你的一模一样。你握住了它。", "effects": {"daoheart": 6, "cult_pct": 25, "injury": 12, "insight": 4}},
					{"weight": 45, "text": "你踏出一步，却被无形之力弹回。你在云海里坠了很久，最后落在山巅，浑身是血。天门在头顶缓缓合拢，像一只闭上的眼。", "effects": {"injury": 26, "daoheart": 3, "lifespan": -5}}
				]
			},
			{
				"text": "驻足，向天门一拜", "hint": "敬 · 道心", "tone": "good",
				"result": "你没有强求，只朝天门一拜。云海翻涌，传来一声极轻的叹息，像是天在说“还不到时候”。你转身下山，脚步比来时稳。",
				"effects": {"daoheart": 5, "insight": 3, "luck": 3, "cult_pct": 6}
			},
			{
				"text": "转身，回到人间", "hint": "淡 · 寿元", "tone": "neutral",
				"result": "你转身回到人间。山下的炊烟正缓缓升起，有个孩子追着鸡跑过田埂。你忽然觉得，天门也不是非进不可。",
				"effects": {"lifespan": 8, "daoheart": 2, "karma": 2}
			}
		]
	},
	{
		"id": "dying_immortal", "title": "仙人垂死", "weight": 4.0, "min_realm": 7, "max_realm": 17,
		"text": "一个老人倒在路边，胸口有一个贯穿的伤口，流出的血泛着金色。他看见你，努力抬起手，指向自己的眉心。\n\n“拿走……”他说，“别让它跟我一起烂掉。”",
		"choices": [
			{
				"text": "渡一口真气，先救他", "hint": "善 · 耗损自身", "tone": "good",
				"result": "你还没救活他。他撑了半炷香，足够说完一句话：“这个世道，好人活不长。”他把额头贴在你手心，一段温暖的记忆流入你识海。那是他年轻时，第一次御剑飞过故乡。",
				"effects": {"karma": 5, "daoheart": 5, "insight": 4, "lifespan": -2, "cult_pct": 8}
			},
			{
				"text": "伸手探入他的眉心", "hint": "贪 · 夺其道果", "tone": "evil",
				"result": "你取走了他毕生凝成的一点道果。老人的眼睛慢慢失去光，最后看你的一眼没有恨，只有怜悯。你的修为暴涨，识海里却多了一座坟，坟前站着一个不认识的人。",
				"effects": {"karma": -7, "cult_pct": 26, "insight": 5, "daoheart": -3}
			},
			{
				"text": "坐在他身旁，送他最后一程", "hint": "静 · 道心", "tone": "neutral",
				"result": "你什么也没做，只是陪他坐着。他断断续续讲了一些往事，大多你已经忘了。最后他说：“多谢。”然后闭了眼。你把他埋在山坡上，墓碑朝向他故乡的方向。",
				"effects": {"daoheart": 4, "insight": 3, "karma": 3, "luck": 2}
			}
		]
	},
	{
		"id": "mirror_heart", "title": "照心镜", "weight": 5.0, "min_realm": 3, "max_realm": 17,
		"text": "古玩摊上有一面铜镜。摊主说，这镜能照出人心里最怕的东西，不灵不要钱。\n\n镜面蒙着灰，你擦了擦，看见里面不是你。",
		"choices": [
			{
				"text": "盯着镜面，看个清楚", "hint": "勇 · 直面无明", "tone": "neutral",
				"outcomes": [
					{"weight": 60, "text": "镜里是你老去的样子：白发，皱纹，坐在一间空屋里等死。你看了很久，忽然笑了。镜面裂开一道细纹，里面那个老人也笑了。", "effects": {"daoheart": 5, "insight": 4, "cult_pct": 6}},
					{"weight": 40, "text": "镜里是你爱过又失去的所有人。他们站在一起，不说话，只是看着你。你手一抖，镜子落地碎了。摊主摇头：“不灵，不要钱。”", "effects": {"daoheart": -2, "insight": 3, "luck": -1}}
				]
			},
			{
				"text": "问摊主：你照过吗？", "hint": "趣 · 小悟", "tone": "neutral",
				"result": "摊主愣了愣，苦笑：“照过。镜里是我年轻时的媳妇，跟人说我没出息，跑了。”他把镜子收进箱子，不再说话。你走出很远，还听见他在叹气。",
				"effects": {"insight": 2, "karma": 1}
			},
			{
				"text": "买下镜子，砸碎", "hint": "需 10 灵石 · 断念", "tone": "neutral", "cost": 10,
				"result": "镜碎时，摊主吓得一哆嗦。你看着满地的碎片，每一片里都有一个更小的你。你转身离开，觉得心里某处松了。",
				"effects": {"daoheart": 3, "luck": 2}
			}
		]
	},
		{
		"id": "epic_bloody_scholar", "title": "血夜追杀", "text": "残月高悬，官道上弥漫着刺鼻的血腥味。一个浑身浴血的书生跌撞着扑到你面前，他怀里死死抱着一个布满符文的黑木匣，眼神中满是绝望与恳求：“道友……救我一命，此物……赠你！”话音刚落，三道凌厉的剑光已破空而至。", "min_realm": 0, "max_realm": 20,
		"choices": [
			{"text": "拔剑迎敌，护他周全", "hint": "侠义之举 · 将面临生死恶战", "tone": "good", "outcomes": [
				{"result": "你拼死挡下追兵，书生重伤垂死。他将木匣交给你，里面竟是一枚上古传承玉简。", "effects": {"cultivation": 80, "insight": 5, "karma": 15}},
				{"result": "追兵实力太强，你被一剑穿胸。书生惨死，你拼死突围，夺走了半截匣子。", "effects": {"injury": 35, "stones": 100, "karma": 8}}
			]},
			{"text": "袖手旁观，坐收渔利", "hint": "冷酷无情 · 待两败俱伤", "tone": "neutral", "outcomes": [
				{"result": "书生与追兵同归于尽。你从尸体堆里摸出了不少储物袋。", "effects": {"stones": 250, "karma": -5}},
				{"result": "追兵杀死了书生，注意到了暗处的你。你被追杀百里，险象环生。", "effects": {"injury": 20, "daoheart": -2}}
			]},
			{"text": "趁乱出手，抢了匣子就跑", "hint": "虎口夺食 · 极度危险", "tone": "danger", "outcomes": [
				{"result": "你仗着身法精妙夺走木匣，里面的宝物让你修为大进！", "effects": {"stones": 300, "cultivation": 50, "karma": -10}},
				{"result": "你被追兵一掌拍飞，木匣也没抢到。", "effects": {"injury": 40, "luck": -2}}
			]}
		]
	},
	{
		"id": "epic_demon_saintess", "title": "正魔之辨", "text": "幽深的山谷中，你撞见一位紫衣少女。她斜倚在青石上，周身魔气与灵气交织。她似乎受了极重的伤，连站起来的力气都没有，却依旧冷傲地看着你：“正道走狗，要杀便杀。若肯替我护法半个时辰，本座赐你一场天大的造化。”", "min_realm": 0, "max_realm": 20,
		"choices": [
			{"text": "替她护法", "hint": "魔道机缘 · 富贵险中求", "tone": "evil", "outcomes": [
				{"result": "少女伤势痊愈，乃是魔宗圣女。她轻点你的眉心，将一门无上魔功倾囊相授。", "effects": {"cultivation": 120, "insight": 6, "karma": -10}},
				{"result": "正道追兵赶到，少女为保全自身将你当做挡箭牌，你重伤逃走。", "effects": {"injury": 30, "daoheart": -2}}
			]},
			{"text": "斩妖除魔，替天行道", "hint": "正道之举 · 或许能扬名立万", "tone": "good", "outcomes": [
				{"result": "你一剑斩下她的头颅。魔气散尽，掉落了一柄极品法器。", "effects": {"stones": 200, "karma": 15, "body": 3}},
				{"result": "她临死反扑，拉着你一起坠入万丈深渊。你侥幸生还，但经脉受创。", "effects": {"injury": 25}}
			]},
			{"text": "装作没看见，悄悄退走", "hint": "独善其身 · 不惹红尘因果", "tone": "neutral", "effects": {"daoheart": 3, "luck": 2}, "result": "你敛去气息，转身离去。修仙界弱肉强食，保全自身才是王道。"}
		]
	},
	{
		"id": "epic_ancient_sword_cave", "title": "绝壁剑鸣", "text": "你失足跌入一处深不见底的峡谷。在谷底的崖壁上，你发现了一具枯骨。枯骨怀中抱着一把锈迹斑斑的铁剑，头顶的石壁上刻着几行苍劲的大字：“剑冢绝地，无上剑意。悟透者生，强求者死。”", "min_realm": 0, "max_realm": 20,
		"choices": [
			{"text": "对剑枯坐，感悟剑意", "hint": "静心悟道 · 收益与悟性相关", "tone": "good", "outcomes": [
				{"result": "你福至心灵，铁剑上的锈迹剥落，露出冲天寒芒。你悟得一招惊天剑意！", "effects": {"insight": 8, "cultivation": 60}},
				{"result": "你心浮气躁，剑意反噬，你吐血不止。", "effects": {"injury": 20, "daoheart": 2}}
			]},
			{"text": "叩拜前辈，取走遗物", "hint": "财帛动人心 · 未知吉凶", "tone": "neutral", "outcomes": [
				{"result": "你恭敬磕了三个响头，枯骨化作飞灰，留下一枚储物袋。", "effects": {"stones": 180, "luck": 3}},
				{"result": "枯骨中突然爆射出一道黑芒，你躲闪不及中了尸毒。", "effects": {"injury": 15}}
			]},
			{"text": "不去碰剑，寻路离开", "hint": "知进退 · 稳中求胜", "tone": "neutral", "effects": {"luck": 2}, "result": "你深知机缘伴随大凶险，果断放弃，安然离开。"}
		]
	},
	{
		"id": "epic_black_market", "title": "地下暗拍", "text": "顺着下水道，你误入一处地下黑市。这里龙蛇混杂，正在举行一场不见光的拍卖。压轴拍品是一枚被重重禁制封印的黑色珠子，连拍卖师都不知它的来历，只称其中蕴含庞大灵气。起拍价：100 灵石。", "min_realm": 0, "max_realm": 20,
		"choices": [
			{"text": "倾尽家财，买下黑珠（需100灵石）", "hint": "赌上全部身家", "tone": "danger", "cost": 100, "outcomes": [
				{"result": "你拍下黑珠，成功解开禁制。里面竟是一滴真龙精血，你将其吸收，肉身蜕变！", "effects": {"body": 10, "cultivation": 50}},
				{"result": "黑珠解开后，里面的魔气瞬间吞噬了你的神智。你拼尽全力才将其镇压，身受重伤。", "effects": {"injury": 30, "daoheart": -5}}
			]},
			{"text": "退而求其次，买下几瓶丹药", "hint": "稳妥之选", "tone": "neutral", "cost": 30, "effects": {"cultivation": 30, "injury": -20}, "result": "你花30灵石买下几瓶疗伤和聚气丹，虽然没有大机缘，但也算满载而归。"},
			{"text": "只看不买，暗中观察", "hint": "长见识", "tone": "neutral", "effects": {"insight": 2}, "result": "你隐匿在角落，见识了各种奇珍异宝，虽然没有买到，但阅历大增。"}
		]
	},
	{
		"id": "epic_mysterious_elder", "title": "古树仙缘", "text": "狂风暴雨中，你在一棵千年古松下避雨。一位浑身酒气、须发皆张的老道人突然出现在你身旁。他打了个酒嗝，从怀里摸出一颗黑乎乎的泥丸递给你：“小娃娃，相见便是缘。这泥丸吃下去，要么爆体而亡，要么洗髓伐脉，你敢不敢赌？”", "min_realm": 0, "max_realm": 20,
		"choices": [
			{"text": "赌了！一口吞下", "hint": "生死有命 · 极大概率逆天改命", "tone": "danger", "outcomes": [
				{"result": "泥丸入腹，化作磅礴药力。你不仅毫发无损，根骨和悟性更是脱胎换骨！", "effects": {"body": 8, "insight": 8, "cultivation": 50}},
				{"result": "剧烈的绞痛传来，你在地上翻滚了三天三夜，虽然没死，但经脉受损。", "effects": {"injury": 40, "body": 3}}
			]},
			{"text": "推辞不受，恭敬行礼", "hint": "谨小慎微 · 稳扎稳打", "tone": "good", "effects": {"daoheart": 5, "luck": 2}, "result": "老道大笑三声，化作一阵清风消失不见，你只觉得道心更加通透。"},
						{"text": "怒斥老道，以为是妖人", "hint": "性格刚烈", "tone": "evil", "effects": {"daoheart": -2, "stones": 10}, "result": "老道摇摇头，拂袖而去。你赫然发现地上留下了几枚灵石。"}
		]
	},
		{
		"id": "new_painted_skin", "title": "画皮", "weight": 5.0, "min_realm": 0, "max_realm": 12,
		"text": "荒村借宿，开门的女子美得不像活人。她递来一碗热汤，指尖冰凉。你低头喝汤时，看见地上她的影子——那不是人形，是一张被撑开的、空荡荡的皮。\n\n她坐在灯下，慢慢梳头，一边梳一边问：“客人，你看我美吗？”",
		"choices": [
			{
				"text": "面不改色，夸她一句美", "hint": "险 · 与鬼周旋", "tone": "neutral",
				"outcomes": [
					{"weight": 55, "text": "她笑了，笑得整张脸都像要裂开。“你是第一个不跑的。”她放下梳子，从袖中摸出一张薄如蝉翼的人皮，说这是她生前的心爱之物，如今用不上了，送你。你接过时，那皮上还带着体温。", "effects": {"luck": 3, "insight": 3, "karma": 1, "treasure": "旧人皮"}},
					{"weight": 45, "text": "她忽然凑近，鼻尖几乎贴上你的眉心：“你在怕。”话音未落，屋里的灯全灭了。你在黑暗里滚出门外，跑了一夜，天亮时发现自己躺在一片坟地里。", "effects": {"injury": 12, "daoheart": 2, "luck": -1}}
				]
			},
			{
				"text": "假装睡下，暗中观察", "hint": "智 · 探究真相", "tone": "neutral",
				"result": "你闭眼装睡。子时，她起身，从柜里取出一支细笔，对着铜镜一点点描自己的脸。描到一半，那脸忽然掉了下来。她蹲下身，小心地把脸捡起，贴上，又照了照镜子，像个怕丑的姑娘。你忽然不忍再看了。",
				"effects": {"insight": 4, "daoheart": 3, "karma": 2}
			},
			{
				"text": "连夜破门而出", "hint": "退 · 保全自身", "tone": "neutral",
				"result": "你连行李都没拿，翻窗就走。身后传来她的声音：“汤还没喝完呢。”那声音不追，也不怒，只是有点委屈。你跑到村口回头，整座村子已经不见了，只有一片荒草。",
				"effects": {"luck": 2, "daoheart": 1}
			}
		]
	},
	{
		"id": "new_ferryman", "title": "忘川渡口", "weight": 4.0, "min_realm": 3, "max_realm": 17,
		"text": "一条黑水河横在路前，河上没有桥。一个披蓑衣的摆渡人撑着乌篷船靠岸，船头挂着一盏青灯。\n\n“过河不收费。”他说，“只收你一段记忆。你自己选。”\n\n河对岸雾很浓，浓得看不见岸，只能听见水声，像很多人在低声说话。",
		"choices": [
			{
				"text": "上船，交出一段记忆", "hint": "玄 · 舍与得", "tone": "neutral",
				"outcomes": [
					{"weight": 60, "text": "你选了最痛的那段。摆渡人伸手在你额前一抹，你忽然忘了自己为何会痛，只觉得胸口轻了一块，像搬走了一块压了很多年的石头。船到岸，你回头，连他的脸也记不清了。", "effects": {"daoheart": 5, "insight": 4, "lifespan": 3}},
					{"weight": 40, "text": "你选了最快乐的那段。摆渡人摇头：“傻子。”船到岸，你发现自己再也想不起母亲的模样，只记得她的声音。那声音在往后很多年里，越来越淡。", "effects": {"daoheart": 3, "luck": -3, "insight": 5}}
				]
			},
			{
				"text": "问他：能不能不交", "hint": "争 · 讨价还价", "tone": "neutral",
				"result": "摆渡人盯着你看了很久，忽然笑了：“不交也行。那你就游过去。”他撑船离岸，青灯渐渐远去。你在河边站到天亮，雾散了，对岸就在百步之外。你涉水过去，水只没到膝盖。原来很多事，是自己吓自己。",
				"effects": {"insight": 4, "daoheart": 2, "luck": 2}
			},
			{
				"text": "不上船，沿河走", "hint": "稳 · 另寻出路", "tone": "neutral",
				"result": "你沿着河岸走，走了三天三夜。河一直流，你一直走。第四天清晨，你看见河源处立着一块碑，碑上刻着你的名字，日期是很多年以后。你愣住了，再回头，那条河已经干涸了。",
				"effects": {"lifespan": 5, "insight": 3, "luck": 2}
			}
		]
	},
	{
		"id": "new_fate_pavilion", "title": "天机阁", "weight": 5.0, "min_realm": 1, "max_realm": 17,
		"text": "坊市尽头有一座三层小楼，檐下挂着一块旧匾：天机阁。门口立着一块木牌，写着“问命者，以寿易之”。\n\n柜台后坐着个瞎眼的老头，头也不抬：“问什么？”",
		"choices": [
			{
				"text": "问前程，愿折十年寿元", "hint": "险 · 知命者悲", "tone": "neutral",
				"outcomes": [
					{"weight": 55, "text": "老头掐指，忽然脸色一变：“你这条命，早该在三百年前就断了。”他抬头，那双瞎眼里似乎有光。“有人替你续过命。你身上，欠着一笔大债。”", "effects": {"lifespan": -10, "insight": 6, "karma": 3}},
					{"weight": 45, "text": "他算了半炷香，摇头：“算不出。要么你命太硬，要么你根本不是这世的人。”他退回了你的寿元，只收了三个铜板，说这是“茶钱”。", "effects": {"insight": 3, "luck": 3, "cult_pct": 5}}
				]
			},
			{
				"text": "问姻缘，只折一年", "hint": "轻 · 小卦", "tone": "neutral",
				"result": "老头笑了：“年轻人啊。”他掐指，只说了两个字：“已至。”你还想问，他已经开始赶客。走出门，你撞到一个姑娘，她手里的花落了一地。你蹲下去捡，抬头时，她正看着你笑。",
				"effects": {"luck": 4, "karma": 2, "lifespan": -1}
			},
			{
				"text": "掀摊子：天机不可泄，你算什么东西", "hint": "狂 · 道心自立", "tone": "evil",
				"result": "老头没恼，只是慢慢合上眼：“我算不出你，是因为你不信命。这就已经是一种命了。”你砸了柜台，走出门，天上正在下雨。雨里，你忽然觉得有目光在很远的地方看着你。",
				"effects": {"daoheart": 4, "karma": -2, "luck": -1, "insight": 2}
			}
		]
	},
	{
		"id": "new_dragon_palace", "title": "龙宫借宝", "weight": 4.0, "min_realm": 4, "max_realm": 17,
		"text": "江底有一处宫阙，珊瑚作梁，鱼骨为柱。龙王须发皆白，坐在一张水玉案后，很客气地给你斟了一杯酒。\n\n“小友远道而来，所为何事？”\n\n酒是冷的，苦的，入喉后却在丹田里烧起来。你知道，这位龙王，不是善茬。",
		"choices": [
			{
				"text": "借定海珠一用", "hint": "贪 · 需还债", "tone": "neutral",
				"outcomes": [
					{"weight": 50, "text": "龙王笑了：“可以。但你得答应我一件事——将来我龙族遭难，你得站在我们这边。”你答应了。定海珠入你识海，凉得像一口井。你并不知道，那句承诺，会在很多年后变成一把刀。", "effects": {"body": 4, "cult_pct": 12, "luck": 3, "karma": -3, "treasure": "定海珠"}},
					{"weight": 50, "text": "他沉默很久，最后摇头：“珠子不借。但我送你一句话——江要干了，别在这儿久留。”你正要问，宫阙忽然晃了一下。水在变浅。", "effects": {"insight": 4, "luck": 2, "daoheart": 2}}
				]
			},
			{
				"text": "只讨一杯酒，不为宝物", "hint": "淡 · 交个善缘", "tone": "good",
				"result": "龙王愣了愣，随即大笑，命人又取出一坛。“这坛是三百年的陈酿，本来是我女儿出阁时喝的。”他给你倒满，自己也倒满。你们喝到天亮，他送了你出宫。江面浮着一层薄雾，他站在水边，看着你，什么也没说。",
				"effects": {"luck": 4, "lifespan": 5, "daoheart": 3, "karma": 3}
			},
			{
				"text": "趁其不备，摸走一件就走", "hint": "恶 · 后患无穷", "tone": "evil",
				"outcomes": [
					{"weight": 40, "text": "你摸走了一枚龙鳞，刚出宫门就被水浪掀翻。龙鳞化了，你的后背多了一道鳞状的疤。此后每次落水，都觉得有人在水下拽你的脚。", "effects": {"stones": 80, "injury": 18, "karma": -6, "luck": -2}},
					{"weight": 60, "text": "你摸走的是一块旧砚台。回来才知，那是他亡妻的遗物。龙王没追来，但从那以后，你在江边再也钓不到一条鱼。", "effects": {"karma": -5, "stones": 30, "daoheart": -2, "luck": -3}}
				]
			}
		]
	},
	{
		"id": "new_peach_grove", "title": "桃林旧约", "weight": 4.0, "min_realm": 2, "max_realm": 17,
		"text": "山谷里有一片桃林，花开得极盛，却没有一个人。树下埋着一坛酒，坛口封泥上还留着半枚指印。\n\n酒坛旁边，压着一封没写完的信。信纸边缘已经发黄，最后一句只写到一半：“若你归来，我……”\n\n“我”字后面，是一片空白。",
		"choices": [
			{
				"text": "挖出酒坛，一个人喝完", "hint": "情 · 敬一段旧事", "tone": "neutral",
				"result": "酒很烈，很苦，后劲却甜。你坐在桃树下，一杯一杯地喝，喝到月上中天。风过处，桃花落了你满身。你忽然明白，写信的人大概早已不在，而收信的人，也许从未来过。",
				"effects": {"daoheart": 4, "lifespan": 3, "insight": 3, "karma": 2}
			},
			{
				"text": "读完那封信", "hint": "静 · 悟缘", "tone": "neutral",
				"outcomes": [
					{"weight": 60, "text": "信里写的是一个等了三十年的人。最后一页背面，还有一行极小的字：“其实我知道你不会回来。我只是想给自己一个等下去的理由。”你把信放回原处，替他们扫了扫碑上的落叶。", "effects": {"insight": 5, "daoheart": 3, "luck": 2}},
					{"weight": 40, "text": "信纸一碰就碎。碎片里落出一枚极小的玉扣，上面刻着一个“念”字。你握住它，觉得手心温热。那一刻，你似乎听见有人在很远的地方，轻轻叹了一口气。", "effects": {"luck": 4, "insight": 3, "treasure": "念字玉扣"}}
				]
			},
			{
				"text": "什么都不动，只扫落叶", "hint": "敬 · 道心 +3", "tone": "good",
				"result": "你找了把旧扫帚，把桃林里的落叶扫成一堆，埋在树根下。你什么也没带走，什么也没留下。离开时，满山桃花忽然一起开了，像有人在你背后，轻轻鼓了一下掌。",
				"effects": {"daoheart": 4, "luck": 3, "karma": 3}
			}
		]
	},
	{
		"id": "new_puppet_troupe", "title": "傀儡戏班", "weight": 4.0, "min_realm": 1, "max_realm": 14,
		"text": "荒庙里点着十几盏灯，一群人在演一出戏。戏文唱的是一个修士渡劫飞升的故事。\n\n你走近才发现，戏台上没有活人，全是傀儡。可它们的动作太真了，真到有一个傀儡转身时，你看见它的眼睛——瞳孔在收缩。\n\n台下坐满了观众。他们也在看戏，一动不动，像另一批傀儡。",
		"choices": [
			{
				"text": "坐下，把戏看完", "hint": "玄 · 观戏者亦是戏", "tone": "neutral",
				"outcomes": [
					{"weight": 55, "text": "戏演到飞升那一刻，台上的傀儡忽然回头看向你，说：“还差最后一个角色。”你忽然明白，这出戏演了几百年，每看一次的人，都会被请上台。你站起身，走进了那片光里。醒来时，你在庙外，修为涨了一截，却想不起戏文的结局。", "effects": {"cult_pct": 14, "insight": 5, "daoheart": 2}},
					{"weight": 45, "text": "你看到一半便觉不对，想走，却发现门口站着两个纸人。它们朝你鞠了一躬：“客官，戏还没完。”你硬着头皮看完，天亮时灯全灭了，台上的傀儡和台下的观众，一起散成了纸屑。", "effects": {"insight": 4, "injury": 8, "luck": -2}}
				]
			},
			{
				"text": "上台，替下那个傀儡", "hint": "危 · 以身入戏", "tone": "neutral",
				"outcomes": [
					{"weight": 50, "text": "你站到台上，学着它的动作。那一刻，你忽然懂了戏里那个修士的心：他不是飞升，是被推上去的。你演完最后一场，台下有人哭了。散场后，你在袖子里摸到一枚小小的木偶。", "effects": {"insight": 6, "daoheart": 4, "treasure": "戏偶"}},
					{"weight": 50, "text": "你刚站上去，四肢就不听使唤了。你眼睁睁看着自己做了很多陌生的动作，演完了别人的一生。回到台下时，你已分不清哪些记忆是自己的。", "effects": {"daoheart": -3, "injury": 10, "insight": 4}}
				]
			},
			{
				"text": "一把火烧了戏台", "hint": "断 · 断人念想", "tone": "evil",
				"result": "火烧起来，傀儡们没有躲，反而都朝你鞠了一躬。台下的观众一个接一个站起身，慢慢散去。你在灰烬里看见一具人骨，手里还攥着半截提线。你烧掉的不只是一出戏，还有一个人等了很久的谢幕。",
				"effects": {"karma": -4, "daoheart": 2, "insight": 3, "injury": 6}
			}
		]
	},
	{
		"id": "new_blank_stele", "title": "无字碑", "weight": 5.0, "min_realm": 0, "max_realm": 17,
		"text": "山巅立着一块碑，碑上什么都没刻，碑前却香火不断，供着各种果子、旧衣和几封信。\n\n一个老农告诉你，这碑很灵，求什么都应。但他不知道这是谁的碑。他说，从他爷爷的爷爷那辈起，这碑就立在这儿了。",
		"choices": [
			{
				"text": "在碑上刻下自己的名字", "hint": "狂 · 与古碑结缘", "tone": "neutral",
				"outcomes": [
					{"weight": 55, "text": "你刻完最后一笔，碑面忽然渗出一层薄汗。你听见有人在很远的地方，轻轻念了一遍你的名字。那之后，你每逢大难，都觉得有人在背后替你挡了一下。", "effects": {"luck": 5, "daoheart": 3, "karma": 2}},
					{"weight": 45, "text": "刻到一半，刀锋崩了。碑上只留下半个字。你看着那个残缺的字，忽然觉得心里空了一块，好像有什么东西，也被刻掉了。", "effects": {"luck": -2, "injury": 5, "insight": 3}}
				]
			},
			{
				"text": "刻一个“空”字", "hint": "悟 · 万法皆空", "tone": "good",
				"result": "你刻完“空”字，碑面忽然变得极亮，又很快暗淡下来。你跪在碑前，闭眼很久。起身时，你觉得自己的道心像被人轻轻擦过一遍，干净，明亮。你走下山，身后有个孩子在喊你，你没有回头。",
				"effects": {"daoheart": 6, "insight": 4, "cult_pct": 6, "luck": 2}
			},
			{
				"text": "把碑推倒", "hint": "断 · 砸人念想", "tone": "evil",
				"result": "碑倒了，断成两截。碑座下露出一个极小的陶罐，里面是一捧灰。你不知道这是谁的骨灰，只知道推倒它的那一瞬，山下忽然安静了，像整个村子同时停了一下呼吸。你走时，身后有个老人坐在废墟边，慢慢地哭。",
				"effects": {"karma": -7, "daoheart": -2, "injury": 8, "stones": 40}
			}
		]
	},
	{
		"id": "new_blood_sea", "title": "血海尸潮", "weight": 3.0, "min_realm": 6, "max_realm": 17,
		"text": "边关城头，老将军跪在你面前，盔甲上全是干涸的血。\n\n“仙师，城后是三万百姓。城前，是十万尸潮。”他把兵符双手奉上，“我这条命，值不了几个钱。可孩子们还小。”\n\n城下已经传来闷闷的脚步声，像雷，也像潮水。",
		"choices": [
			{
				"text": "一人守城，战到尸潮退去", "hint": "勇 · 以一人敌十万", "tone": "good",
				"outcomes": [
					{"weight": 50, "text": "你站在城头，守了七天七夜。最后一天，你扶着城墙才没倒下，而城下已经堆起尸山。老将军跪在你脚边，老泪纵横。三万百姓齐声喊你的名字，那声音，比任何功法都重。", "effects": {"karma": 12, "daoheart": 6, "injury": 30, "stones": 100, "body": 5}},
					{"weight": 50, "text": "你挡住了九波尸潮，第十波来的时候，你的灵力见底了。城破那一夜，你背着老将军杀出一条血路，三万百姓只活下来不到三千。你终身记得那个数字。", "effects": {"karma": 6, "injury": 35, "daoheart": 3, "stones": 40}}
				]
			},
			{
				"text": "只救百姓，不守城", "hint": "智 · 有所取舍", "tone": "neutral",
				"result": "你把城门打开，让百姓连夜出城，从后山的小路撤走。老将军不肯走，站在城头，说要给他的兵收尸。你带着最后一批人走出山道时，回头看见火光冲天。你没敢数，那天夜里死了多少人。",
				"effects": {"karma": 5, "daoheart": 3, "insight": 3, "injury": 8}
			},
			{
				"text": "转身离去", "hint": "退 · 大道无情", "tone": "evil",
				"result": "你转身下了城头。老将军没有拦你，只是在你背后说了一句：“仙师慢走。”你走了一天一夜，路上没有遇到一个人。后来你听说，那座城没有撑过第二天。",
				"effects": {"karma": -10, "daoheart": -4, "luck": -3, "insight": 2}
			}
		]
	},
	{
		"id": "new_monk_passing", "title": "老僧坐化", "weight": 4.0, "min_realm": 1, "max_realm": 17,
		"text": "破庙里，一个老僧已经坐了很久。他的呼吸很轻，轻到你要凑近才听得见。\n\n“小友。”他没有睁眼，“我快走了。走之前，想听一句经。”\n\n“不用念完。一句就好。”",
		"choices": [
			{
				"text": "为他诵一句经", "hint": "善 · 送人一程", "tone": "good",
				"outcomes": [
					{"weight": 65, "text": "你诵完那一句，老僧的嘴角慢慢弯了一下。他走了，走得很安静。你替他合上眼，忽然觉得自己的识海里，也亮了一盏灯。", "effects": {"daoheart": 6, "karma": 6, "insight": 4, "luck": 3}},
					{"weight": 35, "text": "你诵了一半，忽然忘了后面的句子。老僧笑了：“忘了也好。”他自己接了下去，念完最后一个字，便再没声音。你在庙里坐了一夜，天亮时，懂了很多东西，却说不出是什么。", "effects": {"daoheart": 4, "insight": 5, "lifespan": 3}}
				]
			},
			{
				"text": "问他：还有什么放不下", "hint": "情 · 送人一念", "tone": "neutral",
				"result": "老僧沉默很久，说：“山下的桃花，我三年没看了。”你背着他，一步一喘地下了山。桃花开得正好。他看着看着，睡着了。你在树下守了三天，替他扫了扫身上的落花。",
				"effects": {"karma": 7, "daoheart": 5, "insight": 3, "lifespan": 2}
			},
			{
				"text": "抢在他死前取走舍利", "hint": "恶 · 断人因果", "tone": "evil",
				"outcomes": [
					{"weight": 55, "text": "你伸手探向他的眉心。老僧睁眼，看了你一眼，没有反抗。舍利入手，烫得像火。那一夜之后，你的修为暴涨，可你再也念不出一句完整的经。", "effects": {"karma": -12, "cult_pct": 22, "daoheart": -4, "body": 3}},
					{"weight": 45, "text": "你刚碰到他，老僧的身体忽然散了，化作一捧细沙。沙里什么也没有。你愣在原地，忽然听见一句很远的话：“你拿走的，本来也没有。”", "effects": {"karma": -6, "insight": 4, "luck": -2, "daoheart": -1}}
				]
			}
		]
	},
	{
		"id": "new_red_thread", "title": "红线", "weight": 4.0, "min_realm": 2, "max_realm": 17,
		"text": "月老祠很旧了，神像的脸已经模糊。你上香时，忽然觉得小指一紧——一根极细的红线，从你指间延伸出去，穿过墙，穿过山，看不见尽头。\n\n线的另一头，有人在轻轻拽了拽。",
		"choices": [
			{
				"text": "顺着红线找过去", "hint": "缘 · 未知相逢", "tone": "neutral",
				"outcomes": [
					{"weight": 55, "text": "你走了三天三夜，红线最终系在一个姑娘的小指上。她抬头看你，愣了很久，忽然笑了：“原来是你。”你忽然想起，你已经等了她很多年，只是自己忘了。", "effects": {"luck": 6, "daoheart": 4, "karma": 3, "lifespan": 5}},
					{"weight": 45, "text": "线的尽头是一座新坟。坟前摆着一只旧绣鞋，鞋里有一封没寄出去的信。你把信烧了，红线随之消散。那一刻，你发现自己小指上多了一道很细的疤。", "effects": {"insight": 5, "daoheart": 3, "karma": 4, "luck": -2}}
				]
			},
			{
				"text": "剪断红线", "hint": "断 · 断前世今生", "tone": "neutral",
				"result": "你取出一把小刀，把红线割断。断口处没有流血，只是飘出一缕极淡的香。你走出庙门，阳光很好，风也很轻，只是你忽然想不起来，自己来这里是为了什么。",
				"effects": {"daoheart": 4, "luck": 2, "insight": 3, "karma": -2}
			},
			{
				"text": "把红线系到别人身上", "hint": "恶 · 移祸于人", "tone": "evil",
				"result": "你在庙外找了一对吵架的夫妻，把红线系在了他们中间。第二天，那对夫妻一起来上香，脸上都有笑意。你看着他们，忽然觉得自己的小指很冷。回去的路上，你遇到很多成双成对的人，没有人看你一眼。",
				"effects": {"karma": -4, "luck": -2, "insight": 3, "daoheart": 2}
			}
		]
	},
		{
		"id": "new2_sword_heart", "title": "剑冢问心", "weight": 3.0, "min_realm": 8, "max_realm": 17,
		"text": "你踏入剑冢时，十万柄剑同时静了。\n\n不是臣服，是审视。一柄柄剑从土里缓缓抬起，剑尖朝向你。你听见一个苍老的声音从地底传来：“来者，说一句你的道。说对了，剑归你；说错了，你归剑。”\n\n风停了，连呼吸都显得多余。",
		"choices": [
			{
				"text": "我的道，是护", "hint": "正 · 以心证剑", "tone": "good",
				"outcomes": [
					{"weight": 55, "text": "十万剑鸣齐齐一落，如万民跪拜。最中央那柄古剑自行出鞘，剑身映出你的一生——你护过的人，和没能护住的人。剑落在你手中，重得像一座山，也轻得像一句承诺。", "effects": {"daoheart": 7, "body": 5, "cult_pct": 18, "karma": 5, "treasure": "护字古剑"}},
					{"weight": 45, "text": "地底沉默了很久，才缓缓开口：“护？你护得住谁。”话音落下，三道剑意破土而出，贯穿你的肩膀。你跪在血里，第一次明白，说出口的道，要用命来证。", "effects": {"injury": 30, "daoheart": 4, "insight": 5}}
				]
			},
			{
				"text": "我的道，是杀", "hint": "锋 · 以杀证道", "tone": "evil",
				"outcomes": [
					{"weight": 50, "text": "满冢剑鸣如雷，无数剑光朝你涌来。你不躲，任它们穿过身体——每一剑都带走你一部分犹疑。最后你站着，浑身是血，手里握着一柄薄刃。它没有名字，因为它就是你的名字。", "effects": {"body": 6, "cult_pct": 20, "karma": -6, "daoheart": 3, "treasure": "无名薄刃"}},
					{"weight": 50, "text": "声音笑了，笑得像铁锈摩擦：“杀？你杀过几个。”话音刚落，你脚下裂开，无数断剑刺入。你拼命爬出土坑，回头看见剑冢重新合拢，像什么也没发生。你身上多了十几道疤，也多了十几个不眠的夜。", "effects": {"injury": 28, "daoheart": -2, "insight": 4}}
				]
			},
			{
				"text": "我的道，是不知道", "hint": "真 · 诚实最难", "tone": "neutral",
				"result": "剑冢安静了很久。久到你以为自己要被埋了。地底的声音忽然轻了：“八百年了，头一回有人这么说。”没有剑飞出来，只有一枚锈迹斑斑的剑穗落进你手里。“带着它吧。等你想明白了，再来。”",
				"effects": {"insight": 7, "daoheart": 5, "luck": 3, "treasure": "旧剑穗"}
			}
		]
	},
	{
		"id": "new2_withered_temple", "title": "枯荣禅院", "weight": 4.0, "min_realm": 3, "max_realm": 17,
		"text": "禅院一半草木繁盛，一半枯骨成堆。院中坐着一个老和尚，半边脸年轻如少年，半边脸老朽如枯木。\n\n他睁开唯一一只眼：“我坐了三百年，看这院子荣了又枯，枯了又荣。你说——我该走，还是该坐？”",
		"choices": [
			{
				"text": "该走。荣枯都是外物", "hint": "破执 · 悟道", "tone": "good",
				"outcomes": [
					{"weight": 60, "text": "老和尚怔了很久，忽然大笑。笑声里，枯的那半边身子簌簌化灰，年轻的那半边缓缓站起。“三百年，我就等这一句。”他朝你一揖，化作清风，满院草木一夜开花。", "effects": {"daoheart": 6, "insight": 6, "karma": 4, "luck": 3}},
					{"weight": 40, "text": "他摇头：“走？我走了，谁来看着这院子的枯荣？”你无言以对。他合上眼，继续坐着。你走出禅院时，回头看见那半枯的身子，似乎又老了一些。", "effects": {"insight": 4, "daoheart": 2}}
				]
			},
			{
				"text": "该坐。守也是一道", "hint": "守心 · 得传", "tone": "neutral",
				"result": "老和尚点点头，像是早就知道你会这么答。“坐，也是道。你既然懂，便替我坐一夜。”他起身，走到院中那棵枯树下，盘膝坐下，缓缓闭上眼。那一夜，你替他守了整座禅院。天亮时，枯树抽了新芽，他的身体却不见了。",
				"effects": {"daoheart": 5, "insight": 4, "cult_pct": 8, "lifespan": 3}
			},
			{
				"text": "我不该替你答。你该问自己", "hint": "直 · 反问", "tone": "neutral",
				"outcomes": [
					{"weight": 55, "text": "他愣住，随即笑得前仰后合：“好一个不该替你答！”他抬手，把一枚舍利按进你的眉心，“我给你三百年功力，换你这句话。”你还没来得及推辞，他已经散成满地落花。", "effects": {"cult_pct": 22, "insight": 6, "karma": 2, "body": 3}},
					{"weight": 45, "text": "他沉默片刻，低声道：“我要是知道，就不坐三百年了。”他闭上眼，不再说话。你退出禅院时，身后传来很轻的一声叹息，像一片叶子落地。", "effects": {"insight": 5, "daoheart": 3, "luck": 2}}
				]
			}
		]
	},
	{
		"id": "new2_dream_seller", "title": "卖梦人", "weight": 5.0, "min_realm": 1, "max_realm": 14,
		"text": "夜市最角落有个摊位，不卖符，不卖丹，只卖梦。\n\n摊主是个瘸腿老人，面前摆着一排小瓷瓶，每个瓶里都封着一个梦。价格写在木牌上：一梦一灵石。\n\n“梦里什么都有。”他抬头看你，“就是醒来以后，什么都没有。”",
		"choices": [
			{
				"text": "买一个飞升的梦", "hint": "需 1 灵石 · 虚幻一场", "tone": "neutral", "cost": 1,
				"outcomes": [
					{"weight": 60, "text": "梦里你渡劫成功，飞升天门，万仙来贺。醒来时，枕边是冷的地面，摊主正收摊。“怎么样？”他问。你说挺好。他笑了：“梦里好，醒来还接着修，这就值了。”那天之后，你打坐时格外静。", "effects": {"insight": 4, "daoheart": 3, "luck": 2}},
					{"weight": 40, "text": "梦里你飞升了，回头看见人间正在崩塌，亲人一个接一个死去。你想回去，却怎么也回不去。醒来时你一身冷汗，摊主说：“这梦，很多人买。醒了都跟你一样。”", "effects": {"daoheart": -2, "insight": 5, "lifespan": -2}}
				]
			},
			{
				"text": "买一个故人的梦", "hint": "需 1 灵石 · 见想见的人", "tone": "neutral", "cost": 1,
				"result": "梦里，你见到了那个早已不在的人。你们说了很多话，多到醒来时你一句也想不起来，只记得对方笑了一下。你坐在摊前很久，摊主没有催你。他把空瓶收走时说：“见过就够了。”",
				"effects": {"daoheart": 4, "lifespan": 3, "karma": 2, "insight": 2}
			},
			{
				"text": "问他：有没有噩梦，卖给别人", "hint": "疑 · 追问", "tone": "neutral",
				"result": "摊主看了你很久，从最底下摸出一个黑瓶，不收钱。“这个，送你。”他压低声音，“这是别人不要的。你拿着，哪天撑不住了，打开它——看看别人怎么熬过来的。”你收下黑瓶。那夜你没打开，但睡得很沉。",
				"effects": {"insight": 5, "daoheart": 3, "luck": 2, "treasure": "黑梦瓶"}
			}
		]
	},
	{
		"id": "new2_headless_buddha", "title": "断头佛", "weight": 4.0, "min_realm": 5, "max_realm": 17,
		"text": "山壁凿着一尊大佛，佛头早已不知去向。断口处没有风化，反而光滑得像被什么舔过。\n\n你在佛前站了一会儿，忽然听见断口里传来极轻的呼吸声。\n\n佛，好像还活着。",
		"choices": [
			{
				"text": "跪下，向断头佛行礼", "hint": "敬 · 佛亦是人", "tone": "good",
				"outcomes": [
					{"weight": 55, "text": "你跪下去的那一刻，断口里的呼吸停了。风从山间穿过，像有人在你头顶落了一声“善”。你起身，掌心多了一粒温热的砂。你捏碎它，满山的雾都散了一瞬。", "effects": {"daoheart": 5, "karma": 4, "insight": 3, "luck": 3}},
					{"weight": 45, "text": "呼吸声越来越近，最后贴在你耳边。你听见它说：“头呢？”你浑身一冷，抬头看见佛的断口缓缓转向你。你连滚带爬下山，回到镇上才发现，自己的影子——没有了头。", "effects": {"injury": 15, "daoheart": -2, "luck": -3}}
				]
			},
			{
				"text": "爬上佛身，查看断口", "hint": "勇 · 探秘", "tone": "neutral",
				"outcomes": [
					{"weight": 50, "text": "断口下是一个空洞，洞里盘着一卷旧经，经页上沾着暗红的手印。你刚要取，那经书忽然翻动，停在某一页——上面写满了你的名字。", "effects": {"insight": 6, "daoheart": 2, "karma": -2, "treasure": "血手经"}},
					{"weight": 50, "text": "你爬到一半，脚下石屑松动，直直摔下。昏迷前，你看见佛的肩膀上坐着一个没有五官的人，正低头看你。醒来时你躺在山下，浑身是伤。", "effects": {"injury": 22, "body": 2}}
				]
			},
			{
				"text": "找一块石头，替它安一个头", "hint": "善 · 佛缘", "tone": "good",
				"result": "你找了半天，搬来一块形状圆润的石头，用灵力把它嵌在断口上。石头当然不像佛头，可你做完这件事，觉得心里妥帖了。那天夜里，你梦见一个无头僧人坐在你身旁，什么也没说，只是陪你坐着。",
				"effects": {"karma": 6, "daoheart": 4, "luck": 3, "lifespan": 2}
			}
		]
	},
	{
		"id": "new2_old_general", "title": "将军枯骨", "weight": 4.0, "min_realm": 4, "max_realm": 17,
		"text": "古战场深处，一具披甲的枯骨跪在地上，双手擎着一杆残破的军旗。风吹过，甲片哗哗作响。\n\n它没有头，可你分明听见一个声音在说：“……守……不住了……”\n\n军旗上绣的，是几百年前一个早已亡国的番号。",
		"choices": [
			{
				"text": "接过军旗，替它立起来", "hint": "义 · 成全一诺", "tone": "good",
				"result": "你把军旗插进土里，用灵力把它扶正。风忽然停了，枯骨慢慢松开手，朝你深深一拜，然后散成一地甲片。甲片下，压着一枚虎符，还有一行用血写的小字：“国虽亡，人未降。”",
				"effects": {"karma": 8, "daoheart": 6, "luck": 4, "treasure": "旧国虎符"}
			},
			{
				"text": "搜刮它身上的甲片", "hint": "贪 · 得甲，沾怨", "tone": "evil",
				"outcomes": [
					{"weight": 55, "text": "甲片入手极沉，敲之如钟。你剥下最后一片时，枯骨忽然动了，一把攥住你的手腕。你挣脱跑开，回头看，它还跪在原地，军旗却已倒下。此后每逢阴雨，你手腕都会疼。", "effects": {"stones": 90, "injury": 12, "karma": -5, "body": 2}},
					{"weight": 45, "text": "你刚碰到它，周围的黄沙忽然立起，化作无数士兵的虚影。它们围着你，却不攻击，只是齐声问：“你在守什么？”你答不上来。沙兵散去，甲片碎了一地。", "effects": {"insight": 5, "daoheart": 2, "luck": -2}}
				]
			},
			{
				"text": "在它面前坐下，听它讲完", "hint": "静 · 听一段旧事", "tone": "neutral",
				"outcomes": [
					{"weight": 60, "text": "你坐了一整夜。它的声音断断续续，讲城破、讲断粮、讲最后一个人倒下时还在喊“将军”。天亮时它说完了，枯骨缓缓倒下，风把军旗卷起来，轻轻盖在它身上。你起身，觉得心里多了一座城。", "effects": {"daoheart": 6, "insight": 6, "karma": 4, "lifespan": 3}},
					{"weight": 40, "text": "它讲了三天，讲到一半忽然问你：“你也会死，你怕吗？”你没答。它就再也不说话了。你走出战场时，回头看见那面军旗，在风里猎猎作响，像在笑，也像在哭。", "effects": {"insight": 4, "daoheart": 3, "luck": 2}}
				]
			}
		]
	},
	{
		"id": "new2_living_tomb", "title": "活死人墓", "weight": 3.0, "min_realm": 6, "max_realm": 17,
		"text": "山腹里有一座墓，墓门开着。门口立着一块碑，碑上刻的不是墓志，而是一句：“我还没死，别进来。”\n\n门里透出微光，还有很轻的、断断续续的读书声。\n\n你在门口站了很久。书声忽然停了：“外面的，进来吧。”",
		"choices": [
			{
				"text": "推门进去", "hint": "险 · 见一个活着的死人", "tone": "neutral",
				"outcomes": [
					{"weight": 55, "text": "墓里坐着一个年轻人，面前摊着一本翻烂的书。他抬头笑：“我进来三百年了。起初是想闭死关，后来发现——出不去。”他指了指身后那面墙，“墙上有门，可我一靠近，它就变成书。你试试？”你走过去，墙上的确有一扇门。", "effects": {"insight": 6, "daoheart": 3, "cult_pct": 10, "treasure": "翻烂旧书"}},
					{"weight": 45, "text": "墓里空无一人。书摊在石桌上，最后一页写着：“第九百九十九个。别回头。”你猛回头，墓门已经消失，取而代之的是一面墙。你在墓里找了三天，才从一个极小的裂缝爬出去。", "effects": {"injury": 18, "insight": 5, "luck": -2}}
				]
			},
			{
				"text": "站在门口，隔空和他说话", "hint": "慎 · 不越界", "tone": "neutral",
				"result": "你站在门外，和那个声音聊了一夜。他讲外面的事，你讲里面的事——虽然你从没进去过。天亮时他说：“谢谢你陪我说话。三百年，头一回。”你离开时，墓门缓缓合上，碑上多了一行小字：“聊过一次，够了。”",
				"effects": {"karma": 5, "insight": 5, "daoheart": 3, "luck": 2}
			},
			{
				"text": "把门彻底封死", "hint": "断 · 断其念想", "tone": "evil",
				"result": "你搬来巨石，把墓门堵了个严严实实。里面的读书声停了一瞬，随即又响起来，比刚才更轻。你转身下山，走了很远，还听得见那声音——像是有人在念你的名字。",
				"effects": {"karma": -6, "daoheart": -2, "insight": 3, "luck": -3}
			}
		]
	},
	{
		"id": "new2_thunder_clerk", "title": "雷部小吏", "weight": 2.5, "min_realm": 9, "max_realm": 17,
		"text": "乌云压顶，雷声滚滚。你仰头，看见云里立着一个穿青袍的人，手持一面小鼓，正低头往下看。\n\n“下面那个。”他开口，声音像打雷，“你这一片，今日该劈三个人。我偷懒，劈错了一个。你说，剩下两个，我该劈谁？”\n\n他手里捏着一张名册，翻到某一页，停住了。",
		"choices": [
			{
				"text": "替我看看名册上有没有我", "hint": "问 · 直面天数", "tone": "neutral",
				"outcomes": [
					{"weight": 50, "text": "他翻了翻，忽然笑了：“有。不过——是很多年以后了。”他把名册合上，拍了拍你的肩，“好好活着。别到时候让我为难。”雷声远去，云散天开。你站在原地，手心全是汗。", "effects": {"lifespan": 5, "insight": 5, "luck": 3, "daoheart": 3}},
					{"weight": 50, "text": "他脸色一变：“你问这个做什么！”话音刚落，一道雷直劈你头顶。你拼死挡下，半边身子焦黑。他在云里冷笑：“问天机的，天机也要问你。”", "effects": {"injury": 26, "insight": 3, "luck": -2}}
				]
			},
			{
				"text": "该劈谁，你自己看着办", "hint": "淡 · 不涉因果", "tone": "neutral",
				"result": "他愣了半天，忽然大笑：“好！好一个自己看着办。”他把名册往云里一扔，“不劈了。今日这片，一个都不劈。”雷声渐远，天色放晴。你不知道这算不算好事，只知道那天之后，附近几个村子都说，今年雨水格外顺。",
				"effects": {"karma": 6, "luck": 4, "daoheart": 3}
			},
			{
				"text": "劈贪官。剩下两个，我来指", "hint": "狂 · 替天行道", "tone": "good",
				"outcomes": [
					{"weight": 55, "text": "你报了两个名字。青袍人听完，点点头：“查过了，都该劈。”雷声连响三下，远处的城头，有人彻夜未眠。他临走时丢给你一枚小小的雷印：“以后有冤，捏碎它。”", "effects": {"karma": 8, "luck": 4, "insight": 4, "treasure": "小雷印"}},
					{"weight": 45, "text": "你报的名字里，有一个是他朋友。青袍人沉默很久，最终没有劈，把名册收进怀里走了。你站在雨里，忽然明白，连天也不是那么讲理。", "effects": {"insight": 5, "daoheart": 2, "luck": -1}}
				]
			}
		]
	},
	{
		"id": "new2_embroidery", "title": "绣娘", "weight": 5.0, "min_realm": 0, "max_realm": 12,
		"text": "小镇上有个绣娘，绣的东西活的一样。她绣的猫会眨眼，绣的花会落瓣。\n\n你路过时，她正对着一块白绢发呆。“客官，”她抬起头，“你能帮我看看，这块绢上——该绣个什么吗？”\n\n白绢上什么都没有，可你凑近时，闻到一股极淡的血腥味。",
		"choices": [
			{
				"text": "替我绣一幅我的样子", "hint": "险 · 以身入绣", "tone": "neutral",
				"outcomes": [
					{"weight": 55, "text": "她绣了三天。第三天你去看，绢上的人已经绣好了，眉眼分明。你伸手去摸，那人忽然眨了眨眼。绣娘笑了：“活了。”她剪断线头，绢上的人慢慢走出，站在你面前——和你一模一样。", "effects": {"insight": 6, "luck": 4, "karma": -2, "treasure": "替身绣像"}},
					{"weight": 45, "text": "她绣到一半，忽然停手，脸色发白：“我绣不出来。”你问为什么。她说：“因为你还没死。活人的样子，绣不住。”那幅绣品被烧了，你看着火苗，忽然觉得背脊发凉。", "effects": {"insight": 4, "daoheart": 3, "luck": 2}}
				]
			},
			{
				"text": "让她绣一朵开败的花", "hint": "悟 · 一花一世界", "tone": "good",
				"result": "她怔了怔，低头绣起来。绣到一半，花开了；绣到最后，花谢了。她把绢递给你，说：“客官，这朵花，谢了还在。”你看着那朵谢花，忽然懂了什么，朝她深深一揖。",
				"effects": {"daoheart": 5, "insight": 5, "luck": 3, "cult_pct": 6}
			},
			{
				"text": "问她：这绢，是谁的血", "hint": "智 · 追根问底", "tone": "neutral",
				"outcomes": [
					{"weight": 55, "text": "她沉默了很久，说：“是我自己的。绣一件东西，要滴一滴血，才绣得活。”她抬起手，指尖全是针眼。你忽然明白，这镇上那些活了一样的绣品，每一件，都少了她一滴血。", "effects": {"karma": 4, "insight": 6, "daoheart": 3}},
					{"weight": 45, "text": "她猛地抬头，眼神变得极冷：“你管得太多。”话音未落，屋里的绣品全都动了——猫扑、花落、人走。你护住要害退出门外，回头看见她坐在一片飞针里，正低头绣着，嘴角带笑。", "effects": {"injury": 14, "insight": 4, "luck": -2}}
				]
			}
		]
	},
	{
		"id": "new2_failed_tribulation", "title": "渡劫失败者", "weight": 3.0, "min_realm": 10, "max_realm": 17,
		"text": "荒山上坐着一个焦黑的人形，衣服烧没了，皮肤烧没了，只剩下一个人形轮廓，还在缓缓冒着青烟。\n\n“别走。”它开口，声音像砂纸磨铁，“我渡劫失败了。你……能不能告诉我，天上面，到底有什么？”\n\n它的眼睛里，还有一点没灭的光。",
		"choices": [
			{
				"text": "告诉他：什么也没有", "hint": "真 · 残忍的诚实", "tone": "neutral",
				"outcomes": [
					{"weight": 55, "text": "它安静了很久。最后那点光慢慢暗下去，它说：“谢谢你没骗我。”说完，身体化成一撮灰，风一吹，散了。你在原地坐了一夜，忽然觉得“什么也没有”这几个字，比任何雷劫都重。", "effects": {"daoheart": 6, "insight": 7, "karma": 3}},
					{"weight": 45, "text": "它忽然暴起，抓住你的衣领：“不可能！不可能！”它的力气大得吓人，你被甩出很远。再爬起来时，它已经散了，地上只剩一个焦黑的脚印。", "effects": {"injury": 18, "insight": 4, "daoheart": -1}}
				]
			},
			{
				"text": "告诉他：有你", "hint": "善 · 一句谎话", "tone": "good",
				"result": "它愣住，那点光忽然亮了一下。“有我？”它笑了，笑声很难听。“好，好。”它抬手，把体内最后一缕真元按进你胸口，“替我去看看。看完了，回来告诉我。”说完，它散了。你胸口滚烫，像揣着一整个未竟的梦。",
				"effects": {"cult_pct": 18, "karma": 6, "daoheart": 5, "body": 3}
			},
			{
				"text": "什么也不说，陪它坐着", "hint": "静 · 无声", "tone": "neutral",
				"result": "你坐下来，什么也没说。它的烟越来越淡，最后连轮廓都散了。风把地上的灰吹起来，像一群极小的蝶。你起身时，发现自己的衣角，沾了一点洗不掉的焦痕。",
				"effects": {"daoheart": 4, "insight": 4, "luck": 3, "lifespan": 2}
			}
		]
	},
	{
		"id": "new2_dream_tapir", "title": "食梦貘", "weight": 4.5, "min_realm": 2, "max_realm": 15,
		"text": "你连续做了三夜的噩梦。第四夜，你在梦里看见一头黑乎乎的野兽，长鼻獠牙，正趴在你的梦境边缘，一口一口，吃着什么。\n\n它吃了很久，抬起头，用一双温和的眼睛看你：“你的噩梦，太苦了。”\n\n“我吃了三天，还没吃完。”",
		"choices": [
			{
				"text": "让它继续吃", "hint": "舍 · 舍一段旧痛", "tone": "neutral",
				"outcomes": [
					{"weight": 60, "text": "它低头又吃了很久。吃到天亮，它打了个饱嗝，化作一缕黑烟散去。你醒来时，枕边是干的。那件困扰你很多年的事，忽然不那么疼了。你不知道该感谢谁。", "effects": {"daoheart": 5, "lifespan": 3, "insight": 3, "luck": 3}},
					{"weight": 40, "text": "吃到一半，它忽然停下，摇头：“吃不下了。这梦里有你舍不得的东西。”它把吃下去的吐出来还给你，转身走了。你醒来时，那件旧事，还在。", "effects": {"insight": 4, "daoheart": 2}}
				]
			},
			{
				"text": "问它：你的噩梦谁来吃", "hint": "情 · 反问", "tone": "neutral",
				"result": "它愣住，长鼻垂下来。“没人吃。”它说，“吃梦的，不做梦。”你伸手摸了摸它的头，毛硬得像针，身体却在发抖。你把手收回来，掌心里沾了一点湿。它说：“三千年了，头一回有人问。”",
				"effects": {"karma": 6, "daoheart": 5, "insight": 4, "luck": 3}
			},
			{
				"text": "把最甜的梦也给它", "hint": "善 · 以甜化苦", "tone": "good",
				"result": "它吃了你的甜梦，眼睛忽然亮起来。“原来梦还有这个味道。”它低头舔了舔，又抬头看你，眼神像个孩子。它临走时，在你手心吐出一颗极小的黑珠。“这个，能让你以后不做噩梦。”",
				"effects": {"karma": 5, "luck": 4, "insight": 3, "treasure": "食梦珠", "lifespan": 2}
			}
		]
	},
	{
		"id": "new2_failed_scholar", "title": "落第书生", "weight": 5.0, "min_realm": 0, "max_realm": 10,
		"text": "破庙里，一个书生对着半卷书发呆。他连考了七年，一次未中。今年又落榜了，盘缠花光了，回不了家。\n\n他看见你，苦笑：“道友也是赶路的？这庙里冷，一起烤烤火吧。”\n\n火堆旁，压着一封家书，封口没拆。",
		"choices": [
			{
				"text": "陪他坐一夜，听他诉苦", "hint": "情 · 听一段凡人", "tone": "good",
				"result": "他说了一夜。说母亲的病，说未婚妻改嫁，说自己其实并不想做官，只是不想让家里失望。天亮时他睡着了，你替他盖了件衣服。那封家书，他终于拆了——信上说，母亲的病，已经好了。",
				"effects": {"karma": 5, "daoheart": 4, "insight": 3, "luck": 2}
			},
			{
				"text": "给他一枚灵石，让他再考", "hint": "需 1 灵石 · 帮一把", "tone": "good", "cost": 1,
				"result": "他捧着灵石，手在抖。“这……这怎么好意思。”你摆摆手。他把家书塞进怀里，说等明年中了，一定回来给你磕头。你走出庙门，回头看见他还在原地，对着灵石发呆，像个孩子。",
				"effects": {"karma": 6, "luck": 4, "daoheart": 2}
			},
			{
				"text": "问他：为什么不放弃", "hint": "问 · 一问", "tone": "neutral",
				"outcomes": [
					{"weight": 60, "text": "他想了很久，说：“我要是放弃了，前面那七年，就白熬了。”你看着他，忽然觉得这句话有点重。临走时你留了一句：“熬着挺好。”他笑了，眼里的火重新亮起来。", "effects": {"daoheart": 4, "insight": 4, "luck": 2}},
					{"weight": 40, "text": "他什么也没说，只是把书卷起来，扔进了火堆。火忽然旺了一下。“你说得对。”他站起身，朝你拱手，走出庙门。你没拦他。多年后你听说，有个落第的书生，做了个不错的账房先生。", "effects": {"insight": 3, "daoheart": 2, "karma": 1}}
				]
			}
		]
	},
	{
		"id": "new2_ice_corpse", "title": "万年冰尸", "weight": 2.0, "min_realm": 11, "max_realm": 17,
		"text": "雪山之巅，冰层里封着一个人。看不清脸，只看得出她穿着一身极旧的衣袍，手里握着一柄断剑，剑尖朝上，像是临死前还想刺穿什么。\n\n冰层外，插着一块木牌，牌上只有两个字：“别放。”\n\n你抬手，掌心的温度，让冰层裂开了一道细纹。",
		"choices": [
			{
				"text": "后退，重新封上冰层", "hint": "慎 · 听劝", "tone": "good",
				"result": "你后退，用灵力把那道细纹重新冻上，比原来还厚。木牌上的字，忽然变了一行：“谢谢。”你站在冰原上，四下无人，只有风。你不知道该不该信，但你选择信。",
				"effects": {"daoheart": 5, "karma": 4, "luck": 3, "insight": 3}
			},
			{
				"text": "打碎冰层，把她放出来", "hint": "险 · 未知因果", "tone": "neutral",
				"outcomes": [
					{"weight": 40, "text": "冰层碎开，她缓缓睁眼。那双眼睛里没有情绪，只有一片极深的疲惫。“……多少年了？”她问。你说不清。她低头看断剑，忽然笑了：“还没刺完。”她把断剑插回雪里，转身走了。", "effects": {"insight": 7, "daoheart": 3, "luck": 2, "karma": -3}},
					{"weight": 60, "text": "冰层碎开的一瞬，一股寒意直冲你识海。你看见一万年前的那场大战——她一个人，对抗一整个天庭。你跪倒在地，浑身结冰。等她出来时，只淡淡看了你一眼：“你不该放我。”她走了，雪山塌了半边。", "effects": {"injury": 32, "daoheart": -3, "insight": 5, "luck": -4}}
				]
			},
			{
				"text": "隔着冰层，把木牌上的话告诉她", "hint": "静 · 一问", "tone": "neutral",
				"result": "你把“别放”那两个字，念给她听。冰里的人忽然动了一下，眼皮在冰层下轻轻颤了颤。你听见一个极远的声音：“……是他写的。”然后，再没有动静。你在冰原上坐到天黑，临走时，把自己的外袍留在了冰层前。",
				"effects": {"insight": 6, "daoheart": 4, "karma": 3, "lifespan": 3}
			}
		]
	},
		{
		"id": "treasure_heart_gu", "title": "噬心蛊", "weight": 8.0, "min_realm": 0, "max_realm": 20,
		"text": "你在一具无主尸骨旁发现一只半透明的虫壳，壳内还残留着微弱的心跳声。靠近时，你的心脏也跟着猛跳了一下。",
		"choices": [
			{
				"text": "收下虫壳", "hint": "险 · 或得奇物", "tone": "neutral",
				"outcomes": [
					{"weight": 55, "text": "虫壳入手后心跳声渐渐消失，只留下一枚冰冷的残壳。你隐隐觉得自己多了一层防护。", "effects": {"treasure": "噬心蛊残壳", "body": 2, "daoheart": -1}},
					{"weight": 45, "text": "虫壳突然碎裂，一股阴寒之气钻入胸口。你强行压下，却已内伤。", "effects": {"injury": 14, "luck": -2}}
				]
			},
			{
				"text": "用真元彻底摧毁", "hint": "正 · 道心", "tone": "good",
				"result": "你一掌拍碎虫壳，阴气消散。原地留下一小撮灰烬，被风吹走。",
				"effects": {"daoheart": 3, "karma": 2}
			},
			{
				"text": "埋回土中，装作没看见", "hint": "稳", "tone": "neutral",
				"result": "你把虫壳连同尸骨一起埋了。转身离开时，远处似乎传来一声极轻的叹息。",
				"effects": {"daoheart": 1}
			}
		]
	},
	{
		"id": "treasure_no_face", "title": "无面人", "weight": 8.0, "min_realm": 0, "max_realm": 20,
		"text": "夜路遇人。对方没有五官，却精准地停下脚步，朝你微微颔首，然后递过来一张空白的面具。",
		"choices": [
			{
				"text": "接过面具", "hint": "玄 · 未知", "tone": "neutral",
				"result": "面具入手温凉。你戴上的瞬间，世界安静了一瞬。摘下面具后，它自动贴回了对方脸上。对方消失前，留下一句话：“有用得上的时候。”",
				"effects": {"treasure": "无面人面具", "insight": 3, "luck": 2}
			},
			{
				"text": "拒绝，后退三步", "hint": "慎 · 道心", "tone": "good",
				"result": "无面人站了片刻，最终收回面具，消失在夜色里。你总觉得自己错过了什么。",
				"effects": {"daoheart": 2, "insight": 1}
			},
			{
				"text": "拔剑相向", "hint": "刚 · 可能结怨", "tone": "evil",
				"result": "剑光落下时，对方已不在原处。你只斩到了一截衣角，上面绣着一个模糊的“债”字。",
				"effects": {"karma": -3, "daoheart": -1, "injury": 6}
			}
		]
	},
	{
		"id": "treasure_jealous_pen", "title": "天妒笔", "weight": 7.0, "min_realm": 0, "max_realm": 20,
		"text": "古玩摊上有一支旧笔，笔杆裂了细纹，却隐隐有灵光流转。摊主说：“这笔写什么成什么，但写得太好，就会遭天妒。”",
		"choices": [
			{
				"text": "买下（需 35 灵石）", "hint": "需 35 灵石 · 机缘与代价", "tone": "neutral", "cost": 35,
				"outcomes": [
					{"weight": 60, "text": "你试着写下一个字，笔锋落处，灵感如泉涌。收笔时，却觉得胸口微闷。", "effects": {"treasure": "天妒笔", "insight": 5, "cult_pct": 6, "luck": -1}},
					{"weight": 40, "text": "刚写下半个字，笔杆突然发热，差点灼伤手指。你被迫停手。", "effects": {"injury": 8, "insight": 2}}
				]
			},
			{
				"text": "只看不买", "hint": "稳", "tone": "neutral",
				"result": "你把笔放回原处。摊主笑了笑，没再劝。",
				"effects": {"insight": 1}
			}
		]
	},
	{
		"id": "treasure_reincarnation_debt", "title": "轮回债契", "weight": 7.0, "min_realm": 0, "max_realm": 20,
		"text": "一本摊开的旧册子自己翻到了某一页。上面用血写着你的名字，后面跟着一行小字：“尚欠一命。”",
		"choices": [
			{
				"text": "撕下那一页", "hint": "险 · 结下因果", "tone": "evil",
				"result": "纸页入手后化作一缕红光钻入眉心。你感到有什么东西被记下了。",
				"effects": {"treasure": "轮回债契", "karma": -6, "cult_pct": 10, "daoheart": -2}
			},
			{
				"text": "用真元灼烧册子", "hint": "正 · 斩因果", "tone": "good",
				"result": "火起时，册子发出尖啸，最终化为灰烬。你吐出一口浊气，觉得轻松了些。",
				"effects": {"karma": 4, "daoheart": 3, "injury": 5}
			},
			{
				"text": "合上册子，转身就走", "hint": "避", "tone": "neutral",
				"result": "你头也不回地离开。走出很远，仍觉得后颈发凉。",
				"effects": {"luck": -1, "daoheart": 1}
			}
		]
	},
	{
		"id": "treasure_one_hate_river", "title": "一恨成河", "weight": 6.5, "min_realm": 0, "max_realm": 20,
		"text": "河边站着一个背对你的人。她说：“我把恨意炼成了这条河。你若敢踏进去，就能分走我三成恨意，也分走对应的力量。”",
		"choices": [
			{
				"text": "踏入河中", "hint": "魔 · 力量与代价", "tone": "evil",
				"outcomes": [
					{"weight": 55, "text": "河水没过胸口时，你感到无尽的恨意涌入。走出来时，掌心多了一缕凝固的黑色水流。", "effects": {"treasure": "一恨成河", "cult_pct": 16, "body": 3, "daoheart": -4, "karma": -5}},
					{"weight": 45, "text": "恨意太重，你差点被冲走。勉强上岸后，内息大乱。", "effects": {"injury": 20, "daoheart": -2, "luck": -2}}
				]
			},
			{
				"text": "劝她放下", "hint": "善 · 或有转机", "tone": "good",
				"result": "她沉默很久，最终只是摇头。河水却似乎浅了一寸。你离开时，袖中多了一枚温润的石子。",
				"effects": {"treasure": "一念花", "karma": 5, "daoheart": 4, "insight": 2}
			},
			{
				"text": "不语，绕道而行", "hint": "静", "tone": "neutral",
				"result": "你没有回头。河水的声音在身后越来越远。",
				"effects": {"daoheart": 2}
			}
		]
	},
	{
		"id": "treasure_old_god_eye", "title": "旧神残瞳", "weight": 6.0, "min_realm": 0, "max_realm": 20,
		"text": "山洞深处，一颗独眼悬浮在半空，缓缓转动。它看见了你，瞳孔微微收缩，却没有攻击。",
		"choices": [
			{
				"text": "伸手触碰", "hint": "极险 · 大机缘", "tone": "neutral",
				"outcomes": [
					{"weight": 50, "text": "指尖触到的瞬间，无数不属于这个世界的画面涌入识海。你强行切断联系，手中已多了一枚冰冷的瞳仁。", "effects": {"treasure": "旧神残瞳", "insight": 8, "cult_pct": 12, "injury": 10, "daoheart": -2}},
					{"weight": 50, "text": "你被一股庞大意志压得跪倒在地，吐血后退。那只眼睛重新闭上，再无动静。", "effects": {"injury": 22, "daoheart": 1, "insight": 3}}
				]
			},
			{
				"text": "跪拜后离开", "hint": "敬 · 道心", "tone": "good",
				"result": "你恭敬行礼，退出山洞。走出很远，仍觉得有一道目光落在后背，却并不恶意。",
				"effects": {"daoheart": 4, "luck": 3, "insight": 2}
			},
			{
				"text": "直接毁掉它", "hint": "刚 · 可能反噬", "tone": "evil",
				"result": "你全力一击。眼睛碎裂的瞬间，一股狂暴力量炸开，你被掀出山洞，浑身是血。",
				"effects": {"injury": 30, "karma": -4, "body": 2}
			}
		]
	},
	{
		"id": "spirit_root_awakening", "title": "灵根蜕变", "weight": 2.0, "min_realm": 0, "max_realm": 20,
		"text": "你在一处坍塌的古修洞府中发现一座残缺的洗灵池。池底铭文早已模糊，唯有‘返本归元，重塑灵台’八字仍可辨认。池水中浮现出与你灵根相应的光影，仿佛在等待你的抉择。",
		"choices": [
			{"text":"引池水洗炼灵台", "hint":"洗去一重杂属性", "tone":"good", "result":"你以自身精血引动洗灵池。剧痛过后，灵根里有一股驳杂之气被硬生生洗掉。", "effects":{"root_grade_up":1, "injury":5}},
			{"text":"借古阵重塑灵根属性", "hint":"强行凝成天灵根", "tone":"neutral", "result":"你将灵力注入古阵，驳杂的灵根光影轰然破碎，最后只凝成单一属性。", "effects":{"root_type":"天灵根", "injury":12, "insight":2}},
			{"text":"收起铭文，暂不触碰", "hint":"谨慎 · 悟性 +2", "tone":"neutral", "result":"你记下池底残文，没有贸然使用洗灵池。机缘未必只此一次，活着才有以后。", "effects":{"insight":2, "daoheart":1}}
		]
	},
]      

static func build_followup(source_event: Dictionary, source_result: String, source_effects: Dictionary, state: Object = null) -> Dictionary:
	var source_id := String(source_event.get("id", "unknown"))
	var profile := get_npc_profile(source_event)
	var npc_name := String(profile.get("name", "旧日相逢之人"))
	var source_title := String(source_event.get("title", "旧日机缘"))
	var karma_delta := int(source_effects.get("karma", 0))
	var story := "这次机缘带来的见闻暂时告一段落。数日后，你在整理所得时，发现其中还有一处值得留意的细节。"
	match source_id:
		"moon_fox":
			story = "数日后的月夜，一缕熟悉的月华落在你的窗前。白狐留下的气息化作一枚银色狐印，林中传来少女阿九的呼唤。她似乎遇到了麻烦。"
		"broken_sword":
			story = "你手中的断剑忽然轻鸣。剑纹石上的纹路自行亮起，指向东境荒野深处。一名背负木剑的老者拦住你：“你也听见那座剑冢在呼唤了？”"
		"plague_village":
			story = "你再次经过那座村庄。村口新立了一块石碑，碑上刻着你的恩怨因果。一个自称药师的年轻人追上来，说村中还有一味药引未曾找到。"
		"river_god":
			story = "河面再起异象。获救村民送来一枚青色鳞片，称夜里总有蛟影盘踞河心。那场河神风波，似乎还没有真正结束。"
		"ghost_market":
			story = "子时将近，你袖中的旧物忽然发冷。一张没有署名的鬼市请柬滑落出来，背面写着：“上次的交易，还欠最后一笔。”"
		"demon_teach":
			story = "你发现沿途数座村镇出现相同的黑色印记。一个受伤的巡夜修士认出了你：“那邪修的同党正在寻你，他留下的功法也许藏着追踪印记。”"
		"cave_estate":
			story = "洞府中带出的古物在夜里自行发光，映出一幅新的地底地图。地图尽头有一扇此前从未显现的石门，门后传来叩击声。"
		"spirit_beast":
			story = "你曾遇见的幼兽在远处山脊留下灵息。循迹而去，一只受伤的成年灵兽挡在洞口，身后似乎藏着幼兽的族群。"
		"old_beggar":
			story = "那枚旧铜钱在夜里微微发烫。你循着钱面浮现的古篆来到一座荒废道观，门内有人轻声问：“当日那半块干粮，你可还记得？”"
		"sect_gate":
			story = "当日仙门留下的信物忽然亮起。一名外门执事御剑而来，递给你一封补试文书：山门试炼尚有最后一关。"
		"furnace_crisis":
			story = "你曾见过的丹炉纹路再次浮现于眼前。附近坊市传出消息，有人正在收购同一炉火炼出的丹药，似乎想重现那场炉变。"
		_:
			pass

	story += "\n\n" + npc_name + "仍记得你们此前的相逢，这段因果尚未真正了结。"
	var first_text := "追查来龙去脉"
	var first_hint := "探明真相 · 悟性与气运"
	var first_result := "你没有急着离开，而是沿着线索追查。层层迷雾散去，你终于看清这段因果背后的真相，也从中得到新的感悟。"
	var special_rewards: Dictionary = {}
	match source_id:
		"moon_fox":
			special_rewards = {"treasure": "月魄护心铃", "learn_skill": "wind_step"}
		"broken_sword":
			special_rewards = {"treasure": "断岳残锋", "learn_skill": "shadow_blade"}
		"river_god":
			special_rewards = {"treasure": "归潮蛟珠", "learn_skill": "azure_dragon"}
		"ghost_market":
			special_rewards = {"treasure": "幽市照魂镜", "learn_skill": "soul_lance"}
		"demon_teach":
			special_rewards = {"treasure": "血月蚀心刃", "learn_skill": "blood_siphon"}
		"cave_estate":
			special_rewards = {"treasure": "星门道袍", "learn_skill": "void_guard"}
		"spirit_beast":
			special_rewards = {"treasure": "灵犀兽环", "learn_skill": "mirror_body"}
		"furnace_crisis":
			special_rewards = {"treasure": "九转丹炉印", "learn_skill": "five_elements"}
	if karma_delta < 0:
		first_result = "你顺着线索找到当日因果的另一端。对方早有防备，一番周旋后你虽未能全身而退，却夺回了主动。"
	var first_effects: Dictionary = {"insight": 3, "luck": 2, "cult_pct": 3, "world_event": "修士间开始流传「%s」后续因果的传闻。" % source_title}
	for reward_key: Variant in special_rewards.keys():
		first_effects[String(reward_key)] = special_rewards[reward_key]
	var followup := {
		"id": "linked_" + source_id,
		"title": source_title + "·因果续篇",
		"weight": 100.0,
		"min_realm": 0,
		"max_realm": 99,
		"text": story,
		"choices": [
			{
				"text": first_text,
				"hint": first_hint,
				"tone": "neutral",
				"result": first_result,
				"effects": first_effects
			},
			{
				"text": "出手化解眼前麻烦",
				"hint": "善 · 结善缘，稳固道心",
				"tone": "good",
				"result": "你没有计较个人得失，先替眼前之人解决了难处。对方郑重道谢，并将一份谢礼交到你手中。这段因果至此有了温暖的落点。",
				"effects": {"karma": 4, "daoheart": 2, "stones": 12, "lifespan": 1}
			},
			{
				"text": "趁乱取走有价值之物",
				"hint": "利 · 得财，损耗因果",
				"tone": "evil",
				"result": "你趁众人无暇顾及时取走了最有价值的东西。灵石落袋，身后却传来一声叹息。旧因未了，又添新债。",
				"effects": {"karma": -3, "stones": 32, "daoheart": -1, "luck": 1}
			},
			{
				"text": "再次相逢，邀其结伴同行",
				"hint": "交心 · 好感足够时可成为伙伴",
				"tone": "good",
				"result": npc_name + "记起你此前的选择。你坦诚相邀，对方思索良久，决定以后的路同行一段。",
				"effects": {"karma": 2, "npc_recruit": source_id}
			}
		]
	}
	var remembered_affinity := 0
	var remembered_choice := ""
	var already_companion := false
	if state != null and state.get("met_npcs") is Array:
		for remembered_npc: Dictionary in state.get("met_npcs"):
			if String(remembered_npc.get("event_id", "")) == source_id:
				remembered_affinity = int(remembered_npc.get("affinity", 0))
				remembered_choice = String(remembered_npc.get("last_choice", ""))
				already_companion = bool(remembered_npc.get("companion", false))
				break
	var remembered_kind := "neutral"
	if remembered_affinity >= 5:
		remembered_kind = "trusted"
	elif remembered_affinity <= -5:
		remembered_kind = "hostile"
	match source_id:
		"old_beggar":
			if remembered_kind == "trusted":
				followup["text"] = "荒废道观的门缓缓打开。陆玄机仍是当年那副破旧灰袍，却将一盏温酒推到你面前：“肯把半块干粮分给陌生人的人，至少还记得自己曾是凡人。”他愿替你解开铜钱中的一道古篆。"
				followup["choices"][0] = {"text":"请陆玄机指点铜钱古篆","hint":"师者点拨 · 悟性与修为","tone":"good","result":"陆玄机以指代笔，在虚空写下三道古篆。你识海轰鸣，终于看懂铜钱中封存的残缺道诀。","effects":{"insight":6,"cult_pct":8,"daoheart":2,"learn_skill":"wind_step"}}
				followup["choices"][1] = {"text":"请教他世间修行之道","hint":"不求捷径 · 稳固道心","tone":"neutral","result":"陆玄机没有传你功法，只讲了一个凡人挑水百年的故事。你听完后，心境反而开阔许多。","effects":{"insight":4,"daoheart":4,"luck":1}}
				followup["choices"][2] = {"text":"向他请一枚护身符","hint":"旧日善缘 · 得到护佑","tone":"good","result":"陆玄机笑着取下葫芦上的铜钱，化作一道护身符赠你。","effects":{"karma":3,"luck":4,"treasure":"玄机护身钱"}}
			elif remembered_kind == "hostile":
				followup["text"] = "道观门内没有灯火，只有陆玄机的声音从神像后传来：“当日你夺走葫芦时，可曾想过里面装的是什么？”墙上那道多出来的影子再次抬头，竟与陆玄机的身形一模一样。"
				followup["choices"][0] = {"text":"归还旧物，赔礼道歉","hint":"偿还旧债 · 化解心魔","tone":"good","result":"你将当年夺走的东西与赔礼放在供桌上。陆玄机收回影子，旧日阴翳散去大半。","effects":{"karma":5,"daoheart":3,"luck":2}}
				followup["choices"][1] = {"text":"追问葫芦与影子的秘密","hint":"直面因果 · 探查真相","tone":"neutral","result":"陆玄机告诉你，葫芦收着的并非酒，而是被你亲手种下的一缕恶念。你终于明白影子为何不再听从自己。","effects":{"insight":5,"daoheart":-1,"cult_pct":5}}
				followup["choices"][2] = {"text":"强行闯入道观","hint":"恶 · 再结一段恶因","tone":"evil","result":"你刚踏入门槛，整座道观便化作镜中倒影。陆玄机没有出手，你却在自己的影子里看见了当日的自己。","effects":{"karma":-4,"daoheart":-3,"injury":5}}
			else:
				followup["text"] = "道观门内传来熟悉的咳嗽声。陆玄机隔门问你：“当日你选择不惹因果，如今还愿不愿意听一个故事？”门缝里递出半枚刻着古篆的铜钱。"
				followup["choices"][0]["text"] = "接过铜钱，听他讲完旧事"
				followup["choices"][0]["result"] = "陆玄机讲起一段无人知晓的旧事。你虽未得传承，却从他的只言片语中窥见一线大道。"
				followup["choices"][0]["effects"] = {"insight":4,"daoheart":2,"luck":2}
				followup["choices"][2]["text"] = "请他留下日后再见的信物"
				followup["choices"][2]["result"] = "陆玄机将半枚铜钱交给你：“待你想明白何为因果，再来寻我。”"
				followup["choices"][2]["effects"] = {"treasure":"半枚长生钱","luck":2}
		"moon_fox":
			if remembered_kind == "trusted":
				followup["text"] = "月色落在林间，阿九从树影中走出。她认出你后，眼中的戒备化作笑意：“那日若不是你，我恐怕已死在兽夹下。族中长辈愿见你一面。”远处传来数声狐鸣，像是在迎接故友。"
				followup["choices"][0] = {"text":"随阿九拜访白狐族地","hint":"善缘延续 · 结识妖族","tone":"good","result":"白狐族长以月华洗礼答谢你。阿九亲手将一枚狐族信物系在你腕间。","effects":{"karma":5,"luck":4,"treasure":"白狐族信","daoheart":2}}
				followup["choices"][1] = {"text":"帮助阿九寻找失踪的族人","hint":"并肩冒险 · 妖族委托","tone":"good","result":"你与阿九循着血迹找到被困族人。她将一缕本命月华赠你，以作谢礼。","effects":{"karma":4,"insight":3,"cult_pct":6,"treasure":"本命月华"}}
				followup["choices"][2] = {"text":"邀请阿九同行","hint":"旧恩未忘 · 可结为伙伴","tone":"good","result":"阿九认真思量后点头：“若你不嫌我妖族身份，这段路我愿陪你走。”","effects":{"karma":2,"npc_recruit":source_id}}
			elif remembered_kind == "hostile":
				followup["text"] = "林中狐火骤然亮起。阿九站在兽夹旁，后腿旧伤仍未痊愈。她没有靠近，只冷冷问道：“那日你剥下我的皮时，可曾想过我也有名字？”数道狐影已封住退路。"
				followup["choices"][0] = {"text":"放下兵刃，向阿九赔罪","hint":"赎罪 · 尝试修补裂痕","tone":"good","result":"你放下兵刃并交出当日所得。阿九没有原谅你，只允许你离开，仇怨暂时搁置。","effects":{"karma":5,"daoheart":2,"stones":-12}}
				followup["choices"][1] = {"text":"解释当日苦衷，提出补偿","hint":"以诚相待 · 化解敌意","tone":"neutral","result":"阿九听完你的解释，收下补偿，却仍与你保持距离。她说，信任需要时间偿还。","effects":{"karma":2,"luck":1,"stones":-8}}
				followup["choices"][2] = {"text":"迎战狐族追兵","hint":"恶 · 与白狐一族结仇","tone":"evil","result":"狐火照亮山林。你虽杀出重围，却彻底得罪了白狐一族。","effects":{"karma":-5,"injury":8,"daoheart":-2}}
			else:
				followup["text"] = "山林深处传来一声狐鸣。阿九没有现身，只在树枝上留下一枚银色狐印。你若愿意循着月华前行，或许还能知道她后来去了何处。"
				followup["choices"][0]["text"] = "循着狐印寻找阿九"
				followup["choices"][0]["result"] = "你在月潭边再次见到阿九。她虽仍有戒心，却愿与你交换一段关于妖族的见闻。"
				followup["choices"][0]["effects"] = {"insight":3,"luck":2,"treasure":"银色狐印"}
				followup["choices"][1]["text"] = "将狐印放回林中"
				followup["choices"][1]["result"] = "你没有打扰她的生活，只将狐印放回月潭边。林间月华流转，你的心境也平静下来。"
				followup["choices"][1]["effects"] = {"daoheart":3,"luck":1}
				followup["choices"][2]["text"] = "在附近留下疗伤灵药"
				followup["choices"][2]["result"] = "你将灵药留在树下便转身离去。翌日，原地多了一枚温热的狐毛。"
				followup["choices"][2]["effects"] = {"karma":2,"treasure":"白狐灵毛"}
		"plague_village":
			if remembered_kind == "trusted":
				followup["text"] = "村口新立的石碑上刻着你的名字。沈青禾如今已学会行医，村民称她为青禾医师。她将一封染着药香的信交给你：“当年你救下的人，如今也能救别人了。只是山中又出现了相似的疫症。”"
				followup["choices"][0] = {"text":"与沈青禾查明疫症源头","hint":"追查病因 · 医道机缘","tone":"neutral","result":"你与沈青禾深入疫源之地，发现并非天灾，而是地下灵脉中滋生的瘴毒。你们合力封住毒脉。","effects":{"insight":5,"karma":4,"daoheart":3,"treasure":"青禾药囊"}}
				followup["choices"][1] = {"text":"留下丹方，教村民自救","hint":"广施善行 · 改变村庄命运","tone":"good","result":"你将辨毒与炼药之法留给村民。沈青禾接过丹方，承诺会让村中再不因无药而死人。","effects":{"karma":6,"daoheart":4,"lifespan":2}}
				followup["choices"][2] = {"text":"邀请沈青禾同行游历","hint":"共历生死 · 可结为伙伴","tone":"good","result":"沈青禾安顿好村中事务后，决定与你同行，以医术助你闯荡修仙界。","effects":{"karma":2,"npc_recruit":source_id}}
			elif remembered_kind == "hostile":
				followup["text"] = "村庄已成焦土，残碑旁却有人搭起一间草屋。沈青禾从灰烬中走出，手里攥着一张烧焦的药方。她看着你：“你当年说一把火能杜绝后患，可活下来的人，这些年一直在找你。”"
				followup["choices"][0] = {"text":"承认过错，帮助幸存者重建","hint":"赎罪 · 承担旧日后果","tone":"good","result":"你拿出灵石与药材，协助幸存者重建村落。沈青禾没有说原谅，只将药方交给你，要求你记住今日。","effects":{"karma":7,"daoheart":3,"stones":-20}}
				followup["choices"][1] = {"text":"解释当日决定，听取幸存者证词","hint":"面对因果 · 查清当年真相","tone":"neutral","result":"幸存者讲述了火灾后逃出的经历。你终于知道，当年仍有人活着，而你的决定让他们失去了家园。","effects":{"insight":4,"daoheart":-1,"karma":1}}
				followup["choices"][2] = {"text":"拒绝承担责任，转身离开","hint":"恶 · 恩怨继续","tone":"evil","result":"沈青禾没有追赶，只将你的名字刻在残碑背面。此后南境修士都知道你与疫村的旧怨。","effects":{"karma":-5,"luck":-2}}
		_:
			pass
	if already_companion and source_id == "moon_fox" and followup["choices"].size() >= 3:
		followup["choices"][2]["text"] = "与阿九并肩处理此事"
		followup["choices"][2]["hint"] = "伙伴羁绊 · 加深月灵狐的信任"
	return followup



# 重要人物档案：让奇遇中的关键人物拥有可识别、可追溯的身份。
const NPC_PROFILES := {
	"old_beggar": {"name":"陆玄机","identity":"隐世散修","realm":"深不可测","faction":"来历不明","appearance":"灰袍破旧，腰悬缺口葫芦"},
	"moon_fox": {"name":"阿九","identity":"月灵狐一族的化形妖修","realm":"金丹境","faction":"北荒·白狐一族","appearance":"月白衣裙，眼瞳映着淡淡银辉，腕间系着一缕旧狐毛"},
	"plague_village": {"name":"沈青禾","identity":"疫村村长之女","realm":"凡人","faction":"南境·柳家村","appearance":"青布衣衫，眉间有倦色"},
	"broken_sword": {"name":"顾长陵","identity":"无名剑修（已故）","realm":"生前疑似金丹","faction":"不详","appearance":"坟前断剑刻着一个悔字"},
	"ghost_market": {"name":"闻九灯","identity":"鬼市摊主","realm":"金丹境","faction":"幽都鬼市","appearance":"黑袍蒙面，袖口缀着青灯纹"},
	"cliff_sword": {"name":"谢无咎","identity":"游历剑修","realm":"元婴境","faction":"散修","appearance":"白衣胜雪，剑意沉静"},
	"demon_teach": {"name":"厉孤鸿","identity":"旁门邪修","realm":"筑基境","faction":"黑风岭","appearance":"左颊有刀疤，腰间挂着骨铃"},
	"river_god": {"name":"柳含烟","identity":"河神新娘","realm":"凡人","faction":"临河镇","appearance":"红衣湿透，手腕系着褪色红绳"},
	"sect_gate": {"name":"周执事","identity":"青岚剑宗外门执事","realm":"筑基境","faction":"青岚剑宗","appearance":"青衫佩剑，手持招徒名册"},
	"mortal_lamplight": {"name":"许婆婆","identity":"守灯老人","realm":"凡人","faction":"东境·白石村","appearance":"白发挽髻，提一盏旧纸灯"},
	"blood_moon": {"name":"赤面屠夫","identity":"血月功传人","realm":"金丹境","faction":"血煞门","appearance":"面色赤红，掌心有暗色血纹"},
	"familiar_stranger": {"name":"温如故","identity":"云游医师","realm":"筑基境","faction":"散修","appearance":"药箱磨损，衣角沾着药香"},
	"moon_well": {"name":"阿绫","identity":"井边少女","realm":"凡人","faction":"青石镇","appearance":"月白衣裙，手里握着一枚铜钱"},
	"old_debt": {"name":"秦铁算盘","identity":"追债修士","realm":"筑基境","faction":"万宝商会","appearance":"指间转着一枚铁算盘珠"},
	"ghost_house": {"name":"苏绣娘","identity":"荒宅旧主","realm":"凡人（已故）","faction":"旧城苏宅","appearance":"红衣绣鞋，袖口绣着并蒂莲"},
	"furnace_crisis": {"name":"韩百炼","identity":"丹师","realm":"金丹境","faction":"百草谷","appearance":"袖口焦黑，眉毛被火燎去半截"},
	"leaf_crossing": {"name":"摆渡人老陈","identity":"江上船夫","realm":"凡人","faction":"南境·乌篷渡","appearance":"蓑衣斗笠，船桨磨得发亮"},
	"mortal_king": {"name":"虞承曜","identity":"大虞皇帝","realm":"凡人帝王","faction":"大虞皇朝","appearance":"玄色龙袍，鬓边已有白发"},
	"butterfly_dream": {"name":"庄生","identity":"落魄说书人","realm":"凡人","faction":"不详","appearance":"青衫旧扇，谈吐恍惚"},
	"past_enemy": {"name":"裴照","identity":"前世仇敌","realm":"与玩家境界相近","faction":"不详","appearance":"眉心有旧剑痕，目光冷厉"},
	"dying_immortal": {"name":"白云子","identity":"垂死仙人","realm":"境界不详","faction":"上古遗脉","appearance":"白发如雪，仙衣染血"},
	"epic_bloody_scholar": {"name":"陆停舟","identity":"追杀中的落魄书生","realm":"金丹境","faction":"散修","appearance":"书箱染血，仍紧攥半卷古书"},
	"epic_demon_saintess": {"name":"殷红绡","identity":"魔宗圣女","realm":"元婴境","faction":"九幽魔宗","appearance":"黑纱覆面，眉心一点朱砂"},
	"epic_ancient_sword_cave": {"name":"独孤断","identity":"守洞剑灵","realm":"化神境残魂","faction":"古剑洞府","appearance":"半透明身影，身后悬着七柄残剑"},
	"epic_black_market": {"name":"钱万通","identity":"地下拍卖主持","realm":"金丹境","faction":"黑市","appearance":"圆脸细眼，袖中算盘声不断"},
	"epic_mysterious_elder": {"name":"木道人","identity":"古树隐修","realm":"化神境","faction":"青木山","appearance":"须发皆白，衣上落满青叶"},
	"new_painted_skin": {"name":"画皮娘子","identity":"易容妖修","realm":"金丹境","faction":"不详","appearance":"容貌艳丽，颈侧有细密缝线"},
	"new_ferryman": {"name":"孟老七","identity":"忘川摆渡人","realm":"境界不详","faction":"忘川","appearance":"黑篷小舟，腰间挂着三枚铜铃"},
	"new_fate_pavilion": {"name":"闻天机","identity":"天机阁执事","realm":"元婴境","faction":"天机阁","appearance":"手持星盘，眼覆薄纱"},
	"new_dragon_palace": {"name":"敖青","identity":"龙宫三太子","realm":"元婴境","faction":"归墟龙宫","appearance":"青鳞化作人形，额生短角"},
	"new_peach_grove": {"name":"桃夭","identity":"桃林守灵","realm":"金丹境","faction":"南境桃源","appearance":"粉衣少女，发间别着桃花"},
	"new_puppet_troupe": {"name":"班主莫三","identity":"傀儡戏班班主","realm":"筑基境","faction":"流动戏班","appearance":"十指缠线，身后背着木偶箱"},
	"new_monk_passing": {"name":"无尘","identity":"行脚僧","realm":"金丹境","faction":"枯荣禅院","appearance":"旧僧衣洗得发白，手持木鱼"},
	"new_red_thread": {"name":"月老童子","identity":"红线司引路人","realm":"境界不详","faction":"天外姻缘司","appearance":"红绳缠腕，笑容稚气"},
	"new2_withered_temple": {"name":"枯荣禅师","identity":"禅院住持","realm":"元婴境","faction":"枯荣禅院","appearance":"一半白眉，一半枯黄"},
	"new2_dream_seller": {"name":"周梦生","identity":"卖梦人","realm":"金丹境","faction":"梦市","appearance":"眼下青黑，背着装梦的琉璃瓶"},
	"new2_old_general": {"name":"霍镇山","identity":"镇北老将军（已故）","realm":"生前金丹境","faction":"大虞皇朝","appearance":"残甲覆身，手握断枪"},
	"new2_thunder_clerk": {"name":"雷简","identity":"雷部巡察小吏","realm":"化神境","faction":"天庭雷部","appearance":"银甲执册，眉心有雷纹"},
	"new2_embroidery": {"name":"沈绣","identity":"绣娘","realm":"凡人","faction":"江南水乡","appearance":"指尖有针痕，绣绷从不离手"},
	"new2_failed_tribulation": {"name":"玄烬","identity":"渡劫失败者","realm":"大乘境残躯","faction":"散修","appearance":"焦黑道袍，周身残留雷火"},
	"new2_failed_scholar": {"name":"顾砚","identity":"落第书生","realm":"凡人","faction":"中州·天京","appearance":"青衫洗旧，怀中抱着一卷策论"},
	"treasure_no_face": {"name":"无面客","identity":"无面人","realm":"境界不详","faction":"不详","appearance":"面上没有五官，声音像隔着水传来"},
	"treasure_reincarnation_debt": {"name":"契纸婆婆","identity":"轮回债契见证人","realm":"境界不详","faction":"轮回渡","appearance":"背着旧木匣，指甲染朱砂"},
	"treasure_old_god_eye": {"name":"瞽叟","identity":"守瞳老人","realm":"境界不详","faction":"上古遗迹","appearance":"双目蒙布，掌心托着一枚古怪眼瞳"}
}

static func get_npc_profile(event: Dictionary) -> Dictionary:
	var event_id := String(event.get("id", ""))
	var profile_id := event_id.trim_prefix("linked_")
	var profile: Dictionary
	if NPC_PROFILES.has(profile_id):
		profile = NPC_PROFILES[profile_id].duplicate(true)
	else:
		profile = {
			"name": String(event.get("title", "旧日机缘")) + "中的故人",
			"identity": "与此事结下因果之人",
			"realm": "境界不详",
			"faction": "来历不明",
			"appearance": "此人的真实身份，仍待后续相逢揭晓"
		}
	profile["event_id"] = profile_id
	profile["event_title"] = String(event.get("title", "奇遇"))
	return profile

const CHAIN_EVENT_IDS := [
	"old_beggar", "moon_fox", "plague_village", "broken_sword",
	"ghost_market", "demon_teach", "river_god", "cave_estate",
	"spirit_beast", "sect_gate", "furnace_crisis"
]

const REGIONAL_EVENT_RULES := {
	# 东境：剑修遗迹、宗门山门与早期修士际遇
	"broken_sword": ["东境·青岚山"],
	"ancient_sword_grave": ["东境·青岚山"],
	"cliff_sword": ["东境·青岚山"],
	"sect_gate": ["东境·青岚山"],
	"sword_tomb": ["东境·青岚山"],
	"mortal_lamplight": ["东境·青岚山"],
	# 中州：皇朝、王侯、天机与坊市
	"mortal_king": ["中州·天京"],
	"new_fate_pavilion": ["中州·天京", "西境·天机城"],
	"new2_failed_scholar": ["中州·天京"],
	"new2_old_general": ["中州·天京"],
	"epic_black_market": ["中州·天京", "西境·天机城"],
	# 南境：药谷、疫病、灵泉与山野旧约
	"plague_village": ["南境·药王岭"],
	"furnace_crisis": ["南境·药王岭"],
	"mountain_spring": ["南境·药王岭"],
	"new_peach_grove": ["南境·药王岭"],
	"new_monk_passing": ["南境·药王岭", "东境·青岚山"],
	# 西境：机关、阵法、碑刻与天机遗迹
	"new_blank_stele": ["西境·天机城"],
	"new2_thunder_clerk": ["西境·天机城", "北境·葬魂渊"],
	# 北荒：妖族、兽潮与灵兽
	"moon_fox": ["东境·青岚山", "北荒·万妖原"],
	"spirit_beast": ["北荒·万妖原"],
	"new2_dream_tapir": ["北荒·万妖原"],
	# 北境：魔修、古战场、阴魂与寒地
	"demon_teach": ["北境·葬魂渊"],
	"blood_moon": ["北境·葬魂渊"],
	"new_blood_sea": ["北境·葬魂渊"],
	"new2_ice_corpse": ["北境·葬魂渊"],
	"new_ferryman": ["北境·葬魂渊"],
	# 海外：水府、龙宫与海上异闻
	"river_god": ["海外·归墟海"],
	"new_dragon_palace": ["海外·归墟海"],
	"cave_estate": ["东境·青岚山", "南境·药王岭", "海外·归墟海"]
}

static func has_followup(event: Dictionary) -> bool:
	var event_id := String(event.get("id", "")).trim_prefix("linked_")
	return CHAIN_EVENT_IDS.has(event_id)

static func event_metadata(event: Dictionary) -> Dictionary:
	var event_id := String(event.get("id", ""))
	var base_id := event_id.trim_prefix("linked_")
	var groups := {
		"人物": [
			"old_beggar", "plague_village", "cliff_sword", "demon_teach",
			"river_god", "familiar_stranger", "ghost_house",
			"leaf_crossing", "butterfly_dream",
			"dying_immortal", "epic_bloody_scholar", "epic_demon_saintess",
			"epic_mysterious_elder", "new_painted_skin", "new_ferryman",
			"new_puppet_troupe", "new_monk_passing",
			"new2_dream_seller", "new2_old_general",
			"new2_embroidery", "new2_failed_scholar", "treasure_no_face"
		],
		"妖兽": [
			"moon_fox", "spirit_beast", "new_dragon_palace",
			"new2_dream_tapir"
		],
		"势力": [
			"sect_gate", "epic_black_market", "new_fate_pavilion",
			"new2_thunder_clerk", "mortal_king"
		],
		"修行": [
			"heart_demon", "spirit_rain", "blood_moon", "thunder_pool",
			"moon_well", "furnace_crisis", "mountain_spring", "heaven_gate",
			"mirror_heart", "new2_failed_tribulation", "spirit_root_awakening"
		],
		"因果": [
			"old_debt", "past_enemy", "new_peach_grove", "new_red_thread",
			"treasure_reincarnation_debt"
		]
	}
	var category := "探索"
	if event_id.begins_with("linked_"):
		category = "因果"
	else:
		for group_name: String in groups:
			if Array(groups[group_name]).has(base_id):
				category = group_name
				break
	var rarity := "普通"
	if event_id.begins_with("linked_"):
		rarity = "后续"
	elif event_id.begins_with("epic_"):
		rarity = "史诗"
	elif event_id.begins_with("treasure_"):
		rarity = "传说"
	elif event_id.begins_with("new_") or event_id.begins_with("new2_") or base_id in ["ancient_sword_grave", "sword_tomb", "star_fall", "dying_immortal"]:
		rarity = "稀有"
	var allowed_regions: Array = REGIONAL_EVENT_RULES.get(base_id, [])
	var region_hint := "九州各地"
	if not allowed_regions.is_empty():
		var region_labels: PackedStringArray = []
		for region_name: String in allowed_regions:
			region_labels.append(region_name)
		region_hint = "、".join(region_labels)
	return {
		"category": category,
		"rarity": rarity,
		"region_hint": region_hint,
		"has_followup": has_followup(event)
	}

static func prepare_event(event: Dictionary) -> Dictionary:
	var prepared := event.duplicate(true)
	var metadata := event_metadata(prepared)
	for key: String in metadata:
		prepared[key] = metadata[key]
	return prepared

static func pick_event(state: Object, rng: RandomNumberGenerator) -> Dictionary:
	var pending_events: Array = Array(state.flags.get("pending_adventure_events", [])).duplicate(true)
	if pending_events.is_empty():
		var legacy_pending: Variant = state.flags.get("pending_adventure_event", {})
		if legacy_pending is Dictionary and not legacy_pending.is_empty():
			pending_events.append(legacy_pending.duplicate(true))
	if not pending_events.is_empty():
		var pending_event: Variant = pending_events.pop_front()
		state.flags["pending_adventure_events"] = pending_events
		state.flags.erase("pending_adventure_event")
		if pending_event is Dictionary and pending_event.get("choices", []) is Array and not pending_event.get("choices", []).is_empty():
			return prepare_event(pending_event)
	var pool: Array = []
	for event: Dictionary in EVENTS:
		if int(event["min_realm"]) > state.realm or int(event["max_realm"]) < state.realm:
			continue
		var event_id := String(event.get("id", ""))
		var allowed_regions: Array = REGIONAL_EVENT_RULES.get(event_id, [])
		if not allowed_regions.is_empty() and not allowed_regions.has(String(state.current_region)):
			continue
		if state.seen_events.has(event_id):
			continue
		var choices: Variant = event.get("choices", [])
		if not choices is Array or choices.is_empty():
			continue
		pool.append(event)
	# 没有带选项的正式奇遇时，不显示只有文字的弹窗。
	if pool.is_empty():
		return {}
	return prepare_event(GameData.weighted_pick(pool, rng))
