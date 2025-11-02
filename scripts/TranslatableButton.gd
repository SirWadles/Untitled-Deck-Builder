extends Button

@export var translation_key: String = ""

func _ready():
	add_to_group("translatable")
	update_translation()
	
	if TranslationManager.has_signal("language_changed"):
		TranslationManager.language_changed.connect(update_translation)

func update_translation():
	if translation_key != "":
		text = TranslationManager.translate(translation_key)
