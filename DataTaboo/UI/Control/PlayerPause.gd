extends Button


func _process(_delta):
	if(Input.is_action_just_released("pause")):
		_on_Pause_pressed()


func _on_Pause_pressed():
	if get_tree().paused: get_tree().paused = false
	else: get_tree().paused = true
