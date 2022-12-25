extends Control


export (Color)var hover_base_color
export (Color)var hover_color_on_hover

export (Color)var on_interact_base_color
export (Color)var on_interact_color_on_interaction


export (String)var glow_node_texture_hover_name = "TextureRect"
var glow_node_texture_hover = null

export (String)var glow_node_texture_interact_name = "TextureRect"
var glow_node_texture_interact = null


var action = "idle"

var pop_effect_max_axis_amount_reached = Vector2(0, 0)
export (float)var pop_speed = 7.0
export (Vector2)var pop_scale_start_amount = Vector2(1.75, 1.75)
export (Vector2)var pop_scale_max_amount = Vector2(2, 2)
export (Vector2)var pop_scale_end_amount = Vector2(1.0, 1.0)

var scale_shrink_target_axis_reached = Vector2(0, 0)
export (Vector2)var scale_shrink_target = Vector2(0.33, 0.33)
export (float)var shrink_speed = 7.0


func ready_modulate():
	modulate = hover_base_color

func ready_pop_scale():
	rect_scale = pop_scale_start_amount
	rect_pivot_offset = rect_size / 2

func ready_texture_mode():
	glow_node_texture_hover = get_node_or_null(glow_node_texture_hover_name)
	
	if glow_node_texture_hover != null:
		glow_node_texture_hover.self_modulate = hover_base_color
		
		
	glow_node_texture_interact = get_node_or_null(glow_node_texture_interact_name)
	
	if glow_node_texture_interact != null:
		glow_node_texture_interact.self_modulate = on_interact_base_color

func ready_texture_font_mode():
	pass


func process_function_pop_scale(delta):
	call(action, delta)


func handle_pop_scale(
	scale_axis, pop_scale_end_amount_axis, pop_scale_max_amount_axis,
	speed
):
	if pop_effect_max_axis_amount_reached[scale_axis]:
		if rect_scale[scale_axis] >= pop_scale_end_amount_axis:
			rect_scale[scale_axis] -= speed
			
			if rect_scale[scale_axis] <= pop_scale_end_amount_axis:
				rect_scale[scale_axis] = pop_scale_end_amount_axis
	
	elif rect_scale[scale_axis] < pop_scale_max_amount_axis:
		rect_scale[scale_axis] += speed
		
		if rect_scale[scale_axis] >= pop_scale_max_amount_axis:
			rect_scale[scale_axis] = pop_scale_max_amount_axis
			pop_effect_max_axis_amount_reached[scale_axis] = 1

func handle_scale_shrink(scale_axis, scale_shrink_target_axis, speed):
	if rect_scale[scale_axis] >= scale_shrink_target_axis:
		rect_scale[scale_axis] -= speed
		
		if rect_scale[scale_axis] <= scale_shrink_target_axis:
			rect_scale[scale_axis] = scale_shrink_target_axis
			scale_shrink_target_axis_reached[scale_axis] = 1


func idle(_delta):
	pass

func pop(delta):
	handle_pop_scale(
		0, pop_scale_end_amount.x, pop_scale_max_amount.x,
		delta * pop_speed
	)
	
	handle_pop_scale(
		1, pop_scale_end_amount.y, pop_scale_max_amount.y,
		delta * pop_speed
	)

func shrink(delta):
	handle_scale_shrink(
		0, scale_shrink_target.x, 
		delta * shrink_speed
	)
	
	handle_scale_shrink(
		1, scale_shrink_target.y, 
		delta * shrink_speed
	)
	
	if scale_shrink_target_axis_reached.x and scale_shrink_target_axis_reached.y:
		pop_effect_max_axis_amount_reached = Vector2.ZERO
		scale_shrink_target_axis_reached = Vector2.ZERO
		
		action = "idle"


func start_pop():
	action = "pop"

func start_shrink():
	action = "shrink"


func on_mouse_entered_modulate():
	modulate = hover_color_on_hover

func on_mouse_entered_texture():
	glow_node_texture_hover.self_modulate = hover_color_on_hover
		
func on_mouse_entered_font():
	self_modulate = hover_color_on_hover

func on_mouse_entered_pop_shrink():
	start_pop()


func on_mouse_exited_modulate():
	modulate = hover_base_color
	
func on_mouse_exited_texture():
	glow_node_texture_hover.self_modulate = hover_base_color
		
func on_mouse_exited_font():
	self_modulate = hover_base_color

func on_mouse_exited_pop_shrink():
	start_shrink()


func on_Button_down_texture():
	glow_node_texture_interact.self_modulate = on_interact_color_on_interaction
	
func on_Button_down_font():
	self_modulate = on_interact_color_on_interaction


func on_Button_up_texture():
	glow_node_texture_interact.self_modulate = on_interact_base_color

func on_Button_up_font():
	self_modulate = on_interact_base_color
