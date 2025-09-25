extends Node
class_name CardDatabase

var cards: Dictionary = {}

func _ready():
	create_cards()

func create_cards():
	var death_grip_texture = preload("res://assets/Death Grip.png")
	var abundance_texture = preload("res://assets/Abundance.png")
	var blood_fire_texture = preload("res://assets/Blood Fire.png")
	
	cards["attack"] = CardData.new(
		"attack",
		"Death Grip",
		"Deal 5 Damage to Selected Enemy",
		1, #cost
		5, #damage
		0, #defense
		0, #heal
		death_grip_texture #texture
	)
	
	cards["blood_fire"] = CardData.new(
		"blood_fire",
		"Blood Fire",
		"Damage all for 6 Damage",
		1,
		6,
		0,
		-2,
		blood_fire_texture
	)
	
	cards["abundance"] = CardData.new(
		"abundance",
		"Abundance",
		"Heal Self for 7 HP",
		1,
		0,
		0,
		3,
		abundance_texture
	)

func get_card(card_id: String) -> CardData:
	return cards.get(card_id, null)

func get_random_card() -> CardData:
	var card_keys = cards.keys()
	var random_key = card_keys[randi() % card_keys.size()]
	return cards[random_key]
