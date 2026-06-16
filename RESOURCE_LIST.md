# 《阴契》开源资源清单 V1.1

## 结论

优先级最高的是 Microverse：Godot 4 + AI NPC + 记忆 + 多模型接入，最适合作为《阴契》的 NPC 记忆与对话架构参考。恐怖交互和世界模拟可以拆零件，中式民俗恐怖规则库需要原创。

本轮新增结论：

- NPC行为层可以评估 `bitbrain/beehave`，它是 Godot 行为树插件，默认分支就是 `godot-4.x`。
- 状态机/恐怖导演节奏层可以评估 `derkork/godot-statecharts`，适合把 relax/build/peak/cooldown 做成可视化状态图。
- 镜头调度可评估 `ramokz/phantom-camera`，适合做走廊压迫、回头杀、固定镜头切换。
- 物品/线索背包可评估 `don-tnowe/godot-wyvernbox-inventory` 或 `Saelara/godot_addon_gloot`，但第一版不建议直接塞重型背包插件，先自研简版线索库。

## AI NPC / 记忆系统

### KsanaDock/Microverse
- GitHub: github.com/KsanaDock/Microverse
- License: MIT
- 技术栈: Godot 4 + GDScript
- 可借鉴: APIManager、MemoryManager、DialogManager、ConversationManager、GameSaveManager、AIAgent。
- 用法: 保留 AI 接入、记忆、对话、任务思路；删除办公室题材，替换成村庄/学校/祠堂/纸扎/阴婚/诅咒。

### bitbrain/beehave
- GitHub: github.com/bitbrain/beehave
- 类型: Godot 行为树插件
- 分支: godot-4.x
- 用法: 后续可把 NPC 的“巡逻、隐瞒、逃跑、祭祀、寻找玩家、回避鬼怪”等行为拆成行为树。第一阶段只记录，不直接接入。

### joonspk-research/generative_agents
- 价值: 记忆流、反思、计划、社交传播的学术源头。
- 用法: 学架构，不直接套商业代码。

### mem0ai/mem0
- 价值: 通用长期记忆层，后续可作为 Microverse 记忆模块的替代或补强。

## 状态机 / 行为调度

### derkork/godot-statecharts
- GitHub: github.com/derkork/godot-statecharts
- 类型: Godot 状态图/层级状态机插件
- 用法: 很适合 HorrorDirector 的四阶段循环：relax → build → peak → cooldown。第一阶段先保留当前 GDScript 实现，后续再决定是否接入可视化状态图。

## 恐怖交互 / 渲染

### ThiDiamondDev/horror-fps-template
- Godot 项目，MIT。
- 可借鉴: 物品交互、合成、拖拽门窗、夜视摄像机。

### godotengine/godot-demo-projects
- 官方 MIT 示例。
- 可借鉴: 灯光、阴影、粒子、后处理、2D/3D混合。

### ramokz/phantom-camera
- GitHub: github.com/ramokz/phantom-camera
- 类型: Godot 摄影机插件
- 用法: 后期可用于固定镜头、跟随镜头、镜头震动、恐怖镜头转场。第一版先用 Camera2D / AnimationPlayer 手写。

## 线索 / 背包 / 物品系统

### don-tnowe/godot-wyvernbox-inventory
- GitHub: github.com/don-tnowe/godot-wyvernbox-inventory
- 类型: Godot 背包插件
- 用法: 可参考格子背包、物品拖拽、物品栏UI。

### Saelara/godot_addon_gloot
- GitHub: github.com/Saelara/godot_addon_gloot
- 类型: Godot 通用物品/背包插件
- 用法: 可参考物品定义、容器、装备/线索库存结构。

第一阶段建议：先做 `ClueInventory.gd` 简版线索库，不引入复杂背包插件。

## 世界模拟

### talktown
- 可借鉴: 小镇人物关系、社会事件、NPC社交网络。

### Fy-/FyWorld
- Unity/RimWorld 教学向项目。
- 可借鉴: 需求、建造、AI决策。

### Cataclysm DDA
- 可借鉴: 地图、事件、生存、NPC、物品生态。

## 程序化叙事

### nathanhoad/godot_dialogue_manager
- Godot 原生分支对话插件。
- 适合优先接 NarrativeEngine，因为条件/状态变更更适合联动 FolkloreRules 和 NPCMemory。

### dialogic-godot/dialogic
- Godot 可视化分支叙事插件。
- 更适合后期做立绘演出、剧情节点、纸嫁衣式剧情展示。

### inkle/ink
- 分支叙事脚本语言，MIT。
- 可用于线索与案件节点脚本化。

### Yarn Spinner for Godot
- Godot 4 对话树工具。
- 可用于 NPC 对话、任务和分支剧情。

## 明确不能直接抄的内容

RimWorld 反编译源码只能学习，不可复制进项目。商业游戏素材、剧情、谜题不能直接搬。
