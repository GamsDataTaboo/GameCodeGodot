extends Node2D


signal spawn_function_triggered


# Meta
var screen_size
#--

# Configuration
enum mode {AT_SELF, AT_MOUSE, RANDOM_OUTSIDE_FIELD_OF_VIEW}
export (mode)var spawn_mode = mode.AT_SELF

enum control { AUTO, PLAYER, DROPS }
export (control)var control_mode = control.AUTO
export (bool) var player_use_mode_automatic = false
var control_function = null
var can_drop = false
export (String)var use_action

export (Array, PackedScene)var spawn_objects
export (int)var object_spawn_index = 0
export (int)var spawns_per_activation = 1

export (float)var time_till_spawn_timer_starts
export (float)var time_between_spawns
export (bool)var timers_start_stoped = false

export (int)var activation_limit = -1
export (bool)var destroy_after_activation_limit_reached = false

export (Vector2)var screen_size_spawn_buffer
#--

var spawn_function = null
var player


func _ready():
	match spawn_mode:
		mode.AT_SELF:
			spawn_function = funcref(self, "spawn_object_set_location_to_self")
		
		mode.AT_MOUSE:
			spawn_function = funcref(self, "spawn_object_set_location_mouse")
		
		mode.RANDOM_OUTSIDE_FIELD_OF_VIEW:
			randomize()
			screen_size = OS.window_size
			player = get_tree().get_nodes_in_group("player")[0]
			spawn_function = funcref(
				self, 
				"spawn_object_set_location_to_random_outside_field_of_view"
			)
				
	match control_mode:
		control.AUTO:
			control_function = funcref(self, "control_function_auto")
			
		control.PLAYER:
			if player_use_mode_automatic:
				$SpawnTimer.one_shot = false
				
			else:
				$SpawnTimer.one_shot = true
				
			timers_start_stoped = true
			control_function = funcref(self, "control_function_player")
			
		control.DROPS:
			timers_start_stoped = true
			can_drop = true
			control_function = funcref(self, "control_function_drop")
			
	if(!timers_start_stoped):
		$SpawnTimerStartTimer.start(time_till_spawn_timer_starts)
	
	else:
		$SpawnTimerStartTimer.stop()
		$SpawnTimer.stop()

func _process(_delta):
	control_function.call_func()


func control_function_auto():
	pass

func control_function_player():
	if player_use_mode_automatic:
		if Input.is_action_just_pressed(use_action):
			$SpawnTimer.start(time_between_spawns)
		
		elif Input.is_action_just_released(use_action):
			$SpawnTimer.stop()
			
	else:
		if Input.is_action_just_pressed(use_action) and \
			$SpawnTimer.is_stopped():
				$SpawnTimer.start(time_between_spawns)

func control_function_drop():
	pass


func spawn_object_set_location_to_self():
	for _i in range(spawns_per_activation):
		if(activation_limit > 0 or activation_limit == -1):
			var spawned = spawn_objects[object_spawn_index].instance()
			
			spawned.position = global_position
			spawned.rotation = global_rotation
			
			get_tree().root.get_child(0).call_deferred("add_child", spawned)
			
			if activation_limit > 0:
				activation_limit -= 1
				
		else:
			if destroy_after_activation_limit_reached: queue_free()
			return

func spawn_object_set_location_mouse():
	for _i in range(spawns_per_activation):
		if(activation_limit > 0 or activation_limit == -1):
			var spawned = spawn_objects[object_spawn_index].instance()
			spawned.position = get_global_mouse_position()
			
			get_tree().root.get_child(0).call_deferred("add_child", spawned)
			
			if activation_limit > 0:
				activation_limit -= 1
				
		else:
			if destroy_after_activation_limit_reached: queue_free()
			return

func spawn_object_set_location_to_random_outside_field_of_view():
	if is_instance_valid(player):
		for _i in range(spawns_per_activation):
			if(activation_limit > 0 or activation_limit == -1):
				var spawned = spawn_objects[object_spawn_index].instance()
				var spawn_position = player.global_position
				
				
				var spawn_distance_x = screen_size.x + \
					screen_size_spawn_buffer.x
					
				var spawn_distance_y = screen_size.y + \
					screen_size_spawn_buffer.y
				
				
				var roll = rand_range(0, 4)
				
				# Up
				if roll <= 1:
					spawn_position.y -= spawn_distance_y
					
					# Left
					if rand_range(0, 1) <= 0.5:
						spawn_position.x -= rand_range(
							0, screen_size.x
						)
						
					# Right
					else:
						spawn_position.x += rand_range(
							0, screen_size.x
						)
				
				# Down
				elif roll <= 2:
					spawn_position.y += spawn_distance_y
					
					# Left
					if rand_range(0, 1) <= 0.5:
						spawn_position.x -= rand_range(
							0, screen_size.x
						)
						
					# Right
					else:
						spawn_position.x += rand_range(
							0, screen_size.x
						)
			
				# Left
				elif roll <= 3:
					spawn_position.x -= spawn_distance_x
					
					# Up
					if rand_range(0, 1) <= 0.5:
						spawn_position.y -= rand_range(
							0, screen_size.y
						)
						
					# Down
					else:
						spawn_position.y += rand_range(
							0, screen_size.y
						)
				
				# Right
				elif roll <= 4:
					spawn_position.x += spawn_distance_x
					
					# Up
					if rand_range(0, 1) <= 0.5:
						spawn_position.y -= rand_range(
							0, screen_size.y
						)
						
					# Down
					else:
						spawn_position.y += rand_range(
							0, screen_size.y
						)
				
				
				get_tree().root.get_child(0).call_deferred("add_child", spawned)
				spawned.global_position = spawn_position
				
				if activation_limit > 0: activation_limit -= 1
			
			else:
				if destroy_after_activation_limit_reached: queue_free()
				return


func start_spawn_timer():
	$SpawnTimer.start(time_between_spawns)

func stop_spawn_timer():
	$SpawnTimer.stop()


func _on_SpawnTimerStartTimer_timeout():
	$SpawnTimer.start(time_between_spawns)

func _on_SpawnTimer_timeout():
	emit_signal("spawn_function_triggered")
	spawn_function.call_func()


func on_drop():
	if(can_drop):
		spawn_function.call_func()
		can_drop = false
