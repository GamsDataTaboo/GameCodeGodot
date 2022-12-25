extends TextureRect


signal on_button_pressed


var title = null
var message = null

var action = "wait"

var pop_effect_max_axis_amount_reached = Vector2(0, 0)
export (float)var pop_speed = 4.0
export (Vector2)var pop_scale_start_amount = Vector2(0.33, 0.33)
export (Vector2)var pop_scale_max_amount = Vector2(1.1, 1.1)
export (Vector2)var pop_scale_end_amount = Vector2(1.0, 1.0)

var scale_shrink_target_axis_reached = Vector2(0, 0)
export (Vector2)var scale_shrink_target = Vector2(0.33, 0.33)
export (float)var shrink_speed = 3.0


func _ready():
	title = $Title
	message = $Message
	
	rect_scale = pop_scale_start_amount
	rect_pivot_offset = rect_size / 2

func _process(delta):
	call(action, delta)


func wait(_delta):
	pass

func handle_pop_scale(
	scale_axis, pop_scale_end_amount_axis, pop_scale_max_amount_axis,
	speed
):
	if pop_effect_max_axis_amount_reached[scale_axis]:
		if rect_scale[scale_axis] > pop_scale_end_amount_axis:
			rect_scale[scale_axis] -= speed
			
			if rect_scale[scale_axis] < pop_scale_end_amount_axis:
				rect_scale[scale_axis] = pop_scale_end_amount_axis
	
	elif rect_scale[scale_axis] < pop_scale_max_amount_axis:
		rect_scale[scale_axis] += speed
		
		if rect_scale[scale_axis] >= pop_scale_max_amount_axis:
			rect_scale[scale_axis] = pop_scale_max_amount_axis
			pop_effect_max_axis_amount_reached[scale_axis] = 1

func handle_scale_shrink(scale_axis, scale_shrink_target_axis, speed):
	if rect_scale[scale_axis] > scale_shrink_target_axis:
		rect_scale[scale_axis] -= speed
		
		if rect_scale[scale_axis] <= scale_shrink_target_axis:
			rect_scale[scale_axis] = scale_shrink_target_axis
			scale_shrink_target_axis_reached[scale_axis] = 1


func pop_effect(delta):
	show()
	
	handle_pop_scale(
		0, pop_scale_end_amount.x, pop_scale_max_amount.x,
		delta * pop_speed
	)
	
	handle_pop_scale(
		1, pop_scale_end_amount.y, pop_scale_max_amount.y,
		delta * pop_speed
	)
	
func shrink_and_close(delta):
	handle_scale_shrink(
		0, scale_shrink_target.x, 
		delta * shrink_speed
	)
	
	handle_scale_shrink(
		1, scale_shrink_target.y, 
		delta * shrink_speed
	)
	
	if scale_shrink_target_axis_reached.x and scale_shrink_target_axis_reached.y:
		hide()
		rect_scale = pop_scale_start_amount
	
		pop_effect_max_axis_amount_reached = Vector2.ZERO
		scale_shrink_target_axis_reached = Vector2.ZERO
		
		action = "wait"


func start_pop_effect():
	action = "pop_effect"

func start_shrink_and_close():
	action = "shrink_and_close"


func _on_Button_pressed():
	emit_signal("on_button_pressed")
