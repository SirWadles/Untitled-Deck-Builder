extends Control

@onready var start_button = $VBoxContainer/StartButton
@onready var options_button = $VBoxContainer/OptionsButton
@onready var quit_button = $VBoxContainer/QuitButton

func _ready():
	start_button.pressed.connect(_on_start_button_pressed)

func _on_start_button_pressed():
	print("Start Pressed")
	get_tree().change_scene_to_file("res://scenes/battle/battle.tscn")
