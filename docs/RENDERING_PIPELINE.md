# 《阴契》动态渲染管线

## 目标

动态渲染不是单独写死场景特效，而是服务开放地图和开放剧情线：

```text
玩家行为
→ FolkloreRules
→ HorrorDirector
→ RenderingDirector
→ SceneEffectExecutor
→ Godot 场景节点执行
```

## 已接入的地基

### RenderingDirector

路径：`src/rendering/RenderingDirector.gd`

职责：监听 `EventBus.horror_event_requested`，把 HorrorDirector 的事件包转成渲染/音频执行命令。

当前支持事件类型：

```text
audio      → AudioStreamPlayer / AudioStreamPlayer2D
light      → PointLight2D
particle   → GPUParticles2D
visual     → CanvasItem Shader / overlay / shadow
animation  → AnimationPlayer
```

### SceneEffectExecutor

路径：`src/rendering/SceneEffectExecutor.gd`

职责：监听 `render_command_created`，把 RenderingDirector 的命令执行到当前场景节点上。

当前 `scenes/Main.tscn` 已加入占位节点：

```text
AmbientShade         CanvasModulate
VisualOverlay        ColorRect
MainLamp             PointLight2D
PaperAsh             GPUParticles2D
HorrorAnimation      AnimationPlayer
HorrorAudio          AudioStreamPlayer
SceneEffectExecutor  Node + 脚本
```

现在已经形成初版闭环：

```text
HorrorDirector 事件包
→ RenderingDirector 命令
→ SceneEffectExecutor 执行
→ GameState render.executed_commands 记录
```

## Godot 官方能力映射

### 2D光照和阴影

Godot 2D完整光照通常需要：

```text
CanvasModulate    暗化场景环境光
PointLight2D      烛火、手电、鬼火、灯笼
DirectionalLight2D 月光/远光
LightOccluder2D   墙、门、柜子等投影遮挡
Sprite2D/TileMapLayer 接收光照
```

《阴契》第一版用法：

```text
祠堂/老宅整体 CanvasModulate 压暗
灯笼/蜡烛用 PointLight2D
门框/柱子/纸人用 LightOccluder2D
HorrorDirector 触发 light_flicker 时，让 RenderingDirector 生成灯光闪烁命令
```

### 粒子

Godot 4 2D粒子主要用：

```text
GPUParticles2D
ParticleProcessMaterial
one_shot
```

《阴契》第一版用法：

```text
paper_ash     纸灰飘落
rain_loop     雨点/水汽
dust_burst    门开灰尘
incense_smoke 香烟雾气
```

### Shader / 后处理

第一版不做重后处理，先做 CanvasItem 层面的轻量效果：

```text
屏幕一闪
黑影覆盖
轻微色偏
局部扭曲
```

等手机性能稳定后，再加更重的 3D/后处理。

## 性能原则

- 手机优先。
- 先 2.5D，不急着全 3D。
- 多用 2D背景 + Light2D + 粒子 + 少量动画。
- PointLight2D 范围不要过大，大光源会影响更多像素，成本更高。
- 软阴影 PCF13 更重，第一版谨慎使用。
- 粒子默认用 GPUParticles2D，低端机再考虑 CPUParticles2D。

## 下一步

1. 给 `PaperAsh` 补 `ParticleProcessMaterial`，让纸灰方向、速度、重力更像真实纸灰。
2. 给 `MainLamp` 补真实 light texture，让灯光可见。
3. 给 `HorrorAudio` 接占位音效资源。
4. 后续拆 `MapDebug.tscn`，不要一直把调试都堆在 Main。
