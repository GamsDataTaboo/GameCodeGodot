extends Node

signal starting_parameters_set
signal value_lost
signal value_empty

var value
var max_value


func set_starting_values(var new_starting_value, var new_starting_max_value):
	value = new_starting_value
	max_value = new_starting_max_value
	emit_signal("starting_parameters_set")

func add_to_value(var amount):
	value += amount
	
	if value > max_value: value = max_value
	elif amount < 0:
		emit_signal("value_lost", amount)
		
		if value <= 0: 
			emit_signal("value_empty")
			value = 0
