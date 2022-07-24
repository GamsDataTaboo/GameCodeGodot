extends Node2D

enum mode { AT_SELF }
export (mode) var spawn_mode = mode.AT_SELF
var spawn_function = null

export (Array, PackedScene) var spawn_objects

export (float) var time_till_spawn_timer_starts
export (float) var time_between_spawns


func _ready():
	$SpawnTimerStartTimer.start(time_till_spawn_timer_starts)
	
	match spawn_mode:
		mode.AT_SELF:
			spawn_function = funcref(self, "spawn_object_set_location_to_self")


func spawn_object_set_location_to_self():
	var spawned = spawn_objects[0].instance()
	spawned.position = global_position
	get_tree().root.get_child(0).add_child(spawned)


func _on_SpawnTimerStartTimer_timeout():
	$SpawnTimer.start(time_between_spawns)
func _on_SpawnTimer_timeout():
	spawn_function.call_func()
