extends PanelContainer
class_name ShopRelic

@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var description_label:  Label = $VBoxContainer/DescriptionLabel
@onready var price_label: Label = $VBoxContainer/PriceLabel
@onready var texture_rect: TextureRect = $VBoxContainer/TextureRect
@onready var purchase_button: Button = $VBoxContainer/PurchaseButton

var relic_data: Dictionary
signal purchased(relic_data: Dictionary, price: int)

func _ready():
	custom_minimum_size = Vector2(200, 250)
	size = Vector2(200, 250)
	
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.5, 0.4, 0.8, 0.3)
	style_box.corner_radius_top_left = 10
	style_box.corner_radius_top_right = 10
	style_box.corner_radius_bottom_right = 10
	style_box.corner_radius_bottom_left = 10
	style_box.border_width_bottom = 2
	style_box.border_width_top = 2
	style_box.border_width_left = 2
	style_box.border_width_right = 2
	style_box.border_color = Color.DARK_GOLDENROD
	add_theme_stylebox_override("panel", style_box)
		
	purchase_button.text = "BUY"
	purchase_button.custom_minimum_size = Vector2(0, 40)
	purchase_button.pressed.connect(_on_purchase_button_pressed)

	mouse_filter = Control.MOUSE_FILTER_PASS
	
	purchase_button.focus_mode = Control.FOCUS_NONE

func _input(event):
	if event.is_action_pressed("ui_accept") and self.modulate == Color(1.2, 1.2, 0.8):
		_on_purchase_button_pressed()

func setup(data: Dictionary):
	relic_data = data
	name_label.text = data["name"]
	description_label.text = data["description"]
	price_label.text = str(data["price"]) + " Gold"
	if data.has("icon") and data["icon"]:
		texture_rect.texture = data["icon"]
		texture_rect.custom_minimum_size = Vector2(100, 100)

func _on_purchase_button_pressed():
	purchased.emit(relic_data, relic_data["price"])
