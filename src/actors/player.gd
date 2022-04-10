extends KinematicBody2D

export (int) var speed = 200
export (int) var spread = 10
export (int) var health = 400
export (int) var max_health = 400

var Bullet = load("res://src/objects/bullet.tscn")
var Casing = load("res://src/objects/casing.tscn")
var velocity:Vector2 = Vector2()
var roll_vector:Vector2 = Vector2.ZERO

var ready_to_fire = true
var invincible = false

var cross_hair:Vector2 = Vector2()

enum {
	MOVE,
	ROLL
}

var state = MOVE

onready var anim = $PlayerAnimation
onready var player_shadow = $PlayerAnimation/PlayerShadow
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
		anim.flip_h = true
		$BulletSpawn.position.x = -22
		$BulletSpawn/MuzzleFlash.flip_h = true
		$BulletSpawn/MuzzleFlash.position.x = -20
		player_shadow.position.x = 2
	else:
		anim.flip_h = false
		$BulletSpawn.position.x = 22
		$BulletSpawn/MuzzleFlash.flip_h = false
		$BulletSpawn/MuzzleFlash.position.x = 20
		player_shadow.position.x = -3

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


func move_state():
	var input_vector = Vector2.ZERO
	if Input.is_action_pressed("right"):
		input_vector.x += 1
	if Input.is_action_pressed("left"):
		input_vector.x -= 1
	if Input.is_action_pressed("down"):
		input_vector.y += 1
	if Input.is_action_pressed("up"):
		input_vector.y -= 1
		
	velocity = input_vector.normalized() * speed
	
	if velocity.length_squared() > 0:
		roll_vector = velocity
		if $Walk.playing == false:
			$Walk.play()
		anim.play("move")
	else:
		anim.stop()
		anim.frame = 0

	handle_attack()

	if Input.is_action_just_pressed("roll"):
		state = ROLL

func roll_state():
	velocity = roll_vector.normalized() * speed * 1.75
	handle_attack()
	anim.play("roll")
	invincible = true
	modulate = Color.gray


func handle_attack():
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
	match state:
		MOVE:
			move_state()
		
		ROLL:
			roll_state()
		
	velocity = move_and_slide(velocity)
	Game.player_location = global_position
	if health <= 0:
		game_over()

func fire_projectile(offset:int):
	if health <= 1:
		return

	drop_casing()
	show_bullet(offset)

	health -= 1
	health_bar.set_health(health)

func drop_casing():
	var casing = Casing.instance()
	casing.position = $CasingSpawn.global_position
	if anim.flip_h == true:
		casing.flip_h = true
	$CasingContainer.add_child(casing)

func show_bullet(offset):
	$BulletSpawn/MuzzleFlash.frame = 0
	var bullet = Bullet.instance()
	bullet.start($BulletSpawn.global_position, get_angle_to(get_global_mouse_position()) + deg2rad(offset), "player")
	get_parent().add_child(bullet)

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
		game_over()
	else:
		yield(get_tree().create_timer(0.1), "timeout")
		modulate = Color.red
		yield(get_tree().create_timer(0.1), "timeout")
		modulate = Color.gray
		yield(get_tree().create_timer(0.25), "timeout")
		modulate = Color.white
		invincible = false


func game_over():
	for _i in range(5):
		yield(get_tree().create_timer(0.1), "timeout")
		modulate = Color.red
		yield(get_tree().create_timer(0.1), "timeout")
		modulate = Color.gray
	yield(get_tree().create_timer(0.25), "timeout")
	var result = get_tree().change_scene("res://game_over.tscn")
	if result != OK:
		print_debug("Failed to change scene: " + result)

	
func _on_BulletCollider_body_entered(body: Node) -> void:
	if body.get("damage") && body.get("spawned_by") != "player":
		body.queue_free()
		if invincible == false:
			take_damage(body.get("damage"))


func _on_player_anim_finished() -> void:
	state = MOVE
	invincible = false
	modulate = Color.white

