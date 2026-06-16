# 引擎整体架构

《阴契》采用 Godot 4 作为第一阶段主引擎，核心目标是先跑通一个可扩展的 2.5D 民俗恐怖原型。

## 当前分层

```text
Main.gd
  ├─ WorldSim
  ├─ FolkloreRules
  ├─ GhostGenerator
  ├─ HorrorDirector
  ├─ NPCMemory
  └─ NarrativeEngine
```

## 模块职责

### WorldSim
负责世界状态：地点、时间、天气、NPC、世界标记。

### NPCMemory
参考 Microverse 的 MemoryManager，负责记录和检索 NPC 的长期记忆。

### FolkloreRules
原创民俗规则库。第一阶段只做最小规则：时辰、地点、禁忌、线索。

### GhostGenerator
根据案件种子生成鬼怪：来源、执念、弱点、出现条件、活动范围。

### HorrorDirector
恐怖导演系统，根据玩家恐惧值和探索进度动态触发声音、灯光、脚步、异常物件等事件。

### NarrativeEngine
负责把世界状态、民俗规则、鬼怪信息组合成可展示的开场、线索链和结局走向。

## 关键原则

- 民俗规则和剧情内容必须数据化，不能全部写死在场景脚本里。
- NPC 记忆与世界模拟分开，后续可接 Microverse 或 mem0。
- 恐怖导演不直接改剧情，只制造压力和氛围。
- 第一版先跑通文本与系统，后面再补美术、光影、音频、交互。
