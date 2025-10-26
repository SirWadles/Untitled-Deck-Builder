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
var navigation_cooldown: float = 0.0
var is_in_cooldown: bool = false

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
var input_handler: Node
var focused_node: MapNode = null
var available_map_nodes: Array[MapNode] = []

func _ready():
	if has_node("/root/GlobalInputHandler"):
		input_handler = get_node("/root/GlobalInputHandler")
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
	#if deck_view_button:
		#deck_view_button.pressed.connect(_on_deck_view_button_pressed)
	audio_options.visible = false
	music_player.bus = "Music"
	music_player.play()
	
	focus_mode = Control.FOCUS_ALL
	_setup_controller_navigation()

func _process(delta):
	if is_in_cooldown:
		navigation_cooldown -= delta
		if navigation_cooldown <= 0:
			is_in_cooldown = false

func _setup_controller_navigation():
	await get_tree().process_frame
	_update_available_map_nodes()
	if input_handler and input_handler.is_controller_active() and available_map_nodes.size() > 0:
		focused_node = available_map_nodes[0]
		input_handler.set_current_focus(focused_node)
		_highlight_focused_node()

func _update_available_map_nodes():
	available_map_nodes.clear()
	for node in map_nodes.get_children():
		if node.node_id in available_nodes and not node.visited:
			available_map_nodes.append(node)
			if not node.focus_entered.is_connected(_on_map_node_focus_entered):
				node.focus_entered.connect(_on_map_node_focus_entered.bind(node))

func _on_map_node_focus_entered(node: MapNode):
	focused_node = node
	_highlight_focused_node()

func _highlight_focused_node():
	for node in map_nodes.get_children():
		if node.visited:
			node.modulate = Color.GRAY
		elif node.node_id in available_nodes:
			node.modulate = Color.WHITE
		else:
			node.modulate = Color.DIM_GRAY
	if focused_node and focused_node.node_id in available_nodes and not focused_node.visited:
		focused_node.modulate = Color.YELLOW
		focused_node.scale = Vector2(1.1, 1.1)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		audio_options.show_options()
		if input_handler:
			input_handler.disable_navigation()
	if is_in_cooldown:
		return
	if input_handler and input_handler.navigation_enabled and available_map_nodes.size() > 0:
		if event.is_action_pressed("ui_down"):
			_navigation_to_adjacent_node(1)
			is_in_cooldown = true
			navigation_cooldown = 0.3
		elif event.is_action_pressed("ui_up"):
			_navigation_to_adjacent_node(-1)
			is_in_cooldown = true
			navigation_cooldown = 0.3
		elif event.is_action_pressed("ui_left") and event.is_action_pressed("ui_up"):
			_navigation_to_adjacent_node(-1)
			is_in_cooldown = true
			navigation_cooldown = 0.3
		elif event.is_action_pressed("ui_up") and event.is_action_pressed("ui_up"):
			_navigation_to_adjacent_node(-1)
			is_in_cooldown = true
			navigation_cooldown = 0.3
		elif event.is_action_pressed("ui_left") and event.is_action_pressed("ui_down"):
			_navigation_to_adjacent_node(1)
			is_in_cooldown = true
			navigation_cooldown = 0.3
		elif event.is_action_pressed("ui_up") and event.is_action_pressed("ui_down"):
			_navigation_to_adjacent_node(1)
			is_in_cooldown = true
			navigation_cooldown = 0.3
		elif event.is_action_pressed("ui_accept") and focused_node:
			_on_map_node_pressed(focused_node)

func _navigation_to_adjacent_node(direction: int):
	if available_map_nodes.size() <= 0:
		return
	if not focused_node:
		focused_node = available_map_nodes[0]
		_highlight_focused_node()
		return
	var highest_node = focused_node
	var lowest_node = focused_node
	for node in available_map_nodes:
		if node.position.y < highest_node.position.y:
			highest_node = node
		if node.position.y > lowest_node.position.y:
			lowest_node = node
	if direction < 0 and focused_node == highest_node:
		return
	if direction > 0 and focused_node == lowest_node:
		return
	var candidates = []
	var current_pos = focused_node.position
	for node in available_map_nodes:
		if node == focused_node:
			continue
		if direction > 0 and node.position.y > current_pos.y:
			candidates.append(node)
		elif direction < 0 and node.position.y < current_pos.y:
			candidates.append(node)
	if candidates.is_empty():
		for node in available_map_nodes:
			if node != focused_node:
				candidates.append(node)
	if candidates.is_empty():
		return
	var closest_node = null
	var min_distance = INF
	for candidate in candidates:
		var distance = abs(candidate.position.y - current_pos.y)
		if distance < min_distance:
			min_distance = distance
			closest_node = candidate
	if closest_node:
		focused_node = closest_node
		if input_handler and input_handler.is_controller_active():
			input_handler.set_current_focus(focused_node)
		elif focused_node.focus_mode != Control.FOCUS_NONE:
			focused_node.grab_focus()
		_highlight_focused_node()

func _on_button_focus_entered(button: Control):
	_highlight_focused_node()

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
	previous_row.sort_custom(func(a, b): return a["pos"].y < b["pos"].y)
	current_row.sort_custom(func(a, b): return a["pos"].y < b["pos"].y)
	var prev_size = previous_row.size()
	var curr_size = current_row.size()
	
	for i in range(prev_size):
		var connections_needed = 1
		if randf() < map_params["branching_factor"]:
			connections_needed = 2
			if i > 0 and i < prev_size - 1 and curr_size >= 3:
				connections_needed = 3
		var distances = []
		for j in range(curr_size):
			var dist = abs(previous_row[i]["pos"].y - current_row[j]["pos"].y)
			distances.append({"idx": j, "dist": dist})
		distances.sort_custom(func(a, b): return a["dist"] < b["dist"])
		
		for k in range(min(connections_needed, distances.size())):
			var target_idx = distances[k]["idx"]
			previous_row[i]["connections"].append(current_row[target_idx]["id"])
		
	for j in range(curr_size):
		var has_incoming = false
		for prev_node in previous_row:
			if current_row[j]["id"] in prev_node["connections"]:
				has_incoming = true
				break
		if not has_incoming:
			var closest_idx = 0
			var min_dist = INF
			for i in range(prev_size):
				var dist = abs(previous_row[i]["pos"].y - current_row[j]["pos"].y)
				if dist < min_dist:
					min_dist = dist
					closest_idx = i
			previous_row[closest_idx]["connections"].append(current_row[j]["id"])
	for prev_node in previous_row:
		var unique_connections = []
		for conn in prev_node["connections"]:
			if conn not in unique_connections:
				unique_connections.append(conn)
		prev_node["connections"] = unique_connections

func create_map_node(node_data: Dictionary):
	var node = preload("res://scenes/map_node.tscn").instantiate()
	map_nodes.add_child(node)
	var connections_array = PackedStringArray()
	for connection in node_data["connections"]:
		connections_array.append(connection)
	node.setup_node(node_data["id"], node_data["type"], node_data["pos"], connections_array, node_spacing)
	node.pressed.connect(_on_map_node_pressed.bind(node))
	node.focus_mode = Control.FOCUS_ALL

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
	_update_available_map_nodes()

func update_node_states():
	for node in map_nodes.get_children():
		if node.visited:
			node.set_visited()
		elif node.node_id in available_nodes:
			node.set_available()
		else:
			node.set_unavailable()
	_update_available_map_nodes()

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
			get_tree().change_scene_to_file("res://scenes/treasure.tscn")
		MapNode.NodeType.BOSS:
			get_tree().change_scene_to_file("res://scenes/battle/boss_battle.tscn")

func _on_return_to_map():
	var map_state = get_node("/root/MapState")
	if map_state:
		available_nodes = map_state.get_available_nodes()
	update_node_states()
	enable_available_nodes()
	await get_tree().process_frame
	_setup_controller_navigation()

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

#func show_treasure_screen():
	#print("treasure")
	#var player_data = get_node("/root/PlayerDatabase")
	#var reward_type = 0
	#match reward_type:
		#0:
			#var gold_amount = 40 + randi() % 50
			#player_data.add_gold(gold_amount)
			#show_treasure_message("Found " + str(gold_amount) + " gold!")
	#await  get_tree().create_timer(2.0).timeout
	#_on_return_to_map()

func show_treasure_message(message: String):
	var message_label = Label.new()
	add_child(message_label)
	message_label.text = message
	message_label.position = Vector2(300, 400)
	message_label.add_theme_font_size_override("font_size", 24)
	message_label.add_theme_color_override("font_color", Color.GOLD)
	await get_tree().create_timer(5.0).timeout
	message_label.queue_free()

#func _on_deck_view_button_pressed():
	#if deck_viewer:
		#deck_viewer.show_viewer()

func recreate_saved_map(map_data: Array):
	clear_existing_map()
	for node_data in map_data:
		var node = preload("res://scenes/map_node.tscn").instantiate()
		map_nodes.add_child(node)
		node.setup_node(node_data["id"], node_data["type"], node_data["pos"], node_data["connections"], node_spacing)
		node.pressed.connect(_on_map_node_pressed.bind(node))
		node.focus_mode = Control.FOCUS_ALL
