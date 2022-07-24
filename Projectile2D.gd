extends "res://DataTaboo/AI/AIKinematicMovement2DBase.gd"

export (float) var damage = 1
export (float) var flight_time = 0.5


func _ready():
	$FlightTime.start(flight_time)


func _on_FlightTime_timeout():
	destroy()

func _on_TriggerArea_body_entered(body):
	if(body.is_in_group(target_group)): 
		body.take_damage(damage)
		destroy()
