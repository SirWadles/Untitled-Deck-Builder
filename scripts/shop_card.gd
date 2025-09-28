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
	custom_minimum_size = Vector2(200, 300)
	purchase_button.pressed.connect(_on_purchase_button_pressed)

func setup(data: CardData, card_price: int):
	card_data = data
	price = card_price
	name_label.text = data.card_name
	price_label.text = str(price) + " Gold"
	description_label.text = data.description
	if data.texture:
		texture_rect.texture = data.texture
	style_card_by_type()

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
