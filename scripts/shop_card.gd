extends Button
class_name ShopCard

@onready var price_label: Label = $PriceLabel


var card_data: CardData
var price: int

signal purchased(card_data: CardData, price: int)

func setup(data: CardData, card_price: int):
	card_data = data
	price = card_price
	price_label.text = str(price) + " Gold"

func _on_pressed():
	purchased.emit(card_data, price)
