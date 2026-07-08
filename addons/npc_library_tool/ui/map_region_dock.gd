@tool
extends VBoxContainer

const LAYER_DEFS: Array[Dictionary] = [
	{"id": "occlusion", "label": "遮挡层", "order": 100, "color": Color(0.949020, 0.788235, 0.298039, 0.28)},
	{"id": "collision", "label": "碰撞层", "order": 110, "color": Color(0.843137, 0.227451, 0.286275, 0.20)},
	{"id": "adjust", "label": "调节层", "order": 120, "color": Color(0.478431, 0.243137, 0.694118, 0.20)},
	{"id": "top", "label": "最上层", "order": 130, "color": Color(0.058824, 0.623529, 0.560784, 0.28)},
]
const MODE_DEFS: Array[Dictionary] = [
	{"id": "select", "label": "选择"},
	{"id": "rectangle", "label": "矩形"},
	{"id": "polygon", "label": "多边形"},
	{"id": "free", "label": "自由"},
]
const DEFAULT_TILE_KEY := "0,0"
const DEFAULT_COLLISION_LAYER := 1
const DEFAULT_COLLISION_MASK := 0
const SELECT_FILL_COLOR := Color(0.18, 0.58, 1.0, 0.34)
const SELECT_LINE_COLOR := Color(0.18, 0.72, 1.0, 0.92)
const SELECT_RECT_COLOR := Color(0.18, 0.72, 1.0, 0.18)
const SELECT_CLICK_RADIUS := 10.0

var _editor_interface: EditorInterface
var _editor_plugin: EditorPlugin
var _map_node: Node2D
var _drawing_enabled := false
var _current_points: Array[Vector2] = []
var _preview_point := Vector2.ZERO
var _has_preview_point := false
var _preview_line: Line2D
var _dragging_free := false
var _selection_dragging := false
var _selection_start := Vector2.ZERO
var _selection_current := Vector2.ZERO
var _has_selection_rect := false
var _selected_shape_paths: Array[NodePath] = []
var _undo_actions: Array[Dictionary] = []
var _selection_overlay_root: Node2D
var _status_label: Label
var _map_label: Label
var _layer_option: OptionButton
var _mode_option: OptionButton
var _draw_check: CheckBox
var _show_annotations_check: CheckBox
var _tile_bounds: Array[Dictionary] = []


func setup(editor_interface: EditorInterface, editor_plugin: EditorPlugin) -> void:
	_editor_interface = editor_interface
	_editor_plugin = editor_plugin
	_build_ui()
	_refresh_from_selection()


func wants_canvas_input() -> bool:
	return _drawing_enabled and _map_node != null and is_instance_valid(_map_node)


func canvas_gui_input(event: InputEvent) -> bool:
	if not wants_canvas_input():
		return false
	if event is InputEventKey:
		return canvas_shortcut_input(event)
	if event is InputEventMouseButton:
		return _handle_mouse_button(event as InputEventMouseButton)
	if event is InputEventMouseMotion:
		return _handle_mouse_motion(event as InputEventMouseMotion)
	return false


func canvas_shortcut_input(event: InputEvent) -> bool:
	if not wants_canvas_input():
		return false
	if not event is InputEventKey:
		return false
	var key_event: InputEventKey = event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return false
	if _is_ctrl_z(key_event):
		return _undo_last_action()
	if key_event.keycode == KEY_DELETE or key_event.keycode == KEY_BACKSPACE:
		return _delete_selected_shapes()
	if key_event.keycode == KEY_ESCAPE:
		if _has_active_shape() or not _selected_shape_paths.is_empty() or _has_selection_rect:
			_cancel_current_shape()
			return true
		return false
	if key_event.keycode == KEY_ENTER or key_event.keycode == KEY_C:
		if _selected_mode_id() != "polygon":
			return false
		if _current_points.size() < 3:
			_set_status("多边形至少需要 3 个点。")
			return true
		_finish_polygon()
		return true
	return false


func draw_canvas_overlay(viewport_control: Control) -> void:
	if not wants_canvas_input():
		return
	_draw_selection_rect_overlay(viewport_control)
	if _current_points.is_empty() and not _has_preview_point:
		return
	var layer_root: Node2D = _layer_root(_selected_layer_id())
	if layer_root == null:
		return
	var local_points: Array[Vector2] = _preview_shape_points()
	if local_points.is_empty():
		return
	var points: PackedVector2Array = PackedVector2Array()
	var canvas_transform: Transform2D = layer_root.get_global_transform_with_canvas()
	for point: Vector2 in local_points:
		points.append(canvas_transform * point)
	var color: Color = _selected_layer_color()
	if points.size() >= 2:
		for index: int in range(points.size() - 1):
			viewport_control.draw_line(points[index], points[index + 1], color, 2.0)
		if _selected_mode_id() == "polygon" and points.size() >= 3:
			viewport_control.draw_line(points[points.size() - 1], points[0], color, 1.0)
	for point: Vector2 in points:
		viewport_control.draw_circle(point, 4.0, color)


func _draw_selection_rect_overlay(viewport_control: Control) -> void:
	if not _has_selection_rect or _map_node == null:
		return
	var rect: Rect2 = _normalized_rect(_selection_start, _selection_current)
	if rect.size.length() < 1.0:
		return
	var canvas_transform: Transform2D = _map_node.get_global_transform_with_canvas()
	var points: PackedVector2Array = PackedVector2Array([
		canvas_transform * rect.position,
		canvas_transform * (rect.position + Vector2(rect.size.x, 0.0)),
		canvas_transform * (rect.position + rect.size),
		canvas_transform * (rect.position + Vector2(0.0, rect.size.y)),
	])
	viewport_control.draw_colored_polygon(points, SELECT_RECT_COLOR)
	for index: int in range(points.size()):
		viewport_control.draw_line(points[index], points[(index + 1) % points.size()], SELECT_LINE_COLOR, 2.0)


func _build_ui() -> void:
	custom_minimum_size = Vector2(0, 360)
	var title: Label = Label.new()
	title.text = "地图区域绘制"
	title.add_theme_font_size_override("font_size", 16)
	add_child(title)

	_map_label = Label.new()
	_map_label.text = "地图：未选择"
	_map_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_map_label)

	var select_btn: Button = Button.new()
	select_btn.text = "使用当前选中地图"
	select_btn.pressed.connect(_refresh_from_selection)
	add_child(select_btn)

	_show_annotations_check = CheckBox.new()
	_show_annotations_check.text = "显示区域叠加"
	_show_annotations_check.toggled.connect(_on_show_annotations_toggled)
	add_child(_show_annotations_check)

	_layer_option = OptionButton.new()
	for index: int in range(LAYER_DEFS.size()):
		var item: Dictionary = LAYER_DEFS[index]
		_layer_option.add_item("%s (%s)" % [String(item["label"]), String(item["id"])], index)
		_layer_option.set_item_metadata(index, String(item["id"]))
	add_child(_labeled_row("层级", _layer_option))

	_mode_option = OptionButton.new()
	for index: int in range(MODE_DEFS.size()):
		var item: Dictionary = MODE_DEFS[index]
		_mode_option.add_item(String(item["label"]), index)
		_mode_option.set_item_metadata(index, String(item["id"]))
		if String(item["id"]) == "polygon":
			_mode_option.select(index)
	add_child(_labeled_row("形状", _mode_option))

	_draw_check = CheckBox.new()
	_draw_check.text = "启用 2D 视图绘制"
	_draw_check.toggled.connect(_on_draw_toggled)
	add_child(_draw_check)

	var row: HBoxContainer = HBoxContainer.new()
	var finish_btn: Button = Button.new()
	finish_btn.text = "完成多边形"
	finish_btn.pressed.connect(_finish_polygon)
	row.add_child(finish_btn)
	var undo_btn: Button = Button.new()
	undo_btn.text = "撤销"
	undo_btn.tooltip_text = "撤销当前点；没有正在绘制的点时撤销刚创建的区域。快捷键 Ctrl+Z。"
	undo_btn.pressed.connect(_undo_last_action)
	row.add_child(undo_btn)
	var cancel_btn: Button = Button.new()
	cancel_btn.text = "取消当前"
	cancel_btn.tooltip_text = "取消当前未完成的绘制。快捷键 Esc 或右键。"
	cancel_btn.pressed.connect(_cancel_button_pressed)
	row.add_child(cancel_btn)
	add_child(row)

	var clear_row: HBoxContainer = HBoxContainer.new()
	var clear_layer_btn: Button = Button.new()
	clear_layer_btn.text = "清空当前层"
	clear_layer_btn.pressed.connect(_clear_selected_layer)
	clear_row.add_child(clear_layer_btn)
	var clear_all_btn: Button = Button.new()
	clear_all_btn.text = "清空全部区域"
	clear_all_btn.pressed.connect(_clear_all_layers)
	clear_row.add_child(clear_all_btn)
	add_child(clear_row)

	var save_btn: Button = Button.new()
	save_btn.text = "保存当前场景和区域 JSON"
	save_btn.pressed.connect(_save_scene_and_annotations)
	add_child(save_btn)

	var help: Label = Label.new()
	help.text = "选择模式可点选或框选区域，Delete 删除；左键绘制，C/Enter 完成多边形；右键或 Esc 取消；Ctrl+Z 撤销。"
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(help)

	_status_label = Label.new()
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_status_label)
	_set_status("等待选择地图。")


func _labeled_row(label_text: String, control: Control) -> HBoxContainer:
	var row: HBoxContainer = HBoxContainer.new()
	var label: Label = Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(52, 0)
	row.add_child(label)
	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(control)
	return row


func _refresh_from_selection() -> void:
	_map_node = null
	if _editor_interface == null:
		_set_status("EditorInterface 不可用。")
		return
	var selected: Array[Node] = _editor_interface.get_selection().get_selected_nodes()
	for node: Node in selected:
		var candidate: Node2D = _find_map_node(node)
		if candidate != null:
			_set_map_node(candidate)
			return
	var root: Node = _editor_interface.get_edited_scene_root()
	var scene_candidate: Node2D = _find_map_node(root)
	if scene_candidate != null:
		_set_map_node(scene_candidate)
		return
	_map_label.text = "地图：未找到"
	_set_status("请选择导入的 Pixelwork/FrameRonin 地图节点，或打开包含 Map 的场景。")


func _find_map_node(node: Node) -> Node2D:
	if node == null:
		return null
	if node is Node2D and (node.has_meta("map_stitch_manifest_path") or node.get_node_or_null("Annotations") != null):
		return node as Node2D
	for child: Node in node.get_children():
		var found: Node2D = _find_map_node(child)
		if found != null:
			return found
	return null


func _set_map_node(node: Node2D) -> void:
	_clear_preview_line()
	_clear_selection_overlay()
	_selected_shape_paths.clear()
	_map_node = node
	_ensure_annotation_roots()
	_load_tile_bounds()
	var restored_count: int = _restore_annotations_from_json()
	_map_label.text = "地图：%s" % _map_node.get_path()
	var annotations: CanvasItem = _map_node.get_node_or_null("Annotations") as CanvasItem
	if annotations != null:
		if restored_count > 0:
			annotations.visible = true
		_show_annotations_check.button_pressed = annotations.visible
	_set_status("已绑定地图，已从 JSON 恢复 %d 个区域。可以启用绘制。" % restored_count)


func _on_show_annotations_toggled(enabled: bool) -> void:
	if _map_node == null:
		return
	var annotations: CanvasItem = _map_node.get_node_or_null("Annotations") as CanvasItem
	if annotations != null:
		annotations.visible = enabled


func _on_draw_toggled(enabled: bool) -> void:
	_drawing_enabled = enabled
	_cancel_current_shape("")
	if enabled and _map_node != null:
		var annotations: CanvasItem = _map_node.get_node_or_null("Annotations") as CanvasItem
		if annotations != null:
			annotations.visible = true
			_show_annotations_check.button_pressed = true
	if not enabled:
		_clear_preview_line()
	_set_status("绘制已启用。" if enabled else "绘制已关闭。")


func _handle_mouse_button(event: InputEventMouseButton) -> bool:
	if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_cancel_current_shape()
		return true
	if event.button_index != MOUSE_BUTTON_LEFT:
		return false
	var mode_id: String = _selected_mode_id()
	if mode_id == "select":
		return _handle_select_mouse_button(event)
	var local_point: Vector2 = _event_to_layer_local()
	_preview_point = local_point
	_has_preview_point = true
	if mode_id == "rectangle":
		if event.pressed:
			_current_points.append(local_point)
			if _current_points.size() >= 2:
				_add_shape(_rectangle_points(_current_points[0], _current_points[1]), "rectangle")
				_current_points.clear()
				_has_preview_point = false
			_update_preview_line()
			_update_plugin_overlay()
		return true
	if mode_id == "polygon":
		if event.pressed:
			_current_points.append(local_point)
			_update_preview_line()
			_update_plugin_overlay()
		return true
	if mode_id == "free":
		if event.pressed:
			_dragging_free = true
			_current_points = [local_point]
		else:
			_dragging_free = false
			if _current_points.size() >= 3:
				_add_shape(_current_points.duplicate(), "free")
			_current_points.clear()
			_has_preview_point = false
		_update_preview_line()
		_update_plugin_overlay()
		return true
	return false


func _handle_mouse_motion(_event: InputEventMouseMotion) -> bool:
	if _selected_mode_id() == "select":
		if _selection_dragging:
			_selection_current = _event_to_map_local()
			_has_selection_rect = true
			_update_plugin_overlay()
			return true
		return false
	var local_point: Vector2 = _event_to_layer_local()
	_preview_point = local_point
	_has_preview_point = true
	if _selected_mode_id() == "free" and _dragging_free:
		if _current_points.is_empty() or _current_points[_current_points.size() - 1].distance_to(local_point) >= 6.0:
			_current_points.append(local_point)
	_update_preview_line()
	_update_plugin_overlay()
	return true


func _event_to_layer_local() -> Vector2:
	var layer_root: Node2D = _layer_root(_selected_layer_id())
	if layer_root == null:
		return Vector2.ZERO
	return layer_root.get_local_mouse_position()


func _event_to_map_local() -> Vector2:
	if _map_node == null:
		return Vector2.ZERO
	return _map_node.get_local_mouse_position()


func _finish_polygon() -> void:
	if _current_points.size() >= 3:
		_add_shape(_current_points.duplicate(), "polygon")
	_current_points.clear()
	_has_preview_point = false
	_dragging_free = false
	_update_preview_line()
	_update_plugin_overlay()


func _cancel_button_pressed() -> void:
	_cancel_current_shape()


func _cancel_current_shape(status_text: String = "已取消当前绘制。") -> void:
	var had_shape: bool = _has_active_shape() or not _selected_shape_paths.is_empty() or _has_selection_rect
	_current_points.clear()
	_has_preview_point = false
	_dragging_free = false
	_selection_dragging = false
	_has_selection_rect = false
	_selected_shape_paths.clear()
	_update_selection_overlay()
	_update_preview_line()
	_update_plugin_overlay()
	if not status_text.is_empty():
		_set_status(status_text if had_shape else "当前没有未完成操作。")


func _handle_select_mouse_button(event: InputEventMouseButton) -> bool:
	var map_point: Vector2 = _event_to_map_local()
	if event.pressed:
		_selection_dragging = true
		_selection_start = map_point
		_selection_current = map_point
		_has_selection_rect = true
		_update_plugin_overlay()
		return true
	if not _selection_dragging:
		return true
	_selection_dragging = false
	_selection_current = map_point
	var rect: Rect2 = _normalized_rect(_selection_start, _selection_current)
	if rect.size.length() <= SELECT_CLICK_RADIUS:
		_select_shape_at_point(map_point)
	else:
		_select_shapes_in_rect(rect)
	_has_selection_rect = false
	_update_plugin_overlay()
	return true


func _select_shape_at_point(map_point: Vector2) -> void:
	var hit_path: NodePath = NodePath("")
	var candidates: Array[Node] = _all_shape_nodes()
	candidates.reverse()
	for candidate: Node in candidates:
		if _shape_contains_map_point(candidate, map_point):
			hit_path = candidate.get_path()
			break
	_selected_shape_paths.clear()
	if not hit_path.is_empty():
		_selected_shape_paths.append(hit_path)
	_set_status("已选中 1 个区域。" if not hit_path.is_empty() else "未选中区域。")
	_update_selection_overlay()


func _select_shapes_in_rect(rect: Rect2) -> void:
	_selected_shape_paths.clear()
	for candidate: Node in _all_shape_nodes():
		if _shape_intersects_rect(candidate, rect):
			_selected_shape_paths.append(candidate.get_path())
	_set_status("已框选 %d 个区域。" % _selected_shape_paths.size())
	_update_selection_overlay()


func _delete_selected_shapes() -> bool:
	var selected_records: Array[Dictionary] = _serialize_selected_shapes()
	if selected_records.is_empty():
		_set_status("没有选中的区域可删除。")
		return false
	_delete_shape_records(selected_records)
	_push_undo_action({"type": "restore_shapes", "shapes": selected_records})
	_selected_shape_paths.clear()
	_update_selection_overlay()
	_save_annotations_json()
	_update_plugin_overlay()
	_set_status("已删除 %d 个选中区域，可用 Ctrl+Z 恢复。" % selected_records.size())
	return true


func _undo_point() -> bool:
	if not _current_points.is_empty():
		_current_points.remove_at(_current_points.size() - 1)
		if _current_points.is_empty():
			_has_preview_point = false
		_update_preview_line()
		_update_plugin_overlay()
		_set_status("已撤销最后一个点。")
		return true
	return false


func _undo_last_action() -> bool:
	if _undo_point():
		return true
	if _undo_actions.is_empty():
		_set_status("没有可撤销的绘制。")
		return false
	var action: Dictionary = _undo_actions[_undo_actions.size() - 1]
	_undo_actions.remove_at(_undo_actions.size() - 1)
	var action_type: String = String(action.get("type", ""))
	var shapes: Array[Dictionary] = _shape_records_from_variant(action.get("shapes", []))
	if action_type == "delete_shapes":
		_delete_shape_records(shapes)
		_selected_shape_paths.clear()
		_update_selection_overlay()
		_save_annotations_json()
		_update_plugin_overlay()
		_set_status("已撤销创建的区域。")
		return true
	if action_type == "restore_shapes":
		var restored_paths: Array[NodePath] = _restore_shape_records(shapes)
		_selected_shape_paths = restored_paths
		_update_selection_overlay()
		_save_annotations_json()
		_update_plugin_overlay()
		_set_status("已恢复 %d 个区域。" % restored_paths.size())
		return true
	_set_status("没有可撤销的绘制。")
	return false


func _has_active_shape() -> bool:
	return not _current_points.is_empty() or _has_preview_point or _dragging_free


func _is_ctrl_z(key_event: InputEventKey) -> bool:
	var is_z: bool = key_event.keycode == KEY_Z or key_event.physical_keycode == KEY_Z
	return is_z and (key_event.ctrl_pressed or key_event.meta_pressed)


func _preview_shape_points() -> Array[Vector2]:
	var mode_id := _selected_mode_id()
	if mode_id == "rectangle" and _current_points.size() == 1 and _has_preview_point:
		return _rectangle_points(_current_points[0], _preview_point)
	if mode_id == "polygon" and _current_points.size() >= 1 and _has_preview_point:
		var points := _current_points.duplicate()
		points.append(_preview_point)
		return points
	return _current_points.duplicate()


func _update_preview_line() -> void:
	if not wants_canvas_input():
		_clear_preview_line()
		return
	var layer_root: Node2D = _layer_root(_selected_layer_id())
	if layer_root == null:
		_clear_preview_line()
		return
	var points: Array[Vector2] = _preview_shape_points()
	if points.is_empty():
		_clear_preview_line()
		return
	var line: Line2D = _ensure_preview_line(layer_root)
	line.default_color = _selected_layer_color().lightened(0.25)
	line.width = 8.0
	line.z_index = 4096
	line.z_as_relative = false
	var packed := PackedVector2Array()
	for point: Vector2 in points:
		packed.append(point)
	if _selected_mode_id() == "rectangle" and packed.size() >= 4:
		packed.append(packed[0])
	elif _selected_mode_id() == "polygon" and packed.size() >= 3:
		packed.append(packed[0])
	line.points = packed
	line.visible = true


func _ensure_preview_line(layer_root: Node2D) -> Line2D:
	if _preview_line != null and is_instance_valid(_preview_line):
		if _preview_line.get_parent() == layer_root:
			return _preview_line
		_preview_line.get_parent().remove_child(_preview_line)
		_preview_line.queue_free()
	_preview_line = Line2D.new()
	_preview_line.name = "__MapRegionPreviewLine"
	_preview_line.antialiased = true
	_preview_line.joint_mode = Line2D.LINE_JOINT_ROUND
	_preview_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	_preview_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	layer_root.add_child(_preview_line)
	return _preview_line


func _clear_preview_line() -> void:
	if _preview_line != null and is_instance_valid(_preview_line):
		_preview_line.queue_free()
	_preview_line = null


func _rectangle_points(a: Vector2, b: Vector2) -> Array[Vector2]:
	return [
		Vector2(minf(a.x, b.x), minf(a.y, b.y)),
		Vector2(maxf(a.x, b.x), minf(a.y, b.y)),
		Vector2(maxf(a.x, b.x), maxf(a.y, b.y)),
		Vector2(minf(a.x, b.x), maxf(a.y, b.y)),
	]


func _add_shape(points: Array, mode_id: String) -> void:
	if _map_node == null:
		return
	_ensure_annotation_roots()
	var layer_id: String = _selected_layer_id()
	var root: Node2D = _layer_root(layer_id)
	if root == null:
		return
	var typed_points: Array[Vector2] = []
	for point: Variant in points:
		if point is Vector2:
			typed_points.append(point as Vector2)
	if typed_points.size() < 3:
		return
	var tile_key: String = _tile_key_for_points(typed_points)
	var shape_name: String = "%s_%d" % [layer_id, _next_shape_index(root, layer_id)]
	var created_node: Node = _create_shape_node(layer_id, shape_name, typed_points, mode_id, tile_key)
	if created_node != null:
		var created_record: Dictionary = _serialize_shape_node(layer_id, created_node)
		if not created_record.is_empty():
			_push_undo_action({"type": "delete_shapes", "shapes": [created_record]})
	_save_annotations_json()
	_update_plugin_overlay()
	_set_status("已添加 %s：%s" % [layer_id, shape_name])


func _apply_shape_meta(node: Node, mode_id: String, tile_key: String) -> void:
	node.set_meta("mode", mode_id)
	node.set_meta("map_stitch_tile_key", tile_key)
	node.set_meta("pixel_game_tool_region", true)
	if node is CollisionObject2D:
		node.set_meta("map_stitch_collision_layer", DEFAULT_COLLISION_LAYER)
		node.set_meta("map_stitch_collision_mask", DEFAULT_COLLISION_MASK)


func _create_shape_node(layer_id: String, shape_name: String, typed_points: Array[Vector2], mode_id: String, tile_key: String) -> Node:
	var root: Node2D = _layer_root(layer_id)
	if root == null or typed_points.size() < 3:
		return null
	shape_name = _unique_shape_name(layer_id, shape_name)
	if layer_id == "collision":
		var body: StaticBody2D = StaticBody2D.new()
		body.name = shape_name
		body.collision_layer = DEFAULT_COLLISION_LAYER
		body.collision_mask = DEFAULT_COLLISION_MASK
		_apply_shape_meta(body, mode_id, tile_key)
		root.add_child(body)
		_set_owned(body)
		var polygon: CollisionPolygon2D = CollisionPolygon2D.new()
		polygon.name = "CollisionPolygon2D"
		polygon.polygon = PackedVector2Array(typed_points)
		polygon.disabled = false
		body.add_child(polygon)
		_set_owned(polygon)
		return body
	if layer_id == "adjust":
		var area: Area2D = Area2D.new()
		area.name = shape_name
		area.collision_layer = DEFAULT_COLLISION_LAYER
		area.collision_mask = DEFAULT_COLLISION_MASK
		area.monitoring = true
		area.monitorable = true
		area.set_meta("map_stitch_adjust_z_index", -2)
		_apply_shape_meta(area, mode_id, tile_key)
		root.add_child(area)
		_set_owned(area)
		var adjust_polygon: CollisionPolygon2D = CollisionPolygon2D.new()
		adjust_polygon.name = "CollisionPolygon2D"
		adjust_polygon.polygon = PackedVector2Array(typed_points)
		adjust_polygon.disabled = false
		area.add_child(adjust_polygon)
		_set_owned(adjust_polygon)
		return area
	var polygon2d: Polygon2D = Polygon2D.new()
	polygon2d.name = shape_name
	polygon2d.polygon = PackedVector2Array(typed_points)
	polygon2d.color = _layer_color(layer_id)
	_apply_shape_meta(polygon2d, mode_id, tile_key)
	root.add_child(polygon2d)
	_set_owned(polygon2d)
	return polygon2d


func _push_undo_action(action: Dictionary) -> void:
	if action.is_empty():
		return
	_undo_actions.append(action)
	while _undo_actions.size() > 80:
		_undo_actions.remove_at(0)


func _shape_records_from_variant(value: Variant) -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	if not value is Array:
		return records
	for record_value: Variant in value as Array:
		if record_value is Dictionary:
			records.append(record_value as Dictionary)
	return records


func _serialize_selected_shapes() -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	for shape_path: NodePath in _selected_shape_paths:
		var node: Node = get_node_or_null(shape_path)
		if node == null:
			continue
		var layer_id: String = _layer_id_for_shape_node(node)
		var record: Dictionary = _serialize_shape_node(layer_id, node)
		if not record.is_empty():
			records.append(record)
	return records


func _serialize_all_shapes() -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	for layer_def: Dictionary in LAYER_DEFS:
		records.append_array(_serialize_layer_shapes(String(layer_def["id"])))
	return records


func _serialize_layer_shapes(layer_id: String) -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	var root: Node2D = _layer_root(layer_id)
	if root == null:
		return records
	for child: Node in root.get_children():
		if not _is_region_shape_node(child):
			continue
		var record: Dictionary = _serialize_shape_node(layer_id, child)
		if not record.is_empty():
			records.append(record)
	return records


func _serialize_shape_node(layer_id: String, node: Node) -> Dictionary:
	var points: Array[Vector2] = _shape_points_array(node)
	if layer_id.is_empty() or points.size() < 3:
		return {}
	return {
		"layer_id": layer_id,
		"shape_name": String(node.name),
		"mode": String(node.get_meta("mode", "polygon")),
		"tile_key": String(node.get_meta("map_stitch_tile_key", _tile_key_for_points(points))),
		"points": points.duplicate(),
		"node_path": node.get_path(),
	}


func _delete_shape_records(records: Array[Dictionary]) -> void:
	for record: Dictionary in records:
		var node: Node = _shape_node_from_record(record)
		if node == null:
			continue
		var parent: Node = node.get_parent()
		if parent != null:
			parent.remove_child(node)
		node.free()


func _restore_shape_records(records: Array[Dictionary]) -> Array[NodePath]:
	var restored_paths: Array[NodePath] = []
	for record: Dictionary in records:
		var layer_id: String = String(record.get("layer_id", record.get("layer", "")))
		var points: Array[Vector2] = _points_variant_to_vectors(record.get("points", []))
		if layer_id.is_empty() or points.size() < 3:
			continue
		var shape_name: String = String(record.get("shape_name", ""))
		if shape_name.is_empty():
			shape_name = "%s_%d" % [layer_id, _next_shape_index(_layer_root(layer_id), layer_id)]
		var mode_id: String = String(record.get("mode", "polygon"))
		var tile_key: String = String(record.get("tile_key", _tile_key_for_points(points)))
		var node: Node = _create_shape_node(layer_id, shape_name, points, mode_id, tile_key)
		if node != null:
			restored_paths.append(node.get_path())
	return restored_paths


func _shape_node_from_record(record: Dictionary) -> Node:
	var node_path_text: String = String(record.get("node_path", ""))
	if not node_path_text.is_empty():
		var by_path: Node = get_node_or_null(NodePath(node_path_text))
		if by_path != null:
			return by_path
	var layer_id: String = String(record.get("layer_id", record.get("layer", "")))
	var shape_name: String = String(record.get("shape_name", ""))
	if layer_id.is_empty() or shape_name.is_empty():
		return null
	var root: Node2D = _layer_root(layer_id)
	if root == null:
		return null
	return root.get_node_or_null(NodePath(shape_name))


func _unique_shape_name(layer_id: String, desired_name: String) -> String:
	var root: Node2D = _layer_root(layer_id)
	if root == null:
		return desired_name
	var base_name: String = desired_name
	if base_name.is_empty():
		base_name = "%s_%d" % [layer_id, _next_shape_index(root, layer_id)]
	if root.get_node_or_null(NodePath(base_name)) == null:
		return base_name
	var index: int = 2
	while root.get_node_or_null(NodePath("%s_%d" % [base_name, index])) != null:
		index += 1
	return "%s_%d" % [base_name, index]


func _all_shape_nodes() -> Array[Node]:
	var nodes: Array[Node] = []
	for layer_def: Dictionary in LAYER_DEFS:
		var root: Node2D = _layer_root(String(layer_def["id"]))
		if root == null:
			continue
		for child: Node in root.get_children():
			if _is_region_shape_node(child):
				nodes.append(child)
	return nodes


func _is_region_shape_node(node: Node) -> bool:
	if node == null:
		return false
	if String(node.name).begins_with("__"):
		return false
	return node is Polygon2D or node.get_node_or_null("CollisionPolygon2D") is CollisionPolygon2D


func _layer_id_for_shape_node(node: Node) -> String:
	var parent: Node = node.get_parent()
	if parent == null:
		return ""
	return String(parent.name)


func _shape_points(node: Node) -> PackedVector2Array:
	if node is Polygon2D:
		return (node as Polygon2D).polygon
	var collision_polygon: CollisionPolygon2D = node.get_node_or_null("CollisionPolygon2D") as CollisionPolygon2D
	if collision_polygon != null:
		return collision_polygon.polygon
	return PackedVector2Array()


func _shape_points_array(node: Node) -> Array[Vector2]:
	var result: Array[Vector2] = []
	for point: Vector2 in _shape_points(node):
		result.append(point)
	return result


func _shape_contains_map_point(node: Node, map_point: Vector2) -> bool:
	var points: PackedVector2Array = _shape_points(node)
	if points.size() < 3:
		return false
	if Geometry2D.is_point_in_polygon(map_point, points):
		return true
	for index: int in range(points.size()):
		var a: Vector2 = points[index]
		var b: Vector2 = points[(index + 1) % points.size()]
		if _distance_to_segment(map_point, a, b) <= SELECT_CLICK_RADIUS:
			return true
	return false


func _shape_intersects_rect(node: Node, rect: Rect2) -> bool:
	var points: Array[Vector2] = _shape_points_array(node)
	if points.size() < 3:
		return false
	var bounds: Rect2 = _points_bounds(points)
	if not bounds.intersects(rect, true):
		return false
	for point: Vector2 in points:
		if rect.has_point(point):
			return true
	var rect_points: Array[Vector2] = [
		rect.position,
		rect.position + Vector2(rect.size.x, 0.0),
		rect.position + rect.size,
		rect.position + Vector2(0.0, rect.size.y),
	]
	var packed: PackedVector2Array = PackedVector2Array(points)
	for point: Vector2 in rect_points:
		if Geometry2D.is_point_in_polygon(point, packed):
			return true
	return true


func _distance_to_segment(point: Vector2, a: Vector2, b: Vector2) -> float:
	var segment: Vector2 = b - a
	var length_sq: float = segment.length_squared()
	if length_sq <= 0.0001:
		return point.distance_to(a)
	var t: float = clampf((point - a).dot(segment) / length_sq, 0.0, 1.0)
	return point.distance_to(a + segment * t)


func _normalized_rect(a: Vector2, b: Vector2) -> Rect2:
	var min_point: Vector2 = Vector2(minf(a.x, b.x), minf(a.y, b.y))
	var max_point: Vector2 = Vector2(maxf(a.x, b.x), maxf(a.y, b.y))
	return Rect2(min_point, max_point - min_point)


func _update_selection_overlay() -> void:
	_clear_selection_overlay_children()
	if _selected_shape_paths.is_empty() or _map_node == null:
		return
	var overlay_root: Node2D = _ensure_selection_overlay_root()
	if overlay_root == null:
		return
	for shape_path: NodePath in _selected_shape_paths:
		var node: Node = get_node_or_null(shape_path)
		if node == null:
			continue
		var points: PackedVector2Array = _shape_points(node)
		if points.size() < 3:
			continue
		var fill: Polygon2D = Polygon2D.new()
		fill.name = "__SelectedFill"
		fill.polygon = points
		fill.color = SELECT_FILL_COLOR
		overlay_root.add_child(fill)
		var line: Line2D = Line2D.new()
		line.name = "__SelectedOutline"
		line.default_color = SELECT_LINE_COLOR
		line.width = 4.0
		line.closed = true
		line.antialiased = true
		line.points = points
		overlay_root.add_child(line)


func _ensure_selection_overlay_root() -> Node2D:
	if _map_node == null:
		return null
	var annotations: Node2D = _map_node.get_node_or_null("Annotations") as Node2D
	if annotations == null:
		return null
	if _selection_overlay_root != null and is_instance_valid(_selection_overlay_root):
		if _selection_overlay_root.get_parent() == annotations:
			return _selection_overlay_root
		_selection_overlay_root.queue_free()
	_selection_overlay_root = Node2D.new()
	_selection_overlay_root.name = "__MapRegionSelectionOverlay"
	_selection_overlay_root.z_index = 4096
	_selection_overlay_root.z_as_relative = false
	annotations.add_child(_selection_overlay_root)
	return _selection_overlay_root


func _clear_selection_overlay_children() -> void:
	if _selection_overlay_root == null or not is_instance_valid(_selection_overlay_root):
		return
	for child: Node in _selection_overlay_root.get_children():
		_selection_overlay_root.remove_child(child)
		child.free()


func _clear_selection_overlay() -> void:
	if _selection_overlay_root != null and is_instance_valid(_selection_overlay_root):
		_selection_overlay_root.queue_free()
	_selection_overlay_root = null


func _ensure_annotation_roots() -> void:
	if _map_node == null:
		return
	var annotations: Node2D = _map_node.get_node_or_null("Annotations") as Node2D
	if annotations == null:
		annotations = Node2D.new()
		annotations.name = "Annotations"
		annotations.visible = false
		_map_node.add_child(annotations)
		_set_owned(annotations)
	for layer_def: Dictionary in LAYER_DEFS:
		var id: String = String(layer_def["id"])
		var root: Node2D = annotations.get_node_or_null(id) as Node2D
		if root == null:
			root = Node2D.new()
			root.name = id
			annotations.add_child(root)
			_set_owned(root)
		root.z_index = int(layer_def["order"])


func _layer_root(layer_id: String) -> Node2D:
	if _map_node == null:
		return null
	return _map_node.get_node_or_null("Annotations/%s" % layer_id) as Node2D


func _selected_layer_id() -> String:
	if _layer_option == null:
		return "occlusion"
	var selected_metadata: Variant = _layer_option.get_item_metadata(_layer_option.selected)
	return String(selected_metadata)


func _selected_mode_id() -> String:
	if _mode_option == null:
		return "polygon"
	var selected_metadata: Variant = _mode_option.get_item_metadata(_mode_option.selected)
	return String(selected_metadata)


func _selected_layer_color() -> Color:
	return _layer_color(_selected_layer_id())


func _layer_color(layer_id: String) -> Color:
	for layer_def: Dictionary in LAYER_DEFS:
		if String(layer_def["id"]) == layer_id:
			return layer_def["color"] as Color
	return Color(1, 1, 1, 0.25)


func _layer_label(layer_id: String) -> String:
	for layer_def: Dictionary in LAYER_DEFS:
		if String(layer_def["id"]) == layer_id:
			return String(layer_def["label"])
	return layer_id


func _layer_order(layer_id: String) -> int:
	for layer_def: Dictionary in LAYER_DEFS:
		if String(layer_def["id"]) == layer_id:
			return int(layer_def["order"])
	return 0


func _next_shape_index(root: Node, layer_id: String) -> int:
	var max_index := 0
	for child: Node in root.get_children():
		var text: String = String(child.name)
		if text.begins_with("%s_" % layer_id):
			max_index = maxi(max_index, int(text.trim_prefix("%s_" % layer_id)))
	return max_index + 1


func _clear_selected_layer() -> void:
	var layer_id: String = _selected_layer_id()
	var records: Array[Dictionary] = _serialize_layer_shapes(layer_id)
	if records.is_empty():
		_set_status("%s 没有可清空的区域。" % _layer_label(layer_id))
		return
	_push_undo_action({"type": "restore_shapes", "shapes": records})
	_clear_layer(layer_id)
	_selected_shape_paths.clear()
	_save_annotations_json()
	_update_selection_overlay()
	_update_plugin_overlay()
	_set_status("已清空 %s，可用 Ctrl+Z 恢复。" % _layer_label(layer_id))


func _clear_all_layers() -> void:
	var records: Array[Dictionary] = _serialize_all_shapes()
	if records.is_empty():
		_set_status("没有可清空的区域。")
		return
	_push_undo_action({"type": "restore_shapes", "shapes": records})
	for layer_def: Dictionary in LAYER_DEFS:
		_clear_layer(String(layer_def["id"]))
	_selected_shape_paths.clear()
	_save_annotations_json()
	_update_selection_overlay()
	_update_plugin_overlay()
	_set_status("已清空全部区域层，可用 Ctrl+Z 恢复。")


func _clear_layer(layer_id: String) -> void:
	_ensure_annotation_roots()
	var root: Node2D = _layer_root(layer_id)
	if root == null:
		return
	_clear_layer_children(root)
	_set_status("已清空 %s。" % _layer_label(layer_id))


func _clear_layer_children(root: Node) -> void:
	for child: Node in root.get_children():
		root.remove_child(child)
		child.free()


func _prune_undo_stack() -> void:
	pass


func _save_scene_and_annotations() -> void:
	_save_annotations_json()
	if _editor_interface != null:
		var err: Error = _editor_interface.save_scene()
		if err == OK:
			_set_status("已保存场景和区域 JSON。")
		else:
			_set_status("区域 JSON 已保存，但场景保存失败：%s" % error_string(err))


func _save_annotations_json() -> void:
	if _map_node == null:
		return
	var annotations_path: String = _annotations_json_path()
	if annotations_path.is_empty():
		_set_status("未找到 annotations JSON 路径。")
		return
	var data: Dictionary = {
		"version": 1,
		"coordinate_system": "top_left_origin_y_down_pixels",
		"unity_coordinate_system": "x_right_y_up_pixels",
		"layers": [],
	}
	for layer_def: Dictionary in LAYER_DEFS:
		var layer_id: String = String(layer_def["id"])
		var layer_entry: Dictionary = {
			"id": layer_id,
			"label": String(layer_def["label"]),
			"order": int(layer_def["order"]),
			"color": _color_to_hex(layer_def["color"] as Color),
			"shapes": _collect_layer_shapes(layer_id),
		}
		(data["layers"] as Array).append(layer_entry)
	var file: FileAccess = FileAccess.open(annotations_path, FileAccess.WRITE)
	if file == null:
		_set_status("写入区域 JSON 失败：%s" % annotations_path)
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()


func _restore_annotations_from_json() -> int:
	if _map_node == null:
		return 0
	var annotations_path: String = _annotations_json_path()
	if annotations_path.is_empty() or not FileAccess.file_exists(annotations_path):
		return 0
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(annotations_path))
	if not parsed is Dictionary:
		return 0
	var data: Dictionary = parsed as Dictionary
	var layers: Variant = data.get("layers", [])
	if not layers is Array:
		return 0
	var shape_count: int = _count_json_shapes(layers as Array)
	if shape_count <= 0:
		return 0
	for layer_def: Dictionary in LAYER_DEFS:
		var root: Node2D = _layer_root(String(layer_def["id"]))
		if root != null:
			_clear_layer_children(root)
	for layer_variant: Variant in layers as Array:
		if not layer_variant is Dictionary:
			continue
		var layer_data: Dictionary = layer_variant as Dictionary
		var layer_id: String = String(layer_data.get("id", ""))
		var shapes: Variant = layer_data.get("shapes", [])
		if layer_id.is_empty() or not shapes is Array:
			continue
		for shape_variant: Variant in shapes as Array:
			if not shape_variant is Dictionary:
				continue
			var shape_data: Dictionary = shape_variant as Dictionary
			var points: Array[Vector2] = _json_points_to_vectors(shape_data.get("points", []))
			if points.size() < 3:
				continue
			var mode_id: String = String(shape_data.get("mode", "polygon"))
			var tile_key: String = String(shape_data.get("tile_key", _tile_key_for_points(points)))
			var shape_name: String = String(shape_data.get("id", ""))
			if shape_name.is_empty():
				shape_name = "%s_%d" % [layer_id, _next_shape_index(_layer_root(layer_id), layer_id)]
			_create_shape_node(layer_id, shape_name, points, mode_id, tile_key)
	_prune_undo_stack()
	_update_plugin_overlay()
	return shape_count


func _count_json_shapes(layers: Array) -> int:
	var count: int = 0
	for layer_variant: Variant in layers:
		if not layer_variant is Dictionary:
			continue
		var layer_data: Dictionary = layer_variant as Dictionary
		var shapes: Variant = layer_data.get("shapes", [])
		if shapes is Array:
			count += (shapes as Array).size()
	return count


func _json_points_to_vectors(points_value: Variant) -> Array[Vector2]:
	return _points_variant_to_vectors(points_value)


func _points_variant_to_vectors(points_value: Variant) -> Array[Vector2]:
	var result: Array[Vector2] = []
	if not points_value is Array:
		return result
	for point_value: Variant in points_value as Array:
		if point_value is Vector2:
			result.append(point_value as Vector2)
		elif point_value is Dictionary:
			var point_data: Dictionary = point_value as Dictionary
			result.append(Vector2(float(point_data.get("x", 0.0)), float(point_data.get("y", 0.0))))
		elif point_value is Array:
			var point_array: Array = point_value as Array
			if point_array.size() >= 2:
				result.append(Vector2(float(point_array[0]), float(point_array[1])))
	return result


func _annotations_json_path() -> String:
	if _map_node == null:
		return ""
	var manifest_path: String = String(_map_node.get_meta("map_stitch_manifest_path", ""))
	if manifest_path.is_empty() or not FileAccess.file_exists(manifest_path):
		return ""
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
	if not parsed is Dictionary:
		return ""
	var manifest: Dictionary = parsed as Dictionary
	var resource_root: String = String(manifest.get("resource_root", ""))
	var annotations_file: String = String(manifest.get("annotations_file", ""))
	if resource_root.is_empty() or annotations_file.is_empty():
		return ""
	return ProjectSettings.globalize_path("res://%s/%s" % [resource_root, annotations_file])


func _collect_layer_shapes(layer_id: String) -> Array[Dictionary]:
	var shapes: Array[Dictionary] = []
	var root: Node2D = _layer_root(layer_id)
	if root == null:
		return shapes
	for child: Node in root.get_children():
		var shape_points: PackedVector2Array = PackedVector2Array()
		var meta_node: Node = child
		if child is Polygon2D:
			shape_points = (child as Polygon2D).polygon
		else:
			var collision_polygon: CollisionPolygon2D = child.get_node_or_null("CollisionPolygon2D") as CollisionPolygon2D
			if collision_polygon != null:
				shape_points = collision_polygon.polygon
		if shape_points.size() < 3:
			continue
		var points: Array[Vector2] = []
		for point: Vector2 in shape_points:
			points.append(point)
		var mode_id: String = String(meta_node.get_meta("mode", "polygon"))
		var tile_key: String = String(meta_node.get_meta("map_stitch_tile_key", _tile_key_for_points(points)))
		var bounds: Rect2 = _points_bounds(points)
		var local_points: Array[Vector2] = _points_to_tile_local(points, tile_key)
		var local_bounds: Rect2 = _points_bounds(local_points)
		shapes.append({
			"id": "%s_%s" % [String(child.name), str(child.get_instance_id())],
			"tile_key": tile_key,
			"map_layer": "overall",
			"layer": layer_id,
			"layer_label": _layer_label(layer_id),
			"mode": mode_id,
			"points": _points_to_json(points),
			"local_points": _points_to_json(local_points),
			"unity_points": _points_to_unity_json(points),
			"bounds": _rect_to_json(bounds),
			"local_bounds": _rect_to_json(local_bounds),
		})
	return shapes


func _load_tile_bounds() -> void:
	_tile_bounds.clear()
	if _map_node == null:
		return
	var manifest_path: String = String(_map_node.get_meta("map_stitch_manifest_path", ""))
	if manifest_path.is_empty() or not FileAccess.file_exists(manifest_path):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
	if not parsed is Dictionary:
		return
	var manifest: Dictionary = parsed as Dictionary
	var layers: Variant = manifest.get("layers", [])
	if not layers is Array:
		return
	for layer_variant: Variant in layers as Array:
		if not layer_variant is Dictionary:
			continue
		var layer_data: Dictionary = layer_variant as Dictionary
		if String(layer_data.get("id", "")) != "overall":
			continue
		var tiles: Variant = layer_data.get("tiles", [])
		if not tiles is Array:
			continue
		for tile_variant: Variant in tiles as Array:
			if not tile_variant is Dictionary:
				continue
			var tile_data: Dictionary = tile_variant as Dictionary
			var pixel: Variant = tile_data.get("pixel", {})
			if not pixel is Dictionary:
				continue
			var pixel_data: Dictionary = pixel as Dictionary
			var rect := Rect2(
				Vector2(float(pixel_data.get("x", 0.0)), float(pixel_data.get("y", 0.0))),
				Vector2(float(pixel_data.get("width", 0.0)), float(pixel_data.get("height", 0.0)))
			)
			if rect.has_area():
				_tile_bounds.append({"key": String(tile_data.get("key", DEFAULT_TILE_KEY)), "rect": rect})


func _tile_key_for_points(points: Array[Vector2]) -> String:
	if points.is_empty():
		return DEFAULT_TILE_KEY
	var center: Vector2 = _points_bounds(points).get_center()
	for tile_record: Dictionary in _tile_bounds:
		var rect: Rect2 = tile_record["rect"] as Rect2
		if rect.has_point(center):
			return String(tile_record["key"])
	return DEFAULT_TILE_KEY


func _points_to_tile_local(points: Array[Vector2], tile_key: String) -> Array[Vector2]:
	var offset := Vector2.ZERO
	for tile_record: Dictionary in _tile_bounds:
		if String(tile_record["key"]) == tile_key:
			var rect: Rect2 = tile_record["rect"] as Rect2
			offset = rect.position
			break
	var local_points: Array[Vector2] = []
	for point: Vector2 in points:
		local_points.append(point - offset)
	return local_points


func _points_bounds(points: Array[Vector2]) -> Rect2:
	if points.is_empty():
		return Rect2()
	var min_point: Vector2 = points[0]
	var max_point: Vector2 = points[0]
	for point: Vector2 in points:
		min_point.x = minf(min_point.x, point.x)
		min_point.y = minf(min_point.y, point.y)
		max_point.x = maxf(max_point.x, point.x)
		max_point.y = maxf(max_point.y, point.y)
	return Rect2(min_point, max_point - min_point)


func _points_to_json(points: Array[Vector2]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for point: Vector2 in points:
		result.append({"x": roundf(point.x), "y": roundf(point.y)})
	return result


func _points_to_unity_json(points: Array[Vector2]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for point: Vector2 in points:
		result.append({"x": roundf(point.x), "y": -roundf(point.y)})
	return result


func _rect_to_json(rect: Rect2) -> Dictionary:
	return {
		"x": roundf(rect.position.x),
		"y": roundf(rect.position.y),
		"width": roundf(rect.size.x),
		"height": roundf(rect.size.y),
	}


func _color_to_hex(color: Color) -> String:
	return "#%02x%02x%02x" % [
		int(roundf(color.r * 255.0)),
		int(roundf(color.g * 255.0)),
		int(roundf(color.b * 255.0)),
	]


func _set_owned(node: Node) -> void:
	if _editor_interface == null:
		return
	var root: Node = _editor_interface.get_edited_scene_root()
	if root != null and node != root:
		node.owner = root


func _update_plugin_overlay() -> void:
	if _editor_plugin != null:
		_editor_plugin.update_overlays()


func _set_status(text: String) -> void:
	if _status_label != null:
		_status_label.text = text
