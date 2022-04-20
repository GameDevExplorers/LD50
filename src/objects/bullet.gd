extends KinematicBody2D

export var damage: = 30
var spawned_by
var speed = 850
var size = 1.0
var velocity = Vector2()
var target = Vector2();
var piercing_amount = 0

func start(pos, dir, spawner, bullet_speed = speed, dam = damage, bullet_size = size):
	rotation = dir
	position = pos
	speed    = bullet_speed
	damage   = dam
	spawned_by = spawner
	z_index = 3
	size = bullet_size
	velocity = Vector2(speed, 0).rotated(rotation)
	match spawned_by.get_name():
		"player":
			scale = Vector2(size, size)
		"Turret":
			scale = Vector2(size, size)
		"Demon":
			var ran = rand_range(0.5, 2.0)
			scale = Vector2(1.0 * ran, 1.0 * ran)
	

func set_animation(anim: String):
	$AnimatedSprite.animation = anim


func set_velocity(vel: Vector2):
	velocity = vel * speed


func set_target(pos: Vector2):
	target = pos
	velocity = global_position.direction_to(pos) * speed


func _physics_process(delta):
	if spawned_by.get_name() == "Demon":
		rotation += 25 * delta
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.normal)
		if collision.collider.has_method("hit"):
			collision.collider.hit(damage)

func can_pierce() -> bool:
	return spawned_by.has_piercing && piercing_amount <= spawned_by.piercing_amount

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_Timer_timeout():
	if spawned_by.get_name() != "Demon":
		queue_free()


func _on_Hitbox_body_entered(body):
	piercing_amount += 1
	print(body)


func hit_triggered():
	if can_pierce():
		pass
	else:
		queue_free()
