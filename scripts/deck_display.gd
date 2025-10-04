extends Control
class_name DeckDisplay

@onready var deck_count_label: Label = $Panel/VBoxContainer/HBoxContainer/DeckSection/DeckCountLabel
@onready var discard_count_label: Label = $Panel/VBoxContainer/HBoxContainer/DiscardSection/DiscardCountLabel
@onready var exhaust_count_label: Label = $Panel/VBoxContainer/HBoxContainer/ExhaustSection/ExhaustCountLabel
@onready var deck_cards_container: VBoxContainer = $Panel/VBoxContainer/HBoxContainer/DeckSection/DeckScrollContainer/DeckCardsContainer
@onready var discard_cards_container: VBoxContainer = $Panel/VBoxContainer/HBoxContainer/DiscardSection/DiscardScrollContainer/DiscardCardsContainer
@onready var exhaust_cards_container: VBoxContainer = $Panel/VBoxContainer/HBoxContainer/ExhaustSection/ExhaustScrollContainer/ExhaustCardsContainer
@onready var close_button: Button = $Panel/VBoxContainer/CloseButton

var player_data: PlayerData
var card_database: CardDatabase

func _ready():
	player_data = get_node("/root/PlayerDatabase")
	card_database = get_node("/root/CardStuff")
	close_button.pressed.connect(hide)
	
	var panel = Panel.new()
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.1, 0.1, 0.1, 0.95)
	style_box.border_color = Color.GOLD
	style_box.border_width_left = 2
	style_box.border_width_right = 2
	style_box.border_width_top = 2
	style_box.border_width_bottom = 2
	style_box.corner_radius_top_left = 10
	style_box.corner_radius_top_right = 10
	style_box.corner_radius_bottom_right = 10
	style_box.corner_radius_bottom_left = 10
	panel.add_theme_stylebox_override("panel", style_box)
	
	close_button.text = "Close"
	close_button.custom_minimum_size = Vector2(100, 40)

func show_deck():
	update_display()
	visible = true

func update_display():
	for child in deck_cards_container.get_children():
		child.queue_free()
	for child in discard_cards_container.get_children():
		child.queue_free()
	for child in exhaust_cards_container.get_children():
		child.queue_free()
	
	deck_count_label.text = "Deck (%d)" % player_data.deck.size()
	discard_count_label.text = "Discard (%d)" % player_data.discard_pile.size()
	exhaust_count_label.text = "Exhaust (%d)" % player_data.exhause_pile.size()
	
	var deck_card_counts = {}
	for card_id in player_data.deck:
		deck_card_counts[card_id] = deck_card_counts.get(card_id, 0) + 1
	for card_id in deck_card_counts:
		var card_data = card_database.get_card(card_id)
		if card_data:
			var card_label = create_card_label(card_data, deck_card_counts[card_id])
			deck_cards_container.add_child(card_label)
	var discard_card_counts = {}
	for card_id in player_data.deck:
		discard_card_counts[card_id] = discard_card_counts.get(card_id, 0) + 1
	for card_id in discard_card_counts:
		var card_data = card_database.get_card(card_id)
		if card_data:
			var card_label = create_card_label(card_data, discard_card_counts[card_id])
			discard_cards_container.add_child(card_label)
	var exhaust_card_counts = {}
	for card_id in player_data.deck:
		exhaust_card_counts[card_id] = exhaust_card_counts.get(card_id, 0) + 1
	for card_id in exhaust_card_counts:
		var card_data = card_database.get_card(card_id)
		if card_data:
			var card_label = create_card_label(card_data, exhaust_card_counts[card_id])
			exhaust_cards_container.add_child(card_label)

func create_card_label(card_data: CardData, count: int = 1) -> Label:
	var label = Label.new()
	if count > 1:
		label.text = "%s x%d" % [card_data.card_name, count]
	else:
		label.text = card_data.card_name
	match card_data.card_id:
		"attack", "blood_fire":
			label.add_theme_color_override("font_color", Color(1.0, 0.6, 0.6))
		"abundance":
			label.add_theme_color_override("font_color", Color(0.6, 1.0, 0.6))
		_:
			label.add_theme_color_override("font_color", Color(0.8, 0.8, 1.0))
	label.add_theme_font_size_override("font_size", 12)
	return label
