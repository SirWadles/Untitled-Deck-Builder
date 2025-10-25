extends Control

@onready var back_button = $VBoxContainer/BackButton

func _ready():
	back_button.pressed.connect(_on_back_button_pressed)
	back_button.focus_entered.connect(_on_back_button_focused)

func _on_back_button_pressed():
	get_parent().hide_credits()

func _on_back_button_focused():
	pass

func _input(event):
	if visible and event.is_action_pressed("ui_cancel"):
		_on_back_button_pressed()
