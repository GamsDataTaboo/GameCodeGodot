extends Node


signal starting_parameters_set

signal value_set
signal max_value_set

signal value_lost
signal value_gained
signal value_changed
signal value_empty


# Configuration
export (float)var value
export (float)var max_value
#--


func set_starting_values(var new_starting_value, var new_starting_max_value):
	max_value = new_starting_max_value
	value = new_starting_value
	emit_signal("starting_parameters_set", value, max_value)
	emit_signal("value_set", value)
	emit_signal("max_value_set", max_value)


func add_to_value(var amount):
	value += amount
	emit_signal("value_gained", amount)
	if value > max_value: value = max_value
	emit_signal("value_changed", value)


func reduce_value(var amount):
	value -= amount
	emit_signal("value_lost", amount)
	
	if value <= 0: 
		emit_signal("value_empty")
		value = 0
		
	emit_signal("value_changed", value)
