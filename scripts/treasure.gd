extends Control
class_name Treasure

@onready var gold_label: Label = $MarginContainer/VBoxContainer/Header/GoldLabel
@onready var chest_button: Button = $MarginContainer/VBoxContainer/Control/ChestButton
@onready var chest_sprite: Sprite2D = $MarginContainer/VBoxContainer/Control/ChestButton/ChestSprite
@onready var return_button: Button = $ReturnButton
@onready var treasure_message: Label = $TreasureMessage
@onready var card_tooltip: Panel = $CardToolTip
@onready var card_display: Control = $CardDisplay
@onready var relic_display: Control = $RelicDisplay

@onready var music_player = $Audio/MusicPlayer
@onready var audio_options = $Audio/AudioOptions

var player_data: PlayerData
var card_database: CardDatabase
var reward_given: bool = false
var current_card_reward: CardData = null
var current_relic_reward: Dictionary
var displayed_card_instance: Card = null
var displayed_relic_instance: TextureRect = null

var reward_probabilities = {
	"gold": 0.35,
	"card": 0.35,
	"relic": 0.3
}

func _ready():
	player_data = get_node("/root/PlayerDatabase")
	card_database = get_node("/root/CardStuff")
	
	setup_ui()
	update_display()
	setup_chest_sprite()
	
	chest_button.pressed.connect(_on_chest_pressed)
	return_button.pressed.connect(_on_return_button_pressed)
	audio_options.visible = false
	music_player.bus = "Music"
	music_player.play()
	if card_tooltip:
		card_tooltip.visible = false
	if relic_display:
		relic_display.visible = false
		relic_display.position = Vector2(400, 250)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		audio_options.show_options()
	#if event is InputEventMouseButton and event.pressed:
		#if card_tooltip and card_tooltip.visible:
			#card_tooltip.visible = false

func setup_ui():
	return_button.text = "Return to Map"
	return_button.custom_minimum_size = Vector2(150, 40)
	return_button.position = Vector2(0, 600)
	
	var style_box = StyleBoxEmpty.new()
	chest_button.add_theme_stylebox_override("normal", style_box)
	chest_button.add_theme_stylebox_override("hover", style_box)
	chest_button.add_theme_stylebox_override("pressed", style_box)
	chest_button.add_theme_stylebox_override("disabled", style_box)
	chest_button.focus_mode = Control.FOCUS_NONE
	chest_button.custom_minimum_size = Vector2(128, 128)
	chest_button.position = Vector2(500, 300)
	
	treasure_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	treasure_message.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	treasure_message.visible = false
	treasure_message.add_theme_font_size_override("font_size", 36)
	add_text_outline()
	
	if card_tooltip:
		card_tooltip.visible = false
		card_tooltip.position = Vector2(400, 200)
	
	if card_display:
		card_display.visible = false
		card_display.position = Vector2(400, 250)
	
	if relic_display:
		relic_display.visible = false
		relic_display.position = Vector2(400, 250)

func add_text_outline():
	var outline_color = Color.BLACK
	var outline_size = 2
	treasure_message.add_theme_constant_override("outline_size", outline_size)
	treasure_message.add_theme_color_override("font_outline_color", outline_color)

func update_display():
	gold_label.text = "Gold: " + str(player_data.gold) + "g"

func setup_chest_sprite():
	var chest_texture = preload("res://assets/tilesheets/Fantasy RPG (Toony) 32x32.png")
	if chest_texture:
		var atlas = AtlasTexture.new()
		atlas.atlas = chest_texture
		atlas.region = Rect2(0, 0, 32, 32)
		chest_sprite.texture = atlas
		chest_sprite.position = Vector2(32, 32)
		chest_sprite.scale = Vector2(4, 4)

func _on_chest_pressed():
	if reward_given:
		return
	reward_given = true
	chest_button.disabled = true
	await animate_chest_open()
	var reward_type = get_random_reward_type()
	grant_reward(reward_type)

func animate_chest_open():
	var atlas = chest_sprite.texture as AtlasTexture
	atlas.region = Rect2(0, 32, 32, 32)
	await get_tree().create_timer(0.3).timeout
	atlas.region = Rect2(0, 64, 32, 32)
	await get_tree().create_timer(0.3).timeout
	atlas.region = Rect2(0, 96, 32, 32)

func get_random_reward_type() -> String:
	var total_probability = 0
	for reward_type in reward_probabilities:
		total_probability += reward_probabilities[reward_type]
	var rand_value = randf()
	var cumulative_probability = 0.0
	for reward_type in reward_probabilities:
		cumulative_probability += reward_probabilities[reward_type]
		if rand_value <= cumulative_probability:
			return reward_type
	return "gold"

func grant_reward(reward_type: String):
	match reward_type:
		"gold":
			grant_gold_reward()
		"card":
			grant_card_reward()
		"relic":
			grant_relic_reward()

func grant_gold_reward():
	var gold_amount = 50 + randi() % 51
	player_data.add_gold(gold_amount)
	show_treasure_message("Found " + str(gold_amount) + " gold!", Color.GOLDENROD)
	update_display()

func grant_card_reward():
	var random_card = card_database.get_random_card()
	if random_card:
		player_data.add_card_to_deck(random_card.card_id)
		current_card_reward = random_card
		show_treasure_message("Found a new card: " + random_card.card_name + "!", Color.SKY_BLUE)
		show_card_display(random_card)
		show_card_tooltip(random_card)
	else:
		grant_gold_reward()

func grant_relic_reward():
	var available_relics = get_sample_relics()
	if available_relics.size() > 0:
		var random_relic = available_relics[randi() % available_relics.size()]
		var relic_manager = get_node("/root/RelicManager")
		if relic_manager:
			relic_manager.add_relic(random_relic)
			show_treasure_message("Found a relic " + random_relic["name"] + "!", Color.PURPLE)
			show_relic_display(random_relic)
			show_relic_tooltip(random_relic)
		else:
			player_data.add_child(random_relic)
			show_treasure_message("Found a relic " + random_relic["name"] + "!", Color.PURPLE)
			show_relic_display(random_relic)
			show_relic_tooltip(random_relic)

func get_sample_relics() -> Array:
	var health_band_texture = preload("res://assets/relics/Band_of_Regeneration.png")
	var energy_cystal_texture = preload("res://assets/relics/Eternia_Crystal.png")
	var crystal_shard_texture = preload("res://assets/relics/Crystal_Shard.png")
	
	return [
		{
			"name": "Health Band",
			"description": "Heals 5 HP after combat ",
			"price": 0,
			"icon": health_band_texture,
			"id": "health_band"
		},
		{
			"name": "Energy Crystal",
			"description": "+1 Max Energy",
			"price": 0,
			"icon": energy_cystal_texture,
			"id": "energy_crystal"
		},
		{
			"name": "Crystal Shard",
			"description": "+5 Damage",
			"price": 0,
			"icon": crystal_shard_texture,
			"id": "crystal_shard"
		}
	]

func show_treasure_message(message: String, color: Color = Color.WHITE):
	treasure_message.text = message
	treasure_message.add_theme_color_override("font_color", color)
	treasure_message.visible = true
	var chest_center_x = chest_button.position.x + chest_button.size.x / 2
	var message_width = treasure_message.size.x
	var message_x = chest_center_x - message_width / 2
	var message_y = chest_button.position.y - 60
	treasure_message.position = Vector2(message_x, message_y)
	
	var tween = create_tween()
	tween.tween_property(treasure_message, "scale", Vector2(1.2, 1.2), 0.2)
	tween.tween_property(treasure_message, "scale", Vector2(1.0, 1.0), 0.2)
	
	#if "card" in message.to_lower():
		#await get_tree().create_timer(3.5).timeout
	#else:
		#await get_tree().create_timer(2.0).timeout
	#treasure_message.visible = false

func _on_return_button_pressed():
	if displayed_card_instance:
		displayed_card_instance.queue_free()
	if displayed_relic_instance:
		displayed_relic_instance.queue_free()
	get_tree().change_scene_to_file("res://scenes/map.tscn")

func show_card_tooltip(card_data: CardData):
	if not card_tooltip:
		return
	card_tooltip.follow_mouse = false
	card_tooltip.setup_card_tooltip(card_data)
	card_tooltip.position = Vector2(
		chest_button.position.x + chest_button.size.x - 10,
		chest_button.position.y + chest_button.size.y + 20
	)
	card_tooltip.visible = true

func show_card_display(card_data: CardData):
	if not card_display:
		return
	if displayed_card_instance:
		displayed_card_instance.queue_free()
	var card_scene = preload("res://scenes/battle/card.tscn")
	displayed_card_instance = card_scene.instantiate()
	card_display.add_child(displayed_card_instance)
	displayed_card_instance.setup(card_data, null)
	if displayed_card_instance.has_node("CostLabel"):
		displayed_card_instance.get_node("CostLabel").visible = false
	if displayed_card_instance.has_node("NameLabel"):
		displayed_card_instance.get_node("NameLabel").visible = false
	if displayed_card_instance.has_node("DescriptionLabel"):
		displayed_card_instance.get_node("DescriptionLabel").visible = false
	displayed_card_instance.position = Vector2(
		card_display.size.x / 2 - displayed_card_instance.size.x / 2,
		card_display.size.y / 2 - displayed_card_instance.size.y / 2 + 250
	)
	displayed_card_instance.scale = Vector2(2, 2)
	displayed_card_instance.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_display.visible = true
	
	var tween = create_tween()
	card_display.scale = Vector2(0.5, 0.5)
	card_display.modulate = Color.TRANSPARENT
	tween.tween_property(card_display, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_BACK)
	tween.parallel().tween_property(card_display, "modulate", Color.WHITE, 0.5)

func show_relic_tooltip(relic_data: Dictionary):
	if not card_tooltip:
		return
	card_tooltip.follow_mouse = false
	card_tooltip.setup_relic_tooltip(relic_data)
	card_tooltip.position = Vector2(
		chest_button.position.x + chest_button.size.x - 10,
		chest_button.position.y + chest_button.size.y + 20
	)
	card_tooltip.visible = true

func show_relic_display(relic_data: Dictionary):
	if not relic_display:
		return
	if displayed_relic_instance:
		displayed_relic_instance.queue_free()
	displayed_relic_instance = TextureRect.new()
	relic_display.add_child(displayed_relic_instance)
	if relic_data.has("icon") and relic_data["icon"]:
		displayed_relic_instance.texture = relic_data["icon"]
	displayed_relic_instance.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	displayed_relic_instance.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	displayed_relic_instance.custom_minimum_size = Vector2(150, 150)
	displayed_relic_instance.size = Vector2(150, 150)
	displayed_relic_instance.position = Vector2(
		relic_display.size.x / 2 - displayed_relic_instance.size.x / 2 - 50,
		relic_display.size.y / 2 - displayed_relic_instance.size.y / 2 + 250
	)
	displayed_relic_instance.mouse_filter = Control.MOUSE_FILTER_IGNORE
	relic_display.visible = true
	var tween = create_tween()
	relic_display.scale = Vector2(0.5, 0.5)
	relic_display.modulate = Color.TRANSPARENT
	tween.tween_property(relic_display, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_BACK)
	tween.parallel().tween_property(relic_display, "modulate", Color.WHITE, 0.5)
