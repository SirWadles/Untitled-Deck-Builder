extends Button
class_name MapNode

enum NodeType {BATTLE, SHOP, REST, TREASURE, BOSS}

@export var node_type: NodeType = NodeType.BATTLE
@export var node_id: String = ""
@export var scene_path: String = ""
@export var connections: Array[String] = []

var visited: bool = false

func _ready():
	setup_appearance()
	pressed.connect(_on_pressed)

func setup_appearance():
	match node_type:
		NodeType.BATTLE:
			text = "Battle"
			add_theme_color_override("font_color", Color.RED)
		NodeType.SHOP:
			text = "Battle"
			add_theme_color_override("font_color", Color.RED)
		NodeType.REST:
			text = "Battle"
			add_theme_color_override("font_color", Color.RED)
		NodeType.TREASURE:
			text = "Battle"
			add_theme_color_override("font_color", Color.RED)
		NodeType.BOSS:
			text = "Battle"
			add_theme_color_override("font_color", Color.RED)

func set_visited():
	visited = true
	disabled = true
	modulate = Color.GRAY

func _on_pressed():
	get_parent().node_selected.emit(self)
