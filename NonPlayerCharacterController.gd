extends "res://Character/BaseCharacter.gd"

enum behaviors {PASSIVE, HUNT}
export (behaviors) var behavior = behaviors.PASSIVE

var ai = null
var state = null

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
			ai = funcref(self, "passive")
			state = funcref(self, "idle")
		behaviors.HUNT:
			ai = funcref(self, "hunt")
			state = funcref(self, "aquire_target_from_tag")

func _process(_delta):
	state.call_func()

# Utility
func set_can_accelerate(var answer):
	if(answer):
		acceleration = ai_acceleration
		is_accelerating = Vector2.ONE
	else:
		acceleration *= 0
		is_accelerating *= 0


# AI
func passive():
	pass

func hunt():
	if(target != null): 
		set_can_accelerate(true)
		state = funcref(self, "advance_to_target")
	else:
		set_can_accelerate(false)
		state = funcref(self, "aquire_target_from_tag")


# States
func idle():
	ai.call_func()

func aquire_target_from_tag():
	var nodes_in_groups = get_tree().get_nodes_in_group(target_group)
	
	for node in nodes_in_groups:
		if node.is_in_group(target_tag):
			target = node
			
	ai.call_func()

func advance_to_target():
	if(target != null): 
		face_target()
		if(position.distance_squared_to(target.position) \
			<= distance_stop_buffer):
				set_can_accelerate(false)
		else:
			set_can_accelerate(true)
		
	else: ai.call_func()


# Actions
func face_target():
	if target != null: look_at(target.position)
	
	ai.call_func()
