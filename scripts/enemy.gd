extends Node2D
class_name Enemy

@onready var health_label: Label = $HealthLabel
@onready var button: Button = $Button
@onready var sprite: Sprite2D = $Sprite2D
@onready var intent_icon: AnimatedSprite2D = $IntentIcon
@onready var intent_value: Label = $IntentValue

var enemy_name: String
var max_health: int
var current_health: int
var battle_system: Node
var is_targetable: bool = false
var enemy_type: String
var damage: int
var next_attack: Dictionary = {}
var attack_patterns: Array[Dictionary] = []
var current_pattern_index: int = 0

signal enemy_clicked(enemy: Enemy)

func _ready():
	button.pressed.connect(_on_enemy_clicked)
	setup_intent_animation()
	if intent_icon:
		intent_icon.visible = false
	if intent_value:
		intent_value.visible = false

func setup(name: String, health: int, battle_ref: Node, enemy_data: Dictionary = {}):
	enemy_name = name
	max_health = health
	current_health = health
	battle_system = battle_ref
	enemy_type = enemy_data.get("type", "default")
	damage = enemy_data.get("damage", 3)
	setup_attack_pattern(enemy_data)
	
	if enemy_data.has("texture") and enemy_data["texture"]:
		sprite.texture = enemy_data["texture"]
		var target_size = Vector2(80, 80)
		if enemy_data.has("base_size"):
			target_size = enemy_data["base_size"]
		var texture_size = enemy_data["texture"].get_size()
		var scale_x = target_size.x / texture_size.x
		var scale_y = target_size.y / texture_size.y
		sprite.scale = Vector2(scale_x, scale_y)
		if enemy_data.has("sprite_offset"):
			sprite.position = enemy_data["sprite_offset"]
		else:
			sprite.position = Vector2.ZERO
	else:
		sprite.modulate = Color(1, 0, 0)
		sprite.position = Vector2.ZERO
	update_button_size()
	update_display()
	update_button_postion()
	choose_next_attack()

func update_button_size():
	if sprite.texture:
		var texture_size = sprite.texture.get_size()
		var scaled_size = texture_size * sprite.scale
		button.size = scaled_size
		button.position = -scaled_size / 2
	else:
		button.size = Vector2(80, 80)
		button.position = Vector2(-40, -40)

func take_damage(damage: int):
	print("   ENEMY: Taking", damage, "damage. Current HP:", current_health)
	current_health -= damage
	if current_health < 0:
		current_health = 0
	print("   ENEMY: HP after damage:", current_health)
	update_display()
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.RED, 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)

func heal(amount: int):
	current_health += amount
	if current_health > max_health:
		current_health = max_health
	update_display()

func update_display():
	health_label.text = str(current_health) + "/" + str(max_health)
	var y_offset = (-sprite.texture.get_size().y * sprite.scale.y) 
	health_label.position = Vector2(-20, y_offset)

func set_targetable(targetable: bool):
	is_targetable = targetable
	button.disabled = !targetable
	if targetable:
		modulate = Color.YELLOW
	else:
		modulate = Color.WHITE

func _on_enemy_clicked():
	if is_targetable:
		enemy_clicked.emit(self)

func update_button_postion():
	if sprite.texture:
		var texture_size = sprite.texture.get_size()
		var scaled_size = texture_size * sprite.scale
		button.position = sprite.position - scaled_size / 2
		button.size = scaled_size
	else:
		button.position = Vector2(-40, -40)
		button.size = Vector2(80, 80)

func setup_attack_pattern(enemy_data: Dictionary):
	match enemy_type:
		"slime":
			attack_patterns = [
				{"type": "attack", "damage": 3, "weight": 8, "icon": "attack"},
				{"type": "strong_attack", "damage": 6, "weight": 2, "icon": "attack"}
			]
		"tree":
			attack_patterns = [
				{"type": "attack", "damage": 2, "weight": 7, "icon": "attack"},
				{"type": "block", "block": 5, "weight": 3, "icon": "attack"}
			]
		"boss_1":
			attack_patterns = [
				{"type": "attack", "damage": 5, "weight": 5, "icon": "attack"},
				{"type": "strong_attack", "damage": 8, "weight": 2, "icon": "attack"},
				{"type": "debuff", "damage": 3, "weak": 1, "weight": 3, "icon": "attack"}
			]
		_:
			attack_patterns = [
				{"type": "attack", "damage": 3, "weight": 10, "icon": "attack"}
			]

func setup_intent_animation():
	if not intent_icon:
		return
	var sprite_frames = SpriteFrames.new()
	if sprite_frames.has_animation("default"):
		sprite_frames.remove_animation("default")
	sprite_frames.add_animation("default")
	var spritesheet = preload("res://assets/tilesheets/Indicator TileSheet.png")
	var sheet_width = 256
	var sheet_height = 32
	var tile_size = 32
	var frames_per_row = sheet_width / tile_size
	var total_rows = sheet_height / tile_size
	var total_frames = frames_per_row * total_rows
	for row in range(total_rows):
		for col in range(frames_per_row):
			var atlas_texture = AtlasTexture.new()
			atlas_texture.atlas = spritesheet
			atlas_texture.region = Rect2(col * tile_size, row * tile_size, tile_size, tile_size)
			sprite_frames.add_frame("default", atlas_texture)
	intent_icon.sprite_frames = sprite_frames
	intent_icon.play("default")
	intent_icon.scale = Vector2(2, 2)

func choose_next_attack():
	if attack_patterns.is_empty():
		next_attack = {"type": "attack", "damage": damage, "icon": "attack"}
		return
	
	var total_weight = 0
	for attack in attack_patterns:
		total_weight += attack.get("weight", 1)
	var random_value = randi() % total_weight
	var current_weight = 0
	for attack in attack_patterns:
		current_weight += attack.get("weight", 1)
		if random_value < current_weight:
			next_attack = attack.duplicate()
			break
	update_intent_display()

func update_intent_display():
	if not intent_icon or not intent_value:
		return
	if intent_icon is AnimatedSprite2D:
		if not intent_icon.playing:
			intent_icon.play("default")
	match next_attack["type"]:
		"attack", "strong_attack", "debuff":
			intent_value.text = str(next_attack.get("damage", damage))
		"block":
			intent_value.text = "Block: " + str(next_attack.get("block", 0))
		_:
			intent_value.text = str(next_attack.get("damage", damage))
	intent_icon.visible = true
	intent_value.visible = true

func hide_intent():
	if intent_icon:
		intent_icon.visible = false
	if intent_value:
		intent_value.visible = false

func execute_attack():
	match next_attack["type"]:
		"attack", "strong_attack":
			battle_system.player.take_damage(next_attack.get("damage", damage))
			print(enemy_name + " attack for " + str(next_attack.get("damage", damage)))
		"block":
			print("RAAAAHHH")
			print(enemy_name + " will block " + str(next_attack.get("block", 0)) + " damage")
		"debuff":
			battle_system.player.take_damage(next_attack.get("damage", damage))
			print(enemy_name + " debuffs and attacks for " + str(next_attack.get("damage", damage)))
	choose_next_attack()
