extends Node

var active_relics: Array = []

func add_relic(relic_data: Dictionary):
	active_relics.append(relic_data)
	print("relic active " + relic_data["name"])
	print("total", relic_data["name"] + "s", get_relic_count(relic_data["id"]))

func get_relic_count(relic_id: String) -> int:
	var count = 0
	for relic in active_relics:
		if relic["id"] == relic_id:
			count += 1
	return count

func get_combat_start_effects() -> Dictionary:
	var effects = {
		"extra_block": 0,
		"extra_damage": 0,
		"extra_energy": 0,
		"extra_health": 0,
		"max_energy": 0
	}
	for relic in active_relics:
		match relic["id"]:
			"energy_crystal":
				effects["extra_energy"] += 1
				effects["max_energy"] += 1
	return effects
	
func get_combat_end_effects() -> Dictionary:
	var effects = {
		"heal": 0,
		"gold_bonus": 0
	}
	for relic in active_relics:
		match relic["id"]:
			"health_band":
				effects["heal"] += 5
	return effects

func modify_card_play(card_data: CardData) -> Dictionary:
	var modifications = {
		"extra_block": 0,
		"extra_damage": 0,
		"extra_heal": 0
	}
	for relic in active_relics:
		match relic["id"]:
			"health_band":
				if card_data.heal > 0:
					modifications["extra_heal"] += 1
	return modifications

func has_relic_effect(effect_name: String) -> bool:
	match effect_name:
		pass
	return false

func clear_relics():
	active_relics.clear()

func get_relic_display_count(relic_data: Dictionary) -> String:
	var count = get_relic_count(relic_data["id"])
	if count > 1:
		return relic_data["name"] + "x" + str(count)
	return relic_data["name"]
