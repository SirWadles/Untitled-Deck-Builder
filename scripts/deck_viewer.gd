extends Control

@onready var deck_container: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/DeckContainer
@onready var discard_container: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/DiscardContainer
@onready var exhaust_container: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/ExhaustContainer
@onready var hand_container: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/HandContainer
@onready var close_button: Button = $PanelContainer/MarginContainer/VBoxContainer/CloseButton

var card_scene = preload("res://scenes/battle/card.tscn")
var is_visible: bool = false

func _ready():
	close_button.pressed.connect(_on_close_button_pressed)
	hide()
	var battle_system = get_parent()
	if battle_system:
		if battle_system.has_signal("card_played"):
			battle_system.card_played.connect(_on_card_played)
		if battle_system.has_signal("turn_ended"):
			battle_system.turn_ended.connect(_on_turn_ended)
		if battle_system.has_signal("player_turn_started"):
			battle_system.player_turn_started.connect(_on_player_turn_started)
	process_mode = Node.PROCESS_MODE_ALWAYS
	TranslationManager.language_changed.connect(_on_language_changed)

func _on_language_changed():
	_update_texts()
	if is_visible:
		update_display()

func _update_texts():
	if close_button:
		close_button.text = TranslationManager.translate("close")

func _unhandled_input(event):
	if is_visible:
		if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_view_deck") or event.is_action_pressed("ui_accept"):
			hide_viewer()
			get_viewport().set_input_as_handled()

func _on_close_button_pressed():
	hide_viewer()

func _on_card_played(card: Card, target: Enemy):
	if is_visible:
		update_display()

func _on_player_turn_started():
	if is_visible:
		update_display()

func _on_turn_ended():
	if is_visible:
		update_display()

func update_display():
	clear_containers()
	var player_data = get_node("/root/PlayerDatabase")
	var card_database = get_node("/root/CardStuff")
	
	display_card_list(hand_container, TranslationManager.translate("hand_label"), player_data.hand, card_database)
	display_card_list(deck_container, TranslationManager.translate("deck_label"), player_data.deck, card_database)
	display_card_list(discard_container, TranslationManager.translate("discard_label"), player_data.discard_pile, card_database)
	display_card_list(exhaust_container, TranslationManager.translate("exhaust_label"), player_data.exhaust_pile, card_database)

func display_card_list(container: VBoxContainer, title: String, card_list: Array[String], card_database: CardDatabase):
	var title_label = Label.new()
	title_label.text = title + str(card_list.size()) + " cards"
	title_label.add_theme_font_size_override("font_size", 14)
	container.add_child(title_label)
	
	var card_counts = {}
	for card_id in card_list:
		card_counts[card_id] = card_counts.get(card_id, 0) + 1
	for card_id in card_counts:
		var card_data = card_database.get_card(card_id)
		if card_data:
			var card_display = create_card_display(card_data, card_counts[card_id])
			container.add_child(card_display)

func create_card_display(card_data: CardData, count: int) -> HBoxContainer:
	var container = HBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var translated_name = card_data.card_name
	# If card_name looks like a translation key, try translating it
	if TranslationManager.translations.has(TranslationManager.current_language):
		var lang_dict = TranslationManager.translations[TranslationManager.current_language]
		if lang_dict.has(card_data.card_name):
			translated_name = TranslationManager.translate(card_data.card_name)

	var text_label = Label.new()
	text_label.text = translated_name + " x" + str(count)
	text_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_label.add_theme_font_size_override("font_size", 12)
	container.add_child(text_label)
	
	var cost_label = Label.new()
	cost_label.text = "(" + str(card_data.cost) + ")"
	cost_label.add_theme_font_size_override("font_size", 12)
	cost_label.add_theme_color_override("font_color", Color.YELLOW)
	container.add_child(cost_label)
	
	return container

func clear_containers():
	for container in [hand_container, deck_container, discard_container, exhaust_container]:
		for child in container.get_children():
			child.queue_free()
			

func show_viewer():
	update_display()
	show()
	is_visible = true

func hide_viewer():
	hide()
	is_visible = false
