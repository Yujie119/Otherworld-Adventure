extends Node2D

@export var map_path: NodePath = NodePath("Map")
@export var player_path: NodePath = NodePath("Player")
@export var preferred_spawn_position: Vector2 = Vector2(8394, 4685)
@export var collision_layer_bit: int = 1
@export var player_layer_bit: int = 2
@export var camera_padding: float = 96.0
@export var player_clearance_radius: float = 28.0
@export var adjusted_player_z_index: int = -2
@export var plugin_occluder_z_index: int = 160

var _map: Node2D
var _player: CharacterBody2D
var _collision_polygons: Array[CollisionPolygon2D] = []
var _adjust_polygons: Array[CollisionPolygon2D] = []
var _occlusion_polygons: Array[Polygon2D] = []
var _top_polygons: Array[Polygon2D] = []
var _overall_tile_records: Array[Dictionary] = []
var _plugin_occluder_layer: Node2D
var _plugin_occluder_visuals: Array[Dictionary] = []
var _player_visual_state: Dictionary = {}
var _map_rect: Rect2 = Rect2()
var _player_adjusted := false


func _ready() -> void:
	_map = get_node_or_null(map_path) as Node2D
	_player = get_node_or_null(player_path) as CharacterBody2D
	if _map == null or _player == null:
		push_error("SpawnMapController requires Map and Player nodes.")
		return
	_map_rect = _read_map_canvas_rect()
	_load_overall_tile_records()
	_restore_annotations_from_json()
	_configure_visual_occlusion_layers()
	_enable_map_collisions()
	_collect_adjust_polygons()
	_collect_occlusion_polygons()
	_rebuild_plugin_occluder_visuals()
	_place_player()
	_configure_player_camera()
	_reset_player_occlusion_visual_state()
	set_process(true)


func _process(_delta: float) -> void:
	if _player == null:
		return
	var foot_point: Vector2 = _player.global_position
	var active_occluder_source_ids: Dictionary = _active_occluder_source_ids_at(foot_point)
	_sync_plugin_occluder_visibility(active_occluder_source_ids)
	var should_depth_adjust: bool = not active_occluder_source_ids.is_empty() or _point_inside_any_collision_polygon(foot_point, _adjust_polygons)
	_apply_player_depth_adjustment(should_depth_adjust)


func _enable_map_collisions() -> void:
	_collision_polygons.clear()
	var collision_root: Node = _map.get_node_or_null("Annotations/collision")
	if collision_root == null:
		push_warning("Spawn map has no Annotations/collision node.")
		return
	var collision_layer_mask: int = _layer_to_mask(collision_layer_bit)
	for body: Node in collision_root.find_children("*", "StaticBody2D", true, false):
		var static_body: StaticBody2D = body as StaticBody2D
		static_body.collision_layer = collision_layer_mask
		static_body.collision_mask = 0
		for child: Node in static_body.find_children("*", "CollisionPolygon2D", true, false):
			var polygon: CollisionPolygon2D = child as CollisionPolygon2D
			polygon.disabled = false
			_collision_polygons.append(polygon)
		for child: Node in static_body.find_children("*", "CollisionShape2D", true, false):
			var shape: CollisionShape2D = child as CollisionShape2D
			shape.disabled = false
	_player.collision_layer = _layer_to_mask(player_layer_bit)
	_player.collision_mask = collision_layer_mask


func _collect_occlusion_polygons() -> void:
	_occlusion_polygons.clear()
	_top_polygons.clear()
	var occlusion_root: Node = _map.get_node_or_null("Annotations/occlusion")
	if occlusion_root == null:
		push_warning("Spawn map has no Annotations/occlusion node.")
	else:
		for child: Node in occlusion_root.find_children("*", "Polygon2D", true, false):
			var polygon: Polygon2D = child as Polygon2D
			_occlusion_polygons.append(polygon)
	var top_root: Node = _map.get_node_or_null("Annotations/top")
	if top_root != null:
		for child: Node in top_root.find_children("*", "Polygon2D", true, false):
			_top_polygons.append(child as Polygon2D)


func _collect_adjust_polygons() -> void:
	_adjust_polygons.clear()
	var adjust_root: Node = _map.get_node_or_null("Annotations/adjust")
	if adjust_root == null:
		return
	for child: Node in adjust_root.find_children("*", "CollisionPolygon2D", true, false):
		var polygon: CollisionPolygon2D = child as CollisionPolygon2D
		polygon.disabled = false
		_adjust_polygons.append(polygon)


func _place_player() -> void:
	if _player.global_position != Vector2.ZERO:
		return
	_player.global_position = _nearest_free_position(preferred_spawn_position)


func _nearest_free_position(origin: Vector2) -> Vector2:
	if _is_player_space_clear(origin):
		return origin
	var step: float = 64.0
	for radius: int in range(1, 28):
		var r: float = step * float(radius)
		var samples: int = maxi(8, radius * 8)
		for index: int in range(samples):
			var angle: float = TAU * float(index) / float(samples)
			var candidate: Vector2 = origin + Vector2(cos(angle), sin(angle)) * r
			if _map_rect.has_area():
				candidate = candidate.clamp(_map_rect.position, _map_rect.position + _map_rect.size)
			if _is_player_space_clear(candidate):
				return candidate
	return origin


func _is_player_space_clear(global_point: Vector2) -> bool:
	var clearance: float = maxf(1.0, player_clearance_radius)
	var probe_points: Array[Vector2] = [
		Vector2.ZERO,
		Vector2(clearance, 0.0),
		Vector2(-clearance, 0.0),
		Vector2(0.0, clearance),
		Vector2(0.0, -clearance),
		Vector2(clearance * 0.7, clearance * 0.7),
		Vector2(-clearance * 0.7, clearance * 0.7),
		Vector2(clearance * 0.7, -clearance * 0.7),
		Vector2(-clearance * 0.7, -clearance * 0.7),
	]
	for offset: Vector2 in probe_points:
		if _is_point_inside_collision(global_point + offset):
			return false
	return true


func _is_point_inside_collision(global_point: Vector2) -> bool:
	for polygon: CollisionPolygon2D in _collision_polygons:
		if polygon == null or not is_instance_valid(polygon):
			continue
		if Geometry2D.is_point_in_polygon(polygon.to_local(global_point), polygon.polygon):
			return true
	return false


func _is_point_inside_any_occluder(global_point: Vector2) -> bool:
	for polygon: Polygon2D in _occlusion_polygons:
		if polygon == null or not is_instance_valid(polygon):
			continue
		if Geometry2D.is_point_in_polygon(polygon.to_local(global_point), polygon.polygon):
			return true
	return false


func _player_overlaps_any_occluder() -> bool:
	return _point_inside_any_polygon2d(_player.global_position, _occlusion_polygons)


func _is_point_inside_any_top(global_point: Vector2) -> bool:
	for polygon: Polygon2D in _top_polygons:
		if polygon == null or not is_instance_valid(polygon):
			continue
		if Geometry2D.is_point_in_polygon(polygon.to_local(global_point), polygon.polygon):
			return true
	return false


func _player_overlaps_any_top() -> bool:
	return _point_inside_any_polygon2d(_player.global_position, _top_polygons)


func _is_point_inside_any_adjust(global_point: Vector2) -> bool:
	for polygon: CollisionPolygon2D in _adjust_polygons:
		if polygon == null or not is_instance_valid(polygon):
			continue
		if Geometry2D.is_point_in_polygon(polygon.to_local(global_point), polygon.polygon):
			return true
	return false


func _player_overlaps_any_adjust() -> bool:
	return _point_inside_any_collision_polygon(_player.global_position, _adjust_polygons)


func _player_foot_inside_depth_region() -> bool:
	if _player == null:
		return false
	var foot_point: Vector2 = _player.global_position
	return not _active_occluder_source_ids_at(foot_point).is_empty() or _point_inside_any_collision_polygon(foot_point, _adjust_polygons)


func _active_occluder_source_ids_at(global_point: Vector2) -> Dictionary:
	var active_ids: Dictionary = {}
	_add_active_polygon_source_ids(global_point, _occlusion_polygons, active_ids)
	return active_ids


func _add_active_polygon_source_ids(global_point: Vector2, polygons: Array[Polygon2D], active_ids: Dictionary) -> void:
	for polygon: Polygon2D in polygons:
		if polygon == null or not is_instance_valid(polygon):
			continue
		if Geometry2D.is_point_in_polygon(polygon.to_local(global_point), polygon.polygon):
			active_ids[int(polygon.get_instance_id())] = true


func _point_inside_any_polygon2d(global_point: Vector2, polygons: Array[Polygon2D]) -> bool:
	for polygon: Polygon2D in polygons:
		if polygon == null or not is_instance_valid(polygon):
			continue
		if Geometry2D.is_point_in_polygon(polygon.to_local(global_point), polygon.polygon):
			return true
	return false


func _point_inside_any_collision_polygon(global_point: Vector2, polygons: Array[CollisionPolygon2D]) -> bool:
	for polygon: CollisionPolygon2D in polygons:
		if polygon == null or not is_instance_valid(polygon):
			continue
		if Geometry2D.is_point_in_polygon(polygon.to_local(global_point), polygon.polygon):
			return true
	return false


func _apply_player_depth_adjustment(enabled: bool) -> void:
	if _player_adjusted == enabled:
		return
	_player_adjusted = enabled
	var visuals: Array[CanvasItem] = _player_visual_targets()
	if enabled:
		for visual: CanvasItem in visuals:
			var key: int = int(visual.get_instance_id())
			if not _player_visual_state.has(key):
				_player_visual_state[key] = {
					"node": visual,
					"z_index": visual.z_index,
					"z_as_relative": visual.z_as_relative,
				}
			visual.z_as_relative = false
			visual.z_index = adjusted_player_z_index
		return
	for key: Variant in _player_visual_state.keys():
		var state: Dictionary = _player_visual_state[key] as Dictionary
		var visual: CanvasItem = state.get("node", null) as CanvasItem
		if visual != null and is_instance_valid(visual):
			visual.z_index = int(state.get("z_index", visual.z_index))
			visual.z_as_relative = bool(state.get("z_as_relative", visual.z_as_relative))
	_player_visual_state.clear()


func _player_visual_targets() -> Array[CanvasItem]:
	var targets: Array[CanvasItem] = []
	if _player == null:
		return targets
	if _player is CanvasItem:
		targets.append(_player as CanvasItem)
	return targets


func _reset_player_occlusion_visual_state() -> void:
	if _player == null:
		return
	if _player.has_method(&"set_occlusion_strength"):
		_player.call(&"set_occlusion_strength", 0.0)
	elif _player.has_method(&"set_occluded"):
		_player.call(&"set_occluded", false)


func _configure_visual_occlusion_layers() -> void:
	var top_layer: CanvasItem = _map.get_node_or_null("top") as CanvasItem
	if top_layer != null:
		top_layer.visible = false
	_force_map_layer_tiles_visible("top", false)
	_ensure_plugin_occluder_layer()


func _force_map_layer_tiles_visible(layer_id: String, visible: bool) -> void:
	var records_value: Variant = _map.get("_tile_records")
	if not records_value is Array:
		return
	var records: Array = records_value as Array
	for index: int in range(records.size()):
		var record_value: Variant = records[index]
		if not record_value is Dictionary:
			continue
		var record: Dictionary = record_value as Dictionary
		if String(record.get("layer", "")) != layer_id:
			continue
		record["visible"] = visible
		record["wanted"] = visible
		var sprite: CanvasItem = record.get("sprite", null) as CanvasItem
		if sprite != null and is_instance_valid(sprite):
			sprite.visible = visible
		records[index] = record
	_map.set("_tile_records", records)
	if _map.has_method(&"_update_visible_tiles"):
		_map.call_deferred(&"_update_visible_tiles", true)


func _ensure_plugin_occluder_layer() -> void:
	_plugin_occluder_layer = _map.get_node_or_null("PluginOccluders") as Node2D
	if _plugin_occluder_layer == null:
		_plugin_occluder_layer = Node2D.new()
		_plugin_occluder_layer.name = "PluginOccluders"
		_map.add_child(_plugin_occluder_layer)
	_plugin_occluder_layer.visible = true
	_plugin_occluder_layer.z_index = plugin_occluder_z_index


func _rebuild_plugin_occluder_visuals() -> void:
	_ensure_plugin_occluder_layer()
	_plugin_occluder_visuals.clear()
	for child: Node in _plugin_occluder_layer.get_children():
		_plugin_occluder_layer.remove_child(child)
		child.free()
	var used_source_ids: Dictionary = {}
	for polygon: Polygon2D in _occlusion_polygons:
		_create_plugin_occluder_visual_if_new(polygon, false, used_source_ids)
	for polygon: Polygon2D in _top_polygons:
		_create_plugin_occluder_visual_if_new(polygon, true, used_source_ids)


func _create_plugin_occluder_visual_if_new(source_polygon: Polygon2D, always_visible: bool, used_source_ids: Dictionary) -> void:
	if source_polygon == null or not is_instance_valid(source_polygon):
		return
	var source_id: int = int(source_polygon.get_instance_id())
	if used_source_ids.has(source_id):
		return
	used_source_ids[source_id] = true
	_create_plugin_occluder_visual(source_polygon, always_visible)


func _create_plugin_occluder_visual(source_polygon: Polygon2D, always_visible: bool) -> void:
	if source_polygon.polygon.size() < 3:
		return
	var tile_record: Dictionary = _overall_tile_record_for_polygon(source_polygon)
	if tile_record.is_empty():
		return
	var texture_path: String = String(tile_record.get("path", ""))
	var texture: Texture2D = ResourceLoader.load(texture_path, "Texture2D") as Texture2D
	if texture == null:
		return
	var rect: Rect2 = tile_record.get("rect", Rect2()) as Rect2
	var visual: Polygon2D = Polygon2D.new()
	visual.name = "%s_PluginOccluder" % String(source_polygon.name)
	visual.polygon = source_polygon.polygon
	visual.uv = _polygon_uv_for_rect(source_polygon.polygon, rect)
	visual.texture = texture
	visual.color = Color.WHITE
	visual.z_index = plugin_occluder_z_index
	visual.visible = always_visible
	visual.set_meta("pixel_game_tool_occluder_visual", true)
	visual.set_meta("pixel_game_tool_source_polygon_id", int(source_polygon.get_instance_id()))
	visual.set_meta("pixel_game_tool_always_visible", always_visible)
	_plugin_occluder_layer.add_child(visual)
	_plugin_occluder_visuals.append({
		"visual": visual,
		"source_id": int(source_polygon.get_instance_id()),
		"always_visible": always_visible,
	})


func _sync_plugin_occluder_visibility(active_source_ids: Dictionary) -> void:
	for record: Dictionary in _plugin_occluder_visuals:
		var visual: CanvasItem = record.get("visual", null) as CanvasItem
		if visual == null or not is_instance_valid(visual):
			continue
		if bool(record.get("always_visible", false)):
			visual.visible = true
			continue
		var source_id: int = int(record.get("source_id", -1))
		visual.visible = active_source_ids.has(source_id)


func _polygon_uv_for_rect(points: PackedVector2Array, rect: Rect2) -> PackedVector2Array:
	var uv_points: PackedVector2Array = PackedVector2Array()
	for point: Vector2 in points:
		uv_points.append(point - rect.position)
	return uv_points


func _overall_tile_record_for_polygon(polygon: Polygon2D) -> Dictionary:
	var tile_key: String = String(polygon.get_meta("map_stitch_tile_key", ""))
	if not tile_key.is_empty():
		for record: Dictionary in _overall_tile_records:
			if String(record.get("key", "")) == tile_key:
				return record
	var bounds: Rect2 = _polygon_bounds(polygon.polygon)
	var center: Vector2 = bounds.get_center()
	for record: Dictionary in _overall_tile_records:
		var rect: Rect2 = record.get("rect", Rect2()) as Rect2
		if rect.has_point(center):
			return record
	return {}


func _polygon_bounds(points: PackedVector2Array) -> Rect2:
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


func _configure_player_camera() -> void:
	if not _map_rect.has_area():
		return
	if _player.has_method(&"set_camera_limits"):
		_player.call(&"set_camera_limits", _map_rect.grow(camera_padding))


func _read_map_canvas_rect() -> Rect2:
	var manifest_path: String = String(_map.get_meta("map_stitch_manifest_path", ""))
	if manifest_path.is_empty() or not FileAccess.file_exists(manifest_path):
		return Rect2()
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
	if not parsed is Dictionary:
		return Rect2()
	var manifest: Dictionary = parsed as Dictionary
	var canvas: Variant = manifest.get("canvas", {})
	if not canvas is Dictionary:
		return Rect2()
	var canvas_data: Dictionary = canvas as Dictionary
	var size: Vector2 = Vector2(float(canvas_data.get("width", 0.0)), float(canvas_data.get("height", 0.0)))
	if size.x <= 0.0 or size.y <= 0.0:
		return Rect2()
	return Rect2(Vector2.ZERO, size)


func _load_overall_tile_records() -> void:
	_overall_tile_records.clear()
	var manifest_path: String = String(_map.get_meta("map_stitch_manifest_path", ""))
	if manifest_path.is_empty() or not FileAccess.file_exists(manifest_path):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
	if not parsed is Dictionary:
		return
	var manifest: Dictionary = parsed as Dictionary
	var resource_root: String = String(manifest.get("resource_root", ""))
	var layers: Variant = manifest.get("layers", [])
	if resource_root.is_empty() or not layers is Array:
		return
	for layer_variant: Variant in layers as Array:
		if not layer_variant is Dictionary:
			continue
		var layer_data: Dictionary = layer_variant as Dictionary
		if String(layer_data.get("id", "")) != "overall":
			continue
		var tiles: Variant = layer_data.get("tiles", [])
		if not tiles is Array:
			return
		for tile_variant: Variant in tiles as Array:
			if not tile_variant is Dictionary:
				continue
			var tile_data: Dictionary = tile_variant as Dictionary
			var pixel_value: Variant = tile_data.get("pixel", {})
			if not pixel_value is Dictionary:
				continue
			var pixel: Dictionary = pixel_value as Dictionary
			var rect: Rect2 = Rect2(
				Vector2(float(pixel.get("x", 0.0)), float(pixel.get("y", 0.0))),
				Vector2(float(pixel.get("width", 0.0)), float(pixel.get("height", 0.0)))
			)
			var image_path: String = _manifest_resource_path(resource_root, String(tile_data.get("image", "")))
			if rect.has_area() and not image_path.is_empty():
				_overall_tile_records.append({
					"key": String(tile_data.get("key", "")),
					"rect": rect,
					"path": image_path,
				})


func _manifest_resource_path(resource_root: String, image_path: String) -> String:
	if image_path.is_empty():
		return ""
	if image_path.begins_with("res://") or image_path.begins_with("user://"):
		return image_path
	return "res://%s/%s" % [resource_root, image_path]


func _restore_annotations_from_json() -> void:
	var annotations_path: String = _annotations_json_path()
	if annotations_path.is_empty() or not FileAccess.file_exists(annotations_path):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(annotations_path))
	if not parsed is Dictionary:
		return
	var data: Dictionary = parsed as Dictionary
	var layers: Variant = data.get("layers", [])
	if not layers is Array:
		return
	var total_shapes: int = _count_json_shapes(layers as Array)
	if total_shapes <= 0:
		return
	_ensure_annotation_roots()
	_clear_generated_annotation_nodes()
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
			var shape_name: String = String(shape_data.get("id", "%s_region" % layer_id))
			var mode_id: String = String(shape_data.get("mode", "polygon"))
			var tile_key: String = String(shape_data.get("tile_key", ""))
			_create_runtime_annotation_shape(layer_id, shape_name, points, mode_id, tile_key)


func _annotations_json_path() -> String:
	if _map == null:
		return ""
	var manifest_path: String = String(_map.get_meta("map_stitch_manifest_path", ""))
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
	return "res://%s/%s" % [resource_root, annotations_file]


func _ensure_annotation_roots() -> void:
	var annotations: Node2D = _map.get_node_or_null("Annotations") as Node2D
	if annotations == null:
		annotations = Node2D.new()
		annotations.name = "Annotations"
		annotations.visible = false
		_map.add_child(annotations)
	for layer_id: String in ["occlusion", "collision", "adjust", "top"]:
		if annotations.get_node_or_null(layer_id) == null:
			var layer_root: Node2D = Node2D.new()
			layer_root.name = layer_id
			annotations.add_child(layer_root)


func _clear_generated_annotation_nodes() -> void:
	var annotations: Node = _map.get_node_or_null("Annotations")
	if annotations == null:
		return
	for layer_id: String in ["occlusion", "collision", "adjust", "top"]:
		var root: Node = annotations.get_node_or_null(layer_id)
		if root == null:
			continue
		for child: Node in root.get_children():
			root.remove_child(child)
			child.free()


func _create_runtime_annotation_shape(layer_id: String, shape_name: String, points: Array[Vector2], mode_id: String, tile_key: String) -> void:
	var root: Node = _map.get_node_or_null("Annotations/%s" % layer_id)
	if root == null:
		return
	if layer_id == "collision":
		var body: StaticBody2D = StaticBody2D.new()
		body.name = shape_name
		body.collision_layer = _layer_to_mask(collision_layer_bit)
		body.collision_mask = 0
		_apply_runtime_shape_meta(body, mode_id, tile_key)
		root.add_child(body)
		var collision_polygon: CollisionPolygon2D = CollisionPolygon2D.new()
		collision_polygon.name = "CollisionPolygon2D"
		collision_polygon.polygon = PackedVector2Array(points)
		collision_polygon.disabled = false
		body.add_child(collision_polygon)
		return
	if layer_id == "adjust":
		var area: Area2D = Area2D.new()
		area.name = shape_name
		area.collision_layer = 0
		area.collision_mask = 0
		area.monitoring = false
		area.monitorable = false
		_apply_runtime_shape_meta(area, mode_id, tile_key)
		root.add_child(area)
		var adjust_polygon: CollisionPolygon2D = CollisionPolygon2D.new()
		adjust_polygon.name = "CollisionPolygon2D"
		adjust_polygon.polygon = PackedVector2Array(points)
		adjust_polygon.disabled = false
		area.add_child(adjust_polygon)
		return
	var polygon: Polygon2D = Polygon2D.new()
	polygon.name = shape_name
	polygon.polygon = PackedVector2Array(points)
	polygon.color = Color(1.0, 1.0, 1.0, 0.0)
	_apply_runtime_shape_meta(polygon, mode_id, tile_key)
	root.add_child(polygon)


func _apply_runtime_shape_meta(node: Node, mode_id: String, tile_key: String) -> void:
	node.set_meta("mode", mode_id)
	node.set_meta("map_stitch_tile_key", tile_key)
	node.set_meta("pixel_game_tool_runtime_region", true)


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
	var result: Array[Vector2] = []
	if not points_value is Array:
		return result
	for point_value: Variant in points_value as Array:
		if point_value is Dictionary:
			var point_data: Dictionary = point_value as Dictionary
			result.append(Vector2(float(point_data.get("x", 0.0)), float(point_data.get("y", 0.0))))
		elif point_value is Array:
			var point_array: Array = point_value as Array
			if point_array.size() >= 2:
				result.append(Vector2(float(point_array[0]), float(point_array[1])))
	return result


func _layer_to_mask(layer: int) -> int:
	return 1 << maxi(layer - 1, 0)
