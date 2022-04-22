extends KinematicBody2D

var bullet_speed = 850
var bullet_damage = 10
var bullet_size = 1.0
var bullet_type

var fire_speed = .2

var kill_radius = 5

var has_piercing = false

var Bullet = load("res://src/objects/bullet.tscn")
var Casing = load("res://src/objects/casing.tscn")

var cross_hair:Vector2 = Vector2()
var can_fire = true
var target = null
var target_position = Vector2()
var mobs_in_range = []

onready var anim = $TurretAnimation

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func init(turret_bullet_type = "default", turret_bullet_size = bullet_size) -> void:
	bullet_type = turret_bullet_type
	bullet_size = turret_bullet_size


func _process(_delta):
	if can_fire:
		if !is_instance_valid(target):
			remove_dead_mobs()
			assign_new_target()

		if target:
			target_position = target.get_position()
			fire_projectile(1)

	if cross_hair.x < global_position.x:
		anim.frame = 2
	else:
		anim.frame = 0


func hit(_source = null, _weapon = null, _damage = 0, _knockback = false) -> void:
	pass


func remove_dead_mobs() -> void:
	for t in mobs_in_range:
		if !is_instance_valid(t):
			mobs_in_range.erase(t)

func assign_new_target() -> void:
	target = mobs_in_range.front()

func fire_projectile(offset:float):
	cross_hair = target_position
	can_fire = false
	drop_casing()
	show_bullet(offset)
	yield(get_tree().create_timer(fire_speed), "timeout")
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
	bullet.set_animation(bullet_type)
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


func is_ally(source) -> bool:
	return source.is_in_group("ally")


func _on_Radar_body_entered(body:Node):
	mobs_in_range.push_back(body)
	if target == null:
		assign_new_target()


func _on_Radar_body_exited(body:Node):
	mobs_in_range.erase(body)
	if mobs_in_range.empty():
		target = null
	elif body == target:
		assign_new_target()
