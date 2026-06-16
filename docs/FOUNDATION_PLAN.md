# 《阴契》地基建设计划

## 先定原则

现在不写具体剧情。剧情、人物、村庄、鬼怪都可能改，先把底层做成数据驱动。

正确顺序：

```text
数据结构
→ 状态管理
→ 事件总线
→ 规则判定
→ 线索库
→ NPC记忆
→ 恐怖导演
→ 叙事插件
→ 最后才写具体剧情
```

## 地基模块

### EventBus

全局事件总线。任何模块需要通知别的模块时，不直接互相乱调用，而是发事件。

用途：

- 线索获得。
- 世界状态变化。
- 恐怖事件触发。
- NPC记忆写入。
- 规则判定结果。

### GameState

全局游戏状态。

保存：

- world
- case
- player
- flags
- clues
- npcs
- ghosts

原则：所有剧情、规则、NPC行为都读写 GameState，不在场景里散着存。

### DataRegistry

数据注册中心。

保存：

- 地点模板。
- NPC模板。
- 民俗规则模板。
- 恐怖事件模板。

后续所有 JSON 数据都先进入 DataRegistry，再被系统调用。

### ClueStore

线索库。负责获得线索、查询线索、简单组合线索，并同步写入 GameState。

### NPCBehaviorPlanner

轻量行为规划器。先不接 beehave，用自研结构模拟 NPC 行为选择。

## 为什么不急着写剧情

剧情现在写死，会造成三个问题：

1. 后面换村庄/校园/老宅时全要改。
2. AI生成剧情没地方落。
3. 民俗规则和事件系统会被剧情绑死。

所以第一阶段只允许写“示例数据”，不写正式剧情。

## 当前地基完成状态

- [x] `EventBus` 全局事件总线。
- [x] `GameState` 全局状态仓库。
- [x] `DataRegistry` 数据注册中心。
- [x] `DataRegistry.load_all_data()` 读取 `data/*.json`。
- [x] `WorldSim` 从 `DataRegistry` 生成世界。
- [x] `FolkloreRules` 从规则模板判定禁忌。
- [x] `HorrorDirector` 从 `GameState.player` 生成事件包，并通过 `EventBus` 发出。
- [x] `ClueStore` 线索库接入 `GameState` 和 `EventBus`。
- [x] `NPCBehaviorPlanner` 生成 NPC 行为计划，并写回 `GameState`。
- [x] `Main.gd` 调试面板显示数据加载、世界、NPC、规则、线索、恐怖事件、事件日志。

## 下一阶段

地基完成后，进入“最小可玩循环”：

```text
进入地点
→ 调查物品
→ 获得线索
→ 触发民俗规则
→ 改变风险值
→ HorrorDirector触发氛围事件
→ NPC根据记忆/恐惧改变行为
```

此阶段依旧不写正式剧情，只做系统闭环。
