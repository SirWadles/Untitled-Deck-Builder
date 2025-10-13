extends Control

@onready var start_button = $VBoxContainer/StartButton
@onready var options_button = $VBoxContainer/OptionsButton
@onready var credit_button = $VBoxContainer/CreditButton

@onready var start_sound = $Audio/StartSound
@onready var options_sound = $Audio/OptionsSound
@onready var quit_sound = $Audio/QuitSound
@onready var music_player = $Audio/MusicPlayer

@onready var audio_options = $AudioOptions
@onready var credits_menu = $CreditsMenu

func _ready():
	start_button.pressed.connect(_on_start_button_pressed)
	options_button.pressed.connect(_on_options_button_pressed)
	credit_button.pressed.connect(_on_credit_button_pressed)
	music_player.bus = "Music"
	music_player.play()
	audio_options.visible = false
	credits_menu.visible = false

func _on_start_button_pressed():
	print("Start Pressed")
	start_sound.play()
	await start_sound.finished
	music_player.stop()
	get_tree().change_scene_to_file("res://scenes/tutorial_scene.tscn")

func _on_options_button_pressed():
	print("Options")
	options_sound.play()
	audio_options.show_options()
	

func _on_credit_button_pressed():
	print("Credits")
	quit_sound.play()
	show_credits()

func show_credits():
	credits_menu.visible = true
	start_button.disabled = true
	options_button.disabled = true
	credit_button.disabled = true

func hide_credits():
	credits_menu.visible = false
	start_button.disabled = false
	options_button.disabled = false
	credit_button.disabled = false
