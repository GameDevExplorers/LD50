extends KinematicBody2D

export (int) var speed = 200
export (int) var spread = 10

var Bullet = load("res://src/objects/bullet.tscn")
var velocity:Vector2 = Vector2()
var ready_to_fire = true

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
	if Input.is_action_just_released("fire") && ready_to_fire:
		ready_to_fire = false
		$GunFire.play()
		yield(get_tree().create_timer(0.1), "timeout")
		fire_projectile(0)
		yield(get_tree().create_timer(0.05), "timeout")
		fire_projectile(spread / 2)
		yield(get_tree().create_timer(0.05), "timeout")
		fire_projectile((spread / 2) * -1)
		yield(get_tree().create_timer(0.05), "timeout")
		fire_projectile(spread * -1)
		yield(get_tree().create_timer(0.05), "timeout")
		fire_projectile(spread)
		yield(get_tree().create_timer(0.05), "timeout")
		fire_projectile(0)

func _physics_process(delta):
	get_input()
	if velocity.length_squared() > 0 && $Walk.playing == false:
		$Walk.play()
	velocity = move_and_slide(velocity)
	Game.player_location = global_position

func fire_projectile(offset:int):
	var b = Bullet.instance()
	b.start($BulletSpawn.global_position, rotation + deg2rad(offset))
	get_parent().add_child(b)


func _on_GunFire_finished():
	$GunReload.play()


func _on_GunReload_finished():
	ready_to_fire = true


func _on_Walk_finished():
	pass
