extends Label


var state = "idle"

enum modes {MOVE_AND_FADE_OVER_TIME}
export (modes)var mode = modes.MOVE_AND_FADE_OVER_TIME

export (Vector2)var move_speed = Vector2.ZERO

export (bool)var use_pop_effect = false
var pop_effect_max_amount_reached = Vector2(0, 0)
export (float)var pop_speed = 2.5
export (Vector2)var pop_scale_start_amount = Vector2(0.5, 0.5)
export (Vector2)var pop_scale_max_amount = Vector2(1, 1)
export (Vector2)var pop_scale_end_amount = Vector2(0.5, 0.5)

export (float)var time_before_fade_start = 0.1
export (float)var fade_rate = 0.0


func _ready():
	if use_pop_effect:
		rect_scale = pop_scale_start_amount
		rect_pivot_offset = rect_size / 2
	
	match mode:
		modes.MOVE_AND_FADE_OVER_TIME:
			state = "move_and_fade_over_time"

func _process(delta):
	call(state, delta)


func handle_pop_scale(scale_axis, pop_scale_end_amount_axis, pop_scale_max_amount_axis, speed):
	if use_pop_effect:
		if pop_effect_max_amount_reached[scale_axis]:
			if rect_scale[scale_axis] > pop_scale_end_amount_axis:
				rect_scale[scale_axis] -= speed
				
				if rect_scale[scale_axis] <= pop_scale_end_amount_axis:
					rect_scale[scale_axis] = pop_scale_end_amount_axis
					
					if pop_effect_max_amount_reached.x and pop_effect_max_amount_reached.y:
						use_pop_effect = false
		
		elif rect_scale[scale_axis] < pop_scale_max_amount_axis:
			rect_scale[scale_axis] += speed
			
			if rect_scale[scale_axis] >= pop_scale_max_amount_axis:
				rect_scale[scale_axis] = pop_scale_max_amount_axis
				pop_effect_max_amount_reached[scale_axis] = 1
				
				
func fade(delta):
	self_modulate.a -= fade_rate * delta
	
	if self_modulate.a <= 0:
		queue_free()

func move(delta):
	rect_position += move_speed * delta


func idle(_delta):
	pass

func move_and_fade_over_time(delta):
	handle_pop_scale(0, pop_scale_end_amount.x, pop_scale_max_amount.x, delta * pop_speed)
	handle_pop_scale(1, pop_scale_end_amount.y, pop_scale_max_amount.y, delta * pop_speed)
	
	move(delta)
	time_before_fade_start -= delta
	
	if time_before_fade_start <= 0:
		fade(delta)


func change_text_to(new_text):
	text = str(new_text)
