extends Control

@onready var witch_button = $WitchButton
@onready var wizard_button = $WizardButton
@onready var description_label = $DescriptionLabel
@onready var select_sound = $SelectSound

@onready var witch_deck_display: Control = $WitchDeckDisplay
@onready var wizard_deck_display: Control = $WizardDeckDisplay

var selected_character: String = ""

func _ready():
	witch_button.pressed.connect(_on_witch_pressed)
	wizard_button.pressed.connect(_on_wizard_pressed)
	witch_button.texture_normal = preload("res://assets/Witch(Bigger).png")
	wizard_button.texture_normal = preload("res://assets/Witch(Bigger) (1).png")
	if witch_button:
		print("Witch button texture: ", witch_button.texture_normal != null)
	if wizard_button:
		print("Wizard button texture: ", wizard_button.texture_normal != null)
	print("Witch button found: ", witch_button != null)
	print("Wizard button found: ", wizard_button != null) 
	print("Description label found: ", description_label != null)
	print("Select sound found: ", select_sound != null)
	
	if witch_button:
		print("Witch button visible: ", witch_button.visible)
		print("Witch button position: ", witch_button.position)
	if wizard_button:
		print("Wizard button visible: ", wizard_button.visible)
		print("Wizard button position: ", wizard_button.position)
	_display_character_decks()
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
	var character_script = load("res://scripts/character_data.gd")
	var character_data = character_script.new()
	character_data.selected_character = selected_character
	var existing_data = get_node_or_null("/root/CharacterData")
	if existing_data:
		existing_data.queue_free()
	get_tree().root.add_child(character_data)
	character_data.name = "CharacterData"

func _update_description():
	pass

func _display_character_decks():
	var character_script = load("res://scripts/character_data.gd")
	var witch_data = character_script.new()
	witch_data.selected_character = "witch"
	witch_deck_display.display_deck(witch_data.get_character_deck(), "Witch's Starting Deck")
	
	var wizard_data = character_script.new()
	wizard_data.selected_character = "wizard"
	wizard_deck_display.display_deck(wizard_data.get_character_deck(), "Wizard's Starting Deck")
