extends Node

var current_focus: Control = null
var navigation_enabled: bool = true

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process_unhandled_input(true)

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		handle_pause_input()
	elif event.is_action_pressed("view_deck"):
		handle_deck_view_input()

func handle_pause_input():
	var root = get_tree().current_scene
	var audio_options = _find_audio_options(root)
	if audio_options and audio_options.has_method("show_options"):
		if not audio_options.visible:
			audio_options.show_options()
			disable_navigation()

func handle_deck_view_input():
	var root = get_tree().current_scene
	if _is_battle_scene(root):
		var battle_system = _get_battle_system(root)
		if battle_system and battle_system.has_method("_on_deck_view_button_pressed"):
			battle_system._on_deck_view_button_pressed()
	elif _is_map_scene(root):
		var map = _get_map_system(root)
		if map and map.has_method("_on_deck_view_button_pressed"):
			map._on_deck_view_button_pressed()

func _find_audio_options(node: Node) -> Node:
	if node is CanvasLayer and node.has_method("show_options") and node.has_method("hide_options"):
		return node
	var search_paths = [
		"AudioOptions",
		"Audio/AudioOptions",
		"UI/AudioOptions",
		"MarginContainer/AudioOptions",
		"VBoxContainer/AudioOptions"
	]
	for path in search_paths:
		if node.has_node(path):
			var found = node.get_node(path)
			if found.has_method("show_options"):
				return found
	for child in node.get_children():
		var result = _find_audio_options(child)
		if result:
			return result
	return null

func _is_battle_scene(root: Node) -> bool:
	return (root.has_node("BattleSystem") or 
		root.has_node("BossSystem") or
		"battle" in root.name.to_lower() or 
		"boss" in root.name.to_lower())

func _get_battle_system(root: Node) -> Node:
	if root.has_node("BattleSystem"):
		return root.get_node("BattleSystem")
	elif root.has_node("BossSystem"):
		return root.get_node("BossSystem")
	else:
		return root if (root.has_method("_on_map_node_pressed") or root.has_method("start_player_turn")) else null

func _is_map_scene(root: Node) -> bool:
	return (root.has_node("Map") or "map" in root.name.to_lower())

func _get_map_system(root: Node) -> Node:
	if root.has_node("Map"):
		return root.get_node("Map")
	else:
		return root if root.has_method("_on_map_node_pressed") else null

func set_current_focus(control: Control):
	if control and control.visible and control.focus_mode != Control.FOCUS_NONE:
		current_focus = control
		control.grab_focus()

func enable_navigation():
	navigation_enabled = true
	if current_focus and current_focus.visible:
		current_focus.grab_focus()

func disable_navigation():
	navigation_enabled = false
	current_focus = null

func is_controller_active() -> bool:
	return Input.get_mouse_mode() == Input.MOUSE_MODE_HIDDEN
