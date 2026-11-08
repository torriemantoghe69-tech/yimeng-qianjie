# 一梦千劫

《一梦千劫》是一款持续迭代的文字修仙轮回 RPG。玩家从凡尘起步，经历修炼、机缘、宗门、伙伴、灵宠、战斗、炼丹、炼器与轮回传承，最终走向飞升或另一条因果之路。

## 目前已整合的核心系统

- **世界推进**：`WorldSimulation` 统一推进年份、势力冲突、同代修士成长与世界事件。
- **NPC 与伙伴**：重要人物有统一关系档案；好感、仇恨、招募与个人剧情共享同一份数据。
- **伙伴协战**：`PartyCombatSystem` 统一调度伙伴轮换出手与灵宠协战，人物本命战技按档案独立定义。
- **材料经济**：新增 `MaterialEconomySystem`，将材料按灵材、兽元、器纹、魂煞、沧海分组，可炼化为精华，也可直接消耗换取成长收益。
- **材料来源指南**：新增 `MaterialSourceGuide`，把材料的常见掉落场景、主要用途与分类提示统一起来，并进一步补上了区域掉落、秘境掉落与战后掉落的提示入口，后续可直接接到掉落提示、图鉴与任务奖励。
- **炼丹与炼器**：材料可直接用于既有丹方与器方；炼化出的精华还能作为更高层的资源。
- **天下探索**：区域、妖兽、特产、掉落与世界事件互相联动。
- **轮回传承**：一世终结后结算轮回点，传承影响下一世的起点与成长。

## 主要脚本

```text
project.godot
scenes/main.tscn
scripts/main.gd
scripts/game_state.gd
scripts/world_simulation.gd
scripts/npc_relationship_system.gd
scripts/party_combat_system.gd
scripts/material_economy_system.gd
scripts/material_source_guide.gd
scripts/battle_system.gd
scripts/game_data.gd
scripts/event_data.gd
scripts/ink_background.gd
scripts/music_manager.gd
tools/smoke_test.gd
```

## 材料与精华

材料分为五个大类：灵材、兽元、器纹、魂煞、沧海。

- 探索、战斗与灵宠采集会掉落不同材料。
- 材料可以在炼化炉中按类别精炼成对应精华。
- 精华可以直接消耗，转化为气血、灵力、根骨、道心、突破成算与其他即时收益。

## 测试

建议使用独立用户目录，避免覆盖自己的存档：

```powershell
$env:APPDATA = "$PWD\.godot_userdata"
$env:DSH_GAME_TEST = "1"
godot --headless --path . --script res://tools/smoke_test.gd
```

## 当前开发重点

下一阶段会继续把炼丹、炼器、材料图鉴、灵宠成长与界面入口继续统一，让每个系统都能真正回到同一个修仙世界里。
