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
		"texture": blood_slime_texture,
		"base_size": Vector2(50, 50)
	}
	
	enemies["boss_1"] = {
		"name": "Holy One",
		"health": 35,
		"texture": holy_one_texture,
		"base_size": Vector2(60, 60)
	}

func get_enemy_data(enemy_id: String):
	return enemies.get(enemy_id, null)

func get_enemy_types() -> Array:
	return enemies.keys()
