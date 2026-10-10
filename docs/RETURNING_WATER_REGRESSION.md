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

### 本轮视觉回归与人工试玩（2026-10-10）

- Godot 4.7.2 回归报告：**217/217 checks passed**；覆盖两排底栏位置/高度、村口与河桥关键热点定位标记、既有章节流程、失败恢复、设置保存/重载及正确结局。章节场景 smoke test 退出码为 0。完整报告和日志随本轮证据包保存。
- 独立桌面模拟试玩使用 1280×720 Xvfb/Godot 窗口及真实鼠标点击，走完村口线索、河桥三类调查物、五线索解锁、错误纸船—回桥重试—正确纸船—保持沉默—结局。它验证的是桌面模拟输入，不是触屏设备。
- 本轮前后对照均为 1280×720，同一阶段分别保留标题、村口、河桥画面；另保存热点标记、线索卡、纸船菜单、失败恢复及结局截图。**Android Galaxy A53 / Android 15 实机验证仍未完成。**

## GitHub Actions

- 工作流：[Returning Water Roster Godot Regression](https://github.com/xiemingxin1145/yinqi-horror-engine/actions/workflows/returning-water-regression.yml)
- 成功运行（提交 `8881e42`）：[GitHub Actions run #38014262801](https://github.com/xiemingxin1145/yinqi-horror-engine/actions/runs/38014262801)
- PR 检查：[PR #1 checks](https://github.com/xiemingxin1145/yinqi-horror-engine/pull/1/checks)
- CI 使用 Godot 4.7.2、Xvfb 与 Mesa 软件渲染；失败退出码会使 `Godot 4.7.2 gameplay and scene regression` 作业失败。每次运行上传 JSON、截图与日志 artifact。
- 仓库当前未设置 `main` 分支保护。按本次协作要求，不修改分支保护或权限；因此该作业会在 PR 检查中明确呈现失败，但 GitHub 是否强制阻止合并仍取决于仓库外部的分支规则配置。

## 现有 Web 导出失败（不在本次改动范围）

已检查旧失败运行：[web-export run 38012219387](https://github.com/xiemingxin1145/yinqi-horror-engine/actions/runs/38012219387)。日志表明 `Godot Headless Web Export` 在下载阶段以 HTTP 404 失败，目标为仓库原有 workflow 中的 Godot 4.2.2 TuxFamily 下载地址；Godot 未启动，Web 导出步骤未执行。该 workflow 与 `main` 完全相同，本 PR 未修改；此处只记录根因，不扩大产品或工作流修复范围。
