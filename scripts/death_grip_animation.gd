extends Node2D

var target_position: Vector2
var target_enemy: Enemy
var rectangles: Array[ColorRect] = []
var animation_speed: float = 200.0

func _ready():
	await get_tree().process_frame
	global_position = target_position
	var enemy_width = 80
	var enemy_height = 80
	if target_enemy and target_enemy.sprite and target_enemy.sprite.texture:
		var texture_size = target_enemy.sprite.texture.get_size()
		var scale = target_enemy.sprite.scale
		enemy_width = texture_size.x * scale.x
		enemy_height = texture_size.y  * scale.y
	var rect_width = enemy_width * 0.4
	var rect_height = enemy_height * 1.2
	var start_distance = max(enemy_width, enemy_height) * 1.5
	
	for i in range(2):
		var rect = ColorRect.new()
		rect.color = Color.WHITE
		rect.size = Vector2(rect_width, rect_height)
		var start_x = start_distance * (-1 if i == 0 else 1)
		rect.position = Vector2(start_x, -25)
		add_child(rect)
		rectangles.append(rect)

func _process(delta):
	for rect in rectangles:
		var direction = (Vector2.ZERO - rect.position).normalized()
		rect.position += direction * animation_speed * delta
		if rect.position.length() < 10:
			queue_free()
