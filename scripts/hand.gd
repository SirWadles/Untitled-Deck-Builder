extends Node2D
class_name Hand

@onready var card_container: HBoxContainer = $HBoxContainer
@onready var play_sound = $Audio/PlaySound

var cards: Array[Card] = []
var selected_card: Card = null
var battle_system: BattleSystem

signal card_played(card: Card, target: Enemy)

func _ready():
	battle_system = get_parent() as BattleSystem
	_setup_container()

func _setup_container():
	if card_container:
		card_container.alignment = BoxContainer.ALIGNMENT_CENTER
		card_container.add_theme_constant_override("separation", 20)
		card_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card_container.size_flags_vertical = Control.SIZE_SHRINK_CENTER

func add_card(card_data: CardData):
	var card_scene = preload("res://scenes/battle/card.tscn")
	var new_card = card_scene.instantiate() as Card
	card_container.add_child(new_card)
	new_card.setup(card_data, self)
	cards.append(new_card)
	_update_layout()
	adjust_spacing_based_on_hand_size()

func _update_layout():
	card_container.queue_redraw()
	await get_tree().process_frame
	card_container.queue_sort()

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
		play_sound.play()
		

func get_card_count() -> int:
	return cards.size()

func adjust_spacing_based_on_hand_size():
	var card_count = cards.size()
	var spacing = 60
	if card_count > 7:
		spacing = 45
	elif card_count > 5:
		spacing = 50
	elif card_count > 3:
		spacing = 55

	card_container.add_theme_constant_override("separation", spacing)
