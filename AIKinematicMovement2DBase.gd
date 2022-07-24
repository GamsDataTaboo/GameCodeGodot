extends "res://DataTaboo/KinematicObjects2D/KinematicObject2D.gd"

enum behaviors {
	PASSIVE, 
	PASSIVE_AT_START_FACE_CLOSEST_TARGET_IN_GROUP, 
	HUNT_CLOSEST_IN_GROUP}
export (behaviors) var behavior = behaviors.PASSIVE
var ai_function = null
var state_function = null

var target = null
export (String) var target_group
export (String) var target_tag

var ai_acceleration = Vector2.ZERO
export (float) var distance_stop_buffer = 10000


func _ready():
	ai_acceleration = acceleration
	acceleration *= 0
	
	match behavior:
		behaviors.PASSIVE:
			ai_function = funcref(self, "passive")
			state_function = funcref(self, "idle")
			
		behaviors.PASSIVE_AT_START_FACE_CLOSEST_TARGET_IN_GROUP:
			ai_function = funcref(
				self, "passive_at_start_face_closest_target_in_group")
			state_function = funcref(self, "aquire_closest_target_from_group")
		
		behaviors.HUNT_CLOSEST_IN_GROUP:
			ai_function = funcref(self, "hunt_closest_in_group")
			state_function = funcref(self, "aquire_closest_target_from_group")

func _process(_delta):
	state_function.call_func()


# Utility
func set_can_accelerate(var answer):
	if answer:
		acceleration = ai_acceleration
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
		set_can_accelerate(true)
		state_function = funcref(self, "advance_to_target")
	else:
		set_can_accelerate(false)
		state_function = funcref(self, "aquire_closest_target_from_group")


# States
func idle():
	ai_function.call_func()

func aquire_closest_target_from_tag():
	var nodes_in_groups = get_tree().get_nodes_in_group(target_group)
	
	var distance_to_closest_node = 9999999999
	for node in nodes_in_groups:
		if node.is_in_group(target_tag):
			var distance_to_node = position.distance_squared_to(node.position)
			if distance_to_node < distance_to_closest_node:
				distance_to_closest_node = distance_to_node
				target = node
			
	ai_function.call_func()
func aquire_closest_target_from_group():
	var nodes_in_groups = get_tree().get_nodes_in_group(target_group)
	
	var distance_to_closest_node = 9999999999
	for node in nodes_in_groups:
		var distance_to_node = position.distance_squared_to(node.position)
		
		if(distance_to_node < distance_to_closest_node):
			distance_to_closest_node = distance_to_node
			target = node
			
	ai_function.call_func()

func advance_to_target():
	if is_instance_valid(target): 
		face_target()
		if(position.distance_squared_to(target.position) 
			<= distance_stop_buffer):
				set_can_accelerate(false)
				
		else: set_can_accelerate(true)
	else: ai_function.call_func()


# Actions
func face_target():
	if is_instance_valid(target): look_at(target.position)
	
	ai_function.call_func()
