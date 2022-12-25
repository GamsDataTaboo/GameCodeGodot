extends Area2D


export (Array, String)var target_groups = []
export (float)var power = 1.0
export (bool)var random_power = true
export (float)var power_varience = 0.2

export (bool)var slow_object_on_hit = false
var slow_percent = 0.40

export (bool)var boost_damage_over_time = false
var damage_growth_rate_percent = 0.25
var base_damage = 0

export (bool)var grow_over_time = false
var collision_shape_2d_shape = null
var animated_sprite_scale = null
var size_growth_rate_percent = 0.50
var base_scale = Vector2.ZERO
var base_collision_radius = 1
var base_collision_height = 1


export (String)var slow_object_method_name = "reduce_speed"
export (String)var flag_object_as_slowed_method_name = "set_slowed"
export (String)var effect_method_name = "take_damage"


func scale_by_percent(new_scale):
	collision_shape_2d_shape = $CollisionShape2D.shape
	animated_sprite_scale = $AnimatedSprite.scale
	
	base_collision_radius =	collision_shape_2d_shape.radius
	base_collision_height =	collision_shape_2d_shape.height
	
	collision_shape_2d_shape = CapsuleShape2D.new()
	collision_shape_2d_shape.radius = base_collision_radius * new_scale
	collision_shape_2d_shape.height = base_collision_height * new_scale
	
	animated_sprite_scale *= new_scale


func _on_ImpulseDamage_body_entered(body):
	if slow_object_on_hit:
		if( body.has_method(slow_object_method_name) ):
			if(!body.is_slowed):
				body.call(slow_object_method_name, slow_percent)
				body.call(flag_object_as_slowed_method_name, true)
	
	if( body.has_method(effect_method_name) ):
		if random_power:
			var randomized_power = 0
			
			randomized_power = power * ( 1 + rand_range(-power_varience, power_varience) )
			randomized_power = round(randomized_power)
				
			body.call(effect_method_name, randomized_power)
			
		else:
			body.call(effect_method_name, power)


func _on_DespawnTimer_timeout():
	queue_free()
