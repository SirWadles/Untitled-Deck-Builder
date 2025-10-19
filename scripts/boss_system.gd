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
@onready var play_again_button: Button = $PlayAgainButton
@onready var quit_button: Button = $QuitButton

@onready var deck_viewer: Control = $DeckViewer
@onready var deck_view_button: Button = $UI/DeckViewButton

var enemies: Array[Enemy] = []
var current_selected_card: Card = null
var current_state: BattleState = BattleState.PLAYER_TURN

var is_player_targetable: bool = false
var animation_container: Node

signal card_played(card: Card, target: Enemy)
signal turn_ended()
signal player_turn_started()

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
	if play_again_button:
		play_again_button.pressed.connect(_on_play_again)
		play_again_button.visible = false
	if quit_button:
		quit_button.pressed.connect(_on_quit_button)
		quit_button.visible = false
	if deck_view_button:
		deck_view_button.pressed.connect(_on_deck_view_button_pressed)
	if not has_node("AnimationContainer"):
		animation_container = Node2D.new()
		animation_container.name = "AnimationContainer"
		add_child(animation_container)

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
	apply_relic_effects()
	player.start_turn()
	if hand:
		hand.clear_hand()
		await get_tree().process_frame
	draw_cards(3)
	hand.set_cards_selectable(true)
	for enemy in enemies:
		if enemy.current_health > 0:
			enemy.update_intent_display()
	if ui and ui.has_method("update_status"):
		ui.update_status("BOSS BATTLE - Select a Card!")

func apply_relic_effects():
	var relic_manager = get_node("/root/RelicManager")
	var start_effects = relic_manager.get_combat_start_effects()
	if start_effects["max_energy"] > 0:
		var crystal_count = relic_manager.get_relic_count("energy_crystal")
		player.current_energy = player.player_data.max_energy
	player.update_display()

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
	if current_state == BattleState.TARGETING and current_selected_card == card:
		print("Same card clicked - Deselecting")
		_on_card_deselected(card)
		return
	if current_state != BattleState.PLAYER_TURN:
		print("Cannot select card - not player turn. Current state: ", current_state)
		return
	if player.can_play_card(card.card_data.cost):
		print("Card selected: ", card.card_data.card_name)
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
	elif card_id in ["blood_fire", "self_harm"]:
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
		if not player.can_play_card(current_selected_card.card_data.cost):
			print("nope broke")
			return
		var card_data = current_selected_card.card_data
		player.spend_energy(card_data.cost)
		var card_to_play = current_selected_card
		current_selected_card = null
		var relic_manager = get_node("/root/RelicManager")
		var card_modifications = relic_manager.modify_card_play(card_data)
		var actual_heal = card_data.heal + card_modifications["extra_heal"]
		if card_data.heal > 0:
			player.heal(actual_heal)
			player.play_heal_animation()
			await player.heal_animation_finished
			print("Player healed")
			if card_modifications["extra_heal"] > 0:
				print("heal boosted " + str(card_modifications["extra_heal"]))
		hand.play_card(card_to_play, enemies[0] if enemies.size() > 0 else null)
		var player_data = get_node("/root/PlayerDatabase")
		if should_exhaust_card(card_data.card_id):
			player_data.exhaust_card(card_data.card_id)
		else:
			player_data.discard_card(card_data.card_id)
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
	if card_data.card_id == "attack":
		play_death_grip_animation(target)
	print("4. Card data:", card_data.card_name, "Damage:", card_data.damage)
	player.spend_energy(card_data.cost)
	print("5. Energy spent")
	var card_to_play = current_selected_card
	current_selected_card = null
	hand.play_card(card_to_play, target)
	print("6. Card played and consumed")
	
	var player_data = get_node("/root/PlayerDatabase")
	if should_exhaust_card(card_data.card_id):
		print("7. Playing attack animation...")
		player_data.exhaust_card(card_data.card_id)
	else:
		print("7. Playing attack animation...")
		player_data.discard_card(card_data.card_id)
	card_played.emit(card_to_play, target)
	
	if card_data.card_id in ["attack", "blood_fire", "self_harm"]:
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
		"attack":
			if card_data.damage > 0:
				print("10. Dealing", card_data.damage, "damage to", target.enemy_name)
				target.take_damage(card_data.damage)
				print("11. Enemy HP after damage:", target.current_health)
			elif card_data.heal < 0:
				target.take_damage(-card_data.heal)
		"blood_fire", "self_harm":
			var living_enemies = 0
			for enemy in enemies:
				if enemy.current_health > 0:
					enemy.take_damage(card_data.damage)
					living_enemies += 1
			if living_enemies > 0:
				print("blood fire hit ", living_enemies, " enemies")
			if card_data.card_id == "self_harm" and card_data.heal < 0:
				var self_damage = abs(card_data.heal)
				player.take_damage(self_damage)
		"abundance", "heal":
			if card_data.heal > 0:
				if player.current_health > 50:
					pass
				else:
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

func play_death_grip_animation(target: Enemy):
	print("DEATH GRIP ANIMATION: Playing on enemy ", target.enemy_name)
	var death_grip_scene = preload("res://scenes/animation_container.tscn")
	var animation_instance = death_grip_scene.instantiate()
	animation_container.add_child(animation_instance)
	animation_instance.target_enemy = target
	animation_instance.target_position = target.global_position

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
		show_end_screen(true)
	else:
		var player_data = get_node("/root/PlayerDatabase")
		if player_data.current_health <= 0:
			show_end_screen(false)

func show_end_screen(victory: bool):
	music_player.stop()
	hand.set_cards_selectable(false)
	if victory:
		var player_data = get_node("/root/PlayerDatabase")
		player_data.add_gold(100)
		player_data.max_health += 10
		apply_combat_end_relic_effects()
		win_label.visible = true
		win_song.play()
		print("Win")
	#await  get_tree().create_timer(5.0).timeout
	#get_tree().call_deferred("change_scene_to_file", "res://scenes/map.tscn")
	else:
		var player_data = get_node("/root/PlayerDatabase")
		player_data.reset_to_default()
		lose_label.visible = true
		lose_song.play()
	if play_again_button:
		play_again_button.visible = true
	if quit_button:
		quit_button.visible = true

func apply_combat_end_relic_effects():
	var relic_manager = get_node("/root/RelicManager")
	var end_effects = relic_manager.get_combat_end_effects()
	if end_effects["heal"] > 0:
		var band_count = relic_manager.get_relic_count("health_band")
		player.player_data.heal(end_effects["heal"])
		player.update_display()
		

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
		if enemy.current_health <= 0:
			enemy.hide_intent()
	await get_tree().create_timer(0.5).timeout
	for enemy in enemies:
		if enemy.current_health > 0:
			enemy.execute_attack()
			await get_tree().create_timer(0.8).timeout
	check_battle_end()
	await get_tree().create_timer(1.0).timeout
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

func _on_play_again():
	var player_data = get_node("/root/PlayerDatabase")
	if win_label.visible:
		player_data.current_health = player_data.max_health
		var map_state = get_node("/root/MapState")
		map_state.reset()
		map_state.saved_map_data.clear()
		get_tree().call_deferred("change_scene_to_file", "res://scenes/map.tscn")
	else:
		player_data.reset_to_default()
		var map_state = get_node("/root/MapState")
		map_state.reset()
		map_state.saved_map_data.clear()
		get_tree().call_deferred("change_scene_to_file", "res://scenes/main_menu.tscn")

func _on_quit_button():
	get_tree().quit()

func _on_deck_view_button_pressed():
	if deck_viewer:
		deck_viewer.show_viewer()

func should_exhaust_card(card_id: String) -> bool:
	var exhaust_cards = [
		"blood_fire",
		"self_harm"
	]
	return card_id in exhaust_cards

func _on_card_deselected(card: Card):
	if current_state == BattleState.TARGETING and card == current_selected_card:
		print("Card deselected")
		reset_targeting()
		current_selected_card = null
		current_state = BattleState.PLAYER_TURN
		for card_in_hand in hand.cards:
			card_in_hand.set_selectable(true)
		if ui and ui.has_method("update_status"):
			ui.update_status("Your Turn - Select a Card")
