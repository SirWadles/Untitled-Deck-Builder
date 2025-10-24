extends CanvasLayer

@onready var master_slider = $Master/MasterSlider
@onready var music_slider = $Music/MusicSlider
@onready var sfx_slider = $SFX/SFXSlider

@onready var apply_button = $Buttons/ApplyButton
@onready var back_button = $Buttons/BackButton
@onready var button_sound = $Buttons/ButtonSound

var audio_settings = {
	"master_volume": 1.0,
	"music_volume": 1.0,
	"sfx_volume": 1.0
}

var focusable_items: Array[Control] = []
var current_focus_index: int = 0

var input_cooldown: float = 0.0
var is_in_cooldown: bool = false

func _ready():
	load_audio_settings()
	apply_button.pressed.connect(_on_apply_pressed)
	back_button.pressed.connect(_on_back_pressed)
	
	master_slider.value_changed.connect(_on_master_changed)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	
	button_sound.bus = "SFX"
	
	setup_slider_size()
	apply_audio_settings()
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	focusable_items = [master_slider, music_slider, sfx_slider, apply_button, back_button]
	setup_focus_neighbors()

func _process(delta):
	if visible and is_in_cooldown:
		input_cooldown -= delta
		if input_cooldown <= 0:
			is_in_cooldown = false

func _unhandled_input(event):
	if not visible or is_in_cooldown:
		return
	if event.is_action_pressed("ui_up"):
		handle_navigation_input("ui_up")
	elif event.is_action_pressed("ui_down"):
		handle_navigation_input("ui_down")
	elif event.is_action_pressed("ui_left"):
		handle_navigation_input("ui_left")
	elif event.is_action_pressed("ui_right"):
		handle_navigation_input("ui_right")
	elif event.is_action_pressed("ui_cancel"):
		_on_back_pressed()
	elif event.is_action_pressed("ui_accept") and not (focusable_items[current_focus_index] is HSlider):
		var focused_item = focusable_items[current_focus_index]
		if focused_item == apply_button:
			_on_apply_pressed()
		elif focused_item == back_button:
			_on_back_pressed()

func handle_navigation_input(action: String):
	is_in_cooldown = true
	input_cooldown = 0.5
	match action:
		"ui_up":
			current_focus_index = wrapi(current_focus_index - 1, 0, focusable_items.size())
			update_focus_highlight()
		"ui_down":
			current_focus_index = wrapi(current_focus_index + 1, 0, focusable_items.size())
			update_focus_highlight()
		"ui_left":
			if focusable_items[current_focus_index] is HSlider:
				var slider = focusable_items[current_focus_index] as HSlider
				slider.value = clamp(slider.value - 0.05, 0.0, 3.0)
				_on_slider_changed(slider)
		"ui_right":
			if focusable_items[current_focus_index] is HSlider:
				var slider = focusable_items[current_focus_index] as HSlider
				slider.value = clamp(slider.value + 0.05, 0.0, 3.0)
				_on_slider_changed(slider)

func setup_focus_neighbors():
	for i in range(focusable_items.size()):
		var current = focusable_items[i]
		var previous = focusable_items[i - 1] if i > 0 else focusable_items[focusable_items.size() - 1]
		var next = focusable_items[i + 1] if i < focusable_items.size() - 1 else focusable_items[0]
		current.focus_neighbor_top = previous.get_path()
		current.focus_neighbor_bottom = next.get_path()
		current.focus_neighbor_left = current.get_path()
		current.focus_neighbor_right = current.get_path()
		if current is HSlider:
			current.focus_mode = Control.FOCUS_ALL
		else:
			current.focus_mode = Control.FOCUS_ALL

func _on_slider_changed(slider: HSlider):
	if slider == master_slider:
		_on_master_changed(slider.value)
	elif slider == music_slider:
		_on_music_changed(slider.value)
	elif slider == sfx_slider:
		_on_sfx_changed(slider.value)

func load_audio_settings():
	audio_settings = {
	"master_volume": Settings.get_setting("audio", "master_volume", 1.0),
	"music_volume": Settings.get_setting("audio", "music_volume", 1.0),
	"sfx_volume": Settings.get_setting("audio", "sfx_volume", 1.0)
	}
	audio_settings.master_volume = clamp(audio_settings.master_volume, 0.0, 3.0)
	audio_settings.music_volume = clamp(audio_settings.music_volume, 0.0, 3.0)
	audio_settings.sfx_volume = clamp(audio_settings.sfx_volume, 0.0, 3.0)
	master_slider.value = audio_settings.master_volume
	music_slider.value = audio_settings.music_volume
	sfx_slider.value = audio_settings.sfx_volume

func _on_master_changed(value: float):
	audio_settings.master_volume = value
	AudioManager.set_master_volume(value)

func _on_music_changed(value: float):
	audio_settings.music_volume = value
	AudioManager.set_music_volume(value)

func _on_sfx_changed(value: float):
	audio_settings.sfx_volume = value
	AudioManager.set_sfx_volume(value)

func _on_back_pressed():
	hide()
	button_sound.play()
	GlobalInputHandler.enable_navigation()

func _on_apply_pressed():
	save_audio_settings()
	hide()
	button_sound.play()
	GlobalInputHandler.enable_navigation()

func apply_audio_settings():
	AudioManager.set_master_volume(audio_settings.master_volume)
	AudioManager.set_music_volume(audio_settings.music_volume)
	AudioManager.set_sfx_volume(audio_settings.sfx_volume)

func save_audio_settings():
	Settings.set_setting("audio", "master_volume", audio_settings.master_volume)
	Settings.set_setting("audio", "music_volume", audio_settings.music_volume)
	Settings.set_setting("audio", "sfx_volume", audio_settings.sfx_volume)
	Settings.save_settings()

func show_options():
	load_audio_settings()
	visible = true
	get_tree().paused = true
	current_focus_index = 0
	update_focus_highlight()
	GlobalInputHandler.disable_navigation()

func hide_options():
	visible = false
	get_tree().paused = false
	GlobalInputHandler.enable_navigation()

func setup_slider_size():
	master_slider.custom_minimum_size = Vector2(250, 30)
	music_slider.custom_minimum_size = Vector2(250, 30)
	sfx_slider.custom_minimum_size = Vector2(250, 30)

func update_focus_highlight():
	if focusable_items.size() > 0 and current_focus_index < focusable_items.size():
		var current_focus = focusable_items[current_focus_index]
		current_focus.grab_focus()
		for item in focusable_items:
			item.modulate = Color.WHITE
			item.scale = Vector2(1.0, 1.0)
		var selected_item = focusable_items[current_focus_index]
		selected_item.modulate = Color.YELLOW
		if selected_item is HSlider or selected_item is Button:
			var tween = create_tween()
			tween.tween_property(selected_item, "scale", Vector2(1.1, 1.1), 0.1)
			tween.tween_property(selected_item, "scale", Vector2(1.0, 1.0), 0.1)
