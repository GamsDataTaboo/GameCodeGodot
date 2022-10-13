extends Node2D


signal snap


# Meta
var base_screen_size
#--

# Configuration
enum mode { RANDOM_OUTSIDE_FIELD_OF_VIEW }
export (mode) var spawn_mode = mode.RANDOM_OUTSIDE_FIELD_OF_VIEW
var snap_function = null

var target = null
export (String) var target_group
export (String) var target_tag

export (float) var band_range = 200000

export (Vector2) var screen_size_spawn_buffer
#--


func _ready():
	match spawn_mode:
		mode.RANDOM_OUTSIDE_FIELD_OF_VIEW:
			randomize()
			base_screen_size = OS.window_size * 0.5
			aquire_target_from_tag()
			snap_function = funcref(self, "snap_object_to_random_location_outside_field_of_view")

func _process(_delta):
	snap_function.call_func()


func aquire_target_from_tag():
	var nodes_in_groups = get_tree().get_nodes_in_group(target_group)
	
	for node in nodes_in_groups:
		if node.is_in_group(target_tag):
			target = node


func snap_object_to_random_location_outside_field_of_view():
	if(target == null): return
	if global_position.distance_squared_to(target.position) < band_range: return
	
	var snap_position = target.position
	
	var snap_distance_with_buffer = Vector2(
		rand_range(0, screen_size_spawn_buffer.x) + base_screen_size.x,
		rand_range(0, screen_size_spawn_buffer.y) + base_screen_size.y)
	var snap_distance = Vector2(
		rand_range(0, base_screen_size.x),
		rand_range(0, base_screen_size.y))
		
	if rand_range(0, 1) <= 0.5:
		if rand_range(0, 1) <= 0.5: snap_position.x -= snap_distance_with_buffer.x
		else: snap_position.x += snap_distance_with_buffer.x
			
		if rand_range(0, 1) <= 0.5: snap_position.y -= snap_distance.y
		else: snap_position.y += snap_distance.y
	else:
		if rand_range(0, 1) <= 0.5: snap_position.y -= snap_distance_with_buffer.y
		else: snap_position.y += snap_distance_with_buffer.y
			
		if rand_range(0, 1) <= 0.5: snap_position.x -= snap_distance.x
		else: snap_position.x += snap_distance.x
	
	emit_signal("snap", snap_position)
