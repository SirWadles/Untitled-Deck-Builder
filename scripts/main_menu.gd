extends Control

@onready var start_button = $VBoxContainer/StartButton
@onready var options_button = $VBoxContainer/OptionsButton
@onready var quit_button = $VBoxContainer/QuitButton

@onready var start_sound = $Audio/StartSound
@onready var options_sound = $Audio/OptionsSound
@onready var quit_sound = $Audio/QuitSound

func _ready():
	start_button.pressed.connect(_on_start_button_pressed)
	options_button.pressed.connect(_on_options_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

func _on_start_button_pressed():
	print("Start Pressed")
	start_sound.play()
	await start_sound.finished
	get_tree().change_scene_to_file("res://scenes/battle/battle.tscn")

func _on_options_button_pressed():
	print("Options")
	options_sound.play()
	await options_sound.finished
	

func _on_quit_button_pressed():
	quit_sound.play()
	await quit_sound.finished
	get_tree().quit()
