# 项目状态

更新时间：2026-10-10

## 当前交付范围

- 项目：`xiemingxin1145/yinqi-horror-engine`。
- 只处理独立章节《回水名册》及其相关测试/验收文档；工作分支为 `feature/returning-water-roster-android`，更新既有 PR #1。
- 不合并、不发布，不修改 `main` 分支保护，不扩展到全季内容。
- 本轮视觉复核降低了游戏画面遮暗，增加关键调查物定位标记，调整为更薄的半透明双排触控栏并增强调查按钮对比度；未增加冗余/重复资产。

## 验证结果

- Godot 4.7.2 章节自动回归：**217/217 checks passed**。
- 章节主场景 smoke test 通过；静态资产、差异格式及项目配置检查通过。
- Godot/Xvfb 1280×720 桌面模拟鼠标试玩走完章节，验证线索收集、纸船选择、错选后保留线索与重试、正确选择及安全结局。它不是 Android 真机验证。
- 视觉前后对照、自动化报告/日志及桌面模拟实玩截图已单独保存；没有把这些本地证据误称为 CI 或手机测试。

## Android 候选版

- APK：`build/android/yinqi-huishui-0.1.0-debug.apk`。
- Godot 导出成功，debug 签名通过；大小 `42,172,183` 字节（42.17 MB / 40.22 MiB）。
- SHA-256：`1204c4cdba75f26f02a8b14b81b9f702c7877e6e1eea87f8632778a2b8057768`。
- 64 位 ARM Android debug 侧载候选，不是 Play Store release 包。

## 尚未验证 / 已知边界

- Galaxy A53 / Android 15 手机未连接：实体安装启动、真机触控、GPU、声音与性能仍待设备实测。
- Godot 全工程 Editor 导入仍会报告原有 `scenes/MapDebug.tscn:8` `Expected float in constructor`；它不是本章 Android 专属入口，且本轮不在范围内。
- 本地 Android 导出环境没有运行中的 ADB daemon；APK 通过导出器、签名和 Manifest 检查，但没有使用 adb 安装到实体设备。

本章的自动化与桌面模拟结果通过后，候选 APK 可交由项目所有者侧载试玩；在目标手机完整验收前，仍保持“候选版”状态。
