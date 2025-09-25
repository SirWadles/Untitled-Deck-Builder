extends Node2D
class_name BattleSystem

@onready var player: Player = $Player
@onready var hand: Hand = $Hand
@onready var enemy_container: Node2D = $EnemyContainer
@onready var card_database = get_node("/root/CardStuff")
@onready var ui: Control = $UI

var enemies: Array[Enemy] = []
var current_selected_card: Card = null
var current_state: BattleState = BattleState.PLAYER_TURN

var is_player_targetable: bool = false

enum BattleState {	
	PLAYER_TURN,
	ENEMY_TURN,
	TARGETING
}

func _ready():
	if hand:
		hand.card_played.connect(_on_card_played)
	create_enemies()
	start_player_turn()

func create_enemies():
	var enemy_scene = preload("res://scenes/battle/enemy.tscn")
	var enemy_types = ["slime", "boss_1"]
	
	for i in range(2):
		var enemy = enemy_scene.instantiate() as Enemy
		enemy_container.add_child(enemy)
		var enemy_type = enemy_types[randi() % enemy_types.size()]
		var enemy_data = EnemyDatabase.get_enemy_data(enemy_type)
		if enemy_data:
			enemy.setup(enemy_data["name"], enemy_data["health"], self, enemy_data["texture"])
		else:
			enemy.setup("Enemy " + str(i + 1), 30, self)
		enemy.enemy_clicked.connect(_on_enemy_clicked)
		enemies.append(enemy)
		enemy.position.x = i * 150
		enemy.position.y = 0

func start_player_turn():
	current_state = BattleState.PLAYER_TURN
	player.start_turn()
	draw_cards(2)
	hand.set_cards_selectable(true)
	if ui and ui.has_method("update_status"):
		ui.update_status("Your Turn - Select a Card")

func draw_cards(amount: int):
	if not hand:
		return
	hand.clear_hand()
	var card_pool = ["attack", "blood_fire", "abundance"]
	for i in range(amount):
		var random_card = card_pool[randi() % card_pool.size()]
		var card_data = card_database.get_card(random_card)
		hand.add_card(card_data)

func on_card_selected(card: Card):
	if current_state != BattleState.PLAYER_TURN:
		return
	if player.can_play_card(card.card_data.cost):
		current_selected_card = card
		current_state = BattleState.TARGETING
		start_targeting(card)

func start_targeting(card: Card):
	hand.set_cards_selectable(false)
	var card_id = card.card_data.card_id
	if card_id in ["attack", "blood_fire"]:
		for enemy in enemies:
			if enemy.current_health > 0:
				enemy.set_targetable(true)
		is_player_targetable = false
	elif card_id in ["abundance", "heal"]:
		set_player_targetable(true)
		is_player_targetable = true
		if ui and ui.has_method("update_status"):
			ui.update_status("select yourself to heal")

func set_player_targetable(targetable: bool):
	if targetable:
		player.modulate = Color.YELLOW
	else:
		player.modulate = Color.WHITE

func _input(event):
	if (event is InputEventMouseButton and event.pressed and current_state == BattleState.TARGETING and is_player_targetable):
		var mouse_pos = get_global_mouse_position()
		var player_rect = Rect2(player.global_position - Vector2(50, 50), Vector2(100, 100))
		if player_rect.has_point(mouse_pos):
			play_card_on_player()

func play_card_on_player():
	if current_selected_card:
		var card_data = current_selected_card.card_data
		player.spend_energy(card_data.cost)
		if card_data.heal > 0:
			player.heal(card_data.heal)
			print("Player healed")
		reset_targeting()
		hand.play_card(enemies[0] if enemies.size() > 0 else null)
		current_selected_card = null
		current_state = BattleState.PLAYER_TURN
		if hand:
			hand.set_cards_selectable(true)

func _on_enemy_clicked(enemy: Enemy):
	if current_state == BattleState.TARGETING and current_selected_card:
		play_card_on_target(enemy)

func play_card_on_target(target: Enemy):
	var card_data = current_selected_card.card_data
	player.spend_energy(card_data.cost)
	match card_data.card_id:
		"attack", "blood_fire":
			if card_data.damage > 0:
				target.take_damage(card_data.damage)
			elif card_data.heal < 0:
				target.take_damage(-card_data.heal)
		"abundance", "heal":
			if card_data.heal > 0:
				player.heal(card_data.heal)
	reset_targeting()
	hand.play_card(target)
	for enemy in enemies:
		enemy.set_targetable(false)
	current_selected_card = null
	current_state = BattleState.PLAYER_TURN
	if hand:
		hand.set_cards_selectable(true)

func reset_targeting():
	for enemy in enemies:
		enemy.set_targetable(false)
	set_player_targetable(false)
	is_player_targetable = false

func _on_card_played(card: Card, target: Enemy):
	print("Played " + card.card_data.card_name + " on " + target.enemy_name)
	check_battle_end()

func check_battle_end():
	var all_defeated = true
	for enemy in enemies:
		if enemy.current_health > 0:
			all_defeated = false
			break
	if all_defeated:
		print("Win")

func end_turn():
	if current_state == BattleState.PLAYER_TURN:
		current_state = BattleState.ENEMY_TURN
		hand.set_cards_selectable(false)
		start_enemy_turn()

func start_enemy_turn():
	var enemy_scene = preload("res://scenes/battle/enemy.tscn")
	var enemy_types = ["slime", "boss_1"]
	for enemy in enemies:
		if enemy.current_health > 0 and enemy_types[0]:
			player.take_damage(3)
		if enemy.current_health > 0 and enemy_types[1]:
			player.take_damage(5)
	await get_tree().create_timer(1.0).timeout
	start_player_turn()
