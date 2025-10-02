extends Node
class_name RelicStuff

var active_relics: Array = []

func add_relic(relic_data: Dictionary):
	active_relics.append(relic_data)
	print("relic active " + relic_data["name"])
	print("total", relic_data["name"] + "s", get_relic_count(relic_data["id"]))

func get_relic_count() -> Dictionary:
	var effects = {
		"extra_block": 0,
		"extra_damage": 0,
		"extra_energy": 0,
		"extra_heal": 0,
		"extra_health": 0
	}
	for relic in active_relics:
		match relic["id"]:
			
