extends Node2D
class_name Hand

@onready var card_container: HBoxContainer = $HBoxContainer

var cards: Array[Card] = []
var selected_card: Card = null
var battle_system: BattleSystem

signal card_played(card: Card, target: Enemy)

func _ready():
	battle_system = get_parent() as BattleSystem
	if card_container:
		card_container.alignment = BoxContainer.ALIGNMENT_CENTER

func add_card(card_data: CardData):
	var card_scene = preload("res://scenes/battle/card.tscn")
	var new_card = card_scene.instantiate() as Card
	card_container.add_child(new_card)
	new_card.setup(card_data, self)
	cards.append(new_card)
	update_card_positions()

func update_card_positions():
	for i in range(cards.size()):
		var card = cards[i]

func clear_hand():
	for card in cards:
		card.queue_free()
	cards.clear()

func set_cards_selectable(selectable: bool):
	for card in cards:
		card.set_selectable(selectable)

func card_selected(card: Card):
	selected_card = card
	battle_system.on_card_selected(card)

func play_card(target: Enemy):
	if selected_card:
		card_played.emit(selected_card, target)
		cards.erase(selected_card)
		selected_card.queue_free()
		selected_card = null
