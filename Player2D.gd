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
	
	input_acceleration_multiplier = \
		Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		
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
	
	velocity = \
		acceleration * \
			Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")


func get_player_input():
	control_function.call_func()

func accelerate(delta):
	velocity += acceleration * input_acceleration_multiplier * delta
