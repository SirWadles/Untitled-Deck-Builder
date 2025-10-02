extends Node
class_name MapStuff

var current_node_id: String = ""
var player_path: Array[String] = []
var available_nodes: Array[String] = ["start"]
var visited_nodes: Array[String] = []

func reset():
	current_node_id = ""
	player_path.clear()
	available_nodes = ["start"]
	visited_nodes.clear()

func mark_node_visited(node_id: String):
	if node_id not in visited_nodes:
		visited_nodes.append(node_id)
	available_nodes.clear()
	var map = get_tree().get_first_node_in_group("map")
	if map:
		var node = map.get_node_by_id(node_id)
		if node:
			for connection in node.connections:
				available_nodes.append(connection)

func get_available_nodes() -> Array[String]:
	return available_nodes.duplicate()

func get_visited_nodes() -> Array[String]:
	return visited_nodes.duplicate()
