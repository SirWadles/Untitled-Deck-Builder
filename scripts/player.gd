extends Node2D
class_name Player

@onready var health_label: Label = $HealthLabel
@onready var energy_label: Label = $EnergyLabel
@onready var target_button: Button = $TargetButton
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

signal player_clicked(player: Player)
signal attack_animation_finished

var player_data: PlayerData
var current_energy: int = 3
var battle_system: BattleSystem = null
var is_attacking: bool = false

func _ready():
	player_data = get_node("/root/PlayerDatabase")
	setup_animations()
	health_label.position = Vector2(5, -63)
	energy_label.position = Vector2(5, -50)
	target_button.visible = false
	target_button.pressed.connect(_on_target_button_pressed)
	update_display()

func setup_animations():
	var tile_sheet = preload("res://assets/attacks/Witch Attacking.png")
	var sprite_frames = SpriteFrames.new()
	sprite_frames.clear_all()
	sprite_frames.add_animation("attack")

func set_battle_system(system: BattleSystem):
	battle_system = system

func set_targetable(targetable: bool):
	target_button.visible = true
	if targetable:
		modulate = Color.YELLOW
		if battle_system and battle_system.ui and battle_system.ui.has_method("update_status"):
			battle_system.ui.update_status("Click on yourself to heal")
	else:
		modulate = Color.WHITE

func _on_target_button_pressed():
	if battle_system:
		player_clicked.emit(self)

func take_damage(damage: int):
	player_data.take_damage(damage)
	update_display()

func heal(amount: int):
	player_data.heal(amount)
	update_display()

func can_play_card(cost: int) -> bool:
	return current_energy >= cost

func spend_energy(amount: int):
	current_energy -= amount
	update_display()

func start_turn():
	current_energy = player_data.max_energy
	update_display()

func update_display():
	health_label.text = "HP: " + str(player_data.current_health) + "/" + str(player_data.max_health)
	energy_label.text = "Energy: " + str(current_energy) + "/" + str(player_data.max_energy)

func full_heal():
	player_data.current_health = player_data.max_health + 4
	update_display()
