extends "res://DataTaboo/KinematicObjects2D/KinematicObject2D.gd"


# Configuration
enum behaviors {
	PASSIVE,
	PASSIVE_AT_START_FACE_RANDOM_DIRECTION, 
	PASSIVE_AT_START_FACE_CLOSEST_TARGET_IN_GROUP,
	ACCELERATE_AT_START_FACE_RANDOM_TARGET_IN_GROUP,
	HUNT_CLOSEST_IN_GROUP
}
export (behaviors) var behavior = behaviors.PASSIVE

var ai_function = null
var state_function = null
#--

# Goals
var target = null
export (String)var target_group
#--

# Movement
export (bool)var store_starting_velociy_for_instance_speed_change_ignore_acceleration = false
var starting_velocity = Vector2.ZERO

var ai_acceleration_intent_modifer = Vector2.ZERO
export (float)var distance_stop_buffer = 10000.00
export (Array, int)var gimbol_for_select_children

export (bool)var flip_y_to_face_movement_direction = false
export (Array, int)var horizontal_flip_to_face_move_direction_for_select_children
#--


# Godot
func _ready():
	ai_acceleration_intent_modifer = acceleration
	acceleration *= 0
	
	if store_starting_velociy_for_instance_speed_change_ignore_acceleration:
		starting_velocity = velocity
	
	match behavior:
		behaviors.PASSIVE:
			state_function = "idle"
			ai_function = "passive"
		
		behaviors.PASSIVE_AT_START_FACE_RANDOM_DIRECTION:
			state_function = "idle"
			ai_function = "passive_at_start_face_random_direction"

		behaviors.PASSIVE_AT_START_FACE_CLOSEST_TARGET_IN_GROUP:
			state_function = "aquire_closest_target_from_group"
			ai_function = "passive_at_start_face_closest_target_in_group"
		
		behaviors.ACCELERATE_AT_START_FACE_RANDOM_TARGET_IN_GROUP:
			state_function = "aquire_random_target_from_group"
			ai_function = "accelerate_at_start_face_random_target_in_group"
			
		behaviors.HUNT_CLOSEST_IN_GROUP:
			state_function = "aquire_closest_target_from_group"
			ai_function = "hunt_closest_in_group"

	call(state_function)

func _process(_delta):
	call(state_function)
#--


# Utility
func apply_gimbol_to_select_children():
	for child in gimbol_for_select_children:
		get_child(child).global_rotation = 0

func apply_horizontal_flip_to_face_move_direction_for_select_children():
	for child in horizontal_flip_to_face_move_direction_for_select_children:
		if flip_y_to_face_movement_direction:
			if abs(rotation_degrees) > 90 and abs(rotation_degrees) < 270:
				get_child(child).flip_h = true
				
			else:
				get_child(child).flip_h = false

func start_acceleration(answer):
	if answer:
		acceleration = ai_acceleration_intent_modifer
		is_accelerating = Vector2.ONE
	
	else:
		acceleration *= 0
		is_accelerating *= 0

func change_stored_starting_velocity(new_stored_starting_velocity):
	starting_velocity = new_stored_starting_velocity

func set_velocity(new_velocity):
	velocity = new_velocity
#--


# AI
func passive():
	apply_gimbol_to_select_children()
	apply_horizontal_flip_to_face_move_direction_for_select_children()

func passive_at_start_face_random_direction():
	rotation_degrees = rand_range(0, 360)
	ai_function = "passive"

func passive_at_start_face_closest_target_in_group():
	if is_instance_valid(target): 
		look_at(target.position)
		
	ai_function = "passive"

func accelerate_at_start_face_random_target_in_group():
	if is_instance_valid(target): 
		look_at(target.position)
	
	start_acceleration(true)
	ai_function = "passive"

func hunt_closest_in_group():
	if is_instance_valid(target):
		if !store_starting_velociy_for_instance_speed_change_ignore_acceleration:
			start_acceleration(true)
			
		else:
			velocity = starting_velocity
			
		state_function = "advance_to_target"
	
	else:
		if !store_starting_velociy_for_instance_speed_change_ignore_acceleration:
			start_acceleration(false)
			
		else:
			velocity *= 0
			
		state_function = "aquire_closest_target_from_group"
#--


# States
func idle():
	call(ai_function)

func aquire_closest_target_from_group():
	var nodes_in_groups = get_tree().get_nodes_in_group(target_group)
	var distance_to_closest_node = 9999999999
	
	if !nodes_in_groups.empty():
		for node in nodes_in_groups:
			var distance_to_node = global_position.distance_squared_to(node.global_position)
			
			if(distance_to_node < distance_to_closest_node):
				distance_to_closest_node = distance_to_node
				target = node
		
	call(ai_function)
	
	
func aquire_random_target_from_group():
	var nodes_in_groups = get_tree().get_nodes_in_group(target_group)
	
	if !nodes_in_groups.empty():
		nodes_in_groups.shuffle()
		target = nodes_in_groups.front()
		call(ai_function)

func advance_to_target():
	if is_instance_valid(target): 
		face_target()
		
		if(global_position.distance_squared_to(target.global_position) <= distance_stop_buffer): 
			if !store_starting_velociy_for_instance_speed_change_ignore_acceleration:
				start_acceleration(false)
				
			else:
				velocity *= 0
		
		else: 
			if !store_starting_velociy_for_instance_speed_change_ignore_acceleration:
				start_acceleration(true)
				
			else:
				velocity = starting_velocity
			
	else: 
		call(ai_function)
#--


# Actions
func face_target():
	if is_instance_valid(target): 
		look_at(target.global_position)
		apply_gimbol_to_select_children()
		apply_horizontal_flip_to_face_move_direction_for_select_children()
		
	call(ai_function)
#--
