extends Control
class_name Shop

@onready var gold_label: Label = $Header/GoldLabel
@onready var card_container: HBoxContainer = $Content/CardsPanel/CardsContainer
@onready var relic_container: HBoxContainer = $Content/RelicsPanel/RelicContainer
@onready var return_button: Button = $Footer/ReturnButton

var player_gold: int = 100
var available_cards: Array = []
var available_relics: Array = []
var player_data: PlayerData

func _ready():
	player_data = get_node("/root/PlayerDatabase")
	setup_ui_theme()
	load_shop_items()
	update_display()
	return_button.pressed.connect(_on_return_button_pressed)

func  setup_ui_theme():
	return_button.text = "Return to Map"
	return_button.custom_minimum_size = Vector2(150, 40)

func load_shop_items():
	var card_db = get_node("/root/CardStuff")
	var all_cards = ["attack", "blood_fire", "abundance"]
	available_cards.clear()
	available_relics.clear()
	for i in range(3):
		var random_card_id = all_cards[randi() % all_cards.size()]
		var card_data = card_db.get_card(random_card_id)
		if card_data:
			available_cards.append({
				"data": card_data,
				"price": calculate_card_price(card_data)
			})
	#load_sample_relics()
#
#func load_sample_relics():
	

func calculate_card_price(card_data: CardData) -> int:
	var price = card_data.cost * 20
	price += card_data.damage * 10
	price += card_data.heal * 12
	price += card_data.defense * 10
	return max(price, 25)

func update_display():
	gold_label.text = "Gold: " + str(player_data.gold)
	for child in card_container.get_children():
		child.queue_free()
	for card_item in available_cards:
		var shop_card = preload("res://scenes/shop_card.tscn").instantiate()
		card_container.add_child(shop_card)
		shop_card.setup(card_item["data"], card_item["price"])
		shop_card.purchased.connect(_on_card_purchased)

func _on_card_purchased(card_data: CardData, price: int):
	if player_data.gold >= price:
		player_data.gold -= price
		player_data.add_card_to_deck(card_data.card_id)
		update_display()
		print("Bought " + card_data.card_name)

func _on_return_button_pressed():
	get_tree().change_scene_to_file("res://scenes/map.tscn")
