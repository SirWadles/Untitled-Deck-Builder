extends Node2D
class_name BossSystem

@onready var player: Player = $Player
@onready var hand: Hand = $Hand
@onready var enemy_container: Node2D = $EnemyContainer
@onready var card_database = get_node("/root/CardStuff")
@onready var enemy_database = get_node("/root/EnemyDatabase")
@onready var ui: Control = $UI
@onready var win_label = $WinLabel
@onready var win_song = $WinSong
@onready var lose_label = $LoseLabel
@onready var lose_song = $LoseSong
@onready var music_player = $MusicPlayer

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
	win_song.bus = "Music"
	lose_song.bus = "Music"
	music_player.bus = "Music"
	if hand:
		hand.card_played.connect(_on_card_played)
	create_boss_enemies()
	start_player_turn()
	win_label.visible = false
	lose_label.visible = false
	music_player.play()

func create_boss_enemies():
	var enemy_scene = preload("res://scenes/battle/enemy.tscn")
	var enemy_types = ["boss_1"]
	
	for i in range(1):
		var enemy = enemy_scene.instantiate() as Enemy
		enemy_container.add_child(enemy)
		var enemy_type = enemy_types[randi() % enemy_types.size()]
		var enemy_data = enemy_database.get_enemy_data(enemy_type)
		if enemy_data:
			enemy.setup(enemy_data["name"], enemy_data["health"], self, enemy_data)
		else:
			enemy.setup("Enemy " + str(i + 1), 30, self)
		enemy.enemy_clicked.connect(_on_enemy_clicked)
		enemies.append(enemy)
		enemy.position.y = 0

func start_player_turn():
	current_state = BattleState.PLAYER_TURN
	player.start_turn()
	draw_cards(3)
	hand.set_cards_selectable(true)
	if ui and ui.has_method("update_status"):
		ui.update_status("BOSS BATTLE - Select a Card!")

func draw_cards(amount: int):
	if not hand:
		return
	hand.clear_hand()
	var player_data = get_node("/root/PlayerDatabase")
	var drawn_cards_ids = player_data.draw_cards(amount)
	for card_id in drawn_cards_ids:
		var card_data = card_database.get_card(card_id)
		if card_data:
			hand.add_card(card_data)
		else:
			print("Damn you fucked up", card_id)

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
	if card_id in ["attack"]:
		for enemy in enemies:
			if enemy.current_health > 0:
				enemy.set_targetable(true)
		is_player_targetable = false
		if ui and ui.has_method("update_status"):
			ui.update_status("Select enemy to attack")
	elif card_id == "blood_fire":
		play_area_attack(card)
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
	if event.is_action_pressed("ui_accept"):
		player.test_heal()

func play_card_on_player():
	if current_selected_card:
		if not player.can_play_card(current_selected_card.card_data.cost):
			print("nope broke")
			return
		var card_data = current_selected_card.card_data
		player.spend_energy(card_data.cost)
		var card_to_play = current_selected_card
		current_selected_card = null
		if card_data.heal > 0:
			player.heal(card_data.heal)
			print("Player healed")
			player.play_heal_animation()
			await player.heal_animation_finished
		hand.play_card(card_to_play, enemies[0] if enemies.size() > 0 else null)
		reset_targeting()
		current_selected_card = null
		current_state = BattleState.PLAYER_TURN
		if hand:
			hand.set_cards_selectable(true)
		check_battle_end()

func _on_enemy_clicked(enemy: Enemy):
	if current_state == BattleState.TARGETING and current_selected_card:
		play_card_on_target(enemy)

func play_card_on_target(target: Enemy):
	print("=== PLAY CARD ON TARGET START ===")
	print("1. Current state:", current_state)
	print("2. Selected card:", current_selected_card.card_data.card_name if current_selected_card else "None")
	print("3. Target enemy:", target.enemy_name, "HP:", target.current_health)
	if not player.can_play_card(current_selected_card.card_data.cost):
		print("nope broke")
		return
	var card_data = current_selected_card.card_data
	print("4. Card data:", card_data.card_name, "Damage:", card_data.damage)
	player.spend_energy(card_data.cost)
	print("5. Energy spent")
	var card_to_play = current_selected_card
	current_selected_card = null
	hand.play_card(card_to_play, target)
	print("6. Card played and consumed")
	if card_data.card_id in ["attack", "blood_fire"]:
		print("7. Playing attack animation...")
		player.play_attack_animation()
		await player.attack_animation_finished
		print("8. Attack animation finished")
		#await get_tree().create_timer(0.01).timeout
	elif card_data.card_id in ["abundance"]:
		print("7. Playing heal animation...")
		player.play_heal_animation()
		await player.heal_animation_finished
	print("9. Applying card effects...")
	match card_data.card_id:
		"attack", "blood_fire":
			if card_data.damage > 0:
				print("10. Dealing", card_data.damage, "damage to", target.enemy_name)
				target.take_damage(card_data.damage)
				print("11. Enemy HP after damage:", target.current_health)
			elif card_data.heal < 0:
				target.take_damage(-card_data.heal)
		"abundance", "heal":
			if card_data.heal > 0:
				player.heal(card_data.heal)
	print("12. Resetting targeting...")
	reset_targeting()
	current_state = BattleState.PLAYER_TURN
	print("13. Current state set to:", current_state)
	if hand:
		hand.set_cards_selectable(true)
		print("14. Cards set to selectable")
	print("=== PLAY CARD ON TARGET END ===")
	check_battle_end()

func reset_targeting():
	for enemy in enemies:
		enemy.set_targetable(false)
	set_player_targetable(false)
	is_player_targetable = false

func _on_card_played(card: Card, target: Enemy):
	print("Played " + card.card_data.card_name + " on " + target.enemy_name)
	var player_data = get_node("/root/PlayerDatabase")
	player_data.discard_card(card.card_data.card_id)
	check_battle_end()

func check_battle_end():
	var all_defeated = true
	for enemy in enemies:
		if enemy.current_health > 0:
			all_defeated = false
			break
	if all_defeated:
		var player_data = get_node("/root/PlayerDatabase")
		player_data.add_gold(100)
		player_data.max_health += 10
		music_player.stop()
		win_label.visible = true
		win_song.play()
		print("Win")
		await  get_tree().create_timer(5.0).timeout
		get_tree().call_deferred("change_scene_to_file", "res://scenes/map.tscn")
	else:
		var player_data = get_node("/root/PlayerDatabase")
		if player_data.current_health <= 0:
			music_player.stop()
			lose_label.visible = true
			lose_song.play()
			await get_tree().create_timer(10.0).timeout
			game_over()

func game_over():
	var player_data = get_node("/root/PlayerDatabase")
	player_data.reset_to_default()
	get_tree().call_deferred("change_scene_to_file", "res://scenes/main_menu.tscn")

func end_turn():
	if current_state == BattleState.PLAYER_TURN:
		current_state = BattleState.ENEMY_TURN
		hand.set_cards_selectable(false)
		var player_data = get_node("/root/PlayerDatabase")
		player_data.discard_hand()
		start_enemy_turn()

func start_enemy_turn():
	if ui and ui.has_method("update_status"):
		ui.update_status("BOSS TURN - Survive!")
	for enemy in enemies:
		if enemy.current_health > 0:
			if enemy.enemy_type == "boss_1" and randi() % 2 == 0:
				player.take_damage(enemy.damage + 3)
				print("special")
			else:
				player.take_damage(enemy.damage)
	await get_tree().create_timer(3.0).timeout
	start_player_turn()

func play_area_attack(card: Card):
	if card and player.can_play_card(card.card_data.cost):
		var card_data = card.card_data
		player.spend_energy(card_data.cost)
		hand.play_card(card, enemies[0] if enemies.size() > 0 else null)
		var living_enemies = 0
		for enemy in enemies:
			if enemy.current_health > 0:
				enemy.take_damage(card_data.damage)
				living_enemies += 1
		if living_enemies > 0:
			print("Blood fire hit ", living_enemies)
		complete_area_play_card(card)

func complete_area_play_card(card: Card):
	current_selected_card = null
	current_state = BattleState.PLAYER_TURN
	if hand:
		hand.set_cards_selectable(true)
	if ui and ui.has_method("update_status"):
		ui.update_status("Your turn - Select a card")
	check_battle_end()
