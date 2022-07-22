extends "res://Character/BaseCharacter.gd"

var input_acceleration_multiplier = Vector2.ZERO


func _process(_delta):
	get_player_input()


func get_player_input():
	input_acceleration_multiplier = Vector2.ZERO
	
	if (Input.is_action_pressed("ui_up")):
		input_acceleration_multiplier.y = -1
	elif (Input.is_action_pressed("ui_down")):
		input_acceleration_multiplier.y = 1
		
	if (Input.is_action_pressed("ui_left")):
		input_acceleration_multiplier.x = -1
	elif (Input.is_action_pressed("ui_right")):
		input_acceleration_multiplier.x = 1
		
	if(input_acceleration_multiplier.x != 0): 
		is_accelerating[axis.x] = 1
	else:
		is_accelerating[axis.x] = 0
		
	if(input_acceleration_multiplier.y != 0): 
		is_accelerating[axis.y] = 1
	else:
		is_accelerating[axis.y] = 0


func accelerate():
	velocity += \
		acceleration * input_acceleration_multiplier * \
			get_physics_process_delta_time()
