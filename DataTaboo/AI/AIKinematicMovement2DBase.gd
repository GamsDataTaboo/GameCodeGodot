extends "res://DataTaboo/KinematicObjects2D/KinematicObject2D.gd"


# Configuration
enum behaviors {
	PASSIVE, 
	PASSIVE_AT_START_FACE_CLOSEST_TARGET_IN_GROUP, 
	HUNT_CLOSEST_IN_GROUP
}
export (behaviors) var behavior = behaviors.PASSIVE

var ai_function = null
var state_function = null
#--

# Goals
var target = null
export (String) var target_group
#--

# Movement
var ai_acceleration_intent_modifer = Vector2.ZERO
export (float) var distance_stop_buffer = 10000.00
export (Array, int) var gimbol_for_select_children
#--


func _ready():
	ai_acceleration_intent_modifer = acceleration
	acceleration *= 0
	
	match behavior:
		behaviors.PASSIVE:
			ai_function = funcref(self, "passive")
			state_function = funcref(self, "idle")
			
		behaviors.PASSIVE_AT_START_FACE_CLOSEST_TARGET_IN_GROUP:
			ai_function = funcref(
				self, "passive_at_start_face_closest_target_in_group"
			)
			state_function = funcref(self, "aquire_closest_target_from_group")
		
		behaviors.HUNT_CLOSEST_IN_GROUP:
			ai_function = funcref(self, "hunt_closest_in_group")
			state_function = funcref(self, "aquire_closest_target_from_group")

func _process(_delta):
	state_function.call_func()


# Utility
func apply_gimbol_to_select_children():
	for child in gimbol_for_select_children:
		get_child(child).global_rotation = 0

func start_acceleration(var answer):
	if answer:
		acceleration = ai_acceleration_intent_modifer
		is_accelerating = Vector2.ONE
	
	else:
		acceleration *= 0
		is_accelerating *= 0


# AI
func passive():
	pass

func passive_at_start_face_closest_target_in_group():
	if is_instance_valid(target): look_at(target.position)
	ai_function = funcref(self, "passive")

func hunt_closest_in_group():
	if is_instance_valid(target): 
		start_acceleration(true)
		state_function = funcref(self, "advance_to_target")
	
	else:
		start_acceleration(false)
		state_function = funcref(self, "aquire_closest_target_from_group")


# States
func idle():
	ai_function.call_func()

func aquire_closest_target_from_group():
	var nodes_in_groups = get_tree().get_nodes_in_group(target_group)
	
	var distance_to_closest_node = 9999999999
	for node in nodes_in_groups:
		var distance_to_node = global_position.distance_squared_to(
			node.global_position
		)
		
		if(distance_to_node < distance_to_closest_node):
			distance_to_closest_node = distance_to_node
			target = node
			
	ai_function.call_func()

func advance_to_target():
	if is_instance_valid(target): 
		face_target()
		if(global_position.distance_squared_to(target.global_position) <= 
			distance_stop_buffer): 
				start_acceleration(false)
		
		else: start_acceleration(true)
	else: ai_function.call_func()


# Actions
func face_target():
	if is_instance_valid(target): 
		look_at(target.global_position)
		apply_gimbol_to_select_children()
		
	ai_function.call_func()
