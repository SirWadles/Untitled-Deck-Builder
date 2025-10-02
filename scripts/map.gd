extends Control
class_name Map

@onready var map_nodes: Node2D = $MapNodes
@onready var path_lines: Node2D = $PathLines
@onready var ui: Control = $UI
@onready var button_sound = $ButtonSound

var current_node: MapNode = null
var player_path: Array[String] = []
var available_nodes: Array[String] = []

func _ready():
	add_to_group("map")
	create_map()
	draw_paths()
	var map_state = get_node("/root/MapState")
	if map_state:
		available_nodes = map_state.get_available_nodes()
		for visited_id in map_state.get_visited_nodes():
			var node = get_node_by_id(visited_id)
			if node:
				node.set_visited()
	update_node_states()

func create_map():
	var nodes_data = [
		{"id": "start", "type": MapNode.NodeType.BATTLE, "pos": Vector2(100, 300), \
		"connections": ["battle1", "battle2"]},
		{"id": "battle1", "type": MapNode.NodeType.BATTLE, "pos": Vector2(300, 250), \
		"connections": ["shop1", "rest1"]},
		{"id": "battle2", "type": MapNode.NodeType.BATTLE, "pos": Vector2(300, 350), \
		"connections": ["rest1", "treasure1"]},
		{"id": "shop1", "type": MapNode.NodeType.SHOP, "pos": Vector2(500, 200), \
		"connections": ["battle3"]},
		{"id": "rest1", "type": MapNode.NodeType.REST, "pos": Vector2(500, 300), \
		"connections": ["battle3"]},
		{"id": "treasure1", "type": MapNode.NodeType.TREASURE, "pos": Vector2(500, 400), \
		"connections": ["battle3"]},
		{"id": "battle3", "type": MapNode.NodeType.BOSS, "pos": Vector2(700, 300), \
		"connections": []}
	]
	for node_data in nodes_data:
		var node = preload("res://scenes/map_node.tscn").instantiate()
		map_nodes.add_child(node)
		var connections_array = PackedStringArray()
		for connection in node_data["connections"]:
			connections_array.append(connection)
		node.setup_node(node_data["id"], node_data["type"],node_data["pos"], connections_array)
		node.pressed.connect(_on_map_node_pressed.bind(node))

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

func _on_map_node_pressed(node: MapNode):
	if node.node_id in available_nodes and not node.visited:
		disable_all_nodes()
		current_node = node
		player_path.append(node.node_id)
		node.set_visited()
		button_sound.play()
		update_available_nodes(node)
		var map_state = get_node("/root/MapState")
		if map_state:
			map_state.mark_node_visited(node.node_id)
		await get_tree().create_timer(1.5).timeout
		load_node_scene(node)

func update_available_nodes(selected_node: MapNode):
	available_nodes.clear()
	for connection_id in selected_node.connections:
		available_nodes.append(connection_id)

func update_node_states():
	for node in map_nodes.get_children():
		if node.visited:
			node.set_visited()
		elif node.node_id in available_nodes:
			node.set_available()
		else:
			node.set_unavailable()

func disable_all_nodes():
	for node in map_nodes.get_children():
		node.disabled = true

func enable_available_nodes():
	for node in map_nodes.get_children():
		if node.node_id in available_nodes and not node.visited:
			node.disabled = false

func load_node_scene(node: MapNode):
	match node.node_type:
		MapNode.NodeType.BATTLE:
			get_tree().change_scene_to_file("res://scenes/battle/battle.tscn")
		MapNode.NodeType.SHOP:
			get_tree().change_scene_to_file("res://scenes/shop.tscn")
		MapNode.NodeType.REST:
			show_rest_screen()
		MapNode.NodeType.TREASURE:
			show_treasure_screen()
		MapNode.NodeType.BOSS:
			get_tree().change_scene_to_file("res://scenes/battle/boss_battle.tscn")

func _on_return_to_map():
	update_node_states()
	enable_available_nodes()

func show_rest_screen():
	print("Rest")
	var player_data = get_node("/root/PlayerDatabase")
	player_data.full_heal()
	if ui and ui.has_method("show_rest_message"):
		ui.show_rest_message("Rested and recovered all your health!")
	await  get_tree().create_timer(2.0).timeout
	_on_return_to_map()

func show_rest_message(message: String):
	var label = Label.new()
	add_child(label)
	label.text = message
	label.position = Vector2(400, 300)
	label.add_theme_font_size_override("font_size", 24)
	await get_tree().create_timer(5.0).timeout
	label.queue_free()

func show_treasure_screen():
	print("treasure")
	var player_data = get_node("/root/PlayerDatabase")
	var reward_type = 0
	match reward_type:
		0:
			var gold_amount = 40 + randi() % 50
			player_data.add_gold(gold_amount)
			show_treasure_message("Found " + str(gold_amount) + " gold!")
	await  get_tree().create_timer(2.0).timeout
	_on_return_to_map()

func show_treasure_message(message: String):
	var message_label = Label.new()
	add_child(message_label)
	message_label.text = message
	message_label.position = Vector2(300, 400)
	message_label.add_theme_font_size_override("font_size", 24)
	message_label.add_theme_color_override("font_color", Color.GOLD)
	await get_tree().create_timer(5.0).timeout
	message_label.queue_free()
