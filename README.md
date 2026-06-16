# 阴契 / yinqi-horror-engine

中式民俗恐怖 + 动态世界模拟 + AI叙事，Godot 4为主引擎的开发仓库。

## 当前文档状态

- `WHITEPAPER.md` —— 项目白皮书V1.0，定方向用，发给任何AI工具前先让它读这个
- `RESOURCE_LIST.md` —— 开源资源核实清单V1.0，四大类（恐怖框架/世界模拟/AI NPC/民俗叙事）都标了License和真实程度
- `docs/MICROVERSE_ANALYSIS.md` —— 已完成，基于真实拉取的Microverse源码（不是看README瞎猜），标出了能抄/不能碰/要改的具体文件
- `docs/GODOT_HORROR_MODULES.md` —— 待补，下一步分析ThiDiamondDev的horror-fps-template
- `docs/FOLKLORE_RULES.md` —— 待补，黄历/五行/纸扎/丧葬规则库要从零设计
- `docs/ENGINE_ARCHITECTURE.md` —— 待补，等前面几块分析完再定最终分层架构

## src/ 目录约定

- `npc_memory/` —— 对应Microverse的MemoryManager改造版
- `horror_director/` —— 恐怖节奏控制（敲门/脚步/回头杀/灯光），参考L4D AI Director思路
- `folklore_rules/` —— 民俗规则库引擎，原创部分，没有外部依赖
- `world_sim/` —— 村庄/NPC/家族/关系网络模拟层
- `narrative/` —— 事件链/线索生成/结局推演

## 协作约定

这个仓库是给Claude、GPT、Gemini等多个AI工具共同围着写的，每次有AI做了分析或者写了代码，对应更新`docs/`里那份文档，别让信息散在聊天记录里找不到。
