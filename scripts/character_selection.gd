extends Control

@onready var witch_button = $WitchButton
@onready var wizard_button = $WizardButton
@onready var description_label = $DescriptionLabel
@onready var select_sound = $SelectSound
@onready var witch_label = $WitchButton/Label
@onready var wizard_label = $WizardButton/Label
@onready var title_label = $TitleLabel

@onready var witch_deck_display: Control = $WitchDeckDisplay
@onready var wizard_deck_display: Control = $WizardDeckDisplay

var selected_character: String = ""
var input_handler: Node

func _ready():
	if has_node("/root/GlobalInputHandler"):
		input_handler = get_node("/root/GlobalInputHandler")
	witch_button.pressed.connect(_on_witch_pressed)
	wizard_button.pressed.connect(_on_wizard_pressed)
	witch_button.focus_entered.connect(_on_button_focus_entered.bind(witch_button))
	wizard_button.focus_entered.connect(_on_button_focus_entered.bind(wizard_button))
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
	
	_setup_focus_neighbors()
	_setup_initial_focus()
	
	TranslationManager.language_changed.connect(_on_language_changed)
	
	_update_ui_text()

func _update_ui_text():
	if title_label:
		title_label.text = TranslationManager.translate("character_selection")
	if witch_label:
		witch_label.text = TranslationManager.translate("witch")
	if wizard_label:
		wizard_label.text = TranslationManager.translate("wizard")
	if description_label:
		description_label.text = TranslationManager.translate("selected_character")

func _on_language_changed():
	_update_ui_text()
	_display_character_decks()
	_update_description()

func _setup_focus_neighbors():
	witch_button.focus_neighbor_right = wizard_button.get_path()
	witch_button.focus_neighbor_left = wizard_button.get_path()
	wizard_button.focus_neighbor_left = witch_button.get_path()

func _setup_initial_focus():
	await get_tree().process_frame
	if input_handler and input_handler.is_controller_active():
		input_handler.set_current_focus(witch_button)
	elif witch_button.focus_mode != Control.FOCUS_NONE:
		witch_button.grab_focus()

func _on_button_focus_entered(button: Control):
	print("Current character selected: ", button.name)
	_reset_button_appearance()
	button.modulate = Color.YELLOW
	_update_description_for_button(button)

func _update_description_for_button(button: Control):
	if description_label:
		if button == witch_button:
			description_label.text = TranslationManager.translate("witch_description")
		elif button == wizard_button:
			description_label.text = TranslationManager.translate("wizard_description")

func _reset_button_appearance():
	witch_button.modulate = Color.WHITE
	wizard_button.modulate = Color.WHITE

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
	if description_label:
		description_label.text = TranslationManager.translate("select_character")

func _display_character_decks():
	var character_script = load("res://scripts/character_data.gd")
	var witch_data = character_script.new()
	witch_data.selected_character = "witch"
	witch_deck_display.display_deck(witch_data.get_character_deck(), "witch_deck")
	
	var wizard_data = character_script.new()
	wizard_data.selected_character = "wizard"
	wizard_deck_display.display_deck(wizard_data.get_character_deck(), "wizard_deck")

func _input(event):
	if input_handler and input_handler.navigation_enabled:
		if event.is_action_pressed("ui_accept"):
			if witch_button.has_focus():
				_on_witch_pressed()
			elif wizard_button.has_focus():
				_on_wizard_pressed()
		elif event.is_action("ui_cancel"):
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
