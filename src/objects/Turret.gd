extends KinematicBody2D

var bullet_speed = 850
var bullet_damage = 60
var fire_speed = 1

var Bullet = load("res://src/objects/bullet.tscn")
var Casing = load("res://src/objects/casing.tscn")

var cross_hair:Vector2 = Vector2()
var can_fire = true

onready var anim = $TurretAnimation

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(_delta):
	if can_fire:
		fire_projectile(1)

	if cross_hair.x < global_position.x:
		anim.frame = 2
	else:
		anim.frame = 0

func fire_projectile(offset:float):
	cross_hair = get_global_mouse_position()
	can_fire = false
	drop_casing()
	show_bullet(offset)
	yield(get_tree().create_timer(0.5), "timeout")
	can_fire = true


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
		"turret",
		bullet_speed,
		bullet_damage
	)
	get_parent().add_child(bullet)

