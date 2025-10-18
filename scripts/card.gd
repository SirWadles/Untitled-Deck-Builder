extends Control
class_name Card

@onready var button: Button = $CardButton
@onready var name_label: Label = $NameLabel
@onready var cost_label: Label = $CostLabel
@onready var description_label: Label = $DescriptionLabel
@onready var card_border: Sprite2D = $CardBorder
@onready var card_art: Sprite2D = $CardArt

var card_data: CardData
var hand: Node
var is_selectable: bool = false
var pending_selectable: bool = false
var is_selected: bool = false
var original_position: Vector2
var original_scale: Vector2 = Vector2(1.5, 1.5)
var highlight_tween: Tween

func _ready():
	scale = Vector2(1.5, 1.5)
	button.pressed.connect(_on_card_clicked)
	button.size = Vector2(52, 64)
	if pending_selectable != is_selectable:
		button.disabled = !is_selectable
	original_position = position

func setup(data: CardData, hand_reference: Node = null):
	card_data = data
	hand = hand_reference
	call_deferred("_deferred_setup", data)

func _deferred_setup(data: CardData):
	if name_label:
		name_label.text = data.card_name
		name_label.add_theme_font_size_override("font_size", 10)
	if cost_label:
		cost_label.text = str(data.cost)
		cost_label.add_theme_font_size_override("font_size", 10)
	if description_label:
		description_label.text = data.description
		description_label.add_theme_font_size_override("font_size", 9)
	if card_data:
		if data.texture:
			card_art.texture = data.texture
		else: 
			card_art.modulate = Color(0.5, 0.5, 0.5)
	#set_card_visuals_based_on_type()

#func set_card_visuals_based_on_type():
	#if card_data.damage > 0:
		#card_border.modulate = Color(1, 0.3, 0.3)
	#elif card_data.heal > 0:
		#card_border.modulate = Color(0.3, 1, 0.3)
	#elif card_data.defense > 0:
		#card_border.modulate = Color(0.3, 0.3, 1)

func set_selectable(selectable: bool):
	is_selectable = selectable
	if button:
		button.disabled = !selectable
	else:
		pending_selectable = selectable
	if selectable:
		modulate = Color.WHITE
	else:
		modulate = Color.GRAY

func _on_card_clicked():
	if is_selectable and hand != null and hand.has_method("card_selected"):
		hand.card_selected(self)

func select():
	if not is_selectable or is_selected:
		return
	is_selected = true
	if highlight_tween:
		highlight_tween.kill()
	highlight_tween = create_tween()
	highlight_tween.set_parallel(true)
	highlight_tween.tween_property(self, "scale", original_scale * 1.2, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	highlight_tween.tween_property(self, "position:y", original_position.y - 25, 0.15)
	highlight_tween.tween_property(card_border, "modulate", Color(1.2, 1.2, 0.8, 1), 0.1)
	highlight_tween.tween_property(self, "modulate", Color(1.2, 1.2, 1, 1), 0.1)
	
	z_index = 1
	if hand != null and hand.has_method("card_selected"):
		hand.card_selected(self)

func deselect():
	if not is_selected:
		return
	is_selected = false
	if highlight_tween:
		highlight_tween.kill()
	highlight_tween = create_tween()
	highlight_tween.set_parallel(true)
	highlight_tween.tween_property(self, "scale", original_scale, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	highlight_tween.tween_property(self, "position:y", original_position.y - 25, 0.15)
	highlight_tween.tween_property(card_border, "modulate", Color.WHITE, 0.1)
	highlight_tween.tween_property(self, "modulate", Color.WHITE, 0.1)
	
	z_index = 0
	if hand != null and hand.has_method("card_deselected"):
		hand.card_deselected(self)

func _on_mouse_entered():
	if is_selectable and not is_selected:
		if highlight_tween:
			highlight_tween.kill()
		highlight_tween = create_tween()
		highlight_tween.set_parallel(true)
		highlight_tween.tween_property(self, "scale", original_scale * 1.1, 0.1)
		highlight_tween.tween_property(self, "position:y", original_position.y - 10, 0.1)
		highlight_tween.tween_property(card_border, "modulate", Color(1.1, 1.1, 1, 1), 0.1)

func _on_mouse_exited():
	if is_selectable and not is_selected:
		if highlight_tween:
			highlight_tween.kill()
		highlight_tween = create_tween()
		highlight_tween.set_parallel(true)
		highlight_tween.tween_property(self, "scale", original_scale, 0.1)
		highlight_tween.tween_property(self, "position:y", original_position.y, 0.1)
		highlight_tween.tween_property(card_border, "modulate", Color.WHITE, 0.1)

func animate_to_normal_state():
	if highlight_tween:
		highlight_tween.kill()
	highlight_tween = create_tween()
	highlight_tween.set_parallel(true)
	highlight_tween.tween_property(self, "modulate", Color.WHITE, 0.2)
	highlight_tween.tween_property(card_border, "modulate", Color.WHITE, 0.2)

func animate_to_disabled_state():
	if highlight_tween:
		highlight_tween.kill()
	highlight_tween.set_parallel(true)
	highlight_tween.tween_property(self, "modulate", Color.GRAY, 0.2)
	highlight_tween.tween_property(card_border, "modulate", Color(0.7, 0.7, 0.7, 1), 0.2)

func play_entrance_animation():
	scale = Vector2(0.8, 0.8)
	modulate = Color(1, 1, 1, 0)
	if highlight_tween:
		highlight_tween.kill()
	highlight_tween = create_tween()
	highlight_tween.set_parallel(true)
	highlight_tween.tween_property(self, "scale", original_scale, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	highlight_tween.tween_property(self, "modulate", Color.WHITE, 0.2)

func play_play_animation():
	if highlight_tween:
		highlight_tween.kill()
	highlight_tween = create_tween()
	highlight_tween.set_parallel(true)
	highlight_tween.tween_property(self, "scale", original_scale * 1.3, 0.15)
	highlight_tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.2)
	highlight_tween.tween_property(self, "position:y", position.y - 40, 0.2)
	
