extends Node2D
class_name Hand

@onready var card_container: HBoxContainer = $HBoxContainer
@onready var play_sound = $Audio/PlaySound

var cards: Array[Card] = []
var selected_card: Card = null
var battle_system: Node

signal card_played(card: Card, target: Enemy)

func _ready():
	battle_system = get_parent() as Node
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
	animate_card_entrance(new_card)

func animate_card_entrance(card: Card):
	card.scale = Vector2(0.5, 0.5)
	card.modulate = Color(1, 1, 1, 0)
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(card, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(card, "modulate", Color(1, 1, 1, 1), 0.2)

func _update_layout():
	card_container.queue_redraw()
	await get_tree().process_frame
	card_container.queue_sort()

func clear_hand():
	cards.clear()
	for child in card_container.get_children():
		if child is Card:
			child.queue_free()
	_update_layout()

func set_cards_selectable(selectable: bool):
	for card in cards:
		card.set_selectable(selectable)

func card_selected(card: Card):
	selected_card = card
	battle_system.on_card_selected(card)

func play_card(card: Card, target: Enemy):
	if card:
		animate_card_entrance(card)
		await get_tree().create_timer(0.2).timeout
		card_played.emit(card, target)
		cards.erase(card)
		selected_card.queue_free()
		play_sound.play()
		if selected_card == card:
			selected_card = null

func animate_card_play(card: Card):
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(card, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(card, "modulate", Color(1, 1, 1, 0), 0.2)
	tween.tween_property(card, "position.y", card.position.y - 50, 0.2)

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
