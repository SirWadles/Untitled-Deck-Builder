extends Node
class_name MapStuff

var current_node_id: String = ""
var player_path: Array[String] = []
var available_nodes: Array[String] = ["start"]
var visited_nodes: Array[String] = []

var saved_map_data: Array = []

func reset():
	current_node_id = ""
	player_path.clear()
	available_nodes = ["start"]
	visited_nodes.clear()

func mark_node_visited(node_id: String):
	print("=== MAPSTATE mark_node_visited ===")
	print("node_id: ", node_id)
	print("visited_nodes before: ", visited_nodes)
	if node_id not in visited_nodes:
		visited_nodes.append(node_id)
	available_nodes.clear()
	var map = get_tree().get_first_node_in_group("map")
	print("Map found: ", map != null)
	if map:
		var node = map.get_node_by_id(node_id)
		print("Node found by ID: ", node != null)
		if node:
			print("Node connections: ", node.connections)
			for connection in node.connections:
				available_nodes.append(connection)
				print("Added to available_nodes: ", connection)
		else:
			print("ERROR: Could not find node with ID: ", node_id)
	else:
		print("ERROR: Could not find map in group")
	print("available_nodes after: ", available_nodes)
	print("================================")

func get_available_nodes() -> Array[String]:
	return available_nodes.duplicate()

func get_visited_nodes() -> Array[String]:
	return visited_nodes.duplicate()

func save_map_data(data: Array):
	saved_map_data = data

func get_map_data() -> Array:
	return saved_map_data
