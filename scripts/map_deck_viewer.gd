extends Control

@onready var cards_container: GridContainer = $PanelContainer/MarginContainer/ScrollContainer/CardsContainer
@onready var close_button: Button = $PanelContainer/MarginContainer/CloseButton
#@onready var card_tooltip: Control = $
@onready var deck_count_label: Label = $PanelContainer/MarginContainer/Header/DeckCountLabel
@onready var exhaust_count_label: Label = $PanelContainer/MarginContainer/Header/ExhuastCountLabel

var card_scene = preload("res://scenes/battle/card.tscn")
var is_visible: bool = false

func _ready():
	close_button.pressed.connect(_on_close_button_pressed)
	hide()
	#card_tooltip.hide()

func _on_close_button_pressed():
	hide_viewer()

func _input(event):
	if event is InputEventMouseMotion and is_visible:
		update_tooltip_position()

func update_display():
	clear_container()
	var player_data = get_node("/root/PlayerDatabase")
	var card_database = get_node("/root/CardStuff")
	deck_count_label.text = "Deck: " + str(player_data.deck.size()) + " cards"
	exhaust_count_label.text = "Exhaust: " + str(player_data.exhuast_pile.size()) + " cards"
	var all_cards = {}
	for card_id in player_data.deck:
		all_cards[card_id] = all_cards.get(card_id, {"count": 0, "exhaust": false})
		all_cards[card_id].count += 1
	
	for card_id in player_data.exhaust_pile:
		if card_id in all_cards:
			all_cards[card_id].exhaust = true
		else:
			all_cards[card_id] = {"count": 1, "exhaust": true}
	
	for card_id in all_cards:
		var card_data = card_database.get_card(card_id)
		if card_data:
			var card_display = create_card_display(card_data, all_cards[card_id].count, all_cards[card_id].exhaust)
			cards_container.add_child(card_display)

func create_card_display(card_data: CardData, count: int, is_exhausted: bool) -> Card:
	var card = card_scene.instantiate() as Card
	card.setup(card_data, self)
	card.scale = Vector2(0.6, 0.6)
	card.custom_minimum_size = Vector2(80, 120)
	card.set_selectable(false)
	if card.has_node("CardButton"):
		card.get_node("cardButton").disabled = true
	if is_exhausted:
		add_exhaust_overlay(card)
	if count > 1:
		add_count_badge(card, count)
	card.mouse_entered.connect(_on_card_display_mouse_entered.bind(card_data, card))
	card.mouse_exited.connect(_on_card_display_mouse_exited)
	return card

func add_exhaust_overlay(card: Card):
	var exhaust_overlay = ColorRect.new()
	exhaust_overlay.size = card.size
	exhaust_overlay.color = Color(0.3, 0.3, 0.3, 0.6)
	exhaust_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(exhaust_overlay)
	
	var exhaust_label = Label.new()
	exhaust_label.text = "EXHAUSTED"
	exhaust_label.position = Vector2(card.size.x /2 - 40, card.size.y / 2 - 10)
	exhaust_label.add_theme_font_size_override("font_size", 12)
	exhaust_label.add_theme_color_override("font_color", Color.RED)
	exhaust_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	exhaust_overlay.add_child(exhaust_label)

func add_count_badge(card: Card, count: int):
	var count_badge = Panel.new()
	count_badge.size = Vector2(30, 20)
	count_badge.position = Vector2(card.size.x - 35, card.size.y -25)
	count_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = Color(0.1, 0.1, 0.3, 0.9)
	stylebox.border_color = Color.LIGHT_BLUE
	stylebox.border_width_left = 1
	stylebox.border_width_top = 1
	stylebox.border_width_right = 1
	stylebox.border_width_bottom = 1
	stylebox.corner_radius_top_left = 5
	stylebox.corner_radius_top_right = 5
	stylebox.corner_radius_bottom_right = 5
	stylebox.corner_radius_bottom_left = 5
	count_badge.add_theme_stylebox_override("panel", stylebox)
	
	var count_label = Label.new()
