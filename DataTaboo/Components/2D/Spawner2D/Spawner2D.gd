extends Node2D


signal spawn_function_triggered


# Meta
var screen_size
#


# Configuration
export (bool)var can_spawn = true

enum mode {
	AT_SELF,
	AT_MOUSE,
	RANDOM_LOCAION_RELATIVE_TO_SELF,
	RANDOM_LOCATION_OUTSIDE_FIELD_OF_VIEW,
	RANDOM_OBJECT_RANDOM_LOCAION_RELATIVE_TO_SELF,
	RANDOM_OBJECT_RANDOM_LOCATION_INSIDE_FIELD_OF_VIEW,
	RANDOM_OBJECT_RANDOM_LOCATION_OUTSIDE_FIELD_OF_VIEW
}

export (mode)var spawn_mode = mode.AT_SELF
export (Vector2)var spawn_buffer


# BUG - ONLY WORKS WITH: 'RANDOM_LOCAION_RELATIVE_TO_SELF' - !
# CHANGE TO 'max_spawn_distance_after_buffer' - !
export (Vector2)var max_spawn_distance
# BUG - ONLY WORKS WITH: 'RANDOM_LOCAION_RELATIVE_TO_SELF' - !
# CHANGE TO 'max_spawn_distance_after_buffer' - !


export (Array, PackedScene)var spawn_objects
export (bool)var use_spawn_object_cache_for_all_spawn_objects = false
export (bool)var use_spawn_object_cache = false
var spawn_object_cache = []
export (int)var object_spawn_index = 0
export (int)var spawn_limit = -1
export (int)var spawns_per_activation = 1
export (bool)var random_spawn_amount = false
export (int)var spawn_min = 0
export (int)var spawn_max = 0

export (bool)var limit_active_spawns = false
export (String)var spawn_group_name = null
export (int)var active_spawns_limit = 0
var active_spawns = 0

enum control { 
	AUTO,
	PLAYER,
	DROPS,
	AI
}

export (control)var control_mode = control.AUTO
export (bool)var player_use_mode_automatic = false
var control_function = null
export (String)var use_action


export (float)var time_till_spawn_timer_starts
export (float)var time_between_spawns
export (bool)var first_spawn_on_each_timer_start_is_instant = true
export (bool)var timers_start_stoped = false

export (int)var activation_limit = -1
export (bool)var destroy_after_activation_limit_reached = false
# Configuration


export (String)var spawn_parent = null
var spawn_function = null
var location_function = null
var player = null

var spawn_timer_start_timer = null
var spawn_timer = null


func _ready():
	spawn_timer_start_timer = $SpawnTimerStartTimer
	spawn_timer = $SpawnTimer
	
	
	if spawn_parent == null:
		spawn_parent = get_tree().root.get_child(0)
		
	else:
		spawn_parent = get_tree().root.get_node(spawn_parent)
	
	
	match spawn_mode:
		mode.AT_SELF:
			spawn_function = "spawn_object"
			location_function = "get_global_location_data"
		
		mode.AT_MOUSE:
			spawn_function = "spawn_object"
			location_function = "get_player_global_mouse_position"
		
		mode.RANDOM_LOCAION_RELATIVE_TO_SELF:
			randomize()
			spawn_function = "spawn_object"
			location_function = "get_random_spawn_postion_relative_to_self"
		
		mode.RANDOM_LOCATION_OUTSIDE_FIELD_OF_VIEW:
			randomize()
			screen_size = OS.window_size
			player = get_tree().get_nodes_in_group("player")[0]
			spawn_function = "spawn_object"
			location_function = "get_random_spawn_postion_outside_of_screen"

		mode.RANDOM_OBJECT_RANDOM_LOCAION_RELATIVE_TO_SELF:
			randomize()
			spawn_function = "spawn_random_object"
			location_function = "get_random_spawn_postion_relative_to_self"
			
		mode.RANDOM_OBJECT_RANDOM_LOCATION_INSIDE_FIELD_OF_VIEW:
			randomize()
			screen_size = OS.window_size
			player = get_tree().get_nodes_in_group("player")[0]
			spawn_function = "spawn_random_object"
			location_function = "get_random_spawn_position_inside_of_screen"
		
		mode.RANDOM_OBJECT_RANDOM_LOCATION_OUTSIDE_FIELD_OF_VIEW:
			randomize()
			screen_size = OS.window_size
			player = get_tree().get_nodes_in_group("player")[0]
			spawn_function = "spawn_random_object"
			location_function = "get_random_spawn_postion_outside_of_screen"
		
		
	match control_mode:
		control.AUTO:
			control_function = "control_function_auto"
			
		control.PLAYER:
			if player_use_mode_automatic:
				spawn_timer.one_shot = false
				
			else:
				spawn_timer.one_shot = true
				
			timers_start_stoped = true
			control_function = "control_function_player"
			
		control.DROPS:
			timers_start_stoped = true
			control_function = "control_function_drop"
			
		control.AI:
			timers_start_stoped = true
			control_function = "control_function_ai"
			
			
	if(!timers_start_stoped):
		if time_till_spawn_timer_starts != 0:
			spawn_timer_start_timer.start(time_till_spawn_timer_starts)
	
	else:
		spawn_timer_start_timer.stop()
		spawn_timer.stop()
	
	
	if use_spawn_object_cache_for_all_spawn_objects:
		use_spawn_object_cache = true
		
		for i in range(spawn_objects.size()):
			add_spawn_object_to_cache_via_index(i)
			
	call(control_function)

func _process(_delta):
	call(control_function)


func add_spawn_object_to_cache_via_index(index):
	spawn_object_cache.append( spawn_objects[index].instance() )

func add_spawn_object_to_cache(new_spawn_object):
	spawn_object_cache.append( new_spawn_object.instance() )


func control_function_auto():
	pass

func control_function_player():
	if player_use_mode_automatic:
		if Input.is_action_just_pressed(use_action):
			spawn_timer.start(time_between_spawns)
		
		elif Input.is_action_just_released(use_action):
			spawn_timer.stop()
			
	else:
		if Input.is_action_just_pressed(use_action) and spawn_timer.is_stopped():
			spawn_timer.start(time_between_spawns)

func control_function_drop():
	pass

func control_function_ai():
	pass


func use_function_ai(use):
	if use:
		if spawn_timer.is_stopped():
			spawn_timer.start(time_between_spawns)
		
	else:
		spawn_timer.stop()


func get_global_location_data():
	return global_position

func get_player_global_mouse_position():
	return get_global_mouse_position()

func get_random_spawn_postion_relative_to_self():
	var spawn_position = global_position
	
	# !- CHANGE NAME OF 'spawn_buffer_[]' to 'initial_spawn_buffere_[]' - !
	# !- CHANGE NAME OF 'spawn_buffer_[]' to 'initial_spawn_buffere_[]' - !
	
	var roll = rand_range(0, 4)
	
	# Up
	if roll <= 1:
		# Min Up
		spawn_position.y -= spawn_buffer.y
		
		# Max Up
		var real_max_spawn_distance_y = max_spawn_distance.y - spawn_buffer.y
		
		if real_max_spawn_distance_y <= 0:
			real_max_spawn_distance_y = 0
			
		spawn_position.y -= rand_range(0, real_max_spawn_distance_y)
		
		# Left or Right
		spawn_position.x += rand_range(-max_spawn_distance.x, max_spawn_distance.x)
			
	
	# Down
	elif roll <= 2:
		# Min Down
		spawn_position.y += spawn_buffer.y
		
		# Max Down
		var real_max_spawn_distance_y = max_spawn_distance.y - spawn_buffer.y
		
		if real_max_spawn_distance_y <= 0:
			real_max_spawn_distance_y = 0
			
		spawn_position.y += rand_range(0, real_max_spawn_distance_y)
		
		# Left or Right
		spawn_position.x += rand_range(-max_spawn_distance.x, max_spawn_distance.x)

	# Left
	elif roll <= 3:
		# Min Left
		spawn_position.x -= spawn_buffer.x
		
		# Max Left
		var real_max_spawn_distance_x = max_spawn_distance.x - spawn_buffer.x
		
		if real_max_spawn_distance_x <= 0:
			real_max_spawn_distance_x = 0
			
		spawn_position.x -= rand_range(0, real_max_spawn_distance_x)
		
		# Up or Down
		spawn_position.y += rand_range(-max_spawn_distance.y, max_spawn_distance.y)
	
	# Right
	elif roll <= 4:
		# Min Right
		spawn_position.x += spawn_buffer.x
		
		# Max Right
		var real_max_spawn_distance_x = max_spawn_distance.x - spawn_buffer.x
		
		if real_max_spawn_distance_x <= 0:
			real_max_spawn_distance_x = 0
			
		spawn_position.x += rand_range(0, real_max_spawn_distance_x)
		
		# Up or Down
		spawn_position.y += rand_range(-max_spawn_distance.y, max_spawn_distance.y)


	return spawn_position

# BUG - ONLY WORKS WITH STATIC SCREENS - !
# BUG - MYSTERIOUS POSTION PLACEMENT BUG - !
func get_random_spawn_position_inside_of_screen():
	var spawn_position = Vector2(screen_size.x / 2, screen_size.y / 2)
	var roll = rand_range(0, 4)
	
	# Up
	if roll <= 1:
		spawn_position.y -= spawn_buffer.y
		
		# Left
		if rand_range(0, 1) <= 0.5:
			spawn_position.x -= rand_range(0, screen_size.x)
			
		# Right
		else:
			spawn_position.x += rand_range(0, screen_size.x)
	
	# Down
	elif roll <= 2:
		spawn_position.y += spawn_buffer.y
		
		# Left
		if rand_range(0, 1) <= 0.5:
			spawn_position.x -= rand_range(0, screen_size.x)
			
		# Right
		else:
			spawn_position.x += rand_range(0, screen_size.x)

	# Left
	elif roll <= 3:
		spawn_position.x -= spawn_buffer.x
		
		# Up
		if rand_range(0, 1) <= 0.5:
			spawn_position.y -= rand_range(0, screen_size.y)
			
		# Down
		else:
			spawn_position.y += rand_range(0, screen_size.y)
	
	# Right
	elif roll <= 4:
		spawn_position.x += spawn_buffer.x
		
		# Up
		if rand_range(0, 1) <= 0.5:
			spawn_position.y -= rand_range(0, screen_size.y)
			
		# Down
		else:
			spawn_position.y += rand_range(0, screen_size.y)


	return spawn_position
# BUG - ONLY WORKS WITH STATIC SCREENS - !
# BUG - MYSTERIOUS POSTION PLACEMENT BUG - !

# BUG - ONLY WORKS WITH STATIC SCREENS - !
# BUG - MYSTERIOUS POSTION PLACEMENT BUG - !
func get_random_spawn_postion_outside_of_screen():
	var spawn_position = Vector2(screen_size.x / 2, screen_size.y / 2)
	
	# !- CHANGE NAME OF 'spawn_distance_[]' to 'initial_spawn_distance_[]' - !
	# !- CHANGE NAME OF 'spawn_buffer_[]' to 'initial_spawn_buffere_[]' - !
	var spawn_distance_x = screen_size.x + spawn_buffer.x
	var spawn_distance_y = screen_size.y + spawn_buffer.y
	# !- CHANGE NAME OF 'spawn_distance_[]' to 'initial_spawn_distance_[]' - !
	# !- CHANGE NAME OF 'spawn_buffer_[]' to 'initial_spawn_buffere_[]' - !
	
	var roll = randi() % 4
	
	# Up
	if roll == 0:
		spawn_position.y -= spawn_distance_y
		
		# Left
		if rand_range(0, 1) <= 0.5:
			spawn_position.x -= rand_range(0, screen_size.x)
			
		# Right
		else:
			spawn_position.x += rand_range(0, screen_size.x)
	
	# Down
	elif roll == 1:
		spawn_position.y += spawn_distance_y
		
		# Left
		if rand_range(0, 1) <= 0.5:
			spawn_position.x -= rand_range(0, screen_size.x)
			
		# Right
		else:
			spawn_position.x += rand_range(0, screen_size.x)

	# Left
	elif roll == 2:
		spawn_position.x -= spawn_distance_x
		
		# Up
		if rand_range(0, 1) <= 0.5:
			spawn_position.y -= rand_range(0, screen_size.y)
			
		# Down
		else:
			spawn_position.y += rand_range(0, screen_size.y)
	
	# Right
	elif roll == 3:
		spawn_position.x += spawn_distance_x
		
		# Up
		if rand_range(0, 1) <= 0.5:
			spawn_position.y -= rand_range(0, screen_size.y)
			
		# Down
		else:
			spawn_position.y += rand_range(0, screen_size.y)


	return spawn_position
# BUG - ONLY WORKS WITH STATIC SCREENS - !
# BUG - MYSTERIOUS POSTION PLACEMENT BUG - !


# BUG - RANDOM AMOUNT DOES NOT WORK WITH 'LIMIT ACTIVE SPAWNS' - !
func spawn_object():
	if random_spawn_amount:
		spawns_per_activation = randi() % spawn_max + spawn_min
		
	if(activation_limit > 0 or activation_limit == -1):
		for _i in range(spawns_per_activation):
			if(spawn_limit > 0 or spawn_limit == -1):
				var spawned = null
				
				if use_spawn_object_cache and !spawn_object_cache.empty():
					spawned = \
						spawn_object_cache[object_spawn_index].duplicate(DUPLICATE_USE_INSTANCING)
						
				elif !spawn_objects.empty():
					spawned = spawn_objects[object_spawn_index].instance()
				
				if limit_active_spawns:
					spawned.add_to_group(spawn_group_name)
				
				if spawned != null:
					spawned.position = call(location_function)
					spawn_parent.call_deferred("add_child", spawned)
					
					if spawn_limit > 0:
						spawn_limit -= 1
					
		if activation_limit > 0:
			activation_limit -= 1
					
	else:
		if destroy_after_activation_limit_reached:
			queue_free()
# BUG - RANDOM AMOUNT DOES NOT WORK WITH 'LIMIT ACTIVE SPAWNS' - !

func spawn_random_object():
	if use_spawn_object_cache and !spawn_object_cache.empty():
		object_spawn_index = randi() % spawn_object_cache.size()
	
	elif !spawn_object_cache.empty():
		object_spawn_index = randi() % spawn_objects.size()
	
	spawn_object()


func start_spawn_timer_start_timer():
	spawn_timer_start_timer.start()

func start_spawn_timer():
	if first_spawn_on_each_timer_start_is_instant:
		_on_SpawnTimer_timeout()
		
	spawn_timer.start(time_between_spawns)

func stop_spawn_timer():
	spawn_timer.stop()

func stop_all_spawn_timers():
	spawn_timer_start_timer.stop()
	spawn_timer.stop()


func _on_SpawnTimerStartTimer_timeout():
	start_spawn_timer()

func _on_SpawnTimer_timeout():
	if can_spawn:
		if limit_active_spawns:
			active_spawns = get_tree().get_nodes_in_group(spawn_group_name).size()
			
			if active_spawns < active_spawns_limit:
				emit_signal("spawn_function_triggered")
				call(spawn_function)
				
		else:
			emit_signal("spawn_function_triggered")
			call(spawn_function)


func on_drop():
	call(spawn_function)
