extends Resource
class_name CardData

@export var card_id: String
@export var card_name: String
@export_multiline var description: String
@export var cost: int
@export var damage: int
@export var defense: int
@export var heal: int
@export var texture: Texture2D

func _init(id = "", name = "", desc = "", card_cost = 0, card_damage = 0, card_defense = 0, card_heal = 0, tex = null):
	card_id = id
	card_name = name
	description = desc
	cost = card_cost
	damage = card_damage
	defense = card_defense
	heal = card_heal
	texture = tex
