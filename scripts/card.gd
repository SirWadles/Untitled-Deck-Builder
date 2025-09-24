extends Node2D
class_name Card

@onready var button: Button = $Button
@onready var name_label: Label = $NameLabel
@onready var cost_label: Label = $CostLabel
@onready var description_label: Label = $DescriptionLabel
@onready var sprite: Sprite2D = $Sprite2D

var card_data: CardData
var hand: Node
var is_selectable: bool = false

func _ready():
	button.pressed.connect(_on_card_clicked)

func setup(data: CardData, hand_reference: Node):
	card_data = data
	hand = hand_reference
	name_label.text = data.card_name
	cost_label.text = str(data.cost)
	description_label.text = data.description
	if data.texture:
		sprite.texture = data.texture

func set_selected(selectable: bool):
	is_selectable = selectable
	button.disabled = !selectable

func _on_card_clicked():
	if is_selectable:
		hand.card_selected(self)
