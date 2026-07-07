extends Node2D

@export var shadow_size: Vector2i = Vector2i(54, 18)
@export var ground_offset: Vector2 = Vector2(0, 2)
@export_range(0.05, 0.8, 0.01) var max_alpha: float = 0.36

var _sprite: Sprite2D


func _ready() -> void:
	_sprite = Sprite2D.new()
	_sprite.name = "ShadowSprite"
	_sprite.centered = true
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_sprite.z_index = -1
	add_child(_sprite)
	_rebuild()


func _notification(what: int) -> void:
	if what == NOTIFICATION_EDITOR_PRE_SAVE and _sprite != null:
		_rebuild()


func _rebuild() -> void:
	if _sprite == null:
		return
	_sprite.texture = _build_shadow_texture()
	_sprite.position = ground_offset


func _build_shadow_texture() -> ImageTexture:
	var width: int = maxi(4, shadow_size.x)
	var height: int = maxi(4, shadow_size.y)
	var image := Image.create(width, height, false, Image.FORMAT_RGBA8)
	var center := Vector2(float(width - 1) * 0.5, float(height - 1) * 0.5)
	var radius := Vector2(maxf(center.x, 1.0), maxf(center.y, 1.0))
	for y in range(height):
		for x in range(width):
			var point := Vector2(float(x), float(y))
			var delta := (point - center) / radius
			var distance := delta.length_squared()
			var alpha := 0.0
			if distance <= 1.0:
				alpha = max_alpha * pow(1.0 - distance, 0.55)
			image.set_pixel(x, y, Color(0.0, 0.0, 0.0, alpha))
	return ImageTexture.create_from_image(image)
