# 《回水名册》自动化回归

## 本机重复运行

需要 Godot **4.7.2**、`xvfb-run`、Mesa 软件 OpenGL 与 Python 3。仓库入口会导入资源、运行完整触控流程、启动章节场景烟雾测试，并校验结果 JSON 和 PNG 截图：

```bash
scripts/test-returning-water-roster.sh /tmp/returning-water-roster-regression
```

如果 Godot 可执行文件不在 `PATH`：

```bash
GODOT_BIN=/path/to/Godot_v4.7.2-stable_linux.x86_64 \
  scripts/test-returning-water-roster.sh /tmp/returning-water-roster-regression
```

输出目录包含 `report.json`、阶段截图及导入/回归/烟雾测试日志。JSON 记录逐项通过情况、标题启动、村口与河桥、五条线索、错误选项与恢复、正确结局、重玩，以及设置保存/重载与音量触控。自动化注入的是 Godot `InputEventScreenTouch` / `InputEventScreenDrag`；这属于**模拟触控**，不是 Android 真机安装、GPU、音频或触摸设备验收。报告中 `real_device_validation` 固定为 `false`。

## GitHub Actions

- 工作流：[Returning Water Roster Godot Regression](https://github.com/xiemingxin1145/yinqi-horror-engine/actions/workflows/returning-water-regression.yml)
- PR 检查：[PR #1 checks](https://github.com/xiemingxin1145/yinqi-horror-engine/pull/1/checks)
- CI 使用 Godot 4.7.2、Xvfb 与 Mesa 软件渲染；失败退出码会使 `Godot 4.7.2 gameplay and scene regression` 作业失败。每次运行上传 JSON、截图与日志 artifact。
- 仓库当前未设置 `main` 分支保护。按本次协作要求，不修改分支保护或权限；因此该作业会在 PR 检查中明确呈现失败，但 GitHub 是否强制阻止合并仍取决于仓库外部的分支规则配置。

## 现有 Web 导出失败（不在本次改动范围）

已检查旧失败运行：[web-export run 38012219387](https://github.com/xiemingxin1145/yinqi-horror-engine/actions/runs/38012219387)。日志表明 `Godot Headless Web Export` 在下载阶段以 HTTP 404 失败，目标为仓库原有 workflow 中的 Godot 4.2.2 TuxFamily 下载地址；Godot 未启动，Web 导出步骤未执行。该 workflow 与 `main` 完全相同，本 PR 未修改；此处只记录根因，不扩大产品或工作流修复范围。
