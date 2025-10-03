extends Control
class_name Shop

@onready var gold_label: Label = $MarginContainer/VBoxContainer/Header/GoldLabel
@onready var tab_container: TabContainer = $MarginContainer/VBoxContainer/TabContainer
@onready var cards_grid: GridContainer = $MarginContainer/VBoxContainer/TabContainer/Cards/ScrollContainer/CardsGrid
@onready var relic_grid: GridContainer = $MarginContainer/VBoxContainer/TabContainer/Relics/ScrollContainer/RelicGrid
@onready var return_button: Button = $MarginContainer/VBoxContainer/Footer/ReturnButton

var player_gold: int = 100
var available_cards: Array = []
var available_relics: Array = []
var player_data: PlayerData

func _ready():
	player_data = get_node("/root/PlayerDatabase")
	print("Gold label exists: ", gold_label != null)
	print("Tab container exists: ", tab_container != null)
	print("Cards grid exists: ", cards_grid != null)
	print("Relic grid exists: ", relic_grid != null)
	print("Return button exists: ", return_button != null)
	setup_ui_theme()
	load_shop_items()
	update_display()
	return_button.pressed.connect(_on_return_button_pressed)

func  setup_ui_theme():
	return_button.text = "Return to Map"
	return_button.custom_minimum_size = Vector2(150, 40)
	
	var cards_scroll = cards_grid.get_parent() as ScrollContainer
	var relics_scroll = relic_grid.get_parent() as ScrollContainer
	
	if cards_scroll:
		cards_scroll.custom_minimum_size = Vector2(800, 400)
		cards_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cards_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	if relics_scroll:
		relics_scroll.custom_minimum_size = Vector2(800, 400)
		relics_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		relics_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	if cards_grid is GridContainer:
		cards_grid.columns = 3
		cards_grid.custom_minimum_size = Vector2(800, 400)
		cards_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cards_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	if relic_grid is GridContainer:
		relic_grid.columns = 3
		relic_grid.custom_minimum_size = Vector2(800, 400)
		relic_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		relic_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	cards_grid.add_theme_constant_override("h_separation", 10)
	cards_grid.add_theme_constant_override("v_separation", 10)
	relic_grid.add_theme_constant_override("h_separation", 10)
	relic_grid.add_theme_constant_override("v_separation", 10)

func load_shop_items():
	var card_db = get_node("/root/CardStuff")
	var all_cards = ["attack", "blood_fire", "abundance"]
	available_cards.clear()
	available_relics.clear()
	print("Loading shop items...")
	for i in range(6):
		var random_card_id = all_cards[randi() % all_cards.size()]
		var card_data = card_db.get_card(random_card_id)
		if card_data:
			available_cards.append({
				"data": card_data,
				"price": calculate_card_price(card_data)
			})
			print("Added card: ", card_data.card_name)
	load_sample_relics()
	print("Available cards: ", available_cards.size())
	print("Available relics: ", available_relics.size())

func load_sample_relics():
	available_relics.append({
		"name": "Health Band",
		"description": "Heals 5 HP after combat ",
		"price": 75,
		"icon": null,
		"id": "health_band"
	})
	available_relics.append({
		"name": "Energy Crystal",
		"description": "+1 Max Energy",
		"price": 150,
		"icon": null,
		"id": "energy_crystal"
	})
	

func calculate_card_price(card_data: CardData) -> int:
	var price = card_data.cost * 20
	price += card_data.damage * 10
	price += card_data.heal * 12
	price += card_data.defense * 10
	price += randi() % 15
	return max(price, 30)

func update_display():
	gold_label.text = "Gold: " + str(player_data.gold) + "g"
	for child in cards_grid.get_children():
		child.queue_free()
	for child in relic_grid.get_children():
		child.queue_free()
	for card_item in available_cards:
		var shop_card = preload("res://scenes/shop_card.tscn").instantiate()
		cards_grid.add_child(shop_card)
		shop_card.setup(card_item["data"], card_item["price"])
		shop_card.purchased.connect(_on_card_purchased)
	for relic_item in available_relics:
		var shop_relic = preload("res://scenes/shop_relic.tscn").instantiate()
		relic_grid.add_child(shop_relic)
		shop_relic.setup(relic_item)
		shop_relic.purchased.connect(_on_relic_purchased)

func _on_card_purchased(card_data: CardData, price: int):
	if player_data.gold >= price:
		player_data.gold -= price
		player_data.add_card_to_deck(card_data.card_id)
		update_display()
		print("Bought " + card_data.card_name)
		show_purchased_message("Purchased " + card_data.card_name)
	else:
		show_purchased_message("Not Enough Gold!")

func _on_relic_purchased(relic_data: Dictionary, price: int):
	if player_data.gold >= price:
		player_data.gold -= price
		player_data.add_relic(relic_data)
		var relic_manager = get_node("/root/RelicManager")
		print("relic bought", relic_data["name"])
		print("relic in manager", relic_manager.active_relics.size())
		update_display()
		show_purchased_message("Purchased " + relic_data["name"])
	else:
		show_error_message("Not Enough Gold!")

func show_purchased_message(message: String):
	var message_label = Label.new()
	add_child(message_label)
	message_label.text = message
	message_label.position = Vector2(size.x / 2 -100, 550)
	message_label.add_theme_font_size_override("font_size", 20)
	await get_tree().create_timer(2.0).timeout
	message_label.queue_free()

func show_error_message(message: String):
	var error_label = Label.new()
	add_child(error_label)
	error_label.text = message
	error_label.position = Vector2(size.x / 2 -100, size.y / 2)
	error_label.add_theme_font_size_override("font_size", 20)
	error_label.add_theme_color_override("font_color", Color.RED)
	await get_tree().create_timer(2.0).timeout
	error_label.queue_free()

func _on_return_button_pressed():
	get_tree().change_scene_to_file("res://scenes/map.tscn")
