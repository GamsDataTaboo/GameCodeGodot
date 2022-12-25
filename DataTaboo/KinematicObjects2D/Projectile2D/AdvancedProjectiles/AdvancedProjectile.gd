extends "res://DataTaboo/KinematicObjects2D/Projectile2D/Projectile2D.gd"


export (bool)var random_power = true
export (float)var power_varience = 0.2

export (bool)var slow_object_on_hit = false
var slow_percent = 0.40

export (bool)var boost_damage_over_time = false
var damage_growth_rate_percent = 0.15
var base_damage = 0

export (int)var bounce_limit = 3

export (bool)var grow_over_time = false
var size_growth_rate_percent = 0.25
var growth_percent_scaled_by = 1.0
var base_scale = Vector2.ZERO

var physicis_collision_shape = null
var base_collision_radius = 1
var base_collision_height = 1

var virtual_collision_shape = null
var base_virtual_collision_radius = 1
var base_virtual_collision_height = 1

export (bool)var explodes_on_impact = false
export (PackedScene)var explosion = null

export (String)var slow_object_method_name = "reduce_speed"
export (String)var flag_object_as_slowed_method_name = "set_slowed"


func _ready():
	base_damage += power
	base_scale = $AnimatedSprite.scale
	
	
	physicis_collision_shape = $CollisionShape2D
	base_collision_radius = physicis_collision_shape.shape.radius
	base_collision_height = physicis_collision_shape.shape.height

	physicis_collision_shape.shape = CapsuleShape2D.new()
	physicis_collision_shape.shape.radius = base_collision_radius
	physicis_collision_shape.shape.height = base_collision_height
	
	
	virtual_collision_shape = $Area2D/CollisionShape2D
	base_virtual_collision_radius = virtual_collision_shape.shape.radius
	base_virtual_collision_height = virtual_collision_shape.shape.height
	
	virtual_collision_shape.shape = CapsuleShape2D.new()
	virtual_collision_shape.shape.radius = base_virtual_collision_radius
	virtual_collision_shape.shape.height = base_virtual_collision_height
	
	
	._ready()

func _process(delta):
	if boost_damage_over_time:
		power += base_damage * damage_growth_rate_percent * delta
		
	if grow_over_time:
		$AnimatedSprite.scale += base_scale * size_growth_rate_percent * delta
		
		physicis_collision_shape.shape.radius += \
			base_collision_radius * size_growth_rate_percent * delta
		physicis_collision_shape.shape.height += \
			base_collision_height * size_growth_rate_percent * delta
		
		virtual_collision_shape.shape.radius += \
			base_collision_radius * size_growth_rate_percent * delta
		virtual_collision_shape.shape.height += \
			base_collision_height * size_growth_rate_percent * delta
		
		growth_percent_scaled_by += size_growth_rate_percent * delta


func handle_collision(collider):
	var impact_power = power
	
	if(collider.has_method(impact_method)):
		if random_power:
			impact_power = power * ( 1 + rand_range(-power_varience, power_varience) )
			impact_power = round(impact_power)

	if explodes_on_impact:
		var new_explosion = explosion.instance()
		
		new_explosion.position = global_position
		new_explosion.power = impact_power
		new_explosion.slow_object_on_hit = slow_object_on_hit
		new_explosion.scale_by_percent(growth_percent_scaled_by)
		
		get_parent().call_deferred("add_child", new_explosion)
		
	else:
		if slow_object_on_hit:
			if collider.has_method("reduce_speed"):
				if !collider.is_slowed:
					collider.reduce_speed(slow_percent)
					collider.set_slowed(true)
		
		if collider.has_method(impact_method):
			collider.call(impact_method, impact_power)

	if bounce:
		if bounce_limit > 0:
			global_rotation -= 180
			bounce_limit -= 1
		
		else:
			destroy()

	else:
		destroy()


func _on_Projectile2D_collided(collision):
	handle_collision(collision.collider)

func _on_Projectile2D_virtual_collided(body):
	handle_collision(body)
