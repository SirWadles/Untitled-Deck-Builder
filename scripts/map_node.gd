extends Button
class_name MapNode

enum NodeType {BATTLE, SHOP, REST, TREASURE, BOSS}

@export var node_type: NodeType = NodeType.BATTLE
@export var node_id: String = ""
@export var scene_path: String = ""
var connections: Array[String] = []

var visited: bool = false

func _ready():
	connections = []
	setup_appearance()
	pressed.connect(_on_pressed)

func setup_connections(new_connections: Array[String]):
	connections = new_connections.duplicate()

func setup_appearance():
	match node_type:
		NodeType.BATTLE:
			text = "Battle"
			add_theme_color_override("font_color", Color.RED)
		NodeType.SHOP:
			text = "Shop"
			add_theme_color_override("font_color", Color.BLUE)
		NodeType.REST:
			text = "Rest"
			add_theme_color_override("font_color", Color.PURPLE)
		NodeType.TREASURE:
			text = "Treasure"
			add_theme_color_override("font_color", Color.CYAN)
		NodeType.BOSS:
			text = "Boss"
			add_theme_color_override("font_color", Color.GREEN)

func set_visited():
	visited = true
	disabled = true
	modulate = Color.GRAY

func _on_pressed():
	get_parent().node_selected.emit(self)
