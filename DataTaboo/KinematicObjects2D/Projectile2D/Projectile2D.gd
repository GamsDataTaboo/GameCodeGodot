extends "res://DataTaboo/AI/AIKinematicMovement2DBase.gd"


export (String)var impact_method = "impact_method"
export (float) var power = 1.0
export (float) var flight_time = 0.5


func _ready():
	$FlightTime.start(flight_time)


func _on_FlightTime_timeout():
	destroy()


func _on_Projectile2D_collided(collision):
	if collision.collider.has_method(impact_method):
		collision.collider.call(impact_method, power)
	
	
	if bounce:
		global_rotation -= 180
	
	else:
		destroy()

func _on_Projectile2D_virtual_collided(body):
	if body.has_method(impact_method):
		body.call(impact_method, power)
	
	
	if bounce:
			global_rotation -= 180
	
	else:
		destroy()
