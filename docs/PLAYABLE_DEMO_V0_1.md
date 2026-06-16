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

### 主循环

```text
src/MainLoop.gd
```

当前自动演示完整流程：

```text
进入村口
→ 调查界碑
→ 右转到麦克风视角
→ 调查麦克风并获得落水声录音
→ 前往河桥
→ 调查香油白布
→ 右转到桥面脚印视角
→ 调查学生证项链
→ 确认林晚秋身份
→ 试玩版结束提示
```

## 下一步

1. 把自动演示改成真实按钮点击。
2. `MapDebug.tscn` 加 UI 按钮：左转、右转、调查、前往。
3. 热点按钮根据 `ViewpointDirector.get_current_hotspots()` 动态生成。
4. 线索弹窗读取 `InteractionController.inspect_item()` 结果。
5. 加试玩版结束页：老宅被雾封住。

## 验收标准

```text
打开游戏进入村口
能看到村口皮肤
能读取当前视角
能列出可见热点
能获得麦克风线索
能切到河桥
能获得白布和学生证线索
能看到试玩版结束提示
```
