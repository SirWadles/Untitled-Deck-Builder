extends Control

@onready var grid_container: GridContainer = $VBoxContainer/GridContainer
@onready var tool_tip: Panel = $VBoxContainer/CardToolTip
@onready var title_label: Label = $VBoxContainer/TitleLabel

var card_database = CardDatabase

func _ready():
	card_database = get_node("/root/CardStuff")
	tool_tip.visible = false

func display_deck(deck: Array[String], title: String = ""):
	if title_label and title != "":
		title_label.text = title
	for child in grid_container.get_children():
		child.queue_free()
	for card_id in deck:
		var card_texture_rect = TextureRect.new()
		card_texture_rect.texture = card_database.get_card(card_id).texture
		card_texture_rect.custom_minimum_size = Vector2(50, 70)
		card_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		card_texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		card_texture_rect.mouse_entered.connect(_on_card_mouse_entered.bind(card_id))
		card_texture_rect.mouse_exited.connect(_on_card_mouse_exited)
		
		grid_container.add_child(card_texture_rect)

func _on_card_mouse_entered(card_id: String):
	var card_data = card_database.get_card(card_id)
	if card_data:
		tool_tip.setup_card_tooltip(card_data)
		tool_tip.visible = true

func _on_card_mouse_exited():
	tool_tip.visible = false
