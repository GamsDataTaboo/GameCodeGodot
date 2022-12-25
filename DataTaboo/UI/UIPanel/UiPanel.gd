extends Panel


export (bool)var debug_mode = false
export (String)var debug_function_to_call_ready = "idle"

var state_function = "idle"

var bound_reached = Vector2(0, 0)

export (Vector2)var move_distance_on_activation = Vector2()
var move_distance_on_activation_remaining = Vector2()

export (Vector2)var move_distance_on_activation_speed = Vector2()

var at_origin = true


func _ready():
	move_distance_on_activation_remaining = move_distance_on_activation
	
	if debug_mode == true:
		call(debug_function_to_call_ready)


func _process(delta):
	call(state_function, delta)


func start_move_from_activation(_extra_arg = null):
	state_function = "move_from_activation"
	
	if at_origin:
		at_origin = false
		
	else:
		at_origin = true


func idle(_delta):
	pass


func move_check_bounds(axis, distance_to_travel, distance_remaining, goal_distance):
	if distance_remaining - abs(distance_to_travel) > 0:
		rect_position[axis] += distance_to_travel
		distance_remaining -= abs(distance_to_travel)
	
	else:
		var direction = 0
		
		if distance_to_travel != 0:
			direction = distance_to_travel / abs(distance_to_travel)
		
		rect_position[axis] += distance_remaining * direction
		distance_remaining = 0
		bound_reached[axis] = 1
		
		if(bound_reached.x == 1 and bound_reached.y == 1):
			distance_remaining = goal_distance
			bound_reached = Vector2(0, 0)
			move_distance_on_activation_speed *= -1
			state_function = "idle"
	
	return distance_remaining

func move_from_activation(delta):
	move_distance_on_activation_remaining.x = \
		move_check_bounds(
			0,
			move_distance_on_activation_speed.x * delta,
			move_distance_on_activation_remaining.x,
			move_distance_on_activation.x
		)
	
	move_distance_on_activation_remaining.y = \
		move_check_bounds(
			1,
			move_distance_on_activation_speed.y * delta,
			move_distance_on_activation_remaining.y,
			move_distance_on_activation.y
		)

func instant_move():
	move_distance_on_activation_remaining.x = \
		move_check_bounds(
			0,
			move_distance_on_activation_remaining.x * move_distance_on_activation_speed.x,
			move_distance_on_activation_remaining.x,
			move_distance_on_activation.x
		)
	
	move_distance_on_activation_remaining.y = \
		move_check_bounds(
			1,
			move_distance_on_activation_remaining.y * move_distance_on_activation_speed.y,
			move_distance_on_activation_remaining.y,
			move_distance_on_activation.y
		)
		
	if at_origin:
		at_origin = false
		
	else:
		at_origin = true

func instant_move_if_not_at_origin():
	if !at_origin:
		instant_move()
