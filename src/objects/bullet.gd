extends KinematicBody2D

var speed = 750
var velocity = Vector2()

func start(pos, dir, bullet_speed = speed):
	rotation = dir
	position = pos
	speed    = bullet_speed
	velocity = Vector2(speed, 0).rotated(rotation)

func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.normal)
		if collision.collider.has_method("hit"):
			collision.collider.hit()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
