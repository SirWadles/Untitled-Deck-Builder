extends Node
class_name PlayerData

var max_health: int = 50
var current_health: int = 50
var max_energy: int = 3
var current_energy: int = 3
var gold: int = 100

var deck: Array[String] = ["attack", "attack", "blood_fire", "attack", "abundance"]
var discard_pile: Array[String] = []
var exhause_pile: Array[String] = []
var hand: Array[String] = []

var relics: Array = []
var battle_rewards: Array = []

func _ready():
	reset_to_default()

func reset_to_default():
	max_health = 50
	current_health = max_health
	max_energy = 3
	gold = 150
	deck = ["attack", "attack", "blood_fire", "attack", "abundance"]
	discard_pile = []
	exhause_pile = []
	relics = []
	battle_rewards = []

func reshuffle_discard():
	deck.append_array(discard_pile)
	discard_pile.clear()

func draw_cards(amount: int) -> Array[String]:
	var drawn_cards: Array[String] = []
	for i in range(amount):
		if deck.size() == 0:
			if discard_pile.size() > 0:
				reshuffle_discard()
				deck.shuffle()
			else:
				break
		if deck.size() > 0:
			var card_id = deck[0]
			deck.remove_at(0)
			hand.append(card_id)
			drawn_cards.append(card_id)
	return drawn_cards

func discard_card(card_id: String):
	if hand.has(card_id):
		hand.erase(card_id)
		discard_pile.append(card_id)

func discard_hand():
	discard_pile.append_array(hand)
	hand.clear()

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

func add_relic(relic_data: Dictionary):
	relics.append(relic_data)
	var relic_manager = get_node("/root/RelicManager")
	relic_manager.add_relic(relic_data)

func full_heal():
	current_health = max_health + 4

func get_health_percentage() -> float:
	return float(current_health) / float(max_health)


func get_max_energy() -> int:
	var relic_manager = get_node("/root/RelicManager")
	var energy_crystal_count = relic_manager.get_relic_count("energy_crystal")
	return max_energy + energy_crystal_count
