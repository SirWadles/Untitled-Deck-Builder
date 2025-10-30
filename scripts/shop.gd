extends Control
class_name Shop

@onready var gold_label: Label = $MarginContainer/VBoxContainer/Header/GoldLabel
@onready var tab_container: TabContainer = $MarginContainer/VBoxContainer/TabContainer
@onready var cards_grid: GridContainer = $MarginContainer/VBoxContainer/TabContainer/Cards/ScrollContainer/CardsGrid
@onready var relic_grid: GridContainer = $MarginContainer/VBoxContainer/TabContainer/Relics/ScrollContainer/RelicGrid
@onready var return_button: Button = $MarginContainer/VBoxContainer/Footer/ReturnButton

@onready var music_player = $Audio/MusicPlayer
@onready var audio_options = $Audio/AudioOptions

@onready var card_tooltip: Panel = $CardToolTip

var player_gold: int = 100
var available_cards: Array = []
var available_relics: Array = []
var player_data: PlayerData

var controller_navigation_enabled: bool = false
var current_focused_item_index: int = -1
var current_tab: String = "CARDS"
var return_button_focused: bool = false
var joystick_deadzone: float = 0.5
var joystick_cooldown_time: float = 0.3
var last_joystick_navigation: float = 0.0

func _ready():
	player_data = get_node("/root/PlayerDatabase")
	print("Gold label exists: ", gold_label != null)
	print("Tab container exists: ", tab_container != null)
	print("Cards grid exists: ", cards_grid != null)
	print("Relic grid exists: ", relic_grid != null)
	print("Return button exists: ", return_button != null)
	setup_ui_theme()
	load_shop_items()
	update_display()
	return_button.pressed.connect(_on_return_button_pressed)
	audio_options.visible = false
	music_player.bus = "Music"
	music_player.play()
	if card_tooltip:
		card_tooltip.visible = false
	controller_navigation_enabled = true
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		audio_options.show_options()
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		if not controller_navigation_enabled:
			controller_navigation_enabled = true
			current_focused_item_index = 0
			_update_controller_focus()
	if event is InputEventMouseMotion and controller_navigation_enabled:
		controller_navigation_enabled = false
		_clear_controller_focus()

func _process(delta):
	if not controller_navigation_enabled:
		return
	_handle_joystick_navigation()

func _handle_joystick_navigation():
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_joystick_navigation < joystick_cooldown_time:
		return
	var horizontal = Input.get_axis("ui_left", "ui_right")
	var vertical = Input.get_axis("ui_up", "ui_down")
	if abs(horizontal) < joystick_deadzone:
		horizontal = 0
	if abs(vertical) < joystick_deadzone:
		vertical = 0
	if horizontal != 0 or vertical != 0:
		_handle_controller_navigation((horizontal), int(vertical))

func _unhandled_input(event):
	if not controller_navigation_enabled:
		return
	if event.is_action_pressed("ui_accept"):
		_handle_controller_accept()
	elif event.is_action_pressed("ui_cancel"):
		_handle_controller_cancel()
	elif event.is_action_pressed("ui_view_deck"):
		_switch_tab()
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_joystick_navigation < joystick_cooldown_time:
		return
	if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right") or \
	event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down"):
		var x_dir = 0
		var y_dir = 0
		if event.is_action_pressed("ui_left"):
			x_dir = 1
		elif event.is_action_pressed("ui_right"):
			x_dir = 1
		elif event.is_action_pressed("ui_up"):
			y_dir = -1
		elif event.is_action_pressed("ui_down"):
			y_dir = 1
		_handle_controller_navigation(x_dir, y_dir)
		last_joystick_navigation = current_time

func _handle_controller_navigation(x_dir: int, y_dir: int):
	if return_button_focused:
		if y_dir < 0:
			return_button_focused = false
			current_focused_item_index = 0
		else:
			return_button.modulate = Color(1.2, 1.2, 0.8)
	else:
		if y_dir > 0:
			return_button_focused = true
			current_focused_item_index = -1
		else:
			_navigate_items(x_dir, y_dir)
	_update_controller_focus()

func _navigate_items(x_dir:int, y_dir: int):
	var current_items = _get_current_items()
	if current_items.is_empty():
		return
	if current_focused_item_index == 1:
		current_focused_item_index = 0
	else:
		var columns = cards_grid.columns if current_tab == "CARDS" else relic_grid.columns
		current_focused_item_index += x_dir + (y_dir * columns)
	var item_count = current_items.size()
	if current_focused_item_index < 0:
		current_focused_item_index = item_count - 1
	elif current_focused_item_index >= item_count:
		current_focused_item_index = 0
	_update_controller_focus()

func _switch_tab():
	if current_tab == "CARDS":
		current_tab = "RELICS"
		tab_container.current_tab = 1
	else:
		current_tab = "CARDS"
		tab_container .current_tab = 0
	current_focused_item_index = 0
	return_button_focused = false
	_update_controller_focus()

func _handle_controller_accept():
	if return_button_focused:
		_on_return_button_pressed()
	else:
		var current_items = _get_current_items()
		if current_focused_item_index >= 0 and current_focused_item_index < current_items.size():
			var item = current_items[current_focused_item_index]
			if current_tab == "CARDS":
				_on_card_purchased(item["data"], item["price"])
			else:
				_on_relic_purchased(item, item["price"])

func _handle_controller_cancel():
	_on_return_button_pressed()

func _update_controller_focus():
	_clear_controller_focus()
	if return_button_focused:
		return_button.modulate = Color(1.2, 1.2, 0.8)
	else:
		var current_items = _get_current_items()
		if current_focused_item_index >= 0 and current_focused_item_index < current_items.size():
			var container = cards_grid if current_tab == "CARDS" else relic_grid
			var children = container.get_children()
			if current_focused_item_index < children.size():
				var focused_item = children[current_focused_item_index]
				focused_item.modulate = Color(1.2, 1.2, 0.8)
				if card_tooltip:
					if current_tab == "CARDS":
						card_tooltip.setup_card_tooltip(current_items[current_focused_item_index]["data"])
					else:
						card_tooltip.setup_relic_tooltip(current_items[current_focused_item_index])
					card_tooltip.visible = true

func _clear_controller_focus():
	return_button.modulate = Color.WHITE
	for child in cards_grid.get_children():
		child.modulate = Color.WHITE
	for child in relic_grid.get_children():
		child.modulate = Color.WHITE
	if card_tooltip:
		card_tooltip.visible = false

func _get_current_items() -> Array:
	if current_tab == "CARDS":
		return available_cards
	else:
		return available_relics

func  setup_ui_theme():
	return_button.text = "Return to Map"
	return_button.custom_minimum_size = Vector2(150, 40)
	
	var cards_scroll = cards_grid.get_parent() as ScrollContainer
	var relics_scroll = relic_grid.get_parent() as ScrollContainer
	
	if cards_scroll:
		cards_scroll.custom_minimum_size = Vector2(800, 400)
		cards_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cards_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	if relics_scroll:
		relics_scroll.custom_minimum_size = Vector2(800, 400)
		relics_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		relics_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	if cards_grid is GridContainer:
		cards_grid.columns = 4
		cards_grid.custom_minimum_size = Vector2(800, 400)
		cards_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cards_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	if relic_grid is GridContainer:
		relic_grid.columns = 3
		relic_grid.custom_minimum_size = Vector2(800, 400)
		relic_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		relic_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	cards_grid.add_theme_constant_override("h_separation", 10)
	cards_grid.add_theme_constant_override("v_separation", 10)
	relic_grid.add_theme_constant_override("h_separation", 10)
	relic_grid.add_theme_constant_override("v_separation", 10)

func load_shop_items():
	var card_db = get_node("/root/CardStuff")
	var all_cards = ["attack", "blood_fire", "abundance", "self_harm"]
	available_cards.clear()
	available_relics.clear()
	print("Loading shop items...")
	var num_cards = randi_range(6, 12)
	print(num_cards)
	for i in range(num_cards):
		var random_card_id = all_cards[randi() % all_cards.size()]
		var card_data = card_db.get_card(random_card_id)
		if card_data:
			available_cards.append({
				"data": card_data,
				"price": calculate_card_price(card_data)
			})
			print("Added card: ", card_data.card_name)
	load_sample_relics()
	print("Available cards: ", available_cards.size())
	print("Available relics: ", available_relics.size())

func load_sample_relics():
	var health_band_texture = preload("res://assets/relics/Band_of_Regeneration.png")
	var energy_cystal_texture = preload("res://assets/relics/Eternia_Crystal.png")
	var crystal_shard_texture = preload("res://assets/relics/Crystal_Shard.png")
	
	available_relics.append({
		"name": "Health Band",
		"description": "Heals 5 HP after combat",
		"price": 75,
		"icon": health_band_texture,
		"id": "health_band"
	})
	available_relics.append({
		"name": "Energy Crystal",
		"description": "+1 Max Energy",
		"price": 150,
		"icon": energy_cystal_texture,
		"id": "energy_crystal"
	})
	available_relics.append({
		"name": "Crystal Shard",
		"description": "+5 Damage",
		"price": 175,
		"icon": crystal_shard_texture,
		"id": "crystal_shard"
	})
	

func calculate_card_price(card_data: CardData) -> int:
	var price = card_data.cost * 20
	price += card_data.damage * 10
	price += card_data.heal * 12
	price += card_data.defense * 10
	price += randi() % 15
	return max(price, 30)

func update_display():
	gold_label.text = "Gold: " + str(player_data.gold) + "g"
	for child in cards_grid.get_children():
		child.queue_free()
	for child in relic_grid.get_children():
		child.queue_free()
	for card_item in available_cards:
		var shop_card = preload("res://scenes/shop_card.tscn").instantiate()
		cards_grid.add_child(shop_card)
		shop_card.setup(card_item["data"], card_item["price"])
		shop_card.purchased.connect(_on_card_purchased)
		shop_card.mouse_entered.connect(_on_shop_item_mouse_entered.bind(card_item["data"]))
		shop_card.mouse_exited.connect(_on_shop_item_mouse_exited)
	for relic_item in available_relics:
		var shop_relic = preload("res://scenes/shop_relic.tscn").instantiate()
		relic_grid.add_child(shop_relic)
		shop_relic.setup(relic_item)
		shop_relic.mouse_entered.connect(_on_shop_relic_mouse_entered.bind(relic_item))
		shop_relic.mouse_exited.connect(_on_shop_item_mouse_exited)
		shop_relic.purchased.connect(_on_relic_purchased)

func _on_card_purchased(card_data: CardData, price: int):
	if player_data.gold >= price:
		player_data.gold -= price
		player_data.add_card_to_deck(card_data.card_id)
		update_display()
		print("Bought " + card_data.card_name)
		show_purchased_message("Purchased " + card_data.card_name)
	else:
		show_purchased_message("Not Enough Gold!")

func _on_relic_purchased(relic_data: Dictionary, price: int):
	if player_data.gold >= price:
		player_data.gold -= price
		player_data.add_relic(relic_data)
		var relic_manager = get_node("/root/RelicManager")
		print("relic bought", relic_data["name"])
		print("relic in manager", relic_manager.active_relics.size())
		update_display()
		show_purchased_message("Purchased " + relic_data["name"])
	else:
		show_error_message("Not Enough Gold!")

func show_purchased_message(message: String):
	var message_label = Label.new()
	add_child(message_label)
	message_label.text = message
	message_label.position = Vector2(size.x / 2 -100, 550)
	message_label.add_theme_font_size_override("font_size", 20)
	await get_tree().create_timer(2.0).timeout
	message_label.queue_free()

func show_error_message(message: String):
	var error_label = Label.new()
	add_child(error_label)
	error_label.text = message
	error_label.position = Vector2(size.x / 2 -100, size.y / 2)
	error_label.add_theme_font_size_override("font_size", 20)
	error_label.add_theme_color_override("font_color", Color.RED)
	await get_tree().create_timer(2.0).timeout
	error_label.queue_free()

func _on_return_button_pressed():
	get_tree().change_scene_to_file("res://scenes/map.tscn")

func _on_shop_item_mouse_entered(card_data: CardData):
	if card_tooltip:
		card_tooltip.setup_card_tooltip(card_data)
		card_tooltip.visible = true

func _on_shop_relic_mouse_entered(relic_data: Dictionary):
	if card_tooltip:
		card_tooltip.setup_relic_tooltip(relic_data)
		card_tooltip.visible = true

func _on_shop_item_mouse_exited():
	if card_tooltip:
		card_tooltip.visible = false
