extends "res://DataTaboo/KinematicObjects2D/KinematicObject2D.gd"

enum control_mode { ACCELERATION, INSTANT }
export (control_mode) var mode = control_mode.ACCELERATION
var control_function = null

var input_acceleration_multiplier = Vector2.ZERO


func _ready():
	match mode:
		control_mode.ACCELERATION:
			control_function = funcref(self, "control_function_acceleration")
		control_mode.INSTANT:
			control_function = funcref(self, "control_function_instant")

func _process(_delta):
	get_player_input()


func control_function_acceleration():
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
		is_accelerating[axis.X] = 1
	else:
		is_accelerating[axis.X] = 0
		
	if(input_acceleration_multiplier.y != 0): 
		is_accelerating[axis.Y] = 1
	else:
		is_accelerating[axis.Y] = 0
func control_function_instant():
	velocity *= 0
	
	if (Input.is_action_pressed("ui_up")):
		velocity.y = -acceleration.y
	elif (Input.is_action_pressed("ui_down")):
		velocity.y = acceleration.y
		
	if (Input.is_action_pressed("ui_left")):
		velocity.x = -acceleration.x
	elif (Input.is_action_pressed("ui_right")):
		velocity.x = acceleration.x

func get_player_input():
	control_function.call_func()

func accelerate(delta):
	velocity += acceleration * input_acceleration_multiplier * delta
