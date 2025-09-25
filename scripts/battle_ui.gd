extends Control

@onready var end_turn_button: Button = $EndTurnButton
@onready var status_label: Label = $StatusLabel

func _ready():
	end_turn_button.pressed.connect(_on_end_turn_pressed)
	end_turn_button.position = Vector2(50, 50)
	status_label.position = Vector2(200, 50)

func _on_end_turn_pressed():
	var battle_system = get_parent()
	if battle_system and battle_system.has_method("end_turn"):
		battle_system.end_turn()

func update_status(text: String):
	status_label.text = text
