extends Node
class_name CharacterDte

var selected_character: String = "witch"

func get_character_deck() -> Array[String]:
	match selected_character:
		"wizard":
			return ["attack", "attack", "attack", "attack", "abundance", "abundance", "blood_fire"]
		"witch":
			return ["attack", "attack", "attack", "abundance", "abundance", "blood_fire", "self_harm"]
		_:
			return ["attack", "attack", "attack", "abundance", "abundance", "blood_fire", "self_harm"]

func get_character_name() -> String:
	return selected_character

func get_starting_health() -> int:
	match selected_character:
		"wizard":
			return 40
		"witch":
			return 50
		_:
			return 50

func get_character_texture() -> Texture2D:
	match selected_character:
		"wizard":
			return preload("res://assets/Witch (1).png")
		"witch":
			return preload("res://assets/Witch (1).png")
		_:
			return preload("res://assets/Witch (1).png")
