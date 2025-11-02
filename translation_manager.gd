extends Node

signal language_changed

var current_language: String = "en"
var translations: Dictionary = {}

func _ready():
	load_translations()
	load_saved_language()

func load_translations():
	translations = {
		"en": {
			"game_title": "Untitled Deck Builder",
			"start_game": "Start Game",
			"options": "Options",
			"credits": "Credits",
			"back": "Back",
			"apply": "Apply",
			
			"master": "Master",
			"music": "Music", 
			"sfx": "SFX",
			
			"credits_title": "Credits",
			"game_design": "Game Design: Adrian, Aiden, Saman",
			"programming": "Programming: Me", 
			"art_design": "Art Design: Myself",
			"music_credits": "Music: ???",
			"special_thanks": "Special Thanks - Random Tutorials",
			
			"using_cards_title": "Using Cards",
			"using_cards_desc": "Click on a card in your hand, then click on an enemy to use it against them",
			"ending_turn_title": "Ending Your Turn", 
			"ending_turn_desc": "Press the End Turn button when you finish playing your cards. This allows the enemy to take their turn.",
			"enemy_attacks_title": "Enemy Attacks",
			"enemy_attacks_desc": "After your turn ends, the enemies will attack you. Check your health and heal when needed.",
			
			"previous_tip": "Previous Tip",
			"next_tip": "Next Tip",
			"start_game_button": "Start Game!",
			
			"card_death_grip": "Death Grip",
		"card_blood_fire": "Blood Fire", 
		"card_abundance": "Abundance",
		"card_self_harm": "Self Harm",
		
		"card_death_grip_desc": "5 DMG to One",
		"card_blood_fire_desc": "7 DMG to All",
		"card_abundance_desc": "Heal for 7 HP",
		"card_self_harm_desc": "DMG self for 3, 12 DMG to Enemies",
		
		"cost": "Cost",
		"price": "Price", 
		"free": "Free!",
		"damage": "Damage",
		"heal": "Heal"
		},
		"ja": {
			"game_title": "名無しデッキビルダー",
			"start_game": "ゲーム開始",
			"options": "オプション",
			"credits": "クレジット", 
			"back": "戻る",
			"apply": "適用",
			
			"master": "マスタ",
			"music": "音楽",
			"sfx": "効果音",
			
			"credits_title": "クレジット",
			"game_design": "ゲームデザイン: エイドリアン、エイデン、サマン",
			"programming": "プログラミング: 自分",
			"art_design": "アートデザイン: 自分", 
			"music_credits": "音楽: ???",
			"special_thanks": "スペシャルサンクス - ランダムチュートリアル",
			
			"using_cards_title": "カードの使用",
			"using_cards_desc": "手札のカードをクリックし、敵をクリックして使用します",
			"ending_turn_title": "ターンの終了",
			"ending_turn_desc": "カードを使い終わったら「ターン終了」ボタンを押してください。これで敵のターンになります。",
			"enemy_attacks_title": "敵の攻撃", 
			"enemy_attacks_desc": "あなたのターンが終わると、敵が攻撃してきます。体力を確認し、必要に応じて回復してください。",
			
			"previous_tip": "前のヒント",
			"next_tip": "次のヒント", 
			"start_game_button": "ゲーム開始！",
			
			"card_death_grip": "死の握撃",
			"card_blood_fire": "血の炎", 
			"card_abundance": "豊穣",
			"card_self_harm": "自傷",
			
			"card_death_grip_desc": "単体に5ダメージ",
			"card_blood_fire_desc": "全体に7ダメージ",
			"card_abundance_desc": "HPを7回復",
			"card_self_harm_desc": "自分に3ダメージ、敵に12ダメージ",
			
			"cost": "コスト",
			"price": "価格",
			"free": "無料！",
			"damage": "ダメージ", 
			"heal": "回復"
		}
	}

func translate(key: String) -> String:
	if translations.has(current_language) and translations[current_language].has(key):
		return translations[current_language][key]
	elif translations["en"].has(key):
		return translations["en"][key]
	else:
		return "MISSING: " + key

func set_language(lang: String):
	if translations.has(lang):
		current_language = lang
		save_language()
		language_changed.emit()

func get_available_languages() -> Array:
	return translations.keys()

func save_language():
	var config = ConfigFile.new()
	config.set_value("settings", "language", current_language)
	config.save("user://settings.cfg")

func load_saved_language():
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		current_language = config.get_value("settings", "language", "en")
	else:
		current_language = "en"
