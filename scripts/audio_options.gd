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

func load_audio_settings():
	audio_settings = {
	"master_volume": Settings.get_setting("audio", "master_volume", 1.0),
	"music_volume": Settings.get_setting("audio", "music_volume", 1.0),
	"sfx_volume": Settings.get_setting("audio", "sfx_volume", 1.0)
	}
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

func _on_apply_pressed():
	save_audio_settings()
	hide()
	button_sound.play()

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

func hide_options():
	visible = false
	get_tree().paused = false

func setup_slider_size():
	master_slider.custom_minimum_size = Vector2(250, 30)
	music_slider.custom_minimum_size = Vector2(250, 30)
	sfx_slider.custom_minimum_size = Vector2(250, 30)
