extends Control

@onready var witch_button = $WitchButton
@onready var wizard_button = $WizardButton
@onready var description_label = $DescriptionLabel
@onready var select_sound = $SelectSound

var selected_character: String = ""

func _ready():
	witch_button.pressed.connect(_on_witch_pressed)
	wizard_button.pressed.connect(_on_wizard_pressed)
	
	_update_description()

func _on_witch_pressed():
	selected_character = "witch"
	select_sound.play()
	_save_character_choice()
	get_tree().change_scene_to_file("res://scenes/map.tscn")

func _on_wizard_pressed():
	selected_character = "wizard"
	select_sound.play()
	_save_character_choice()
	get_tree().change_scene_to_file("res://scenes/map.tscn")

func _save_character_choice():
	var character_data = CharacterData.new()
	character_data.selected_character = selected_character
	get_tree().root.add_child(character_data)
	character_data.name = "CharacterData"

func _update_description():
	pass
