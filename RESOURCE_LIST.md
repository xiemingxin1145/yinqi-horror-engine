# 《阴契》开源资源清单 V1.0

## 结论

优先级最高的是 Microverse：Godot 4 + AI NPC + 记忆 + 多模型接入，最适合作为《阴契》的 NPC 记忆与对话架构参考。恐怖交互和世界模拟可以拆零件，中式民俗恐怖规则库需要原创。

## AI NPC / 记忆系统

### KsanaDock/Microverse
- GitHub: github.com/KsanaDock/Microverse
- License: MIT
- 技术栈: Godot 4 + GDScript
- 可借鉴: APIManager、MemoryManager、DialogManager、ConversationManager、GameSaveManager、AIAgent。
- 用法: 保留 AI 接入、记忆、对话、任务思路；删除办公室题材，替换成村庄/学校/祠堂/纸扎/阴婚/诅咒。

### joonspk-research/generative_agents
- 价值: 记忆流、反思、计划、社交传播的学术源头。
- 用法: 学架构，不直接套商业代码。

### mem0ai/mem0
- 价值: 通用长期记忆层，后续可作为 Microverse 记忆模块的替代或补强。

## 恐怖交互 / 渲染

### ThiDiamondDev/horror-fps-template
- Godot 项目，MIT。
- 可借鉴: 物品交互、合成、拖拽门窗、夜视摄像机。

### godotengine/godot-demo-projects
- 官方 MIT 示例。
- 可借鉴: 灯光、阴影、粒子、后处理、2D/3D混合。

## 世界模拟

### talktown
- 可借鉴: 小镇人物关系、社会事件、NPC社交网络。

### Fy-/FyWorld
- Unity/RimWorld 教学向项目。
- 可借鉴: 需求、建造、AI决策。

### Cataclysm DDA
- 可借鉴: 地图、事件、生存、NPC、物品生态。

## 程序化叙事

### inkle/ink
- 分支叙事脚本语言，MIT。
- 可用于线索与案件节点脚本化。

### Yarn Spinner for Godot
- Godot 4 对话树工具。
- 可用于 NPC 对话、任务和分支剧情。

## 明确不能直接抄的内容

RimWorld 反编译源码只能学习，不可复制进项目。商业游戏素材、剧情、谜题不能直接搬。