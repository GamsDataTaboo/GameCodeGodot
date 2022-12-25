extends Node


signal starting_parameters_set

signal value_set
signal max_value_set

signal max_value_gained
signal max_value_changed

signal all_values_set

signal value_lost
signal value_gained
signal value_changed
signal value_empty


# Configuration
export (float)var value
export (float)var max_value
#--


func _ready():
	# Use this to emit signals at start.
	set_starting_values(value, max_value)


func set_starting_values(new_starting_value, new_starting_max_value):
	max_value = new_starting_max_value
	value = new_starting_value
	
	emit_signal("starting_parameters_set", value, max_value)
	emit_signal("value_set", value)
	emit_signal("max_value_set", max_value)

func set_all_values(new_max_value, new_value):
	max_value = new_max_value
	value = new_value
	
	emit_signal("value_set", value)
	emit_signal("max_value_set", max_value)
	emit_signal("all_values_set", max_value, value)


func add_to_max_value(amount):
	max_value += amount
	
	emit_signal("max_value_gained", amount)
	emit_signal("max_value_changed", max_value)

func add_to_value(amount):
	value += amount
	emit_signal("value_gained", amount)
	
	if value > max_value:
		value = max_value
		
	emit_signal("value_changed", value)

func add_to_all_values(max_value_amount, value_amount):
	add_to_max_value(max_value_amount)
	add_to_value(value_amount)


func reduce_value(amount):
	value -= amount
	emit_signal("value_lost", amount)
	
	if value <= 0: 
		value = 0
		emit_signal("value_empty")
		
	emit_signal("value_changed", value)
