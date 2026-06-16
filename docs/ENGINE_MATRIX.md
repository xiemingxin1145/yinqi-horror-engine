# 《阴契》引擎矩阵

## 项目总定位

《阴契》当前主打不是单一剧情，也不是单一关卡，而是：

```text
中式民俗恐怖开放世界底层引擎
```

所有剧情、地图、人物、鬼怪、事件，都必须围绕“引擎化、数据化、开放式演化”来做。

## 核心原则

1. 剧情不写死，剧情线由数据和线索触发。
2. 地图不做死关卡，地点之间是开放连接。
3. NPC不是摆设，要有记忆、恐惧、信任、行为计划。
4. 鬼怪不是固定BOSS，要由死亡原因、执念、民俗规则生成。
5. 恐怖不是随机吓人，而是由压力、风险、线索进度驱动。
6. 渲染不是装饰，而是 HorrorDirector 的执行层。
7. 每个模块都要能独立升级成一个“引擎”。

## 当前引擎列表

### 1. 世界模拟引擎 WorldSim

负责：

- 时间。
- 天气。
- 地点。
- NPC实例。
- 世界flags。

状态：地基已接入。

### 2. 开放地图引擎 LocationController

负责：

- 当前地点。
- 可连接地点。
- 当前地点可交互物。
- 后续开放地图移动。

状态：地基已接入。

### 3. 交互探索引擎 InteractionController

负责：

- 调查物品。
- 执行动作。
- 获得线索。
- 触发民俗规则。

状态：地基已接入。

### 4. 线索引擎 ClueStore

负责：

- 线索获得。
- 线索查询。
- 线索组合。
- 后续证据板/案件图谱。

状态：地基已接入。

### 5. 民俗规则引擎 FolkloreRules

负责：

- 禁忌判定。
- 风险增减。
- flags写入。
- 民俗事件触发。

状态：地基已接入。

### 6. 恐怖导演引擎 HorrorDirector

负责：

- 玩家压力。
- 恐惧阶段。
- 恐怖事件包。
- 节奏控制。

状态：地基已接入。

### 7. 动态渲染引擎 RenderingDirector

负责：

- 把恐怖事件转成光照、粒子、音效、动画命令。
- 后续接 Godot 场景节点。

状态：命令层已接入，真实节点执行层待做。

### 8. NPC记忆引擎 NPCMemory

负责：

- NPC记忆写入。
- 标签回忆。
- 后续大模型上下文。

状态：原型已接入。

### 9. NPC行为引擎 NPCBehaviorPlanner

负责：

- 根据恐惧、信任、地点、案件状态生成行为。
- 后续接行为树/日程系统。

状态：地基已接入。

### 10. 开放剧情线引擎 StorylineEngine

负责：

- 根据线索激活剧情线。
- 多条剧情线并行。
- 结局条件准备。

状态：地基已接入。

### 11. 鬼怪生成引擎 GhostGenerator

负责：

- 来源。
- 执念。
- 弱点。
- 活动范围。
- 出现条件。

状态：原型已接入。

### 12. 叙事桥接引擎 NarrativeEngine

负责：

- 对话上下文。
- Dialogue Manager/Dialogic桥接。
- 剧情mutation回调。

状态：桥接层已接入。

## 下一步优先级

```text
1. RenderingDirector → SceneEffectExecutor，让灯光/纸灰/音效真执行
2. OpenMap → 地点切换与锁路/危险区
3. FolkloreRules → 规则链、黄历、五行、节气
4. ClueStore → 证据板/案件图谱
5. NPCMemory + NPCBehavior → NPC日程与记忆影响行为
6. GhostGenerator → 动态鬼怪生成参数表
7. NarrativeEngine → Dialogue Manager接入
```

## 给其他AI的硬要求

接手本仓库时，不能只写剧情。必须先确认自己改的是哪一个引擎：

```text
WorldSim / LocationController / InteractionController / ClueStore / FolkloreRules / HorrorDirector / RenderingDirector / NPCMemory / NPCBehaviorPlanner / StorylineEngine / GhostGenerator / NarrativeEngine
```

所有新功能必须走：

```text
data配置
→ 引擎处理
→ GameState记录
→ EventBus通知
→ 调试面板验证
```
