extends Control

@onready var end_turn_button: Button = $EndTurnButton
@onready var end_turn_sound = $EndTurnButton/EndTurnSound
@onready var status_label: Label = $StatusLabel

func _ready():
	end_turn_sound.bus = "SFX"
	if end_turn_button:
		end_turn_button.pressed.connect(_on_end_turn_pressed)
		end_turn_button.text = "End Turn"
		end_turn_button.size = Vector2(80, 30)
		end_turn_button.position = Vector2(0, 20)
	if status_label:
		status_label.text = "Player's Turn"
		status_label.size = Vector2(300, 30)
		status_label.position = Vector2(140, 20)
		var font = status_label.get_theme_font("font")
		status_label.add_theme_font_size_override("font_size", 18)

func _on_end_turn_pressed():
	var battle_system = get_parent()
	if battle_system and battle_system.has_method("end_turn"):
		end_turn_sound.play()
		battle_system.end_turn()

func update_status(text: String):
	status_label.text = text

func show_end_turn_focus():
	if end_turn_button:
		end_turn_button.modulate = Color(1.2, 1.2, 0.8)

func show_deck_view_focus():
	if has_node("DeckViewButton"):
		var deck_button = get_node("DeckViewButton")
		deck_button.modulate = Color(1.2, 1.2, 0.8)

func hide_focus_indicators():
	if end_turn_button:
		end_turn_button.modulate = Color.WHITE
	if has_node("DeckViewButton"):
		var deck_button  = get_node("DeckViewButton")
		deck_button.modulate = Color.WHITE
