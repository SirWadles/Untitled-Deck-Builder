extends Node2D
class_name Enemy

@onready var health_label: Label = $HealthLabel
@onready var button: Button = $Button
@onready var sprite: Sprite2D = $Sprite2D

var enemy_name: String
var max_health: int
var current_health: int
var battle_system: BattleSystem
var is_targetable: bool = false

signal enemy_clicked(enemy: Enemy)

func _ready():
	button.pressed.connect(_on_enemy_clicked)

func setup(name: String, health: int, battle_ref: BattleSystem, enemy_texture: Texture2D = null):
	enemy_name = name
	max_health = health
	current_health = health
	battle_system = battle_ref
	if enemy_texture:
		sprite.texture = enemy_texture
	else:
		sprite.modulate = Color(1, 0, 0)
	update_display()

func take_damage(damage: int):
	current_health -= damage
	if current_health < 0:
		current_health = 0
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
