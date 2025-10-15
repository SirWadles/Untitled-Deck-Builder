extends PanelContainer
class_name ShopCard

@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var description_label: Label = $VBoxContainer/DescriptionLabel
@onready var price_label: Label = $VBoxContainer/PriceLabel
@onready var texture_rect: TextureRect = $VBoxContainer/TextureRect
@onready var purchase_button: Button = $VBoxContainer/PurchaseButton

var card_data: CardData
var price: int

signal purchased(card_data: CardData, price: int)

func _ready():
	custom_minimum_size = Vector2(190, 260)
	size = Vector2(190, 260)
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	purchase_button.text = "BUY"
	purchase_button.custom_minimum_size = Vector2(0, 40)
	purchase_button.pressed.connect(_on_purchase_button_pressed)

func setup(data: CardData, card_price: int):
	card_data = data
	price = card_price
	name_label.text = data.card_name
	price_label.text = str(price) + " Gold"
	description_label.text = data.description
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	description_label.max_lines_visible = 2
	description_label.custom_minimum_size.y = 0
	if data.texture:
		texture_rect.texture = data.texture
		texture_rect.custom_minimum_size = Vector2(120, 120)
	style_card_by_type()
	custom_minimum_size = Vector2(180, 240)
	size = Vector2(180, 240)

func style_card_by_type():
	var style_box = StyleBoxFlat.new()
	match card_data.card_id:
		"attack":
			style_box.bg_color = Color(0.8, 0.3, 0.3, 0.3)
		"blood_fire":
			style_box.bg_color = Color(0.8, 0.2, 0.2, 0.3)
		"abundance":
			style_box.bg_color = Color(0.3, 0.8, 0.3, 0.3)
		_:
			style_box.bg_color = Color(0.3, 0.3, 0.8, 0.3)
	style_box.corner_radius_top_left = 10
	style_box.corner_radius_top_right = 10
	style_box.corner_radius_bottom_right = 10
	style_box.corner_radius_bottom_left = 10
	style_box.border_width_bottom = 2
	style_box.border_width_top = 2
	style_box.border_width_left = 2
	style_box.border_width_right = 2
	style_box.border_color = Color.GOLD
	add_theme_stylebox_override("panel", style_box)

func _on_purchase_button_pressed():
	purchased.emit(card_data, price)
