extends Control

@onready var back_button = $VBoxContainer/BackButton

func _ready():
	back_button.pressed.connect(_on_back_button_pressed)
	back_button.focus_entered.connect(_on_back_button_focused)
	back_button.focus_mode = Control.FOCUS_ALL
	back_button.mouse_filter = Control.MOUSE_FILTER_PASS
	back_button.focus_neighbor_top = back_button.get_path()
	back_button.focus_neighbor_bottom = back_button.get_path()
	back_button.focus_neighbor_left = back_button.get_path()
	back_button.focus_neighbor_right = back_button.get_path()

func _on_back_button_pressed():
	get_parent().hide_credits()

func _on_back_button_focused():
	pass

func _input(event):
	if visible and event.is_action_pressed("ui_cancel"):
		_on_back_button_pressed()
	if visible and event is InputEventMouseButton and event.pressed:
		if back_button.get_global_rect().has_point(event.position):
			_on_back_button_pressed()

func _notification(what):
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if visible:
			await get_tree().process_frame
			back_button.grab_focus()
