extends Control
class_name Card

@onready var button: Button = $CardButton
@onready var name_label: Label = $NameLabel
@onready var cost_label: Label = $CostLabel
@onready var description_label: Label = $DescriptionLabel
@onready var card_border: Sprite2D = $CardBorder
@onready var card_art: Sprite2D = $CardArt
@onready var card_tooltip: Panel = $CardToolTip

var card_data: CardData
var hand: Node
var is_selectable: bool = false
var pending_selectable: bool = false
var is_selected: bool = false
var base_position: Vector2
var base_scale: Vector2 = Vector2(1.5, 1.5)
var highlight_tween: Tween

var tooltip_instance: Control = null
var is_hovering: bool = false

func _ready():
	base_scale = Vector2(1, 1)
	base_scale = scale
	button.pressed.connect(_on_card_clicked)
	button.mouse_entered.connect(_on_mouse_entered)
	button.mouse_exited.connect(_on_mouse_exited)
	button.size = Vector2(52, 64)
	if pending_selectable != is_selectable:
		button.disabled = !is_selectable
	if card_tooltip:
		card_tooltip.visible = false
	
	TranslationManager.language_changed.connect(_on_language_changed)

func _on_language_changed():
	if card_data and name_label and description_label:
		name_label.text = TranslationManager.translate(card_data.card_name)
		description_label.text = TranslationManager.translate(card_data.description)

func setup(data: CardData, hand_reference: Node = null):
	card_data = data
	hand = hand_reference
	call_deferred("_deferred_setup", data)

func _deferred_setup(data: CardData):
	if name_label:
		name_label.text = TranslationManager.translate(data.card_name)
		name_label.add_theme_font_size_override("font_size", 10)
	if cost_label:
		cost_label.text = str(data.cost)
		cost_label.add_theme_font_size_override("font_size", 10)
	if description_label:
		description_label.text = TranslationManager.translate(data.description)
		description_label.add_theme_font_size_override("font_size", 9)
	if card_data:
		if data.texture:
			card_art.texture = data.texture
		else: 
			card_art.modulate = Color(0.5, 0.5, 0.5)
	await get_tree().process_frame
	base_position = position

func set_selectable(selectable: bool):
	is_selectable = selectable
	if button:
		button.disabled = !selectable
	else:
		pending_selectable = selectable
	if selectable:
		animate_to_normal_state()
	else:
		if is_selected:
			deselect()
		animate_to_disabled_state()

func _on_card_clicked():
	if not is_selectable:
		return
	if hand != null and hand.has_method("card_selected"):
		if not is_selected:
			select()
		else:
			deselect()

func select():
	if not is_selectable or is_selected:
		return
	is_selected = true
	hide_tooltip()
	if highlight_tween:
		highlight_tween.kill()
	scale = base_scale
	position.y = base_position.y
	highlight_tween = create_tween()
	highlight_tween.set_parallel(true)
	var target_scale = base_scale * 1.2
	highlight_tween.tween_property(self, "scale", target_scale, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
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
	highlight_tween.tween_property(self, "scale", base_scale, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	highlight_tween.tween_property(card_border, "modulate", Color.WHITE, 0.1)
	highlight_tween.tween_property(self, "modulate", Color.WHITE, 0.1)
	
	z_index = 0
	if hand != null and hand.has_method("card_deselected"):
		hand.card_deselected(self)

func _on_mouse_entered():
	is_hovering = true
	if is_selectable and not is_selected:
		if highlight_tween:
			highlight_tween.kill()
		highlight_tween = create_tween()
		highlight_tween.set_parallel(true)
		highlight_tween.tween_property(self, "scale", base_scale * 1.1, 0.1)
		highlight_tween.tween_property(card_border, "modulate", Color(1.1, 1.1, 1, 1), 0.1)
	await get_tree().create_timer(0.3).timeout
	if is_hovering and card_data:
		show_tooltip()

func _on_mouse_exited():
	is_hovering = false
	if is_selectable and not is_selected:
		if highlight_tween:
			highlight_tween.kill()
		highlight_tween = create_tween()
		highlight_tween.set_parallel(true)
		highlight_tween.tween_property(self, "scale", base_scale, 0.1)
		#highlight_tween.tween_property(self, "position:y", base_position.y, 0.1)
		highlight_tween.tween_property(card_border, "modulate", Color.WHITE, 0.1)
	hide_tooltip()

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
	highlight_tween = create_tween()
	highlight_tween.set_parallel(true)
	highlight_tween.tween_property(self, "modulate", Color.GRAY, 0.2)
	highlight_tween.tween_property(card_border, "modulate", Color(0.7, 0.7, 0.7, 1), 0.2)

func play_entrance_animation():
	scale = Vector2(0.5, 0.5)
	modulate = Color(1, 1, 1, 0)
	if highlight_tween:
		highlight_tween.kill()
	highlight_tween = create_tween()
	highlight_tween.set_parallel(true)
	highlight_tween.tween_property(self, "scale", base_scale, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	highlight_tween.tween_property(self, "modulate", Color.WHITE, 0.2)
	await highlight_tween.finished
	base_position = position

func play_play_animation():
	if highlight_tween:
		highlight_tween.kill()
	highlight_tween = create_tween()
	highlight_tween.set_parallel(true)
	highlight_tween.tween_property(self, "scale", base_scale * 1.3, 0.15)
	highlight_tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.2)
	highlight_tween.tween_property(self, "position:y", position.y - 40, 0.2)

func show_tooltip():
	if card_tooltip and card_data:
		card_tooltip.setup_card_tooltip(card_data)
		card_tooltip.visible = false
		card_tooltip.scale = Vector2(0.5, 0.5)
		await get_tree().process_frame
		await get_tree().process_frame
		card_tooltip.visible = true

func hide_tooltip():
	if card_tooltip:
		card_tooltip.visible = false

func _exit_tree():
	hide_tooltip()

func _update_tooltip_position():
	if not card_tooltip:
		return
	var card_global_pos = global_position
	var viewport_size = get_viewport().get_visible_rect().size
	if not card_tooltip.follow_mouse:
		var tooltip_pos = Vector2(card_global_pos.x + size.x + 70, \
		card_global_pos.y - card_tooltip.size.y - 20)
		if tooltip_pos.x + card_tooltip.size.x > viewport_size.x:
			tooltip_pos.x = card_global_pos.x - card_tooltip.size.x - 10
		if tooltip_pos.x < 0:
			tooltip_pos.x = 10
		if tooltip_pos.y < 0:
			tooltip_pos.y = card_global_pos.y + size.y + 10
		if tooltip_pos.y + card_tooltip.size.y > viewport_size.y:
			tooltip_pos.y = viewport_size.y - card_tooltip.size.y - 10
		card_tooltip.global_position = tooltip_pos
	else:
		var mouse_pos = get_global_mouse_position()
		var tooltip_pos = mouse_pos + Vector2(20, 20)
		if tooltip_pos.x + card_tooltip.size.x > viewport_size.x:
			tooltip_pos.x = mouse_pos.x - card_tooltip.size.x - 20
		if tooltip_pos.y + card_tooltip.size.y > viewport_size.y:
			tooltip_pos.y = mouse_pos.y - card_tooltip.size.y - 20
		tooltip_pos.x = max(0, tooltip_pos.x)
		tooltip_pos.y = max(0, tooltip_pos.y)
		card_tooltip.global_position = tooltip_pos

func show_controller_focus():
	modulate = Color(1.2, 1.2, 0.8)
	scale = base_scale * 1.1
	show_tooltip()
	if card_tooltip and card_data:
		card_tooltip.follow_mouse = false
		card_tooltip.setup_card_tooltip(card_data)
		card_tooltip.visible = true
		await get_tree().process_frame
		await get_tree().process_frame
		var card_global_pos = global_position
		var viewport_size = get_viewport().get_visible_rect().size
		var tooltip_pos = Vector2(card_global_pos.x + size.x + 70, \
		card_global_pos.y - card_tooltip.size.y - 20)
		if tooltip_pos.x + card_tooltip.size.x > viewport_size.x:
			tooltip_pos.x = card_global_pos.x - card_tooltip.size.x - 10
		if tooltip_pos.x < 0:
			tooltip_pos.x = 10
		if tooltip_pos.y < 0:
			tooltip_pos.y = card_global_pos.y + size.y + 10
		if tooltip_pos.y + card_tooltip.size.y > viewport_size.y:
			tooltip_pos.y = viewport_size.y - card_tooltip.size.y - 10
		card_tooltip.global_position = tooltip_pos

func hide_controller_focus():
	modulate = Color.WHITE
	scale = base_scale
	if card_tooltip:
		card_tooltip.visible = false
		card_tooltip.follow_mouse = true
