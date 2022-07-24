extends KinematicBody2D

var active = true
enum axis {X, Y}
export (Vector2) var acceleration
export (Vector2) var is_accelerating

export (Vector2) var velocity
export (Vector2) var max_velocity
export (Vector2) var velocity_decay_rate


func _physics_process(delta):
	accelerate(delta)
	enforce_max_velocity_of_axis(axis.X)
	enforce_max_velocity_of_axis(axis.Y)
	move()
	slow_down(axis.X, delta)
	slow_down(axis.Y, delta)


func disable():
	$PhysicalBody.disabled = true
	$TriggerArea/CollisionShape2D.disabled = true

func destroy():
	if(active):
		call_deferred("disable")
		queue_free()
		active = false

func accelerate(delta):
	velocity += acceleration * delta
func enforce_max_velocity_of_axis(axis):
	if(velocity[axis] > max_velocity[axis]): velocity[axis] = max_velocity[axis]
	elif(velocity[axis] < -max_velocity[axis]): velocity[axis] = -max_velocity[axis]

func slow_down(axis, delta):
	if(is_accelerating[axis] != 1):
		var decay = velocity_decay_rate * delta

		if(velocity[axis] > 0): velocity[axis] -= decay[axis]
		elif(velocity[axis] < 0): velocity[axis] += decay[axis]
		
		if(abs(velocity[axis]) <= decay[axis]): velocity[axis] = 0

func move():
	return move_and_slide(velocity.rotated(rotation))
