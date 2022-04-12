extends KinematicBody2D

export var damage: = 30
export var spawned_by: = ""
var speed = 850
var velocity = Vector2()
var target = Vector2();

func start(pos, dir, spawner, bullet_speed = speed, dam = damage):
	rotation = dir
	position = pos
	speed    = bullet_speed
	damage   = dam
	spawned_by = spawner
	z_index = 3
	velocity = Vector2(speed, 0).rotated(rotation)
	if spawned_by == "demon":
		var ran = rand_range(0.5, 2.0)
		scale = Vector2(1 * ran, 1 * ran)


func set_animation(anim: String):
	$AnimatedSprite.animation = anim


func set_velocity(vel: Vector2):
	velocity = vel * speed


func set_target(pos: Vector2):
	target = pos
	velocity = global_position.direction_to(pos) * speed


func _physics_process(delta):
	if spawned_by == "demon":
		rotation += 25 * delta
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.normal)
		if collision.collider.has_method("hit"):
			collision.collider.hit()


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_Timer_timeout():
	if spawned_by != "demon":
		queue_free()


func _on_Hitbox_body_entered(body):
	print(body)
