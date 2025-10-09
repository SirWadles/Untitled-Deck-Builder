extends Control
class_name Treasure

@onready var gold_label: Label = $MarginContainer/VBoxContainer/Header/GoldLabel
@onready var chest_button: Button = $MarginContainer/VBoxContainer/CenterContainer/ChestButton
@onready var chest_sprite: Sprite2D = $MarginContainer/VBoxContainer/CenterContainer/ChestButton/ChestSprite
@onready var return_button: Button = $MarginContainer/VBoxContainer/Footer/ReturnButton
@onready var treasure_message: Label = $TreasureMessage

@onready var music_player = $Audio/MusicPlayer
@onready var audio_options = $Audio/AudioOptions

var player_data: PlayerData
var card_database: CardDatabase
var reward_given: bool = false

var reward_probabilities = {
	"gold": 0.5,
	"card": 0.35,
	"relic": 0.15
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

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		audio_options.show_options()

func setup_ui():
	return_button.text = "Return to Map"
	return_button.custom_minimum_size = Vector2(150, 40)
	chest_button.focus_mode = Control.FOCUS_NONE
	chest_button.custom_minimum_size = Vector2(64, 64)
	treasure_message.visible = false
	treasure_message.add_theme_font_size_override("font_size", 24)

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
		chest_sprite.scale = Vector2(2, 2)

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
		show_treasure_message("Found a new card: " + random_card.card_name + "!", Color.SKY_BLUE)
	else:
		grant_gold_reward()

func grant_relic_reward():
	var available_relics = get_sample_relics()
	if available_relics.size() > 0:
		var random_relic = available_relics[randi() % available_relics.size()]
		player_data.add_relic(random_relic)
		show_treasure_message("Found a relic " + random_relic["name"] + "!", Color.PURPLE)
		var relic_manager = get_node("/root/RelicManager")
		if relic_manager:
			relic_manager.add_relic(random_relic)
		else:
			grant_gold_reward()

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
	
	var tween = create_tween()
	tween.tween_property(treasure_message, "scale", Vector2(1.2, 1.2), 0.2)
	tween.tween_property(treasure_message, "scale", Vector2(1.0, 1.0), 0.2)
	
func _on_return_button_pressed():
	get_tree().change_scene_to_file("res://scenes/map.tscn")
