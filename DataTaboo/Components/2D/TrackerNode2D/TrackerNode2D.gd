extends Node2D


var active = true
var starting_postion = null
export (Vector2)var max_move_position


func ready_set_starting_postion_to_position():
	starting_postion = position

func process_track_mouse():
	if active:
		position = get_global_mouse_position()


func set_postion_x_as_percentage_of_max(percentage):
	if active:
		position.x = max_move_position.x * percentage
