extends Area2D


# Configuration
var active = true
export (String) var collector_group
#--


func on_collected():
	pass


func _on_Collectable_body_entered(body):
	if(body.is_in_group(collector_group)):
		on_collected()
