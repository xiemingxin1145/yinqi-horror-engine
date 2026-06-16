# 《阴契》试玩版 V0.1：村口 → 河桥

## 目标

把项目从调试面板推进到第一段可试玩流程。

本版本只做两个地点：

```text
归魂村村口 → 河桥
```

不开放老宅、戏台、祠堂，避免盲目扩大。

## 已接入

### 数据层

```text
data/viewpoints/viewpoints.example.json
```

定义固定机位视角：

```text
village_gate_front
village_gate_left
village_gate_right
river_bridge_front
river_bridge_rail
river_bridge_ground
```

### 引擎层

```text
src/viewpoints/ViewpointDirector.gd
src/hotspots/HotspotController.gd
```

职责：

```text
ViewpointDirector：进入地点、切换视角、读取可见热点、地点出口
HotspotController：点击/调查当前热点，调用 InteractionController
```

### 交互层

```text
src/MainLoop.gd
```

当前已从自动演示改为按钮交互。按钮由 `MainLoop.gd` 运行时动态创建，不强依赖 `MapDebug.tscn` 固定 UI 节点。

当前按钮：

```text
Left      左转
Right     右转
Inspect   调查当前可见热点中的第一个
Go        前往当前出口
Restart   重开试玩
```

当前可玩流程：

```text
进入村口
→ 左右切视角
→ 调查当前热点
→ 获得线索
→ 前往河桥
→ 在河桥继续切视角和调查
→ 试图前往老宅时显示 V0.1 结束提示
```

## 当前限制

1. `Inspect` 目前只调查当前视角第一个热点。
2. 还没有真正的热点列表按钮。
3. 还没有线索弹窗，只在状态文本里显示结果。
4. 还没有正式 UI 美术，仅为可玩骨架。

## 下一步

1. 生成动态热点按钮，允许玩家选择具体调查对象。
2. 添加线索获得弹窗。
3. 添加试玩版结束页。
4. 接入资源包背景图，替换程序化地图皮肤。

## 验收标准

```text
打开游戏进入村口
能看到村口皮肤
能按 Left / Right 切换视角
能按 Inspect 获得线索
能按 Go 切到河桥
能在河桥获得白布和学生证线索
能看到试玩版结束提示
```
