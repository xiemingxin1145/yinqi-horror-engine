# 《阴契》视觉资产包 v0.3 修正版导入说明

这版严格按 `阴契-视觉素材标准清单-v0.3.md` 生成。

## 重要说明

- `assets/` 里的 PNG 是标准尺寸占位槽位，不代表最终美术。
- 上一版错误图片不要复用。
- 用 AI 生成最终图后，直接按同名文件覆盖。
- 背景：1920x1080，无透明。
- 角色：800x1200，透明背景。
- 图标：512x512，透明背景。

## 数量

- 背景图：17 张
- 角色立绘：20 张
- 线索图标：18 张
- 总计：55 个文件槽位

## Godot 导入建议

复制 `assets/` 到 Godot 项目根目录或 `res://assets/`，保持：

```text
assets/backgrounds/
assets/characters/
assets/icons/
```

角色和图标保持 alpha 透明；背景不要透明。

## 当前仓库接入状态

当前已完成：

```text
manifest/assets_manifest.json
godot/import_map_example.json
data/viewpoints/viewpoints.example.json 已绑定 background_asset 路径
```

当前未完成：

```text
55 个 PNG 二进制文件尚未全部写入仓库
```

原因：当前连接器适合提交代码与文本文件，大批量 PNG 二进制建议通过 GitHub 网页上传、git push、或后续专门资产导入脚本处理。

## V0.1 已绑定背景路径

```text
village_gate_front  -> res://assets/backgrounds/bg_village_gate_front_view.png
village_gate_left   -> res://assets/backgrounds/bg_village_gate_left_view.png
village_gate_right  -> res://assets/backgrounds/bg_village_gate_right_view.png
river_bridge_front  -> res://assets/backgrounds/bg_river_bridge_bridge_head.png
river_bridge_rail   -> res://assets/backgrounds/bg_river_bridge_bridge_railing.png
river_bridge_ground -> res://assets/backgrounds/bg_river_bridge_bridge_middle.png
```

等 PNG 复制进 `assets/backgrounds/` 后，V0.1 就可以从程序化皮肤升级为图片背景。
