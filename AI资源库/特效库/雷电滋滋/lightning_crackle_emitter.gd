@tool
extends Node2D

const FX_TEX := preload("res://AI资源库/特效库/雷电滋滋/fx.png")
const COLS := 7

@export var spawn_rect_half_extents: Vector2 = Vector2(48, 24):
	set(v):
		spawn_rect_half_extents = v
		queue_redraw()

@export_range(0.0, 80.0, 0.5) var arcs_per_second: float = 10.0
@export_range(0.05, 2.0, 0.01) var arc_lifetime: float = 0.38
@export_range(1.0, 60.0, 0.5) var animation_fps: float = 20.0:
	set(v):
		animation_fps = v
		if _sprite_frames != null:
			_sprite_frames.set_animation_speed(&"default", animation_fps)

@export_range(0.05, 3.0, 0.01) var arc_scale_min: float = 0.30
@export_range(0.05, 3.0, 0.01) var arc_scale_max: float = 0.65
@export_range(0.0, 16.0, 0.1) var jitter_pixels: float = 1.8
@export var arc_z_index: int = 8
@export_range(1, 256, 1) var max_simultaneous_arcs: int = 36
@export var preview_in_editor: bool = true:
	set(v):
		preview_in_editor = v
		if not preview_in_editor:
			_clear_arcs()

@export var draw_spawn_gizmo: bool = true:
	set(v):
		draw_spawn_gizmo = v
		queue_redraw()

var _sprite_frames: SpriteFrames
var _accum: float = 0.0


class LightningArc extends Node2D:
	var _life: float
	var _max_life: float
	var _jitter: float
	var _base_position: Vector2
	var _sprite: AnimatedSprite2D

	func configure(frames: SpriteFrames, lifetime: float, z_idx: int, smin: float, smax: float, jitter: float) -> void:
		_life = lifetime
		_max_life = lifetime
		_jitter = jitter
		_base_position = position
		z_as_relative = false
		z_index = z_idx
		_sprite = AnimatedSprite2D.new()
		_sprite.sprite_frames = frames
		_sprite.animation = &"default"
		_sprite.centered = true
		_sprite.speed_scale = randf_range(0.85, 1.45)
		_sprite.flip_h = randf() < 0.5
		_sprite.flip_v = randf() < 0.35
		var sc: float = randf_range(smin, smax)
		_sprite.scale = Vector2(sc, sc)
		_sprite.modulate = Color(0.75, 0.95, 1.0, 1.0)
		_sprite.play()
		add_child(_sprite)

	func _process(delta: float) -> void:
		_life -= delta
		if _life <= 0.0:
			queue_free()
			return
		var fade: float = clampf(_life / maxf(_max_life, 0.001), 0.0, 1.0)
		var flicker: float = randf_range(0.68, 1.22)
		_sprite.modulate.a = clampf(fade * flicker, 0.0, 1.0)
		position = _base_position + Vector2(randf_range(-_jitter, _jitter), randf_range(-_jitter, _jitter))


func _ready() -> void:
	randomize()
	_sprite_frames = _build_sprite_frames()
	queue_redraw()


func _build_sprite_frames() -> SpriteFrames:
	var tex: Texture2D = FX_TEX
	var fw: int = int(floor(float(tex.get_width()) / float(COLS)))
	var fh: int = tex.get_height()
	var sf := SpriteFrames.new()
	if not sf.has_animation(&"default"):
		sf.add_animation(&"default")
	sf.set_animation_loop(&"default", true)
	sf.set_animation_speed(&"default", animation_fps)
	for i in COLS:
		var at := AtlasTexture.new()
		at.atlas = tex
		at.region = Rect2(i * fw, 0, fw, fh)
		sf.add_frame(&"default", at)
	return sf


func _process(delta: float) -> void:
	if Engine.is_editor_hint() and not preview_in_editor:
		return
	if arcs_per_second <= 0.0:
		return
	_accum += arcs_per_second * delta
	while _accum >= 1.0:
		_accum -= 1.0
		if _active_arc_count() >= max_simultaneous_arcs:
			break
		_spawn_one()


func _spawn_one() -> void:
	var p := LightningArc.new()
	p.position = Vector2(
		randf_range(-spawn_rect_half_extents.x, spawn_rect_half_extents.x),
		randf_range(-spawn_rect_half_extents.y, spawn_rect_half_extents.y)
	)
	p.rotation = randf_range(-PI, PI)
	p.configure(
		_sprite_frames,
		arc_lifetime * randf_range(0.78, 1.25),
		arc_z_index,
		arc_scale_min,
		arc_scale_max,
		jitter_pixels
	)
	add_child(p)


func _active_arc_count() -> int:
	var count := 0
	for c in get_children():
		if c is LightningArc:
			count += 1
	return count


func _clear_arcs() -> void:
	for c in get_children():
		if c is LightningArc:
			(c as Node).queue_free()


func _draw() -> void:
	if not draw_spawn_gizmo:
		return
	if not Engine.is_editor_hint():
		return
	var r := Rect2(-spawn_rect_half_extents, spawn_rect_half_extents * 2.0)
	draw_rect(r, Color(0.35, 0.85, 1.0, 0.16), false, 1.0)
