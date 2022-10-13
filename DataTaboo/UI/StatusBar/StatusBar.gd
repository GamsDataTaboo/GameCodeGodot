extends TextureProgress


func set_starting_values(start_value, start_max_value):
	max_value = start_max_value
	value = start_value


func update_value(new_value):
	value = new_value
