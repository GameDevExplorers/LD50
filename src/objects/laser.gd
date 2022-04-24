extends Node2D

export var damage: = 30
var charged_damage = 0
var damage_with_mods = damage
var spawned_by
var size = 1.0
var cooldown = 1
var velocity = Vector2()
var piercing_amount = 0
var damage_type = "ranged"
var knockback = false

const ray_length = 1000
var ray_charge = 1

onready var laser = $Line2D

var mobs_in_range = []
var target = null

var crit_chance = 0
var crit

var laser_type = "charge"

###
const MAX_LENGTH = 10000

onready var begin = $Begin
onready var beam = $Beam
onready var end = $End
onready var rayCast2D = $RayCast2D
onready var beam_hitbox = $RayCast2D/BeamHitbox
onready var beam_collision_shape = $RayCast2D/BeamHitbox/CollisionShape2D

func _ready():
	set_cooldown_timer()


func start(pos, spawner, dam = damage, laser_size = size, laser_cooldown = cooldown, _crit_chance = 0, type = "charge", masks = []):
	spawned_by = spawner
	rotation = get_angle_to(get_local_mouse_position())
	damage   = dam
	z_index = 3
	size = laser_size
	cooldown = laser_cooldown
	crit_chance = _crit_chance
	laser_type = type

	scale = Vector2(size * ray_charge * .01, size * ray_charge * .01)
	set_mask(masks)
	# scale = Vector2(size, size)


func _physics_process(delta):
	if laser_type == "charge":
		charge_laser()
	else:
		beam_laser()
	

func charge_laser() -> void:
	beam_collision_shape.disabled = true
	rotation = get_angle_to(get_local_mouse_position())

	if ray_charge <= 99:
		ray_charge += 1 
		scale = Vector2(size * ray_charge * .01, size * ray_charge * .01)
		charged_damage = floor(damage * ray_charge * .01)

	spawned_by.velocity_mod = (spawned_by.velocity * ray_charge * .005)

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


func beam_laser() -> void:
	scale = Vector2(size, size)

	var mouse_position = get_local_mouse_position()
	var max_cast_to = mouse_position.normalized() * MAX_LENGTH
	rayCast2D.cast_to = max_cast_to
	end.global_position = rayCast2D.cast_to

	begin.rotation = rayCast2D.cast_to.angle()
	beam.rotation = rayCast2D.cast_to.angle()
	beam.region_rect.end.x = (end.position.length() * 10) - 150
	beam_hitbox.rotation = rayCast2D.cast_to.angle()
	charged_damage = damage
	yield(get_tree().create_timer(0.5), "timeout")
	spawned_by.laser = null
	queue_free()


func is_crit() -> bool:
	if Utils.percentage(crit_chance):
		damage_with_mods = charged_damage * 2
		return true
	else:
		damage_with_mods = charged_damage
		return false

func set_mask(masks: Array) -> void:
	for m in masks:
		$RayCast2D.set_collision_mask_bit(m, true)
		$RayCast2D/BeamHitbox.set_collision_mask_bit(m, true)


func is_from_self_or_ally(body) -> bool:
	return spawned_by.is_ally(body)


func damage_mobs():
	for mob in mobs_in_range:
		crit = is_crit()
		mob.hit(spawned_by, self, damage_with_mods, knockback, crit)


func _on_Hitbox_body_entered(body):
	if body.has_method("hit") && !is_from_self_or_ally(body):
		crit = is_crit()
		body.hit(spawned_by, self, damage_with_mods, knockback, crit)
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
	

func _on_laser_tree_exited():
	spawned_by.velocity_mod = Vector2.ZERO
