extends KinematicBody2D


signal collided


# Configuration
var active = true
enum axis {X, Y}

enum turning_mode {
	INSTANT, 
	TURN_WITH_X_VELOCITY
}

export (turning_mode)var turning = turning_mode.INSTANT
var move_function = null

export (bool)var bounce = false
#--


# Movement
var movement_modifer = Vector2.ONE

export (Vector2)var acceleration
export (Vector2)var is_accelerating

export (Vector2)var velocity
export (Vector2)var max_velocity
export (Vector2)var velocity_decay_rate

export (Vector2)var oscillation_bounds = Vector2.ZERO
var oscillation_distanced_moved = Vector2.ZERO
#--


func _ready():
	match turning:
		turning_mode.INSTANT:
			move_function = "move_in_facing_direction"
			
		turning_mode.TURN_WITH_X_VELOCITY:
			move_function = "move_with_x_velocity_turn"

func _physics_process(delta):
	accelerate(delta)
	enforce_max_velocity_of_axis(axis.X)
	enforce_max_velocity_of_axis(axis.Y)
	call(move_function, delta)
	slow_down(axis.X, delta)
	slow_down(axis.Y, delta)


func destroy():
	if(active):
		$CollisionShape2D.set_deferred("disabled", true)
		active = false
		queue_free()


func accelerate(delta):
	velocity += acceleration * delta

func enforce_max_velocity_of_axis(axis):
	if(velocity[axis] > max_velocity[axis]): 
		velocity[axis] = max_velocity[axis]
		
	elif(velocity[axis] < -max_velocity[axis]):
		 velocity[axis] = -max_velocity[axis]

func slow_down(axis, delta):
	if(is_accelerating[axis] != 1):
		var decay = velocity_decay_rate * delta

		if(velocity[axis] > 0): 
			velocity[axis] -= decay[axis]
		
		elif(velocity[axis] < 0): 
			velocity[axis] += decay[axis]
		
		
		if(abs(velocity[axis]) <= decay[axis]): 
			velocity[axis] = 0


func update_distance_moved_if_oscillation_bounds_present(distance):
	if oscillation_bounds.x != 0:
		if abs(oscillation_distanced_moved.x) > oscillation_bounds.x:
			movement_modifer *= -1
			oscillation_distanced_moved *= 0
			return
			
	if oscillation_bounds.y != 0:
		if abs(oscillation_distanced_moved.y) > oscillation_bounds.y:
			movement_modifer *= -1
			oscillation_distanced_moved *= 0
			return
	
	if(oscillation_bounds != Vector2.ZERO): 
		oscillation_distanced_moved += distance


func move_and_check_collision(raw_velocity, velocity_with_delta):
	# Test Move
	var collision = move_and_collide(velocity_with_delta.rotated(global_rotation), true, true, true)
	#---
	
	if(collision != null): 
		emit_signal("collided", collision)
		
		if bounce:
			global_rotation -= 180
		
	update_distance_moved_if_oscillation_bounds_present(velocity_with_delta)
	
	return move_and_slide((raw_velocity).rotated(global_rotation))


func move_in_facing_direction(delta):
	var raw_velocity = velocity * movement_modifer
	var velocity_with_delta = raw_velocity * delta
	move_and_check_collision(raw_velocity, velocity_with_delta)

func move_with_x_velocity_turn(delta):
	var raw_velocity = velocity * movement_modifer
	var velocity_with_delta = raw_velocity * delta
	rotate(velocity_with_delta.x)
	move_and_check_collision(raw_velocity, velocity_with_delta)
