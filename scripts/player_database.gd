extends Node
class_name PlayerData

var max_health: int = 50
var current_health: int = 50
var max_energy: int = 3
var current_energy: int = 3
var gold: int = 100

var deck: Array[String] = ["attack", "attack", "blood_fire", "attack", "abundance"]
var relics: Array[String] = []

var battle_rewards: Array = []

func _ready():
	reset_to_default()

func reset_to_default():
	max_health = 50
	current_health = max_health
	max_energy = 3
	gold = 100
	deck = ["attack", "attack", "blood_fire", "attack", "abundance"]
	relics = []
	battle_rewards = []

func take_damage(damage: int):
	current_health -= damage
	if current_health < 0:
		current_health = 0

func heal(amount: int):
	current_health += amount
	if current_health > max_health:
		current_health = max_health

func add_gold(amount: int):
	gold += amount

func add_card_to_deck(card_id: String):
	deck.append(card_id)

func add_relic(relic_id: String):
	relics.append(relic_id)

func full_heal():
	current_health = max_health + 4

func get_health_percentage() -> float:
	return float(current_health) / float(max_health)
