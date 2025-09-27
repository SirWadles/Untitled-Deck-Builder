extends Control
class_name Map

@onready var map_nodes: Node2D = $MapNodes
@onready var path_lines: Node2D = $PathLines

var current_node: MapNode = null
var player_path: Array[String] = []

signal node_selected(node: MapNode)

func _ready():
	create_map()
	draw_paths()

func create_map():
	var nodes_data = [
		{"id": "start", "type": MapNode.NodeType.BATTLE, "pos": Vector2(100, 50), \
		"connections": ["battle1", "battle2"]},
		{"id": "battle1", "type": MapNode.NodeType.BATTLE, "pos": Vector2(200, 100), \
		"connections": ["shop1", "rest1"]},
		{"id": "battle2", "type": MapNode.NodeType.BATTLE, "pos": Vector2(200, 200), \
		"connections": ["rest1", "treasure1"]},
		{"id": "shop1", "type": MapNode.NodeType.SHOP, "pos": Vector2(100, 50), \
		"connections": ["boss1"]},
		{"id": "rest1", "type": MapNode.NodeType.REST, "pos": Vector2(100, 50), \
		"connections": ["boss1"]},
		{"id": "treasure1", "type": MapNode.NodeType.TREASURE, "pos": Vector2(100, 50), \
		"connections": ["boss1"]},
		{"id": "boss1", "type": MapNode.NodeType.BOSS, "pos": Vector2(100, 50), \
		"connections": []}
	]
	for node_data in nodes_data:
		var node = preload("res://scenes/map_node.tscn").instantiate()
		map_nodes.add_child(node)
		node.node_id = node_data["id"]
		node.node_type = node_data["type"]
		node.position = node_data["pos"]
		node.connections = node_data["connections"]
		node.node_selected.connect(_on_node_selected)

func draw_paths():
	for node in map_nodes.get_children():
		for connection_id in node.connections:
			var target_node = get_node_by_id(connection_id)
			if target_node:
				draw_line_between_nodes(node, target_node)

func draw_line_between_nodes(from_node: MapNode, to_node: MapNode):
	var line = Line2D.new()
	path_lines.add_child(line)
	line.add_point(from_node.position + from_node.size / 2)
	line.add_point(to_node.position + to_node.size / 2)
	line.width = 3
	line.default_color = Color.WHITE

func get_node_by_id(node_id: String) -> MapNode:
	for node in map_nodes.get_children():
		if node.node_id == node_id:
			return node
	return null

func _on_node_selected(node: MapNode):
	if current_node == null or node.node_id in current_node.connections:
		current_node = node
		player_path.append(node.node_id)
		node.set_visited()
		load_node_scene(node)

func load_node_scene(node: MapNode):
	match node.node_type:
		MapNode.NodeType.BATTLE:
			get_tree().change_scene_to_file("res://scenes/battle/battle.tscn")
		MapNode.NodeType.SHOP:
			get_tree().change_scene_to_file("res://scenes/shop/shop.tscn")
		MapNode.NodeType.REST:
			show_rest_screen()
		MapNode.NodeType.TREASURE:
			show_treasure_screen()
		MapNode.NodeType.BOSS:
			get_tree().change_scene_to_file("res://scenes/battle/boss_battle.tscn")

func show_rest_screen():
	print("Rest")
	await  get_tree().create_timer(2.0).timeout

func show_treasure_screen():
	print("treasure")
	await  get_tree().create_timer(2.0).timeout
