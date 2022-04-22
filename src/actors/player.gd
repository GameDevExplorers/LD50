extends KinematicBody2D

const BULLET_DAMAGE_MOD = 30
const AMMO_COUNT_MOD = 1
const HEAL_AMOUNT = 30
const ALLIES = ["player", "Turret"]

export (int) var level = 1
export (int) var speed = 200
export (int) var health = 400
export (int) var max_health = 400

var primary_bullet_spread: int = 4
var primary_bullet_count: int = 1
var primary_weapon_cooldown: float = 0.25
var primary_ready = true

var secondary_bullet_spread: int = 5
var secondary_bullet_count: int = 5
var secondary_weapon_cooldown: float = 2
var secondary_ready = true

var bullet_speed = 850
var bullet_damage = 30
var bullet_size: float = 1.0

var available_turrets = 3
var turret_bullet_type = "none"
var turret_bullet_size: float = 1.0

var blood_loss = 0
var has_shield = false

var invincible = false

var MASS_FACTOR: float = 5.0

var velocity:Vector2 = Vector2()
var roll_vector:Vector2 = Vector2.ZERO
var cross_hair:Vector2 = Vector2()

var Bullet = load("res://src/objects/bullet.tscn")
var Sword = load("res://src/objects/sword_root.tscn")
var Casing = load("res://src/objects/casing.tscn")
var Turret = load("res://src/objects/Turret.tscn")

enum Action {
	MOVE,
	ROLL
}

enum Weapon {
	GUN,
	SWORD
}

var action_state = Action.MOVE
var weapon_state = Weapon.GUN

onready var anim = $PlayerAnimation
onready var player_shadow = $PlayerAnimation/PlayerShadow
onready var health_bar = $Healthbar

## For Boons
# Idle Heal
var has_idle_heal_boon = false
var idle_time_limit = 3
var idle_heal_amount = 0
var is_idle = false

# Thorns
var has_thorns = false

# Sword
var slash_frame = "slash2"

# Piercing
var has_piercing = false
var piercing_amount = 0


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


func _physics_process(delta):
	get_input()
	match action_state:
		Action.MOVE:
			move_state()

		Action.ROLL:
			roll_state()

	var collision = move_and_collide(velocity * delta)
	if collision && collision.collider.is_in_group("movable"):
		collision.collider.move_and_slide(velocity * Utils.calculate_resistance(self, collision.collider))

	Game.player_location = global_position
	if health <= 0:
		game_over()


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
		set_idle_timer()
	if Input.is_action_pressed("left"):
		input_vector.x -= 1
		set_idle_timer()
	if Input.is_action_pressed("down"):
		input_vector.y += 1
		set_idle_timer()
	if Input.is_action_pressed("up"):
		input_vector.y -= 1
		set_idle_timer()

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
		action_state = Action.ROLL
	


func roll_state():
	velocity = roll_vector.normalized() * speed * 1.75
	handle_attack()
	anim.play("roll")
	invincible = true
	modulate = Color.gray
	yield(anim, "animation_finished")
	action_state = Action.MOVE
	invincible = false
	modulate = Color.white


func handle_attack():
	match weapon_state:
		Weapon.GUN:
			handle_gun_attack()
		Weapon.SWORD:
			handle_sword_attack()

func handle_gun_attack() -> void:
	if Input.is_action_just_pressed("fire") && primary_ready:
		$BulletSpawn/MuzzleFlash.frame = 1
		primary_ready = false

		$GunFire.play()
		yield(get_tree().create_timer(0.05), "timeout")
		if primary_bullet_count > 1:
			for _i in range(primary_bullet_count):
				fire_projectile(rand_range(-primary_bullet_spread, primary_bullet_spread))
		else:
			fire_projectile(0)
		$BulletSpawn/MuzzleFlash.frame = 0
		yield(get_tree().create_timer(primary_weapon_cooldown), "timeout")
		primary_ready = true


	if Input.is_action_just_released("alt_fire") && secondary_ready:
		$BulletSpawn/MuzzleFlash.frame = 0
		secondary_ready = false

		for _i in range(secondary_bullet_count):
			$GunFire.play()
			fire_projectile(rand_range(-secondary_bullet_spread, secondary_bullet_spread))
			$BulletSpawn/MuzzleFlash.frame = 1
			yield(get_tree().create_timer(0.03), "timeout")
			$BulletSpawn/MuzzleFlash.frame = 0

		yield(get_tree().create_timer(secondary_weapon_cooldown), "timeout")
		$GunReload.play()
		yield(get_tree().create_timer(0.1), "timeout")
		secondary_ready = true

func fire_projectile(offset:float):
	if health <= 1:
		return

	drop_casing()
	show_bullet(offset)

	health -= blood_loss
	health_bar.set_health(health)


func drop_casing() -> void:
	var casing = Casing.instance()
	casing.position = $CasingSpawn.global_position
	if scale.x == -1:
		casing.flip_h = true
	$CasingContainer.add_child(casing)


func show_bullet(offset) -> void:
	$BulletSpawn/MuzzleFlash.frame = 0
	var bullet = Bullet.instance()
	bullet.set_animation("default")
	bullet.start(
		$BulletSpawn.global_position,
		get_angle_to(cross_hair) + deg2rad(offset),
		self,
		bullet_speed,
		bullet_damage,
		bullet_size,
		[Game.Masks.MOB, Game.Masks.BOSS]
	)
	get_parent().add_child(bullet)


func handle_sword_attack() -> void:
	if Input.is_action_just_pressed("fire") && primary_ready:
		primary_ready = false

		var sword = Sword.instance()
		slash_sword(sword, bullet_damage * 2)
		add_child(sword)
		yield(get_tree().create_timer(primary_weapon_cooldown), "timeout")
		primary_ready = true

	if Input.is_action_just_released("alt_fire") && secondary_ready:
		secondary_ready = false

		var sword = Sword.instance()
		slash_sword(sword, bullet_damage * 10)
		add_child(sword)
		yield(get_tree().create_timer(secondary_weapon_cooldown), "timeout")
		secondary_ready = true


func slash_sword(sword, dmg) -> void:
	sword.start(
		get_global_mouse_position().angle_to_point(position),
		self,
		dmg,
		bullet_size,
		[Game.Masks.MOB, Game.Masks.BOSS]
	)


func place_turret():
	if available_turrets > 0:
		var turret = Turret.instance()
		turret.init(turret_bullet_type, turret_bullet_size)
		turret.position = $TurretSpawn.global_position
		$TurretContainer.add_child(turret)
		available_turrets -= 1
		$"../CanvasLayer/hud/HBoxContainer2/AvailableTurrets".text = "Available Turrets: " + str(available_turrets)


func heal() -> void:
	health = health + HEAL_AMOUNT
	if health > max_health:
		health = max_health
	health_bar.set_health(health)


func damage_up() -> void:
	bullet_damage += BULLET_DAMAGE_MOD
	secondary_bullet_spread += 1


func ammo_up() -> void:
	secondary_bullet_count += secondary_bullet_count
	secondary_bullet_spread += 1


func is_ally(source) -> bool:
	return source.is_in_group("ally")


func hit(source = null, weapon = null, damage = 0, _knockback = false) -> void:
	take_damage(damage)
	# TODO: prevent ranged from taking thorn damage
	has_thorns = true
	if has_thorns && weapon.damage_type == "melee":
		source.take_damage(damage * .5)


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


func set_idle_timer() -> void:
	if has_idle_heal_boon:
		$IdleTimer.start(idle_time_limit)
		is_idle = false


func _on_IdleTimer_timeout():
	is_idle = true
	$IdleTimer.stop()
	while is_idle:
		if health < max_health:
			health += idle_heal_amount
			health_bar.set_health(health)
			print(health)
		yield(get_tree().create_timer(1), "timeout")
