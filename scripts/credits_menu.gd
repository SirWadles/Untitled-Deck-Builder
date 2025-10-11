extends Control

@onready var back_button = $VBoxContainer/BackButton

func _ready():
	back_button.pressed.connect(_on_back_button_pressed)

func _on_back_button_pressed():
	get_parent().hide_credits()
