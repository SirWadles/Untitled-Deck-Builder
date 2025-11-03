extends CanvasLayer

@onready var tutorial_container: Control = $TutorialContainer
@onready var card_tip: Control = $TutorialContainer/CardTip
@onready var end_turn_tip: Control = $TutorialContainer/EndTurnTip
@onready var enemy_attack_tip: Control = $TutorialContainer/EnemyAttackTip
@onready var controller_tip: Control = $TutorialContainer/ControllerTip
@onready var next_button: Button = $TutorialContainer/NextButton
@onready var prev_button: Button = $TutorialContainer/PrevButton
@onready var start_game_button: Button = $TutorialContainer/StartGameButton

@onready var prev_sound: AudioStreamPlayer2D = $Audio/PrevButtonSound
@onready var next_sound: AudioStreamPlayer2D = $Audio/NextButtonSound
@onready var start_sound: AudioStreamPlayer2D = $Audio/StartButtonSound

var current_tip: int = 0
var tips: Array[Control] = []
var input_handler: Node

func _ready():
	if has_node("/root/GlobalInputHandler"):
		input_handler = get_node("/root/GlobalInputHandler")
	tips = [card_tip, end_turn_tip, enemy_attack_tip]
	show_tip(0)
	next_button.pressed.connect(_on_next_button_pressed)
	prev_button.pressed.connect(_on_prev_button_pressed)
	start_game_button.pressed.connect(_on_start_game_button_pressed)
	
	next_button.focus_entered.connect(_on_button_focus_entered.bind(next_button))
	prev_button.focus_entered.connect(_on_button_focus_entered.bind(prev_button))
	start_game_button.focus_entered.connect(_on_button_focus_entered.bind(start_game_button))
	
	prev_sound.bus = "SFX"
	next_sound.bus = "SFX"
	start_sound.bus = "SFX"
	
	_setup_initial_focus()

func _setup_initial_focus():
	await get_tree().process_frame
	if input_handler and input_handler.is_controller_active():
		input_handler.set_current_focus(next_button)
	elif next_button.focus_mode != Control.FOCUS_NONE:
		next_button.grab_focus()

func show_tip(index: int):
	current_tip = index
	for tip in tips:
		tip.visible = false
	tips[current_tip].visible = true
	prev_button.disabled = (current_tip == 0)
	next_button.visible = (current_tip < tips.size() - 1)
	start_game_button.visible = (current_tip == tips.size() - 1)
	
	_update_focus()

func _update_focus():
	await get_tree().process_frame
	if start_game_button.visible:
		if input_handler and input_handler.is_controller_active():
			input_handler.set_current_focus(start_game_button)
		elif start_game_button.focus_mode != Control.FOCUS_NONE:
			start_game_button.grab_focus()
	elif next_button.visible:
		if input_handler and input_handler.is_controller_active():
			input_handler.set_current_focus(next_button)
		elif next_button.focus_mode != Control.FOCUS_NONE:
			next_button.grab_focus()
	elif prev_button.visible:
		if input_handler and input_handler.is_controller_active():
			input_handler.set_current_focus(prev_button)
		elif prev_button.focus_mode != Control.FOCUS_NONE:
			prev_button.grab_focus()

func _on_button_focus_entered(button: Control):
	print("Tutorial: ", button.name)

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

func _input(event):
	if input_handler and input_handler.navigation_enabled:
		if event.is_action_pressed("ui_left") and not prev_button.disabled:
			if input_handler and input_handler.is_controller_active():
				input_handler.set_current_focus(prev_button)
			elif prev_button.focus_mode != Control.FOCUS_NONE:
				prev_button.grab_focus()
		elif event.is_action_pressed("ui_right"):
			if next_button.visible:
				if input_handler and input_handler.is_controller_active():
					input_handler.set_current_focus(next_button)
				elif next_button.focus_mode != Control.FOCUS_NONE:
					next_button.grab_focus()
			elif start_game_button.visible:
				if input_handler and input_handler.is_controller_active():
					input_handler.set_current_focus(start_game_button)
				elif start_game_button.focus_mode != Control.FOCUS_NONE:
					start_game_button.grab_focus()
		elif event.is_action_pressed("ui_cancel"):
			pass
