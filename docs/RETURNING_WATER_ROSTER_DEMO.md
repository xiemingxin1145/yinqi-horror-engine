# 《阴契：回水名册》Android 首版实施与验收

## 当前状态

**视觉复核候选版已完成：Godot 自动回归、Xvfb 鼠标模拟完整流程及 Android APK 构建/签名校验通过。实体 Android 手机安装及目标机型全流程尚未验证，因此不标记为最终实机验收通过。**

- 基线：`main`，起始提交 `22e34022f3e4576b4b027055c90ecb8bb5a66d91`。
- 独占工作分支：`feature/returning-water-roster-android`。
- 章节：独立《回水名册》，不并入《我不仙》，只复用现有 `village_gate → river_bridge` 地点/视角/热点系统。
- 工程入口隔离：桌面/Web 的默认启动场景保持原来的 `res://scenes/MapDebug.tscn`；使用 Godot Android feature-tag override 将 Android APK 指向 `res://scenes/ReturningWaterRoster.tscn`，并只对 Android 改名、换图标、设为横屏。
- ETC2/ASTC 导入开关必须全局启用才能通过 Godot Android 导出器校验；这项导入配置属于本次为 Android 构建新增的共享项目设置。

## 实现范围与玩法闭环

1. 标题页提供开始/重玩、设置入口，明确这是固定机位 2.5D 独立短章。
2. 村口先调查备用麦克风录音与被涂掉的归魂村规则；界碑可选。录音文字稿随线索显示，播放音效为水声/静电，不申请麦克风权限。
3. 调查开放真实河桥路线，再收集香油白布、脚印、学生证。线索簿保留已找到线索，显示数量与更清楚的可关闭提示。
4. 五类核心线索齐备后开放三只名牌不同的纸船：“陈默”“林晚秋”“空白”。每只可先检查名牌（不消耗判断次数），也可返回线索簿暂不放船；必须把写有林晚秋名字的船顺水放下，错误可无损重试。
5. 正确放船后先显示三次清楚可见的拍岸反馈，再停止河水环境声；随后河水以陈默的声音呼名。回应是可恢复错误，保持沉默才平息本夜异常。
6. 每轮仅触发一次低强度短追逐/闪暗，关闭闪暗后仍可通关；两次错误后提供额外提示。无死亡惩罚、耗材或软锁。
7. 成功会停止河水循环和效果声、切到专门的散雾退场画面，呈现陈默提灯越过界碑离村；继续后显示结案页和重玩入口。重玩清空线索/失败/结局状态，保留音量及闪暗设置。
8. 本集事件闭合；“归魂村老宅订单”只作后续钩子，不进入老宅、戏台或祠堂，不展示冥婚暴力，不接生成式 AI NPC。

**真实性边界：**“子时河里呼名不可应”、纸船送名等均明确标为归魂村的虚构规则，不表述为现实普遍民俗。

## 资源审计与交付资产

- 最新 `main` 原有 `assets/backgrounds/`、`assets/characters/`、`assets/icons/` 共 55 张 PNG；逐张缩略图复核确认均含 `PLACEHOLDER` 字样，不能作为正式游戏美术。Android APK 未打包这些占位素材。
- 本章使用原创正式资源：7 张 16:9 WebP 场景背景（含结尾散雾/退场图）、陈默角色立绘、纸船判断卡、Android 图标、三段原创环境/提示音，以及按需裁剪的简体中文字体子集。大图均等比压缩为 1792×1008 WebP；过渡 PNG 候选已从提交目录清理。
- 中文字体随包附 SIL Open Font License 文本。资源均由本章专用目录 `assets/returning_water/` 提供，不借用旧项目占位图。
- Android 章节只读入 `data/returning_water/chapter.json`，其中严格限于两个地点、六个交互物、两个场景皮肤、六个视角。桌面/Web 保持通用样例数据加载路径。
- 核心线索 ID：`microphone_drowning_audio`、`red_painted_rule_three`、`oil_soaked_gag_cloth`、`footprints_to_river`、`lin_wanqiu_student_id`。

## 自动化测试结果

端到端脚本在 Godot 4.7.2 项目树下的 1280×720 `SubViewport` 中真实注入 `InputEventScreenTouch`，依次命中可见按钮并读取界面状态，明确输出 `RWR_SELF_TEST_PASS`；shell 同时拒绝脚本异常、失败断言与音频资源泄漏。覆盖：

- 闪暗 `CheckButton` 通过触屏切换；音量滑杆使用 `InputEventScreenTouch/Drag` 真触屏拖动并持久化到 `user://`，新场景加载后读回；
- 从村口进入河桥、必须先查录音/村规、旧宅出口不开放；
- Android 章节数据加载后只注册两个地点、六个固定视角及本章交互物；确认老宅、戏台、祠堂地点与物件不在章节数据中；
- 五种核心线索和线索计数；
- 三只名牌各有触屏检查按钮，检查不消耗尝试；错船触发一次、约一秒的可见追逐但保留线索，特效自动结束，提示可见且可关闭；
- 正确纸船/顺流后实际播放三次河声节拍并停声；错误应答后仍可重试、保持沉默通关；
- 成功后使用散雾退场图并停止两路音频，写入章节完成标记；
- 回标题/重玩清除章节状态但保留设置。

### 视觉质量复核与桌面模拟试玩（2026-10-10）

- 降低了游戏阶段全屏压暗程度；在麦克风、村规牌、白布、草鞋和学生证热点上显示轻量暖色定位标记；底部操作收拢为较薄的半透明两排布局，调查按钮提高文字与背景的对比度。
- Godot 4.7.2 / Xvfb 软件渲染 1280×720 下，章节触控回归结果为 **217/217**，新增检查覆盖底栏位置/高度及多个视角的热点标记；章节主场景 smoke test 退出码为 0。
- 另以桌面窗口的实际鼠标输入完整试玩：标题与开场、村口村规及录音、河桥白布/脚印/学生证、五条线索齐备、三只纸船选择、故意错选后的线索保留与重试、正确放船及“保持沉默”成功结局均通过。截图为 Godot/Xvfb 桌面模拟渲染，不是实体手机测试。
- **Galaxy A53 / Android 15 实机安装、触控、GPU 与音频表现仍未验证；本轮不作手机验收通过的表述。**

实际测试命令：

```bash
godot --headless --path . res://tests/ReturningWaterRosterTestRunner.tscn --quit-after 1200
godot --headless --path . --scene res://scenes/ReturningWaterRoster.tscn --quit-after 30
```

章节主场景烟雾测试也须以退出码 0 完成且无本章脚本异常。**全工程 Editor 导入仍会报告最新 `main` 原有的 `scenes/MapDebug.tscn:8` `Expected float in constructor` 解析错误；本次未修改该 Android 章节之外的旧调试场景。**APK 的 Android 专属入口与打包资源只选本章场景，不能把这一构建结果理解成旧桌面/Web 调试场景也已修复。

## Android APK 实际构建

- Godot：`4.7.2.stable.official.ed1daf0bf`。
- JDK：OpenJDK 21；Android SDK Platform 36；Build Tools 36.0.0；NDK `28.1.13356709`；CMake `3.10.2.4988404`。
- 导出 preset：`Android APK`，仅 `arm64-v8a`；应用 ID `com.xiemingxin1145.yinqi_huishui`；最低 API 24，目标 API 36；横屏。
- 实际命令：

```bash
godot --headless --path . --export-debug "Android APK" build/android/yinqi-huishui-0.1.0-debug.apk
```

- 本轮视觉候选 APK 导出进程退出码：`0`；文件：`build/android/yinqi-huishui-0.1.0-debug.apk`；大小：`42,172,183` 字节（42.17 MB / 40.22 MiB）；SHA-256：`1204c4cdba75f26f02a8b14b81b9f702c7877e6e1eea87f8632778a2b8057768`。
- `apksigner` 确认 APK Signature Scheme v2、v3 签名通过；`aapt2` 二进制 Manifest 显示应用 ID `com.xiemingxin1145.yinqi_huishui`、min SDK 24、target SDK 36、`debuggable=true`，标签为“阴契：回水名册”。
- Manifest 没有任何 `<uses-permission>` 条目（不请求网络、录音、振动或唤醒权限）。Manifest 中 AndroidX ProfileInstallReceiver 的 `android.permission.DUMP` 是组件访问保护属性，不是应用申请的用户权限。
- 包内检查确认 Android 启动资源为 `ReturningWaterRoster.tscn`，只包含 `data/returning_water/chapter.json` 与本章允许清单内的 15 项导入资源（七张 WebP 背景、角色/纸船、三段音频、中文字体及两档图标）；未打包老宅/戏台/祠堂数据、旧场景、旧目录占位图或未选中的中间美术稿。
- 这是可侧载的 **debug APK**，不是可直接上架 Play 的 release 签名包。APK 只支持 64 位 ARM Android，32 位设备不在本次 ABI 范围内。

## 未验证项与 CI 边界

- 当前可用设备列表只有 Sandbox；`adb devices -l` 未列出手机，Android Emulator 也未安装。故实际手机安装、触控布局、GPU/声音表现及目标机型全流程**未验证**。不能据本机导出结果宣称实机验收通过。
- `.github/workflows/validate.yml` 增加了 JSON、入口隔离和场景资产路径静态校验；本报告中的游戏逻辑测试与 APK 导出是在本机 Godot/Android 工具链执行，不能冒称为远程 CI 或实体手机测试。
- Web/桌面默认入口经 Godot Linux `ProjectSettings.get_setting_with_override()` 实测仍为 `MapDebug.tscn` / `Yinqi Horror Engine`；Android 包显示独立应用名。

## 构建参考（官方来源）

- [Godot：Exporting for Android](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html)
- [Godot：Feature tags（平台专属项目设置覆盖）](https://docs.godotengine.org/en/stable/tutorials/export/feature_tags.html)
- [Android Developers：Godot Android 导出](https://developer.android.com/games/engines/godot/godot-export)
- [Android SDK Manager / sdkmanager](https://developer.android.com/tools/sdkmanager)
