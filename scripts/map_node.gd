extends Button
class_name MapNode

enum NodeType {BATTLE, SHOP, REST, TREASURE, BOSS}

var node_type: NodeType = NodeType.BATTLE
var node_id: String = ""
var scene_path: String = ""

var connections: PackedStringArray = []
var visited: bool = false

const TEXTURE_PATHS = {
	NodeType.BATTLE: "res://assets/buttons/Map Button (Battle).png",
	NodeType.SHOP: "res://assets/buttons/Map Button (Shop).png",
	NodeType.REST: "res://assets/buttons/Map Button (Rest).png",
	NodeType.TREASURE: "res://assets/buttons/Map Button (Treasure).png",
	NodeType.BOSS: "res://assets/buttons/Map Button (Boss).png",
}

var node_size: Vector2 = Vector2(80, 40)

func _ready():
	custom_minimum_size = Vector2(80, 40)
	size = Vector2(80, 40)
	text = ""
	expand_icon = true

func setup_node(id: String, type: NodeType, pos: Vector2, new_connections: PackedStringArray, custom_size: Vector2):
	node_id = id
	node_type = type
	position = pos
	connections = new_connections
	node_size = custom_size
	custom_minimum_size = node_size
	size = node_size
	setup_appearance()

func setup_appearance():
	print("Setting up node: ", node_id, " with type: ", node_type)
	var texture_path = TEXTURE_PATHS.get(node_type)
	if texture_path and ResourceLoader.exists(texture_path):
		var texture = load(texture_path)
		icon = texture
		icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	else:
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

func get_center_position() -> Vector2:
	return position + (node_size / 2)

func set_connections(new_connections: PackedStringArray):
	connections = new_connections

func set_visited():
	visited = true
	disabled = true
	modulate = Color.GRAY

func set_available():
	disabled = false
	modulate = Color.WHITE

func set_unavailable():
	disabled = true
	modulate = Color.DIM_GRAY
