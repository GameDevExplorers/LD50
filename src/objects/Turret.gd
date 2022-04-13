extends KinematicBody2D

var bullet_speed = 850
var bullet_damage = 60
var fire_speed = 1

var kill_radius = 5

var Bullet = load("res://src/objects/bullet.tscn")
var Casing = load("res://src/objects/casing.tscn")

var cross_hair:Vector2 = Vector2()
var can_fire = true
var enemy_in_range = false
var enemy_position = Vector2()
var enemies_in_range = {}

onready var anim = $TurretAnimation

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(_delta):
	if can_fire && enemy_in_range:
		fire_projectile(1)

	if cross_hair.x < global_position.x:
		anim.frame = 2
	else:
		anim.frame = 0


func fire_projectile(offset:float):
	cross_hair = enemy_position
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


func _on_Radar_body_entered(body:Node):
	enemies_in_range[body.get_instance_id()] = body.get_position()
	enemy_in_range = true
	enemy_position = body.get_position()


func _on_Radar_body_exited(body:Node):
	enemies_in_range.erase(body.get_instance_id())
	if enemies_in_range.empty():
		enemy_in_range = false
		enemy_position = Vector2()
	else:
		enemy_position = enemies_in_range.values().front()