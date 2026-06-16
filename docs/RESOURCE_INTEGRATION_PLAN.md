# 开源资源接入计划

> 原则：先验证真实仓库，再写入清单；先做桥接层，不直接把第三方插件源码塞进本仓库。

## 本轮新增候选

### 1. bitbrain/beehave

- 定位：Godot 行为树。
- 用处：NPC自主行为。
- 适合《阴契》的功能：
  - 村民夜间巡逻。
  - 神婆守口如瓶。
  - 纸扎匠主动隐瞒线索。
  - 鬼魂寻找玩家。
  - NPC恐惧后逃跑。

接入方式：

```text
第一阶段：自研 NPCBehaviorPlanner.gd，用类似行为树的数据结构模拟。
第二阶段：如果行为复杂，再正式引入 beehave。
```

### 2. derkork/godot-statecharts

- 定位：Godot 状态图 / 层级状态机。
- 用处：恐怖导演和鬼怪状态。
- 适合《阴契》的功能：
  - HorrorDirector: relax → build → peak → cooldown。
  - Ghost: dormant → hinting → hunting → retreating。
  - NPC: normal → suspicious → afraid → panic。

接入方式：

```text
第一阶段：保留 HorrorDirector.gd 的四阶段硬编码。
第二阶段：当状态变多后，再接 StateCharts。
```

### 3. ramokz/phantom-camera

- 定位：Godot 摄影机控制。
- 用处：恐怖镜头调度。
- 适合《阴契》的功能：
  - 固定机位切换。
  - 走廊压迫镜头。
  - 回头杀镜头。
  - 轻微镜头抖动。

接入方式：

```text
第一阶段：Camera2D + AnimationPlayer。
第二阶段：接 Phantom Camera。
```

### 4. godot-wyvernbox-inventory / Gloot

- 定位：背包/物品系统。
- 用处：线索库、道具组合。
- 适合《阴契》的功能：
  - 红线、族谱、香灰、铜钱、纸人。
  - 线索组合。
  - 道具触发民俗规则。

接入方式：

```text
第一阶段：自研 ClueInventory.gd。
第二阶段：如果需要复杂格子背包，再看 Gloot 或 Wyvernbox。
```

## 接入优先级

```text
1. Dialogue Manager 桥接 NarrativeEngine
2. 自研 ClueInventory.gd
3. HorrorDirector 接真实 Audio/Light/Animation 节点
4. NPCBehaviorPlanner.gd 模拟行为树
5. 需要复杂行为后再引入 beehave/statecharts/phantom-camera
```

## 不直接塞插件源码的原因

- 插件版本和 Godot 版本强绑定。
- 有些插件目录结构较大，直接塞进来会污染当前轻量原型。
- 现在核心目标是先跑通《阴契》自己的系统，不是把项目变成插件垃圾场。
