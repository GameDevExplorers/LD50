extends KinematicBody2D

export (int) var speed = 200
export (int) var spread = 5
export (int) var health = 400
export (int) var max_health = 400

var bullet_speed = 850
var bullet_damage = 30
var ammo_count = 5

const BULLET_DAMAGE_MOD = 30
const AMMO_COUNT_MOD = 1
const RELOAD_TIMER = 0.5
const HEAL_AMOUNT = 30
var ALLIES = ["player", "turret"]

var Bullet = load("res://src/objects/bullet.tscn")
var Casing = load("res://src/objects/casing.tscn")
var Turret = load("res://src/objects/turret.tscn")
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
	if cross_hair.x < global_position.x:
		anim.flip_h = true
		player_shadow.position.x = 2
	else:
		anim.flip_h = false
		player_shadow.position.x = -3

	if fmod($BulletSpawn.rotation_degrees, 360) > 90 && fmod($BulletSpawn.rotation_degrees, 360) < 270:
		$BulletSpawn/Gun.flip_v = true
	else:
		$BulletSpawn/Gun.flip_v = false

	if fmod($BulletSpawn.rotation_degrees, 360) < 0 && fmod($BulletSpawn.rotation_degrees, 360) > -140:
		$BulletSpawn/Gun.z_index = -1
	else:
		$BulletSpawn/Gun.z_index = 1

func _on_demon_summoned():
	add_child(health_bar)


func _on_repair_tick():
	if health > 1:
		health -= 1
		health_bar.set_health(health)

func _input(event):
	if event is InputEventMouseMotion:
		$CrosshairContainer.visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		cross_hair = get_global_mouse_position()


func get_input():
	var input = Input.get_vector("nav-left", "nav-right", "nav-up", "nav-down")
	if input:
		$CrosshairContainer.visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		cross_hair = $CrosshairContainer/Crosshair.global_position
		$CrosshairContainer.look_at(input + global_position)

	$BulletSpawn.look_at(cross_hair)
	velocity = Vector2()


func handle_directional_camera():
	if $CrosshairContainer.visible == true:
		return
	var x = (cross_hair.x - global_position.x) / 10
	var y = (cross_hair.y - global_position.y) / 10
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

	if Input.is_action_just_pressed("special"):
		place_turret()

	if Input.is_action_just_pressed("roll"):
		state = ROLL

func roll_state():
	velocity = roll_vector.normalized() * speed * 1.75
	handle_attack()
	anim.play("roll")
	invincible = true
	modulate = Color.gray
	yield(anim, "animation_finished")
	state = MOVE
	invincible = false
	modulate = Color.white


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

		for _i in range(ammo_count):
			$GunFire.play()
			fire_projectile(rand_range(-spread, spread))
			$BulletSpawn/MuzzleFlash.frame = 1
			yield(get_tree().create_timer(0.03), "timeout")
			$BulletSpawn/MuzzleFlash.frame = 0

		yield(get_tree().create_timer(RELOAD_TIMER), "timeout")
		$GunReload.play()
		yield(get_tree().create_timer(0.1), "timeout")
		ready_to_fire = true

func _physics_process(_delta):
	get_input()
	match state:
		MOVE:
			move_state()

		ROLL:
			roll_state()

	velocity = move_and_slide(velocity)
	Game.player_location = global_position
	if health <= 0:
		game_over()


func place_turret():
	var turret = Turret.instance()
	turret.position = $TurretSpawn.global_position
	$TurretContainer.add_child(turret)


func fire_projectile(offset:float):
	if health <= 1:
		return

	drop_casing()
	show_bullet(offset)

	health -= 1
	health_bar.set_health(health)


func drop_casing() -> void:
	var casing = Casing.instance()
	casing.position = $CasingSpawn.global_position
	if anim.flip_h == true:
		casing.flip_h = true
	$CasingContainer.add_child(casing)


func show_bullet(offset) -> void:
	$BulletSpawn/MuzzleFlash.frame = 0
	var bullet = Bullet.instance()
	bullet.start(
		$BulletSpawn.global_position,
		get_angle_to(cross_hair) + deg2rad(offset),
		"player",
		bullet_speed,
		bullet_damage
	)
	get_parent().add_child(bullet)


func heal() -> void:
	health = health + HEAL_AMOUNT
	if health > max_health:
		health = max_health
	health_bar.set_health(health)


func damage_up() -> void:
	bullet_damage += BULLET_DAMAGE_MOD
	spread += 1


func ammo_up() -> void:
	ammo_count += AMMO_COUNT_MOD
	spread += 1


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


func game_over() -> void:
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
	if body.get("damage") && !ALLIES.has(body.get("spawned_by")):
		if invincible == false:
			body.queue_free()
			take_damage(body.get("damage"))

