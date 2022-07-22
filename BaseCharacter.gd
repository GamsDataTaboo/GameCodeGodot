extends RigidBody2D

enum axis {x , y}
export (Vector2) var acceleration
export (Vector2) var is_accelerating

export (Vector2) var velocity;
export (Vector2) var max_velocity;
export (Vector2) var velocity_decay_rate;


func _physics_process(_delta):
	accelerate()
	enforce_max_velocity_of_axis(axis.x)
	enforce_max_velocity_of_axis(axis.y)
	move()
	slow_down(axis.x)
	slow_down(axis.y)


func accelerate():
	velocity += acceleration * get_physics_process_delta_time()
func enforce_max_velocity_of_axis(axis):
	if(velocity[axis] > max_velocity[axis]): velocity[axis] = max_velocity[axis]
	elif(velocity[axis] < -max_velocity[axis]): velocity[axis] = -max_velocity[axis]

func slow_down(axis):
	if(is_accelerating[axis] != 1):
		var decay = velocity_decay_rate * get_physics_process_delta_time()

		if(velocity[axis] > 0): velocity[axis] -= decay[axis]
		elif(velocity[axis] < 0): velocity[axis] += decay[axis]
		
		if(abs(velocity[axis]) <= decay[axis]): velocity[axis] = 0

func move():
	translate(velocity * get_physics_process_delta_time())
