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

当前按钮由 `MainLoop.gd` 运行时动态创建，不强依赖 `MapDebug.tscn` 固定 UI 节点。

当前固定按钮：

```text
Left      左转
Right     右转
Go        前往当前出口
Restart   重开试玩
```

当前动态热点按钮：

```text
根据 ViewpointDirector.get_current_hotspots() 自动生成
当前视角有几个热点，就显示几个可调查按钮
点击具体热点后调用 HotspotController.inspect_hotspot(hotspot_id)
```

当前弹窗：

```text
AcceptDialog 线索弹窗
获得线索后显示 clue.name 与 clue.text
试图进入老宅时显示 Demo End 弹窗
```

当前可玩流程：

```text
进入村口
→ 左右切视角
→ 选择当前视角具体热点
→ 获得线索弹窗
→ 前往河桥
→ 在河桥继续切视角和调查
→ 试图前往老宅时显示 V0.1 结束提示
```

## 当前限制

1. 热点按钮目前最多显示 3 个。
2. 线索弹窗还是 Godot 默认 AcceptDialog 样式，未套正式 UI 美术。
3. 还没有真正背景图资源，仅使用 MapSkin 程序化皮肤。
4. 还没有 APK 构建验证。

## 下一步

1. 接入视觉资产包背景图，替换程序化地图皮肤。
2. 给线索弹窗套 UI 风格。
3. 加基础保存 / 读档。
4. 跑一轮 Claude 审计，检查 GDScript 语法和运行链路。

## 验收标准

```text
打开游戏进入村口
能看到村口皮肤
能按 Left / Right 切换视角
能看到当前视角具体热点按钮
能点击具体热点获得线索弹窗
能按 Go 切到河桥
能在河桥获得白布和学生证线索
能看到试玩版结束提示
```
