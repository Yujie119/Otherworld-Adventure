@tool
extends Node2D

const FX_TEX := preload("res://AI资源库/特效库/水面波动/fx.png")
const COLS := 7
const MODE := "single"
const GIZMO_COLOR := Color(0.300, 0.780, 1.000, 0.140)
const POINT_LIGHT_COLOR := Color(1.000, 1.000, 1.000, 1.000)

@export var spawn_rect_half_extents: Vector2 = Vector2(48, 48):
	set(v):
		spawn_rect_half_extents = v
		queue_redraw()

@export_range(0.0, 180.0, 0.5) var particles_per_second: float = 0.0
@export_range(0.05, 10.0, 0.01) var particle_lifetime: float = 1.0
@export var velocity_min: Vector2 = Vector2(0, 0)
@export var velocity_max: Vector2 = Vector2(0, 0)
@export_range(-200.0, 300.0, 0.5) var gravity: float = 0.0
@export_range(1.0, 60.0, 0.5) var animation_fps: float = 11.0:
	set(v):
		animation_fps = v
		if _sprite_frames != null:
			_sprite_frames.set_animation_speed(&"default", animation_fps)

@export_range(0.05, 4.0, 0.01) var particle_scale_min: float = 1.0
@export_range(0.05, 4.0, 0.01) var particle_scale_max: float = 1.0
@export_range(0.05, 4.0, 0.01) var single_scale: float = 1.0
@export_range(0.0, 24.0, 0.1) var jitter_pixels: float = 0.0
@export var random_rotation: bool = false
@export var spin_speed_range: Vector2 = Vector2(0.0, 0.0)
@export var fx_z_index: int = 5
@export_range(1, 256, 1) var max_simultaneous_particles: int = 48
@export var use_point_light: bool = false
@export_range(0.0, 3.0, 0.01) var light_energy: float = 0.0
@export_range(0.1, 5.0, 0.01) var light_texture_scale: float = 1.0
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
var _time: float = 0.0
var _single_sprite: AnimatedSprite2D
var _point_light: PointLight2D


class FxParticle extends Node2D:
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
		_sprite.speed_scale = randf_range(0.82, 1.28)
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
		_sprite.modulate.a = clampf(fade * randf_range(0.88, 1.12), 0.0, 1.0)


func _ready() -> void:
	randomize()
	_sprite_frames = _build_sprite_frames()
	if MODE == "single" or MODE == "light":
		_ensure_single_sprite()
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


func _ensure_single_sprite() -> void:
	if _single_sprite != null:
		return
	_single_sprite = AnimatedSprite2D.new()
	_single_sprite.sprite_frames = _sprite_frames
	_single_sprite.animation = &"default"
	_single_sprite.centered = true
	_single_sprite.scale = Vector2(single_scale, single_scale)
	_single_sprite.z_as_relative = false
	_single_sprite.z_index = fx_z_index
	_single_sprite.play()
	add_child(_single_sprite)
	if use_point_light:
		_point_light = PointLight2D.new()
		_point_light.color = POINT_LIGHT_COLOR
		_point_light.energy = light_energy
		_point_light.texture_scale = light_texture_scale
		_point_light.z_as_relative = false
		_point_light.z_index = fx_z_index - 1
		add_child(_point_light)


func _process(delta: float) -> void:
	if Engine.is_editor_hint() and not preview_in_editor:
		return
	_time += delta
	if MODE == "single" or MODE == "light":
		_process_single(delta)
		return
	if particles_per_second <= 0.0:
		return
	_accum += particles_per_second * delta
	while _accum >= 1.0:
		_accum -= 1.0
		if _active_particle_count() >= max_simultaneous_particles:
			break
		_spawn_one()


func _process_single(delta: float) -> void:
	if _single_sprite == null:
		_ensure_single_sprite()
		return
	var pulse: float = 1.0 + sin(_time * TAU * 0.75) * 0.035
	_single_sprite.scale = Vector2(single_scale * pulse, single_scale * pulse)
	_single_sprite.rotation += spin_speed_range.x * delta
	if _point_light != null:
		_point_light.energy = light_energy * (0.86 + sin(_time * TAU * 0.9) * 0.14)


func _spawn_one() -> void:
	var p := FxParticle.new()
	p.position = Vector2(
		randf_range(-spawn_rect_half_extents.x, spawn_rect_half_extents.x),
		randf_range(-spawn_rect_half_extents.y, spawn_rect_half_extents.y)
	)
	p.configure(
		_sprite_frames,
		Vector2(randf_range(velocity_min.x, velocity_max.x), randf_range(velocity_min.y, velocity_max.y)),
		particle_lifetime * randf_range(0.82, 1.24),
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
	var count := 0
	for c in get_children():
		if c is FxParticle:
			count += 1
	return count


func _clear_particles() -> void:
	for c in get_children():
		if c is FxParticle:
			(c as Node).queue_free()


func _draw() -> void:
	if not draw_spawn_gizmo:
		return
	if not Engine.is_editor_hint():
		return
	var r := Rect2(-spawn_rect_half_extents, spawn_rect_half_extents * 2.0)
	draw_rect(r, GIZMO_COLOR, false, 1.0)

