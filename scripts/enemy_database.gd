extends Node
class_name  EnemyStuff

var enemies: Dictionary = {}

func _ready():
	create_enemies()

func create_enemies():
	var holy_one_texture = preload("res://assets/Holy One.png")
	var tree_texture = preload("res://assets/Tree.png")
	var blood_slime_texture = preload("res://assets/Blood Slime(1).png")
	
	enemies["slime"] = {
		"name": "Slime",
		"type": "slime",
		"damage": 3,
		"health": 15,
		"texture": blood_slime_texture,
		"base_size": Vector2(78, 78),
		"sprite_offset": Vector2(0, 5)
	}
	enemies["tree"] = {
		"name": "Tree",
		"type": "tree",
		"damage": 2,
		"health": 50,
		"texture": tree_texture,
		"base_size": Vector2(128, 128),
		"sprite_offset": Vector2(-20, -30)
	}
	
	enemies["boss_1"] = {
		"name": "Holy One",
		"type": "boss_1",
		"damage": 5,
		"health": 65,
		"texture": holy_one_texture,
		"base_size": Vector2(150, 150),
		"sprite_offset": Vector2(0, -35)
	}

func get_enemy_data(enemy_id: String):
	return enemies.get(enemy_id, null)

func get_enemy_types() -> Array:
	return enemies.keys()
