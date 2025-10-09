extends Control
class_name Map

@onready var map_nodes: Node2D = $MapNodes
@onready var path_lines: Node2D = $PathLines
@onready var ui: Control = $UI
@onready var button_sound = $ButtonSound
@onready var deck_viewer: Control = $MapDeckViewer
@onready var deck_view_button: Button = $UI/DeckViewButton

@onready var music_player = $Audio/MusicPlayer
@onready var audio_options = $Audio/AudioOptions

var current_node: MapNode = null
var player_path: Array[String] = []
var available_nodes: Array[String] = []

var map_params = {
	"rows": 4,
	"nodes_per_row": 3,
	"min_nodes_per_row": 2,
	"node_spacing": Vector2(150, 100),
	"start_pos": Vector2(100, 300),
	"horizontal_spread": 400,
	"branching_factor": 0.8,
}
var node_spacing: Vector2

func _ready():
	add_to_group("map")
	node_spacing = Vector2(100, 50)
	var map_state = get_node("/root/MapState")
	if map_state:
		if map_state.saved_map_data.is_empty():
			create_procedural_map()
			var map_data = []
			for node in map_nodes.get_children():
				map_data.append({
					"id": node.node_id,
					"type": node.node_type,
					"pos": node.position,
					"connections": node.connections
				})
				map_state.save_map_data(map_data)
		else:
			recreate_saved_map(map_state.get_map_data())
		draw_paths()
		var visited_nodes = map_state.get_visited_nodes()
		for visited_id in visited_nodes:
			var node = get_node_by_id(visited_id)
			if node:
				node.set_visited()
		available_nodes = map_state.get_available_nodes()
		if available_nodes.is_empty() and not visited_nodes.is_empty():
			var last_visited_id = visited_nodes[visited_nodes.size() - 1]
			var last_node = get_node_by_id(last_visited_id)
			if last_node:
				available_nodes.clear()
				for connection_id in last_node.connections:
					available_nodes.append(connection_id)
	update_node_states()
	if deck_view_button:
		deck_view_button.pressed.connect(_on_deck_view_button_pressed)
	audio_options.visible = false
	music_player.bus = "Music"
	music_player.play()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		audio_options.show_options()

func create_procedural_map():
	clear_existing_map()
	var all_nodes = []
	var rows = []
	var start_node_data = {
		"id": "start",
		"type": MapNode.NodeType.BATTLE,
		"pos": map_params["start_pos"],
		"connections": [],
		"row": 0
	}
	all_nodes.append(start_node_data)
	rows.append([start_node_data])
	
	for row_index in range(1, map_params["rows"] + 1):
		var row_nodes = create_row(row_index, rows[row_index - 1])
		rows.append(row_nodes)
		all_nodes.append_array(row_nodes)
	for first_row_node in rows[1]:
		start_node_data["connections"].append(first_row_node["id"])
	var last_row = rows[rows.size() - 1]
	var boss_pos = Vector2(
		map_params["start_pos"].x + (map_params["rows"] + 1) * map_params["node_spacing"].x,
		map_params["start_pos"].y
	)
	var boss_connections = []
	for node in last_row:
		boss_connections.append(node["id"])
	var boss_node_data = {
		"id": "boss",
		"type": MapNode.NodeType.BOSS,
		"pos": boss_pos,
		"connections": [],
		"row": map_params["rows"] + 1
	}
	all_nodes.append(boss_node_data)
	for node_id in boss_connections:
		var node = find_node_by_id(all_nodes, node_id)
		if node:
			node["connections"].append("boss")
	for node_data in all_nodes:
		create_map_node(node_data)
	print("Map generation complete:")
	print("Total nodes: ", all_nodes.size())
	print("Last row nodes: ", last_row.size())
	print("Boss connections: ", boss_connections.size())
	for node in all_nodes:
		if node["id"] == "boss":
			print("Boss node connections: ", node["connections"])
		elif node["row"] == map_params["rows"]:  # Last row nodes
			print("Last row node ", node["id"], " connects to: ", node["connections"])

func find_node_by_id(all_nodes: Array, node_id: String) -> Dictionary:
	for node_data in all_nodes:
		if node_data["id"] == node_id:
			return node_data
	return {}

func create_row(row_index: int, previous_row: Array) -> Array:
	var row_nodes = []
	var nodes_in_row = map_params["min_nodes_per_row"] + randi() % (map_params["nodes_per_row"] - map_params["min_nodes_per_row"] + 1) 
	var base_y = map_params["start_pos"].y
	var vertical_range = map_params["horizontal_spread"] / 2
	var y_spacing = vertical_range * 2.0 / max(nodes_in_row, 1)
	for i in range(nodes_in_row):
		var node_id = "node_%d_%d" % [row_index, i]
		
		var pos_x = map_params["start_pos"].x + row_index * map_params["node_spacing"].x
		var pos_y = base_y - vertical_range + i * y_spacing + randf() * y_spacing * 0.3
		var node_type = randi() % 4
		var node_data = {
			"id": node_id,
			"type": node_type,
			"pos": Vector2(pos_x, pos_y),
			"connections": [],
			"row": row_index
		}
		row_nodes.append(node_data)
	connect_rows(previous_row, row_nodes)
	return row_nodes

func connect_rows(previous_row: Array, current_row: Array):
	for previous_node in previous_row:
		previous_node["connections"].clear()
	for current_node in current_row:
		var possible_connections = previous_row.duplicate()
		possible_connections.shuffle()
		var num_connections = 1
		if possible_connections.size() > 1 and randf() < map_params["branching_factor"]:
			num_connections = 2
		num_connections = min(num_connections, possible_connections.size())
		for i in range(num_connections):
			if i < possible_connections.size():
				var previous_node = possible_connections[i]
				previous_node["connections"].append(current_node["id"])
	for previous_node in previous_row:
		if previous_node["connections"].is_empty() and current_row.size() > 0:
			var best_candidate = current_row[0]
			for candidate in current_row:
				if candidate["connections"].size() < best_candidate["connections"].size():
					best_candidate = candidate
			if best_candidate["connections"].size() < 3:
				best_candidate["connections"].append(previous_node["id"])

func create_map_node(node_data: Dictionary):
	var node = preload("res://scenes/map_node.tscn").instantiate()
	map_nodes.add_child(node)
	var connections_array = PackedStringArray()
	for connection in node_data["connections"]:
		connections_array.append(connection)
	node.setup_node(node_data["id"], node_data["type"], node_data["pos"], connections_array, node_spacing)
	node.pressed.connect(_on_map_node_pressed.bind(node))

func clear_existing_map():
	for node in map_nodes.get_children():
		node.queue_free()
	for line in path_lines.get_children():
		line.queue_free()

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
	print("=== NODE PRESSED ===")
	print("Node pressed: ", node.node_id)
	print("Node connections: ", node.connections)
	print("Available nodes before: ", available_nodes)
	print("Node visited: ", node.visited)
	if node.node_id in available_nodes and not node.visited:
		print("Node is valid - proceeding...")
		disable_all_nodes()
		current_node = node
		player_path.append(node.node_id)
		node.set_visited()
		button_sound.play()
		update_available_nodes(node)
		var map_state = get_node("/root/MapState")
		if map_state:
			print("Calling mark_node_visited with: ", node.node_id)
			map_state.mark_node_visited(node.node_id)
		await get_tree().create_timer(1.5).timeout
		load_node_scene(node)
	else:
		print("Node is NOT valid - skipping")
		print("Reason: ")
		if node.visited:
			print("- Node already visited")
		if node.node_id not in available_nodes:
			print("- Node ID not in available_nodes")
	print("===================")

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
	var map_state = get_node("/root/MapState")
	if map_state:
		available_nodes = map_state.get_available_nodes()
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

func _on_deck_view_button_pressed():
	if deck_viewer:
		deck_viewer.show_viewer()

func recreate_saved_map(map_data: Array):
	clear_existing_map()
	for node_data in map_data:
		var node = preload("res://scenes/map_node.tscn").instantiate()
		map_nodes.add_child(node)
		node.setup_node(node_data["id"], node_data["type"], node_data["pos"], node_data["connections"], node_spacing)
		node.pressed.connect(_on_map_node_pressed.bind(node))
