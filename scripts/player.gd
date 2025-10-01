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
	var tile_sheet = preload("res://assets/tilesheets/Witch TileSheet(1).png")
	var sprite_frames = SpriteFrames.new()
	sprite_frames.clear_all()
	var tile_width = 64
	var tile_height = 64
	var frames_per_row = 4
	sprite_frames.add_animation("idle")
	sprite_frames.set_animation_speed("idle", 5)
	sprite_frames.set_animation_loop("idle", true)
	for i in range(2):
		var frame = AtlasTexture.new()
		frame.atlas = tile_sheet
		frame.region = Rect2(i * tile_width, 0 * tile_height, tile_width, tile_height)
		sprite_frames.add_frame("idle", frame)
	sprite_frames.add_animation("attack")
	sprite_frames.set_animation_speed("attack", 10)
	sprite_frames.set_animation_loop("attack", false)
	for i in range(2, frames_per_row):
		var frame = AtlasTexture.new()
		frame.atlas = tile_sheet
		frame.region = Rect2(i * tile_width, 0 * tile_height, tile_width, tile_height)
		sprite_frames.add_frame("attack", frame)
	for i in range(frames_per_row):
		var frame = AtlasTexture.new()
		frame.atlas = tile_sheet
		frame.region = Rect2(i * tile_width, 1 * tile_height, tile_width, tile_height)
		sprite_frames.add_frame("attack", frame)
	animated_sprite.sprite_frames = sprite_frames
	animated_sprite.play("idle")
	if not animated_sprite.animation_finished.connect(_on_animated_finished):
		animated_sprite.animation_finished.connect(_on_animated_finished)
	print("Animation signal connected:", animated_sprite.animation_finished.is_connected(_on_animated_finished))
	print("=== ANIMATION SETUP ===")
	print("Idle frames:", sprite_frames.get_frame_count("idle"))
	print("Attack frames:", sprite_frames.get_frame_count("attack"))
	print("Current animation:", animated_sprite.animation)
	print("Animation speed:", sprite_frames.get_animation_speed("attack"))
	
func play_attack_animation():
	print("   PLAYER: Starting attack animation")
	if not is_attacking:
		is_attacking = true
		animated_sprite.play("attack")
		print("   PLAYER: Attack animation playing")
	else:
		print("   PLAYER: Already attacking, ignoring")

func play_idle_animation():
	animated_sprite.play("idle")

func _on_animated_finished():
	print("   PLAYER: Animation finished -", animated_sprite.animation)
	if animated_sprite.animation == "attack":
		is_attacking = false
		attack_animation_finished.emit()
		print("   PLAYER: Attack animation signal emitted")
		play_idle_animation()
	#elif animated_sprite.animation == "hurt":
		#play_idle_animation()

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
