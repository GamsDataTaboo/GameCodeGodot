extends TextureRect


# Conifguration
export (int)var id = -1

var tool_tip_layer
export (PackedScene)var tooltip
var base_tooltip_size
var active_tooltip
#--

var is_mouseover = false


func _ready():
	tool_tip_layer = get_parent().get_parent().get_parent().get_node("TooltipLayer")
	active_tooltip = tooltip.instance()
	base_tooltip_size = active_tooltip.rect_size


func _on_Item_mouse_entered():
	active_tooltip.rect_position = get_local_mouse_position()
	active_tooltip.rect_size = base_tooltip_size
	tool_tip_layer.add_child(active_tooltip)
	
	is_mouseover = true
	
func _on_Item_mouse_exited():
	tool_tip_layer.remove_child(active_tooltip)
	
	is_mouseover = false
