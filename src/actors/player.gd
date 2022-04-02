extends KinematicBody2D

export (int) var speed = 200
export (int) var spread = 10

var Bullet = load("res://src/objects/bullet.tscn")
var velocity:Vector2 = Vector2()

func get_input():
	look_at(get_global_mouse_position())
	velocity = Vector2()
	if Input.is_action_pressed("right"):
		velocity.x += 1
	if Input.is_action_pressed("left"):
		velocity.x -= 1
	if Input.is_action_pressed("down"):
		velocity.y += 1
	if Input.is_action_pressed("up"):
		velocity.y -= 1
	velocity = velocity.normalized() * speed
	if Input.is_action_just_released("fire"):
		fire_projectile(spread)
		fire_projectile(spread * -1)
		fire_projectile(0)

func _physics_process(delta):
	Game.player_location = position
	get_input()
	velocity = move_and_slide(velocity)
	Game.player_location = global_position

func fire_projectile(offset:int):
	var b = Bullet.instance()
	b.start($BulletSpawn.global_position, rotation + deg2rad(offset))
	get_parent().add_child(b)
