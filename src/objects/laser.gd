extends Node2D

export var damage: = 30
var spawned_by
var size = 1.0
var cooldown = 1
var velocity = Vector2()
var piercing_amount = 0
var damage_type = "ranged"
var knockback = false

const ray_length = 1000

onready var laser = $Line2D

var mobs_in_range = []
var target = null

###
const MAX_LENGTH = 10000

onready var begin = $Begin
onready var beam = $Beam
onready var end = $End
onready var rayCast2D = $RayCast2D

func _ready():
	set_cooldown_timer()


func start(pos, spawner, dam = damage, laser_size = size, laser_cooldown = cooldown, masks = []):
	spawned_by = spawner
	rotation = get_angle_to(get_local_mouse_position())
	damage   = dam
	z_index = 3
	size = laser_size
	cooldown = laser_cooldown
	set_mask(masks)
	# scale = Vector2(size, size)


func _physics_process(delta):
	rotation = get_angle_to(get_local_mouse_position())

	var mouse_position = get_local_mouse_position()
	var max_cast_to = mouse_position.normalized() * MAX_LENGTH
	rayCast2D.cast_to = max_cast_to
	if rayCast2D.is_colliding():
		end.global_position = rayCast2D.get_collision_point()
	else:
		end.global_position = rayCast2D.cast_to

	begin.rotation = rayCast2D.cast_to.angle()
	beam.rotation = rayCast2D.cast_to.angle()
	beam.region_rect.end.x = (end.position.length() * 10) - 150
	

func set_mask(masks: Array) -> void:
	for m in masks:
		get_node("RayCast2D").set_collision_mask_bit(m, true)


func is_from_self_or_ally(body) -> bool:
	return spawned_by.is_ally(body)


func damage_mobs():
	for mob in mobs_in_range:
		mob.hit(spawned_by, self, damage, knockback)


func _on_Hitbox_body_entered(body):
	if body.has_method("hit") && !is_from_self_or_ally(body):
		body.hit(spawned_by, self, damage, knockback)
		mobs_in_range.push_back(body)
	else:
		pass


func _on_Hitbox_body_exited(body):
	if mobs_in_range.has(body):
		mobs_in_range.erase(body)


func set_cooldown_timer() -> void:
	damage_mobs()
	$CooldownTimer.start(cooldown)


func _on_CooldownTimer_timeout():
	$CooldownTimer.stop()
	set_cooldown_timer()
	
