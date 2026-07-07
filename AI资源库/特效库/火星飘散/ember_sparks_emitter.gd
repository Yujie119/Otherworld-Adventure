@tool
extends Node2D

const FX_TEX := preload("res://AI资源库/特效库/火星飘散/fx.png")
const COLS := 7
const GIZMO_COLOR := Color(1.000, 0.420, 0.120, 0.150)

@export var spawn_rect_half_extents: Vector2 = Vector2(34, 10):
	set(v):
		spawn_rect_half_extents = v
		queue_redraw()

@export_range(0.0, 180.0, 0.5) var particles_per_second: float = 4.8
@export_range(0.05, 10.0, 0.01) var particle_lifetime: float = 1.45
@export var velocity_min: Vector2 = Vector2(-7, -30)
@export var velocity_max: Vector2 = Vector2(7, -14)
@export_range(-200.0, 300.0, 0.5) var gravity: float = -2.0
@export_range(1.0, 60.0, 0.5) var animation_fps: float = 12.0:
	set(v):
		animation_fps = v
		if _sprite_frames != null:
			_sprite_frames.set_animation_speed(&"default", animation_fps)

@export_range(0.05, 4.0, 0.01) var particle_scale_min: float = 0.65
@export_range(0.05, 4.0, 0.01) var particle_scale_max: float = 1.05
@export_range(0.0, 24.0, 0.1) var jitter_pixels: float = 0.35
@export var random_rotation: bool = true
@export var spin_speed_range: Vector2 = Vector2(-0.9, 0.9)
@export var fx_z_index: int = 8
@export_range(1, 256, 1) var max_simultaneous_particles: int = 32
@export var preview_in_editor: bool = true:
	set(v):
		preview_in_editor = v
		if not preview_in_editor:
			_clear_particles()

@export var draw_spawn_gizmo: bool = true:
	set(v):
		draw_spawn_gizmo = v
		queue_redraw()

var _sprite_frames: SpriteFrames
var _accum: float = 0.0


class EmberParticle extends Node2D:
	var _velocity: Vector2
	var _life: float
	var _max_life: float
	var _gravity_p: float
	var _jitter: float
	var _base_position: Vector2
	var _spin_speed: float
	var _sprite: AnimatedSprite2D

	func configure(frames: SpriteFrames, vel: Vector2, lifetime: float, grav: float, z_idx: int, smin: float, smax: float, jitter: float, random_rot: bool, spin_min: float, spin_max: float) -> void:
		_velocity = vel
		_life = lifetime
		_max_life = lifetime
		_gravity_p = grav
		_jitter = jitter
		_base_position = position
		_spin_speed = randf_range(spin_min, spin_max)
		z_as_relative = false
		z_index = z_idx
		if random_rot:
			rotation = randf_range(-PI, PI)
		_sprite = AnimatedSprite2D.new()
		_sprite.sprite_frames = frames
		_sprite.animation = &"default"
		_sprite.centered = true
		_sprite.speed_scale = randf_range(0.85, 1.35)
		var sc: float = randf_range(smin, smax)
		_sprite.scale = Vector2(sc, sc)
		_sprite.play()
		add_child(_sprite)

	func _process(delta: float) -> void:
		_velocity.y += _gravity_p * delta
		_base_position += _velocity * delta
		if _jitter > 0.0:
			position = _base_position + Vector2(randf_range(-_jitter, _jitter), randf_range(-_jitter, _jitter))
		else:
			position = _base_position
		rotation += _spin_speed * delta
		_life -= delta
		if _life <= 0.0:
			queue_free()
			return
		var fade: float = clampf(_life / maxf(_max_life, 0.001), 0.0, 1.0)
		var flicker: float = randf_range(0.82, 1.18)
		_sprite.modulate.a = clampf(fade * flicker, 0.0, 1.0)


func _ready() -> void:
	randomize()
	_sprite_frames = _build_sprite_frames()
	queue_redraw()


func _build_sprite_frames() -> SpriteFrames:
	var tex: Texture2D = FX_TEX
	var fw: int = int(floor(float(tex.get_width()) / float(COLS)))
	var fh: int = tex.get_height()
	var sf: SpriteFrames = SpriteFrames.new()
	if not sf.has_animation(&"default"):
		sf.add_animation(&"default")
	sf.set_animation_loop(&"default", true)
	sf.set_animation_speed(&"default", animation_fps)
	for i in COLS:
		var at: AtlasTexture = AtlasTexture.new()
		at.atlas = tex
		at.region = Rect2(i * fw, 0, fw, fh)
		sf.add_frame(&"default", at)
	return sf


func _process(delta: float) -> void:
	if Engine.is_editor_hint() and not preview_in_editor:
		return
	if particles_per_second <= 0.0:
		return
	_accum += particles_per_second * delta
	while _accum >= 1.0:
		_accum -= 1.0
		if _active_particle_count() >= max_simultaneous_particles:
			break
		_spawn_one()


func _spawn_one() -> void:
	var p: EmberParticle = EmberParticle.new()
	p.position = Vector2(
		randf_range(-spawn_rect_half_extents.x, spawn_rect_half_extents.x),
		randf_range(-spawn_rect_half_extents.y, spawn_rect_half_extents.y)
	)
	p.configure(
		_sprite_frames,
		Vector2(randf_range(velocity_min.x, velocity_max.x), randf_range(velocity_min.y, velocity_max.y)),
		particle_lifetime * randf_range(0.78, 1.22),
		gravity,
		fx_z_index,
		particle_scale_min,
		particle_scale_max,
		jitter_pixels,
		random_rotation,
		spin_speed_range.x,
		spin_speed_range.y
	)
	add_child(p)


func _active_particle_count() -> int:
	var count: int = 0
	for c in get_children():
		if c is EmberParticle:
			count += 1
	return count


func _clear_particles() -> void:
	for c in get_children():
		if c is EmberParticle:
			(c as Node).queue_free()


func _draw() -> void:
	if not draw_spawn_gizmo:
		return
	if not Engine.is_editor_hint():
		return
	var r: Rect2 = Rect2(-spawn_rect_half_extents, spawn_rect_half_extents * 2.0)
	draw_rect(r, GIZMO_COLOR, false, 1.0)
