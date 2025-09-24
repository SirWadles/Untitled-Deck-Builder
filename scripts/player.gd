extends Node2D
class_name Player

@onready var health_label: Label = $HealthLabel
@onready var energy_label: Label = $EnergyLabel

var max_health: int = 50
var current_health: int = 50
var max_energy: int = 3
var current_energy: int = 3

func _ready():
	update_display()

func take_damage(damage: int):
	current_health -= damage
	if current_health < 0:
		current_health = 0
	update_display()

func heal(amount: int):
	current_health += amount
	if current_health > max_health:
		current_health = max_health
	update_display()

func can_play_card(cost: int) -> bool:
	return current_energy >= cost

func spend_energy(amount: int):
	current_energy -= amount
	update_display()

func start_turn():
	current_energy = max_energy
	update_display()

func update_display():
	health_label.text = "HP: " + str(current_health) + "/" + str(max_health)
	energy_label.text = "Energy: " + str(current_energy) + "/" + str(max_energy)
