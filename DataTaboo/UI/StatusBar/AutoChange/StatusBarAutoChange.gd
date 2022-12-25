extends "res://DataTaboo/UI/StatusBar/StatusBar.gd"


signal bar_full
signal percentage_value


var is_bar_full = false
export (float)var auto_delta = 0.0


func _ready():
	emit_signal("percentage_value", value / max_value)

func _process(delta):
	emit_signal("percentage_value", value / max_value)
	
	if !is_bar_full:
		value += auto_delta * delta
		
		if value >= max_value:
			emit_signal("bar_full")
			is_bar_full = true
