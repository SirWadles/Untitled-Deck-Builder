extends Button
class_name MapNode

enum NodeType {BATTLE, SHOP, REST, TREASURE, BOSS}

var node_type: NodeType = NodeType.BATTLE
var node_id: String = ""
var scene_path: String = ""

var connections: PackedStringArray = []
var visited: bool = false

func _ready():
	custom_minimum_size = Vector2(80, 40)
	size = Vector2(80, 40)

func setup_node(id: String, type: NodeType, pos: Vector2, new_connections: PackedStringArray):
	node_id = id
	node_type = type
	position = pos
	connections = new_connections
	setup_appearance()

func setup_appearance():
	print("Setting up node: ", node_id, " with type: ", node_type)
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

func set_connections(new_connections: PackedStringArray):
	connections = new_connections

func set_visited():
	visited = true
	disabled = true
	modulate = Color.GRAY
