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

var input_handler: Node
var is_submenu_open: bool = false

func _ready():
	if has_node("/root/GlobalInputHandler"):
		input_handler = get_node("/root/GlobalInputHandler")
	start_button.pressed.connect(_on_start_button_pressed)
	options_button.pressed.connect(_on_options_button_pressed)
	credit_button.pressed.connect(_on_credit_button_pressed)
	
	start_button.focus_entered.connect(_on_button_focus_entered.bind(start_button))
	options_button.focus_entered.connect(_on_button_focus_entered.bind(options_button))
	credit_button.focus_entered.connect(_on_button_focus_entered.bind(credit_button))
	
	music_player.bus = "Music"
	music_player.play()
	audio_options.visible = false
	credits_menu.visible = false
	
	_setup_focus_neighbors()
	_setup_initial_focus()

func _setup_initial_focus():
	await get_tree().process_frame
	if is_submenu_open:
		return
	if input_handler and input_handler.is_controller_active():
		input_handler.set_current_focus(start_button)
	elif start_button.focus_mode != Control.FOCUS_NONE:
		start_button.grab_focus()

func _setup_focus_neighbors():
	start_button.focus_neighbor_bottom = options_button.get_path()
	options_button.focus_neighbor_top = start_button.get_path()
	options_button.focus_neighbor_bottom = credit_button.get_path()
	credit_button.focus_neighbor_top = options_button.get_path()
	credit_button.focus_neighbor_bottom = start_button.get_path()
	start_button.focus_neighbor_top = credit_button.get_path()

func _on_start_button_pressed():
	print("Start Pressed")
	start_sound.play()
	await get_tree().create_timer(2.5).timeout
	music_player.stop()
	get_tree().change_scene_to_file("res://scenes/tutorial_scene.tscn")

func _on_options_button_pressed():
	if is_submenu_open:
		return
	print("Options")
	options_sound.play()
	audio_options.show_options()
	is_submenu_open = true
	if input_handler:
		input_handler.disable_navigation()

func _on_credit_button_pressed():
	if is_submenu_open:
		return
	print("Credits")
	quit_sound.play()
	show_credits()
	is_submenu_open = true

func show_credits():
	credits_menu.visible = true
	start_button.disabled = true
	options_button.disabled = true
	credit_button.disabled = true
	start_button.focus_mode = Control.FOCUS_NONE
	options_button.focus_mode = Control.FOCUS_NONE
	credit_button.focus_mode = Control.FOCUS_NONE
	is_submenu_open = true
	if input_handler:
		input_handler.disable_navigation()

func hide_credits():
	credits_menu.visible = false
	start_button.disabled = false
	options_button.disabled = false
	credit_button.disabled = false
	start_button.focus_mode = Control.FOCUS_ALL
	options_button.focus_mode = Control.FOCUS_ALL
	credit_button.focus_mode = Control.FOCUS_ALL
	is_submenu_open = false
	if input_handler:
		input_handler.enable_navigation()
	await get_tree().process_frame
	_setup_initial_focus()

func _on_button_focus_entered(button: Control):
	print("Focus: ", button.name)

func _input(event):
	if is_submenu_open:
		return
	if input_handler and input_handler.navigation_enabled and not audio_options.visible and not credits_menu.visible:
		if event.is_action_pressed("ui_accept"):
			if start_button.has_focus():
				_on_start_button_pressed()
			elif options_button.has_focus():
				_on_options_button_pressed()
			elif credit_button.has_focus():
				_on_credit_button_pressed()
		elif event.is_action_pressed("ui_cancel"):
			pass

func _notification(what):
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if visible and input_handler and input_handler.navigation_enabled:
			await get_tree().process_frame
			_setup_initial_focus()

func _on_options_closed():
	is_submenu_open = false
	if input_handler:
		input_handler.enable_navigation()
	await get_tree().process_frame
	_setup_initial_focus()
