extends Node

signal language_changed

var current_language: String = "ja"
var translations: Dictionary = {}

func _ready():
	load_translations()
	load_saved_language()

func load_translations():
	translations = {
		"en": {
			"start_game": "Start Game",
			"options": "Options",
			"credits": "Credits",
			"back": "Back",
			"apply": "Apply",
			
			"master_volume": "Master Volume",
			"music_volume": "Music Volume",
			"sfx_volume": "SFX Volume"
			
			
		},
		"ja": {
			"start_game": "ゲーム開始",
			"options": "オプション",
			"credits": "クレジット", 
			"back": "戻る",
			"apply": "適用",
			
			"master_volume": "マスタ音量",
			"music_volume": "音楽音量",
			"sfx_volume": "効果音音量"
			
			
		}
	}

func translate(key: String) -> String:
	if translations.has(current_language) and translations[current_language].has(key):
		return translations[current_language][key]
	elif translations["en"].has(key):
		return translations["en"][key]
	else:
		return "MISSING: " + key

func set_language(lang: String):
	if translations.has(lang):
		current_language = lang
		save_language()
		language_changed.emit()

func get_available_languages() -> Array:
	return translations.keys()

func save_language():
	var config = ConfigFile.new()
	config.set_value("settings", "language", current_language)
	config.save("user://settings.cfg")

func load_saved_language():
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		current_language = config.get_value("settings", "language", "en")
	else:
		current_language = "en"
