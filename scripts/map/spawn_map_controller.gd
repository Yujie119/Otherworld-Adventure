extends Node2D

@export var map_path: NodePath = NodePath("Map")
@export var player_path: NodePath = NodePath("Player")
@export var preferred_spawn_position: Vector2 = Vector2(8394, 4685)
@export var collision_layer_bit: int = 1
@export var player_layer_bit: int = 2
@export var camera_padding: float = 96.0
@export var player_clearance_radius: float = 28.0
@export var include_top_layer_as_occlusion: bool = true
@export var adjusted_player_z_index: int = -2

var _map: Node2D
var _player: CharacterBody2D
var _collision_polygons: Array[CollisionPolygon2D] = []
var _adjust_polygons: Array[CollisionPolygon2D] = []
var _occlusion_polygons: Array[Polygon2D] = []
var _top_polygons: Array[Polygon2D] = []
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
	_restore_annotations_from_json()
	_enable_map_collisions()
	_collect_adjust_polygons()
	_collect_occlusion_polygons()
	_place_player()
	_configure_player_camera()
	set_process(true)


func _process(_delta: float) -> void:
	if _player == null:
		return
	var player_point: Vector2 = _player.global_position
	var in_top: bool = _is_point_inside_any_top(player_point)
	var occluded: bool = _is_point_inside_any_occluder(player_point) or in_top
	if _player.has_method(&"set_occluded"):
		_player.call(&"set_occluded", occluded)
	_apply_player_depth_adjustment(_is_point_inside_any_adjust(player_point) or in_top)


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
	var roots: Array[Node] = []
	var occlusion_paths: Array[NodePath] = [NodePath("Annotations/occlusion")]
	if include_top_layer_as_occlusion:
		occlusion_paths.append(NodePath("Annotations/top"))
	for path: NodePath in occlusion_paths:
		var root: Node = _map.get_node_or_null(path)
		if root != null:
			roots.append(root)
	if roots.is_empty():
		push_warning("Spawn map has no Annotations/occlusion node.")
		return
	for root: Node in roots:
		for child: Node in root.find_children("*", "Polygon2D", true, false):
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


func _is_point_inside_any_top(global_point: Vector2) -> bool:
	for polygon: Polygon2D in _top_polygons:
		if polygon == null or not is_instance_valid(polygon):
			continue
		if Geometry2D.is_point_in_polygon(polygon.to_local(global_point), polygon.polygon):
			return true
	return false


func _is_point_inside_any_adjust(global_point: Vector2) -> bool:
	for polygon: CollisionPolygon2D in _adjust_polygons:
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
	for child: Node in _player.find_children("*", "CanvasItem", true, false):
		var canvas_item: CanvasItem = child as CanvasItem
		if canvas_item != null:
			targets.append(canvas_item)
	return targets


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
