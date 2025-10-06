extends Panel

@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var cost_label: Label = $VBoxContainer/CostLabel
@onready var desc_label: Label = $VBoxContainer/DescLabel
@onready var stats_label: Label = $VBoxContainer/StatsLabel

func _ready():
	z_index = 100
	
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
	add_theme_stylebox_override("panel", stylebox)
	
	custom_minimum_size = Vector2(220, 200)
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", Color.GOLD)
	cost_label.add_theme_font_size_override("font_size", 14)
	cost_label.add_theme_color_override("font_color", Color.YELLOW)
	desc_label.add_theme_font_size_override("font_size", 12)
	stats_label.add_theme_font_size_override("font_size", 12)
	stats_label.add_theme_color_override("font_color", Color.ORANGE)
