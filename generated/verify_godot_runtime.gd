extends SceneTree

const MAIN_SCENE_PATH := "res://scenes/map/spawn_gameplay.tscn"
const REQUIRED_NODES := [
	"Map",
	"Player",
	"MapElementsLayer/法阵球元素",
	"EffectsLayer/雷电滋滋",
	"EffectsLayer/火焰燃烧",
]

var _frames_left: int = 300
var _scene: Node = null
var _failed: bool = false
var _cleaned_up: bool = false

func _init() -> void:
	var loaded: Resource = ResourceLoader.load(MAIN_SCENE_PATH, "PackedScene")
	if loaded == null or not (loaded is PackedScene):
		push_error("Failed to load main scene: %s" % MAIN_SCENE_PATH)
		_failed = true
		quit(1)
		return
	_scene = (loaded as PackedScene).instantiate()
	root.add_child(_scene)
	for node_path in REQUIRED_NODES:
		var found: Node = _scene.get_node_or_null(NodePath(String(node_path)))
		if found == null:
			push_error("Missing required node: %s" % String(node_path))
			_failed = true
	if _failed:
		quit(1)
		return
	print("VERIFY: scene loaded and required nodes found")

func _process(_delta: float) -> bool:
	_frames_left -= 1
	if _frames_left <= 0:
		if not _cleaned_up:
			print("VERIFY: processed runtime frames without fatal errors")
			_cleaned_up = true
			if _scene != null and is_instance_valid(_scene):
				root.remove_child(_scene)
				_scene.free()
			_scene = null
			_frames_left = 10
			return false
		quit(0)
	return false
