extends Control
class_name Card

@onready var button: Button = $CardButton
@onready var name_label: Label = $NameLabel
@onready var cost_label: Label = $CostLabel
@onready var description_label: Label = $DescriptionLabel
@onready var card_border: Sprite2D = $CardBorder
@onready var card_art: Sprite2D = $CardArt

var card_data: CardData
var hand: Node
var is_selectable: bool = false
var pending_selectable: bool = false

func _ready():
	scale = Vector2(1.5, 1.5)
	button.pressed.connect(_on_card_clicked)
	button.size = Vector2(52, 64)
	if pending_selectable != is_selectable:
		button.disabled = !is_selectable

func setup(data: CardData, hand_reference: Node = null):
	card_data = data
	hand = hand_reference
	call_deferred("_deferred_setup", data)

func _deferred_setup(data: CardData):
	if name_label:
		name_label.text = data.card_name
		name_label.add_theme_font_size_override("font_size", 10)
	if cost_label:
		cost_label.text = str(data.cost)
		cost_label.add_theme_font_size_override("font_size", 10)
	if description_label:
		description_label.text = data.description
		description_label.add_theme_font_size_override("font_size", 9)
	if card_data:
		if data.texture:
			card_art.texture = data.texture
		else: 
			card_art.modulate = Color(0.5, 0.5, 0.5)
	#set_card_visuals_based_on_type()

#func set_card_visuals_based_on_type():
	#if card_data.damage > 0:
		#card_border.modulate = Color(1, 0.3, 0.3)
	#elif card_data.heal > 0:
		#card_border.modulate = Color(0.3, 1, 0.3)
	#elif card_data.defense > 0:
		#card_border.modulate = Color(0.3, 0.3, 1)

func set_selectable(selectable: bool):
	is_selectable = selectable
	if button:
		button.disabled = !selectable
	else:
		pending_selectable = selectable
	if selectable:
		modulate = Color.WHITE
	else:
		modulate = Color.GRAY

func _on_card_clicked():
	if is_selectable and hand != null and hand.has_method("card_selected"):
		hand.card_selected(self)
