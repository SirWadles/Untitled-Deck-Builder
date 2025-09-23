extends Node2D
class_name Hand

@onready var card_container: HBoxContainer = $HBoxContainer

var cards: Array[Card] = []
var selected_card: Card = null
var battle_system: BattleSystem

signal card_played(card: Card, target: Enemy)

func _ready():
	battle_system = get_parent() as BattleSystem

func add_card(card_data: CardData):
	var card_scene = preload("res://scenes/battle/card.tscn")
	var new_card = card_scene.instantiate() as Card
	card_container.add_child(new_card)
	new_card.setup(card_data, self)
	cards.append(new_card)

func clear_hand():
	
