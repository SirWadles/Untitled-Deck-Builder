extends CanvasLayer

@onready var tutorial_container: Control = $TutorialContainer
@onready var card_tip: Control = $TutorialContainer/CardTip
@onready var end_turn_tip: Control = $TutorialContainer/EndTurnTip
@onready var enemy_attack_tip: Control = $TutorialContainer/EnemyAttackTip
@onready var next_button: Button = $TutorialContainer/NextButton
@onready var prev_button: Button = $TutorialContainer/PrevButton
@onready var close_button: Button = $TutorialContainer/CloseButton
@onready var start_game_button: Button = $TutorialContainer/StartGameButton

@onready var prev_sound: AudioStreamPlayer2D = $Audio/PrevButtonSound
@onready var next_sound: AudioStreamPlayer2D = $Audio/NextButtonSound
@onready var start_sound: AudioStreamPlayer2D = $Audio/StartButtonSound

var current_tip: int = 0
var tips: Array[Control] = []

func _ready():
	tips = [card_tip, end_turn_tip, enemy_attack_tip]
	show_tip(0)
	next_button.pressed.connect(_on_next_button_pressed)
	prev_button.pressed.connect(_on_prev_button_pressed)
	start_game_button.pressed.connect(_on_start_game_button_pressed)
	
	prev_sound.bus = "SFX"
	next_sound.bus = "SFX"
	start_sound.bus = "SFX"

func show_tip(index: int):
	current_tip = index
	for tip in tips:
		tip.visible = false
	tips[current_tip].visible = true
	prev_button.disabled = (current_tip == 0)
	next_button.visible = (current_tip < tips.size() - 1)
	start_game_button.visible = (current_tip == tips.size() - 1)

func _on_next_button_pressed():
	next_sound.play()
	show_tip(current_tip + 1)

func _on_prev_button_pressed():
	prev_sound.play()
	show_tip(current_tip - 1)

func show_tutorial():
	get_tree().root.add_child(self)

func _on_start_game_button_pressed():
	start_sound.play()
	await get_tree().create_timer(1.4).timeout
	get_tree().change_scene_to_file("res://scenes/character_selection.tscn")
