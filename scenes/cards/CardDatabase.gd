extends Node
class_name CardDatabase

var cards: Dictionary = {}

func _ready():
	create_cards()

func create_cards():
	cards["attack"] = CardData.new(
		"attack",
		"Death Grip",
		"Deal 5 Damage to Selected Enemy",
		1, #cost
		5, #damage
		0, #defense
		0, #heal
		null #texture
	)
	
	cards["blood_fire"] = CardData.new(
		"blood_fire",
		"Blood Fire",
		"Heal Self for 7 HP",
		1,
		0,
		0,
		3,
		null
	)
	
	cards["heal"] = CardData.new(
		"heal",
		"Abundance",
		"Heal Self for 7 HP",
		1,
		0,
		0,
		3,
		null
	)

func get_card(card_id: String) -> CardData:
	return cards.get(card_id, null)
