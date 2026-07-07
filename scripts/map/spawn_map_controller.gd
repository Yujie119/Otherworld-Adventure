extends Node2D

@export var map_path: NodePath = NodePath("Map")
@export var player_path: NodePath = NodePath("Player")
@export var preferred_spawn_position: Vector2 = Vector2(8394, 4685)
@export var collision_layer_bit: int = 1
@export var player_layer_bit: int = 2
@export var camera_padding: float = 96.0
@export var player_clearance_radius: float = 28.0

var _map: Node2D
var _player: CharacterBody2D
var _collision_polygons: Array[CollisionPolygon2D] = []
var _occlusion_polygons: Array[Polygon2D] = []
var _map_rect: Rect2 = Rect2()


func _ready() -> void:
	_map = get_node_or_null(map_path) as Node2D
	_player = get_node_or_null(player_path) as CharacterBody2D
	if _map == null or _player == null:
		push_error("SpawnMapController requires Map and Player nodes.")
		return
	_map_rect = _read_map_canvas_rect()
	_enable_map_collisions()
	_collect_occlusion_polygons()
	_place_player()
	_configure_player_camera()
	set_process(true)


func _process(_delta: float) -> void:
	if _player == null:
		return
	var occluded: bool = _is_point_inside_any_occluder(_player.global_position)
	if _player.has_method(&"set_occluded"):
		_player.call(&"set_occluded", occluded)


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
	var roots: Array[Node] = []
	var occlusion_paths: Array[NodePath] = [
		NodePath("Annotations/occlusion"),
		NodePath("Annotations/top"),
	]
	for path: NodePath in occlusion_paths:
		var root: Node = _map.get_node_or_null(path)
		if root != null:
			roots.append(root)
	if roots.is_empty():
		push_warning("Spawn map has no Annotations/occlusion or Annotations/top node.")
		return
	for root: Node in roots:
		for child: Node in root.find_children("*", "Polygon2D", true, false):
			var polygon: Polygon2D = child as Polygon2D
			_occlusion_polygons.append(polygon)


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


func _layer_to_mask(layer: int) -> int:
	return 1 << maxi(layer - 1, 0)
