extends Node
class_name  EnemyStuff

var enemies: Dictionary = {}

func _ready():
	create_enemies()

func create_enemies():
	var holy_one_texture = preload("res://assets/Holy One.png")
	var blood_slime_texture = preload("res://assets/Blood Slime(1).png")
	
	enemies["slime"] = {
		"name": "Slime",
		"health": 15,
		"texture": blood_slime_texture
	}
	
	enemies["boss_1"] = {
		"name": "Holy One",
		"health": 35,
		"texture": holy_one_texture
	}

func get_enemy_data(enemy_id: String):
	return enemies.get(enemy_id, null)
