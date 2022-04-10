extends KinematicBody2D

export (int) var speed = 200
export (int) var spread = 10
export (int) var health = 400
export (int) var max_health = 400

var Bullet = load("res://src/objects/bullet.tscn")
var Casing = load("res://src/objects/casing.tscn")
var velocity:Vector2 = Vector2()
var ready_to_fire = true
var invincible = false

var cross_hair:Vector2 = Vector2()

onready var health_bar = $Healthbar

func _ready():
	health_bar.set_max_health(max_health)
	health_bar.set_health(health)
	cross_hair = get_global_mouse_position()
	var _i = get_parent().connect("demon_summoned", self, "_on_demon_summoned")
	var _x = get_parent().connect("repair_tick", self, "_on_repair_tick")

func _process(_delta):
	handle_directional_camera()
	if get_global_mouse_position().x < global_position.x:
		$AnimatedSprite.flip_h = true
		$BulletSpawn.position.x = -22
		$BulletSpawn/MuzzleFlash.flip_h = true
		$BulletSpawn/MuzzleFlash.position.x = -20
		$AnimatedSprite/Sprite.position.x = 2
	else:
		$AnimatedSprite.flip_h = false
		$BulletSpawn.position.x = 22
		$BulletSpawn/MuzzleFlash.flip_h = false
		$BulletSpawn/MuzzleFlash.position.x = 20
		$AnimatedSprite/Sprite.position.x = -3

func _on_demon_summoned():
	add_child(health_bar)


func _on_repair_tick():
	if health > 1:
		health -= 1
		health_bar.set_health(health)


func handle_directional_camera():
	var x = (get_global_mouse_position().x - global_position.x) / 10
	var y = (get_global_mouse_position().y - global_position.y) / 10
	$Camera2D.offset.x = x
	$Camera2D.offset.y = y


func get_input():
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

	if invincible:
		return

	if Input.is_action_just_pressed("fire"):
		$BulletSpawn/MuzzleFlash.frame = 1
		$GunFire.play()
		yield(get_tree().create_timer(0.05), "timeout")
		fire_projectile(0)
		$BulletSpawn/MuzzleFlash.frame = 0


	if Input.is_action_just_released("alt_fire") && ready_to_fire:
		$BulletSpawn/MuzzleFlash.frame = 0
		ready_to_fire = false
		$GunAltFire.play()
		yield(get_tree().create_timer(0.1), "timeout")
		fire_projectile(0)
		fire_projectile(spread / 3)
		$BulletSpawn/MuzzleFlash.frame = 1
		yield(get_tree().create_timer(0.05), "timeout")
		$BulletSpawn/MuzzleFlash.frame = 0
		fire_projectile(spread / 2)
		yield(get_tree().create_timer(0.05), "timeout")
		fire_projectile((spread / 2) * -1)
		yield(get_tree().create_timer(0.05), "timeout")
		fire_projectile(spread * -1)
		yield(get_tree().create_timer(0.05), "timeout")
		fire_projectile(spread)
		yield(get_tree().create_timer(0.05), "timeout")
		fire_projectile(0)
		fire_projectile((spread / 3) * -1)

func _physics_process(delta):
	# var direction: Vector2 = Input.get_vector("nav-left", "nav-right", "nav-down", "nav-up")

	# var movement = direction * delta * 500
	# if (movement):
		# cross_hair += movement
		# get_viewport().warp_mouse(cross_hair)
		# print("movement: ", movement)

	get_input()
	if velocity.length_squared() > 0:
		if $Walk.playing == false:
			$Walk.play()
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()
		$AnimatedSprite.frame = 0

	velocity = move_and_slide(velocity)
	Game.player_location = global_position
	if health <= 0:
		var result = get_tree().change_scene("res://game_over.tscn")
		if result != OK:
			print_debug("Failed to change scene: " + result)

func fire_projectile(offset:int):
	if health <= 1:
		return
	var c = Casing.instance()
	c.position = $CasingSpawn.global_position
	if $AnimatedSprite.flip_h == true:
		c.flip_h = true
	$CasingContainer.add_child(c)
	$BulletSpawn/MuzzleFlash.frame = 0
	var b = Bullet.instance()
	b.start($BulletSpawn.global_position, get_angle_to(get_global_mouse_position()) + deg2rad(offset), "player")
	get_parent().add_child(b)
	health -= 1
	health_bar.set_health(health)


func _on_GunFire_finished():
	$GunReload.play()

func _on_GunReload_finished():
	ready_to_fire = true

func heal() -> void:
	health = health + 30
	if health > max_health:
		health = max_health
	health_bar.set_health(health)

func take_damage(damage) -> void:
	$Hit.play()
	invincible = true
	health = health - damage
	health_bar.set_health(health)

	modulate = Color.white
	yield(get_tree().create_timer(0.1), "timeout")
	modulate = Color.red
	yield(get_tree().create_timer(0.1), "timeout")
	modulate = Color.white

	if health <= 0:
		var result = get_tree().change_scene("res://game_over.tscn")
		if result != OK:
			print_debug("Failed to change scene: " + result)
	else:
		yield(get_tree().create_timer(0.1), "timeout")
		modulate = Color.red
		yield(get_tree().create_timer(0.1), "timeout")
		modulate = Color.gray
		yield(get_tree().create_timer(0.25), "timeout")
		modulate = Color.white
		invincible = false

func _on_BulletCollider_body_entered(body: Node) -> void:
	if body.get("damage") && body.get("spawned_by") != "player":
		body.queue_free()
		if invincible == false:
			take_damage(body.get("damage"))
