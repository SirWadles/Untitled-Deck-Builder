extends Node
class_name GameStuff

var player_deck: Array = []
var player_gold: int = 20
var player_health: int = 50
var max_health: int = 50
var current_map_path: Array = []
var relics: Array = []

func _ready():
	var card_db = get_node("/root/CardStuff")
	player_deck = ["attack", "attack", "blood_fire", "abundance", "abundance"]

func get_starter_deck() -> Array[CardData]:
	var card_db = get_node("/root/CardStuff")
	var deck: Array[CardData] = []
	for card_id in player_deck:
		var card = card_db.get_card(card_id)
		if card:
			deck.append(card)
	return deck

func add_card_to_deck(card_id: String):
	player_deck.append(card_id)

func add_gold(amount: int):
	player_gold += amount
