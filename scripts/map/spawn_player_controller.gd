extends CharacterBody2D

const _TinaData := preload("res://ifmap/infmap_tina_data.gd")

@export var walk_speed: float = 260.0
@export var run_speed_multiplier: float = 1.8
@export var zoom_min: float = 0.65
@export var zoom_max: float = 3.5
@export var zoom_step: float = 0.18
@export_range(0.15, 1.0, 0.01) var occluded_alpha: float = 0.42

var _facing: int = 1
var _anim_name: String = "idledown"
var _frame_idx: int = 0
var _anim_accum: float = 0.0
var _anim_defs: Dictionary = {}
var _is_occluded := false
var _occlusion_strength: float = 0.0

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _camera: Camera2D = $Camera2D


func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	add_to_group("player")
	_anim_defs = _TinaData.anim_by_name()
	if _sprite.texture == null:
		_sprite.texture = load("res://ifmap/map/TINA.png") as Texture2D
	_sprite.region_enabled = true
	_sprite.centered = true
	_apply_tina_frame()
	_apply_occlusion_visual()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if not mouse_event.pressed:
			return
		if mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_camera.zoom = (_camera.zoom + Vector2(zoom_step, zoom_step)).clamp(Vector2(zoom_min, zoom_min), Vector2(zoom_max, zoom_max))
		elif mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_camera.zoom = (_camera.zoom - Vector2(zoom_step, zoom_step)).clamp(Vector2(zoom_min, zoom_min), Vector2(zoom_max, zoom_max))


func _process(delta: float) -> void:
	var def: Variant = _anim_defs.get(_anim_name)
	if def == null:
		return
	var speed: float = float(def.get("speed", _TinaData.DEFAULT_ANIM_SPEED))
	var frames: Array = def.get("frames", [])
	if frames.is_empty():
		return
	_anim_accum += speed * delta
	while _anim_accum >= 1.0:
		_anim_accum -= 1.0
		_frame_idx = (_frame_idx + 1) % frames.size()
	_apply_tina_frame()


func _physics_process(_delta: float) -> void:
	var input_dir := _movement_input()
	_update_animation_state(input_dir)
	var speed := walk_speed * (run_speed_multiplier if Input.is_key_pressed(KEY_SHIFT) else 1.0)
	velocity = input_dir * speed
	move_and_slide()


func set_occluded(value: bool) -> void:
	if _is_occluded == value:
		return
	_is_occluded = value
	_occlusion_strength = 1.0 if value else 0.0
	_apply_occlusion_visual()


func set_occlusion_strength(value: float) -> void:
	var next_strength: float = clampf(value, 0.0, 1.0)
	if is_equal_approx(_occlusion_strength, next_strength):
		return
	_occlusion_strength = next_strength
	_is_occluded = _occlusion_strength > 0.01
	_apply_occlusion_visual()


func is_occluded() -> bool:
	return _is_occluded


func set_camera_limits(rect: Rect2) -> void:
	if rect.has_area():
		_camera.limit_left = int(floor(rect.position.x))
		_camera.limit_top = int(floor(rect.position.y))
		_camera.limit_right = int(ceil(rect.position.x + rect.size.x))
		_camera.limit_bottom = int(ceil(rect.position.y + rect.size.y))


func _movement_input() -> Vector2:
	var x := 0.0
	var y := 0.0
	if Input.is_key_pressed(KEY_A) or Input.is_action_pressed(&"ui_left"):
		x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_action_pressed(&"ui_right"):
		x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_action_pressed(&"ui_up"):
		y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_action_pressed(&"ui_down"):
		y += 1.0
	var dir := Vector2(x, y)
	if dir.length_squared() > 1.0:
		dir = dir.normalized()
	return dir


func _update_animation_state(input_dir: Vector2) -> void:
	var next_anim := _anim_name
	var walk_prefix := "run" if Input.is_key_pressed(KEY_SHIFT) else "walk"
	if input_dir == Vector2.ZERO:
		next_anim = "idleL" if _facing == -1 else "idledown"
	elif absf(input_dir.y) >= absf(input_dir.x):
		next_anim = "%sup" % walk_prefix if input_dir.y < 0.0 else "%sdown" % walk_prefix
	else:
		next_anim = "%sL" % walk_prefix
		_facing = -1 if input_dir.x < 0.0 else 1
	if next_anim == _anim_name:
		return
	_anim_name = next_anim
	_frame_idx = 0
	_anim_accum = 0.0


func _apply_tina_frame() -> void:
	var def: Variant = _anim_defs.get(_anim_name)
	if def == null:
		return
	var frames: Array = def.get("frames", [])
	if frames.is_empty():
		return
	var key := str(frames[_frame_idx % frames.size()])
	var region: Variant = _TinaData.REGIONS.get(key)
	if not region is Rect2:
		return
	var rect := region as Rect2
	_sprite.region_rect = rect
	_sprite.flip_h = _anim_name.ends_with("L") and _facing == 1
	_sprite.offset = Vector2(0.0, -rect.size.y * 0.5)


func _apply_occlusion_visual() -> void:
	_sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
