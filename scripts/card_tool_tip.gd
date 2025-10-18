extends Panel

@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var cost_label: Label = $VBoxContainer/CostLabel
@onready var desc_label: Label = $VBoxContainer/DescLabel
@onready var stats_label: Label = $VBoxContainer/StatsLabel
@onready var vbox_container: VBoxContainer = $VBoxContainer

var mouse_offset = Vector2(20, 20)
var follow_mouse: bool = true

func _ready():
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = Color(0.1, 0.1, 0.2, 0.95)
	stylebox.border_color = Color.GOLD
	stylebox.border_width_left = 2
	stylebox.border_width_top = 2
	stylebox.border_width_right = 2
	stylebox.border_width_bottom = 2
	stylebox.corner_radius_top_left = 8
	stylebox.corner_radius_top_right = 8
	stylebox.corner_radius_bottom_right = 8
	stylebox.corner_radius_bottom_left = 8
	stylebox.expand_margin_left = 5
	add_theme_stylebox_override("panel", stylebox)
	
	#name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	#cost_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	#desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	#stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", Color.GOLD)
	cost_label.add_theme_font_size_override("font_size", 14)
	cost_label.add_theme_color_override("font_color", Color.YELLOW)
	desc_label.add_theme_font_size_override("font_size", 12)
	stats_label.add_theme_font_size_override("font_size", 12)
	stats_label.add_theme_color_override("font_color", Color.ORANGE)
	
	custom_minimum_size = Vector2(180, 0)
	size = Vector2.ZERO
	
	z_index = 100

func _process(_delta):
	if visible and follow_mouse:
		_update_tooltip_position()

func setup_card_tooltip(card_data: CardData):
	name_label.text = card_data.card_name
	cost_label.text = "Cost: " + str(card_data.cost)
	desc_label.text = card_data.description
	var stats_text = ""
	if card_data.damage > 0:
		stats_text += "Damage: " + str(card_data.damage) + "\n"
	if card_data.heal > 0:
		stats_text += "Heal: " + str(card_data.heal) + "\n"
	stats_label.text = stats_text
	stats_label.visible = !stats_text.is_empty()
	cost_label.visible = true
	await get_tree().process_frame
	_resize_to_fit_content()
	if follow_mouse:
		_update_tooltip_position()

func setup_relic_tooltip(relic_data: Dictionary):
	name_label.text = relic_data["name"]
	cost_label.text = "Price: " + str(relic_data["price"]) + " Gold"
	desc_label.text = relic_data["description"]
	if relic_data["price"] == 0:
		cost_label.text = "Price: Free!"
	var stats_text = ""
	match relic_data["id"]:
		"health_band":
			stats_text += "Heals 5 HP after combat\n"
		"energy_crystal":
			stats_text += "+1 Max Energy\n"
		"crystal_shard":
			stats_text += "+5 Damage to all attacks\n"
	stats_label.text = stats_text
	stats_label.visible = !stats_text.is_empty()
	cost_label.visible = true
	await get_tree().process_frame
	_resize_to_fit_content()
	if follow_mouse:
		_update_tooltip_position()

func _update_tooltip_position():
	var mouse_pos = get_global_mouse_position()
	var tooltip_pos = mouse_pos + mouse_offset
	var viewport_size = get_viewport().get_visible_rect().size
	if tooltip_pos.x + size.x > viewport_size.x:
		tooltip_pos.x = mouse_pos.x - size.x - mouse_offset.x
	if tooltip_pos.y + size.y > viewport_size.y:
		tooltip_pos.y = mouse_pos.y - size.y - mouse_offset.y
	tooltip_pos.x = max(0, tooltip_pos.x)
	tooltip_pos.y = max(0, tooltip_pos.y)
	global_position = tooltip_pos

func _resize_to_fit_content():
	vbox_container.queue_sort()
	await get_tree().process_frame
	
	var content_width = 0
	var content_height = 0
	
	content_width = max(content_width, name_label.size.x)
	content_width = max(content_width, cost_label.size.x)
	content_width = max(content_width, desc_label.size.x)
	content_width = max(content_width, stats_label.size.x)
	
	content_width = max(content_width + 20, 180)
	content_height = vbox_container.size.y + 20
	size = Vector2(content_width, content_height)
