# Microverse 架构分析

> 目标：把 Microverse 当作《阴契》的 AI NPC / 长期记忆 / 对话系统参考，不直接搬办公室题材。

## 可借鉴模块

| 模块 | 用途 | 《阴契》改造方向 |
|---|---|---|
| APIManager | 多模型接口 | 接 OpenAI / Claude / Gemini / DeepSeek / Kimi 等，用于 NPC 对话和事件生成 |
| MemoryManager | NPC记忆 | 改成村民、纸扎匠、神婆、道士、学生、鬼魂的长期记忆 |
| DialogManager | 对话状态 | 改成调查问话、秘密试探、恐惧反应、隐瞒线索 |
| ConversationManager | 对话调度 | 用于 NPC 互相交谈、玩家询问、鬼魂低语 |
| CharacterManager | 角色管理 | 改成村民/家族/学校/祠堂角色库 |
| GameSaveManager | 存档 | 保存世界状态、NPC记忆、诅咒传播、线索进度 |
| AIAgent | 感知/任务/行动 | 后续拆分成 Perception / Planner / Task / Action 四层 |

## 需要避免

- 不复制办公室设定、角色、美术。
- 不把 Microverse 的大脚本原样塞进项目。
- 不让 AI 直接修改核心世界数据，必须通过规则层校验。

## 推荐改造方式

第一步先学结构：

```text
Microverse MemoryManager
→ NPCMemory.gd

Microverse DialogManager
→ 后续 YinqiDialogManager.gd

Microverse AIAgent
→ 后续拆成 NPCPerception / NPCPlanner / NPCTask / NPCAction
```

## 《阴契》角色替换表

| Microverse办公室 | 阴契民俗恐怖 |
|---|---|
| 员工 | 村民/学生 |
| 经理 | 村长/校长 |
| 会议 | 祠堂议事/家族会议 |
| 工作任务 | 祭祀、守夜、隐瞒、调查、逃离 |
| 社交记忆 | 旧案记忆、家族秘密、禁忌、目击证词 |

## 下一步

继续拆 MemoryManager 的数据结构：

- 记忆怎么存。
- 怎么按角色检索。
- 是否有重要性、时间、标签。
- 怎么写入存档。
- 怎么在对话里召回。
