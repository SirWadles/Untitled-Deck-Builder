extends Control

@onready var start_button = $VBoxContainer/StartButton
@onready var options_button = $VBoxContainer/OptionsButton
@onready var credit_button = $VBoxContainer/CreditButton

@onready var start_sound = $Audio/StartSound
@onready var options_sound = $Audio/OptionsSound
@onready var quit_sound = $Audio/QuitSound
@onready var music_player = $Audio/MusicPlayer

@onready var audio_options = $AudioOptions

func _ready():
	start_button.pressed.connect(_on_start_button_pressed)
	options_button.pressed.connect(_on_options_button_pressed)
	credit_button.pressed.connect(_on_credit_button_pressed)
	music_player.bus = "Music"
	music_player.play()
	audio_options.visible = false

func _on_start_button_pressed():
	print("Start Pressed")
	start_sound.play()
	await start_sound.finished
	music_player.stop()
	get_tree().change_scene_to_file("res://scenes/map.tscn")

func _on_options_button_pressed():
	print("Options")
	options_sound.play()
	await options_sound.finished
	audio_options.show_options()
	

func _on_credit_button_pressed():
	quit_sound.play()
	await quit_sound.finished
	get_tree().quit()
