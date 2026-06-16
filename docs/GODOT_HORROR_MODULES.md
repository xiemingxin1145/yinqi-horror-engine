# Godot恐怖交互模块分析

## 一、恐怖交互参考

### ThiDiamondDev/horror-fps-template

计划拆解：

- 物品拾取。
- 物品检查。
- 门窗拖拽。
- 合成系统。
- 夜视摄像机。
- 音效触发。

第一版《阴契》不急着完整FPS化，优先拆“调查、开门、拾取、物品组合、声音触发”这些底层能力。

## 二、叙事插件选择

### 推荐优先级：Dialogue Manager > Dialogic

#### nathanhoad/godot_dialogue_manager

- GitHub：github.com/nathanhoad/godot_dialogue_manager
- License：MIT
- 当前主线：Dialogue Manager 4 for Godot 4.6+
- 重要提醒：官方README建议在 Dialogue Manager 4 正式发布前优先使用 v3；v3.10 适合 Godot 4.4 / 4.5，v3.3 适合 Godot 4.3。
- 价值：分支对话脚本、条件、状态变更、对话气泡、Godot原生集成。
- 对《阴契》的价值：适合把 NarrativeEngine 从“手写字符串模板”升级成“可编排的线索/对话/分支脚本”。

适配方向：

```text
Dialogue Manager 条件/状态变更
→ 调 FolkloreRules.check_rule_violation()
→ 改 case risk / clue / npc trust / ghost danger
```

例如：

```text
玩家追问纸扎匠“未点睛纸人”
→ 对话脚本触发 mutation
→ NPCMemory 写入新记忆
→ FolkloreRules 解锁禁忌线索
```

#### dialogic-godot/dialogic

- GitHub：github.com/dialogic-godot/dialogic
- License：MIT
- Godot要求：Dialogic 2 需要 Godot 4.3+
- 价值：可视化分支编辑器、角色管理、视觉小说/RPG对话制作体验更强。
- 对《阴契》的价值：适合后期做“纸嫁衣式剧情演出”和角色立绘对话。

结论：

- 第一阶段：优先 Dialogue Manager，轻量、脚本化、适合规则联动。
- 第二阶段：如果需要大量角色立绘演出，再评估 Dialogic。

## 三、恐怖节奏 / AI Director

### 现状判断

没有找到适合直接接入 Godot 的成熟恐怖节奏库。Left 4 Dead 的 AI Director 没有官方开源实现；Unity 里有类似 `charlie2099/Director-Ai-For-Survival-and-Shooter-Games`，但引擎不对版，只适合学习规则思路，不适合照搬。

### 可借鉴思想

Valve 的 AI Director 核心不是“随机吓人”，而是：

```text
持续监控玩家状态
→ 计算紧张度/强度
→ 升压
→ 爆点
→ 缓和
→ 再升压
```

《阴契》的 HorrorDirector 也应采用这个循环，只是事件从“刷怪”变成：

```text
脚步声
灯光闪烁
纸灰飘落
门外敲门
远处戏腔
鬼影掠过
追逐/躲藏
```

## 四、HorrorDirector 下一步代码目标

当前 `HorrorDirector.gd` 已经有 fear + progress 分档逻辑，下一步要从“返回事件名”升级为“返回可执行事件包”：

```json
{
  "mood": "uneasy",
  "intensity": 42,
  "events": [
    {"id":"door_knock", "type":"audio", "target":"door", "weight":0.8},
    {"id":"light_flicker", "type":"light", "target":"main_lamp", "weight":0.5}
  ]
}
```

再由 Godot 场景里的 AudioStreamPlayer / Light2D / AnimationPlayer 真正执行。

## 五、《阴契》需要的恐怖交互

第一版只做 2.5D / 少量3D，不急着完整 FPS。

### 必备交互

- 点击调查物件。
- 拾取线索。
- 背包查看。
- 物品组合。
- 门锁/机关/密码。
- 场景切换。
- 简单追逐或躲藏。

### 氛围组件

- 烛火闪动。
- 灯光忽明忽暗。
- 纸灰飘落。
- 门外脚步声。
- 远处戏腔。
- 物件轻微位移。

## 六、渲染路线

- Godot 4 Mobile Renderer。
- 2D背景 + Light2D。
- 少量3D空间用于走廊/教室/祠堂。
- 粒子负责纸灰、雾、雨。
- 后处理谨慎使用，优先保证手机性能。
