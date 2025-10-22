extends Node2D
class_name Player

@onready var health_label: Label = $HealthLabel
@onready var energy_label: Label = $EnergyLabel
@onready var target_button: Button = $TargetButton
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var healing_effect: AnimatedSprite2D = $HealingEffect

signal player_clicked(player: Player)
signal attack_animation_finished
signal heal_animation_finished

var player_data: PlayerData
var current_energy: int = 3
var battle_system: BattleSystem = null
var is_attacking: bool = false
var is_healing: bool = false
var active_debuffs: Dictionary = {}
var debuff_indicators: Array[Node] = []

func _ready():
	player_data = get_node("/root/PlayerDatabase")
	setup_animations()
	health_label.position = Vector2(5, -63)
	energy_label.position = Vector2(5, -50)
	target_button.visible = false
	target_button.pressed.connect(_on_target_button_pressed)
	update_display()
	if healing_effect:
		healing_effect.visible = false
		if not healing_effect.animation_finished.is_connected(_on_heal_effect_finished):
			healing_effect.animation_finished.connect(_on_heal_effect_finished)
	if not has_node("DebuffContainer"):
		var container = Node2D.new()
		container.name = "DebuffContainer"
		container.position = Vector2.ZERO
		container.z_index = 5
		add_child(container)
		print("DEBUG: Created DebuffContainer with z-index: ", container.z_index)

func setup_animations():
	var character_data = get_node("/root/PlayerDatabase")
	var character_type = character_data.character_type
	var tile_sheet: Texture2D
	var tile_sheet_heal = preload("res://assets/tilesheets/Healing Circle(3).png")
	match character_type:
		"wizard":
			tile_sheet = preload("res://assets/tilesheets/Witch TileSheet(1).png")
		"witch":
			tile_sheet = preload("res://assets/tilesheets/Witch TileSheet(1).png")
		_:
			tile_sheet = preload("res://assets/tilesheets/Witch TileSheet(1).png")
	var sprite_frames = SpriteFrames.new()
	sprite_frames.clear_all()
	var tile_width = 64
	var tile_height = 64
	var frames_per_row = 4
	if character_type == "wizard":
		setup_wizard_animations(sprite_frames, tile_sheet, tile_width, tile_height, frames_per_row)
	else:
		setup_witch_animations(sprite_frames, tile_sheet, tile_width, tile_height, frames_per_row)
	sprite_frames.add_animation("idle")
	sprite_frames.set_animation_speed("idle", 1.5)
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
	if not animated_sprite.animation_finished.is_connected(_on_animated_finished):
		animated_sprite.animation_finished.connect(_on_animated_finished)
	if healing_effect:
		var heal_frames = SpriteFrames.new()
		heal_frames.clear_all()
		heal_frames.add_animation("heal")
		heal_frames.set_animation_speed("heal", 16)
		heal_frames.set_animation_loop("heal", false)
		for i in range(8):
			var frame = AtlasTexture.new()
			frame.atlas = tile_sheet_heal
			frame.region = Rect2(i * tile_width, 0 * tile_height, tile_width, tile_height)
			heal_frames.add_frame("heal", frame)
		if healing_effect:
			healing_effect.sprite_frames = heal_frames
			healing_effect.position = Vector2(0, -7)
			healing_effect.scale = Vector2(1.2, 1.1)
			#healing_effect.z_index = -0.7
	#animated_sprite.z_index = 1
	animated_sprite.sprite_frames = sprite_frames
	animated_sprite.play("idle")
	if not animated_sprite.animation_finished.is_connected(_on_animated_finished):
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

func play_heal_animation():
	if not is_healing:
		is_healing = true
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color.GREEN, 0.2)
		tween.tween_property(self, "modulate", Color.WHITE, 0.3)
		if healing_effect:
			healing_effect.visible = true
			healing_effect.play("heal")
		else:
			animated_sprite.play("heal")

func _on_animated_finished():
	print("   PLAYER: Animation finished -", animated_sprite.animation)
	if animated_sprite.animation == "attack":
		is_attacking = false
		attack_animation_finished.emit()
		print("   PLAYER: Attack animation signal emitted")
		play_idle_animation()

func _on_heal_effect_finished():
	if healing_effect:
		healing_effect.visible = false
		healing_effect.stop()
	is_healing = false
	heal_animation_finished.emit()
		
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
	var actual_damage = damage
	if battle_system and battle_system.has_method("calculate_player_incoming_damage"):
		actual_damage = battle_system.calculate_player_incoming_damage(damage)
	player_data.take_damage(actual_damage)
	update_display()
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.RED, 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)

func heal(amount: int, allow_overheal: bool = false):
	player_data.heal(amount, allow_overheal)
	update_display()

func can_play_card(cost: int) -> bool:
	return current_energy >= cost

func spend_energy(amount: int):
	current_energy -= amount
	update_display()

func start_turn():
	process_debuffs()
	current_energy = player_data.get_max_energy()
	update_display()

func update_display():
	health_label.text = "HP: " + str(player_data.current_health) + "/" + str(player_data.max_health)
	var current_max_energy = player_data.get_max_energy()
	energy_label.text = "Energy: " + str(current_energy) + "/" + str(current_max_energy)

func full_heal():
	player_data.current_health = player_data.max_health + 4
	update_display()

func test_heal():
	print("test heal")
	modulate = Color.GREEN
	play_heal_animation()
	await heal_animation_finished
	modulate = Color.WHITE

func setup_witch_animations(sprite_frames: SpriteFrames, tile_sheet: Texture2D, tile_width: int, tile_height: int, frames_per_row: int):
	sprite_frames.add_animation("idle")
	sprite_frames.set_animation_speed("idle", 1.5)
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

func setup_wizard_animations(sprite_frames: SpriteFrames, tile_sheet: Texture2D, tile_width: int, tile_height: int, frames_per_row: int):
	sprite_frames.add_animation("idle")
	sprite_frames.set_animation_speed("idle", 1.5)
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

func apply_debuff(debuff_type: String, duration: int, value: int = 0):
	if not active_debuffs.has(debuff_type):
		active_debuffs[debuff_type] = {"duration": duration, "value": value}
	else:
		active_debuffs[debuff_type].duration = duration
		active_debuffs[debuff_type].value = value
	print("DEBUG: Applied debuff - Type: ", debuff_type, " Duration: ", duration, " Value: ", value)
	print("DEBUG: Active debuffs: ", active_debuffs)
	update_debuff_indicators()

func remove_debuff(debuff_type: String):
	if active_debuffs.has(debuff_type):
		active_debuffs.erase(debuff_type)
		update_debuff_indicators()

func process_debuffs():
	var debuffs_to_remove: Array[String] = []
	for debuff_type in active_debuffs:
		active_debuffs[debuff_type].duration -= 1
		if active_debuffs[debuff_type].duration <= 0:
			debuffs_to_remove.append(debuff_type)
	update_debuff_indicators()
	for debuff_type in debuffs_to_remove:
		remove_debuff(debuff_type)

func has_debuff(debuff_type: String) -> bool:
	return active_debuffs.has(debuff_type)

func get_debuff_value(debuff_type: String) -> int:
	if active_debuffs.has(debuff_type):
		return active_debuffs[debuff_type].value
	return 0

func update_debuff_indicators():
	var container = get_node_or_null("DebuffContainer")
	if not container:
		print("No container found")
		return
	print("DEBUG: Updating debuff indicators. Active debuffs: ", active_debuffs.keys())
	for indicator in debuff_indicators:
		if is_instance_valid(indicator) and indicator.get_parent() == container:
			container.remove_child(indicator)
		indicator.queue_free()
	debuff_indicators.clear()
	await get_tree().process_frame
	var index = 0
	for debuff_type in active_debuffs:
		print("DEBUG: Creating indicator for: ", debuff_type)
		var indicator = create_debuff_indicator(debuff_type, active_debuffs[debuff_type])
		if indicator:
			indicator.position = Vector2(-40 + (index * 25), -80)
			container.add_child(indicator)
			debuff_indicators.append(indicator)
			index += 1
	print("DEBUG: Created ", debuff_indicators.size(), " indicators")

func create_debuff_indicator(debuff_type: String, debuff_data: Dictionary) -> Node2D:
	var indicator = Node2D.new()
	indicator.z_index = 10
	var animated_sprite = AnimatedSprite2D.new()
	animated_sprite.z_index = 11
	var sprite_frames = SpriteFrames.new()
	sprite_frames.add_animation("default")
	var spritesheet = preload("res://assets/tilesheets/Indicator TileSheet.png")
	var sheet_width = 256
	var sheet_height = 32
	var tile_size = 32
	var frames_per_row = sheet_width / tile_size
	var total_rows = sheet_height / tile_size
	for row in range(total_rows):
		for col in range(frames_per_row):
			var atlas_texture = AtlasTexture.new()
			atlas_texture.atlas = spritesheet
			atlas_texture.region = Rect2(col * tile_size, row * tile_size, tile_size, tile_size)
			sprite_frames.add_frame("default", atlas_texture)
	sprite_frames.set_animation_loop("default", true)
	sprite_frames.set_animation_speed("default", 5)
	animated_sprite.sprite_frames = sprite_frames
	animated_sprite.play("default")
	animated_sprite.scale = Vector2(0.8, 0.8)
	animated_sprite.visible = true
	print("DEBUG: AnimatedSprite frames: ", sprite_frames.get_frame_count("default"))
	print("DEBUG: AnimatedSprite playing: ", animated_sprite.is_playing())
	indicator.add_child(animated_sprite)
	
	var label = Label.new()
	label.z_index = 12
	label.text = str(debuff_data.duration)
	label.add_theme_font_size_override("font_size", 12)
	label.position = Vector2(8, 8)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	var background = ColorRect.new()
	background.z_index = 11
	background.size = Vector2(25, 18)
	background.position = Vector2(-12.5, 18)
	background.color = Color(0, 0, 0, 0.7)
	indicator.add_child(background)
	indicator.add_child(label)
	return indicator

func get_debuff_texture(debuff_type) -> Texture2D:
	match debuff_type:
		"weak":
			return preload("res://assets/tilesheets/Indicator TileSheet.png")
		"vulnerable":
			return preload("res://assets/tilesheets/Indicator TileSheet.png")
		_:
			return null

func calculate_outgoing_damage(base_damage: int) -> int:
	var actual_damage = base_damage
	if has_debuff("weak"):
		var weak_value = get_debuff_value("weak")
		actual_damage = max(0, actual_damage - weak_value)
		print("Weak debuff reduces damage: ", base_damage, " -> ", actual_damage)
	return actual_damage
