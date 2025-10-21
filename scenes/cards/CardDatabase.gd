extends Node
class_name CardDatabase

var cards: Dictionary = {}

func _ready():
	create_cards()

func create_cards():
	var death_grip_texture = preload("res://assets/Death Grip.png")
	var abundance_texture = preload("res://assets/Abundance.png")
	var blood_fire_texture = preload("res://assets/Good Blood Fire.png")
	var self_harm_texture = preload("res://assets/Self Harm.png")
	
	cards["attack"] = CardData.new(
		"attack",
		"Death Grip",
		"5 DMG to One",
		1, #cost
		5, #damage
		0, #defense
		0, #heal
		death_grip_texture #texture
	)
	
	cards["blood_fire"] = CardData.new(
		"blood_fire",
		"Blood Fire",
		"7 DMG to All",
		1,
		7,
		0,
		0,
		blood_fire_texture
	)
	
	cards["abundance"] = CardData.new(
		"abundance",
		"Abundance",
		"Heal for 7 HP",
		2,
		0,
		0,
		7,
		abundance_texture
	)
	
	cards["self_harm"] = CardData.new(
		"self_harm",
		"Self Harm",
		"DMG self for 3, 12 DMG to Enemies",
		2,
		12,
		0,
		-3,
		self_harm_texture
	)

func get_card(card_id: String) -> CardData:
	return cards.get(card_id, null)

func get_random_card() -> CardData:
	var card_keys = cards.keys()
	var random_key = card_keys[randi() % card_keys.size()]
	return cards[random_key]
