extends Node2D
class_name BattleSystem

@onready var player: Player = $Player
@onready var hand: Hand = $Hand
@onready var enemy_container: Node2D = $EnemyContainer

var enemies: Array[Enemy] = []
var current_selected_card: Card = null
var current_state: String = "player_turn"

enum BattleState {
	PLAYER_TURN,
	ENEMY_TURN,
	TARGETING
}

func _ready():
	hand.card_played.connect(_on_card_played)
	create_enemies()
	start_player_turn()

func create_enemies():
	var enemy_scene = preload("res://scenes/battle/enemy.tscn")
	
	for i in range(2):
		var enemy = enemy_scene.instantiate() as Enemy
		enemy_container.add_child(enemy)
		enemy.setup("Enemy " + str(i + 1), 30, self)
		enemy.enemy_clicked.connect(_on_enemy_clicked)
		enemies.append(enemy)
		enemy.position.x = i * 200

func start_player_turn():
	current_state = BattleState.PLAYER_TURN
	player.start_turn()
	draw_cards(5)
	hand.set_cards_selectable(true)

func draw_cards(amount: int):
	hand.clear_hand()
	var card_ids = ["attack", "defend", "heal"]
	for i in range(amount):
		var random_card = card_ids[randi() % card_ids.size()]
		var card_data = CardDatabase.get_card(random_card)
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
	for enemy in enemies:
		if enemy.current_health > 0:
			enemt.set_targetable(true)

func _on_enemy_clicked(enemy: Enemy):
	if current_state == BattleState.TARGETING and current_selected_card:
		play_card_on_target(enemy)

func play_card_on_target(target: Enemy):
	var card_data = current_selected_card.card_data
	player.spend_energy(card_data.cost)
	if card_data.damage > 0:
		target.take_damage(card_data.damage)
	if card_data.heal > 0:
		player.heal(card_data.heal)
	hand.play_card(target)
	for enemy in enemies:
		enemy.set_targetable(false)
	current_selected_card = null
	current_state = BattleState.PLAYER_TURN
	hands.set_cards_selectable(true)

func _on_card_played(card: Card, target: Enemy):
	print("Played " + card.card_data.card_name, " on ", target.enemy_name)
