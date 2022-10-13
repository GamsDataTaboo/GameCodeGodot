extends "res://DataTaboo/AI/AIKinematicMovement2DBase.gd"


# Configuration
export (float) var damage = 1.0
export (float) var flight_time = 0.5
#--


func _ready():
	$FlightTime.start(flight_time)


func _on_FlightTime_timeout():
	destroy()

func _on_Projectile2D_collided(collision):
	if(collision.collider.is_in_group(target_group)):
		if(collision.collider.has_method("take_damage")):
			collision.collider.take_damage(damage)
		destroy()
