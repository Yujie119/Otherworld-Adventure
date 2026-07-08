# FrameRonin 地图区域层级说明

本项目的 `AI资源库` 插件已经同步了 FrameRonin 地图拼接里的区域绘制层。打开 Godot 后，右侧会出现 `地图区域` Dock。

## 层级

- `遮挡层 / occlusion`：给游戏逻辑判断角色是否进入遮挡区域。本项目的 `SpawnMapController` 会读取 `Annotations/occlusion`，并兼容读取 `Annotations/top`，用于让角色进入前景遮挡区时触发 `set_occluded`。
- `碰撞层 / collision`：实体阻挡区域。导出为 `StaticBody2D + CollisionPolygon2D`，运行时用于阻止角色通过。
- `调节层 / adjust`：特殊显示顺序区域。FrameRonin 运行时会把进入区域的角色视觉层级提高，并可显示半透明 ghost，适合桥洞、屋檐、门廊这类“角色层级需要临时调整”的位置。不要把它当普通碰撞层用。
- `最上层 / top`：最高前景注释区。它本身不是物理碰撞；在本项目里也会被遮挡检测兼容读取，适合画明确压在角色上方的前景范围。

## 用法

1. 在 Godot 打开包含地图的场景，例如 `res://scenes/map/spawn_gameplay.tscn`。
2. 选中导入的地图节点，或直接点击 `地图区域` Dock 的 `使用当前选中地图`。
3. 勾选 `显示区域叠加`，再选择层级和形状。
4. 勾选 `启用 2D 视图绘制`。
5. 在 2D 视图中绘制：
   - 矩形：左键点起点，再左键点终点。
   - 多边形：连续左键加点，按 Enter 或点 `完成多边形`。
   - 自由：按住左键拖动，松开完成。
6. 点 `保存当前场景和区域 JSON`。

当前地图的历史误画区域已经清空，只保留空的 `occlusion`、`collision`、`adjust`、`top` 根层。
