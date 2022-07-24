extends "res://DataTaboo/AI/AIKinematicMovement2DBase.gd"

signal damaged

export (float) var starting_health = 10
export (float) var starting_max_health = 10

export (float) var damage = 0


func _ready():
	$Health.set_starting_values(starting_health, starting_max_health)


func take_damage(amount):
	emit_signal("damaged", -amount)


func _on_Health_value_empty():
	destroy()
func _on_Health_value_lost(amount):
	print("health lost:", amount, "health left:", $Health.value)
