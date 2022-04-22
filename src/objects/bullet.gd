extends KinematicBody2D

export var damage: = 30
var spawned_by
var speed = 850
var size = 1.0
var velocity = Vector2()
var target = Vector2();
var piercing_amount = 0
var damage_type = "ranged"
var knockback = false

func start(pos, dir, spawner, bullet_speed = speed, dam = damage, bullet_size = size, masks = []):
	rotation = dir
	position = pos
	speed    = bullet_speed
	damage   = dam
	spawned_by = spawner
	z_index = 3
	size = bullet_size
	velocity = Vector2(speed, 0).rotated(rotation)
	set_mask(masks)
	match spawned_by.get_name():
		"player":
			scale = Vector2(size, size)
		"turret":
			scale = Vector2(size, size)
		"Demon":
			var ran = rand_range(1.5, 2.0)
			scale = Vector2(ran, ran)
	

func set_animation(anim: String):
	$AnimatedSprite.animation = anim


func set_velocity(vel: Vector2):
	velocity = vel * speed


func set_mask(masks: Array) -> void:
	for m in masks:
		get_node("Hitbox").set_collision_mask_bit(m, true)


func set_target(pos: Vector2):
	target = pos
	velocity = global_position.direction_to(pos) * speed


func _physics_process(delta):
	if spawned_by.get_name() == "Demon":
		rotation += 25 * delta
	move_and_collide(velocity * delta, false)


func can_pierce() -> bool:
	return spawned_by.has_piercing && piercing_amount <= spawned_by.piercing_amount

func take_damage(_damage) -> void:
	pass


func is_from_self_or_ally(body) -> bool:
	return spawned_by.is_ally(body)


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_Timer_timeout():
	if spawned_by.get_name() != "Demon":
		queue_free()


func _on_Hitbox_body_entered(body):
	if is_from_self_or_ally(body): #prevents people from shooting themselves
		return
	piercing_amount += 1
	body.hit(spawned_by, self, damage, knockback)
	if can_pierce():
		pass
	else:
		queue_free()
