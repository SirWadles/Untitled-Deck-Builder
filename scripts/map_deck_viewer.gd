extends Control

@onready var cards_container: GridContainer = $PanelContainer/MarginContainer/ScrollContainer/CardsContainer
@onready var close_button: Button = $CloseButton
@onready var card_tooltip: Control = $CardToolTip
@onready var deck_count_label: Label = $PanelContainer/MarginContainer/Header/DeckCountLabel
@onready var exhaust_count_label: Label = $PanelContainer/MarginContainer/Header/ExhaustCountLabel

var card_scene = preload("res://scenes/battle/card.tscn")
var is_visible: bool = false

func _ready():
	close_button.pressed.connect(_on_close_button_pressed)
	hide()
	if card_tooltip:
		card_tooltip.hide()
	$PanelContainer.size = Vector2(300, 100)
	$PanelContainer.custom_minimum_size = Vector2(300, 100)
	configure_grid_container()

func configure_grid_container():
	cards_container.columns = 4
	cards_container.add_theme_constant_override("h_separation", 20)
	cards_container.add_theme_constant_override("v_separation", 20)

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
	exhaust_count_label.text = "Exhaust: " + str(player_data.exhaust_pile.size()) + " cards"
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
	card.scale = Vector2(0.8, 0.8)
	card.custom_minimum_size = Vector2(100, 150)
	card.set_selectable(false)
	if card.has_node("CardButton"):
		card.get_node("CardButton").disabled = true
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
	exhaust_label.position = Vector2(card.size.x / 2 - 40, card.size.y / 2 - 10)
	exhaust_label.add_theme_font_size_override("font_size", 12)
	exhaust_label.add_theme_color_override("font_color", Color.RED)
	exhaust_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	exhaust_overlay.add_child(exhaust_label)

func add_count_badge(card: Card, count: int):
	var count_badge = Panel.new()
	count_badge.size = Vector2(35, 25)
	count_badge.position = Vector2(card.size.x - 40, card.size.y - 30)
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
	count_label.text = "x" + str(count)
	count_label.position = Vector2(8, 5)
	count_label.add_theme_font_size_override("font_size", 12)
	count_label.add_theme_color_override("font_color", Color.WHITE)
	count_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	count_badge.add_child(count_label)
	
	card.add_child(count_badge)

func _on_card_display_mouse_entered(card_data: CardData, card: Card):
	show_card_tooltip(card_data, card)

func _on_card_display_mouse_exited():
	hide_card_tooltip()

func show_card_tooltip(card_data: CardData, card: Card):
	if not card_tooltip:
		print("mistake for card tool")
		return
	card_tooltip.show()
	var name_label = card_tooltip.get_node("VBoxContainer/NameLabel")
	var cost_label = card_tooltip.get_node("VBoxContainer/CostLabel")
	var desc_label = card_tooltip.get_node("VBoxContainer/DescLabel")
	var stats_label = card_tooltip.get_node("VBoxContainer/StatsLabel")
	
	if name_label:
		name_label.text = card_data.card_name
	if cost_label:
		cost_label.text = "Energy Cost: " + str(card_data.cost)
	if desc_label:
		desc_label.text = card_data.description
	
	var stats_text = ""
	if card_data.damage > 0:
		stats_text += "Damage: " + str(card_data.damage) + "\n"
	if card_data.heal > 0:
		stats_text += "Heal: " + str(card_data.heal) + "\n"
	
	if stats_text == "":
		stats_text = "Utility Card"
	if stats_label:
		stats_label.text = stats_text
	update_tooltip_position()

func hide_card_tooltip():
	card_tooltip.hide()

func update_tooltip_position():
	if card_tooltip.visible:
		var mouse_pos = get_global_mouse_position()
		card_tooltip.position = mouse_pos + Vector2(20, 20)
		
		var viewport_size = get_viewport().get_visible_rect().size
		if card_tooltip.position.x + card_tooltip.size.x > viewport_size.x:
			card_tooltip.position.x = viewport_size.x - card_tooltip.size.x
		if card_tooltip.position.y + card_tooltip.size.y > viewport_size.y:
			card_tooltip.position.y = viewport_size.y - card_tooltip.size.y
		card_tooltip.position = card_tooltip.position.clamp(Vector2.ZERO, viewport_size - card_tooltip.size)

func clear_container():
	for child in cards_container.get_children():
		child.queue_free()

func show_viewer():
	update_display()
	show()
	is_visible = true

func hide_viewer():
	hide()
	is_visible = false
	hide_card_tooltip()
