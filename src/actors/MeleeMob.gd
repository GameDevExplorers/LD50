extends KinematicBody2D

class_name MeleeMob

onready var anim
onready var bullet_collider = $BulletCollider
onready var attack_timer = $AttackTimer
onready var cooldown_timer = $CooldownTimer

var movables_in_range := []
var separation_factor: float = 2

var health: int = 30
var _speed: int = 55
var attack_damage: int = 0
var cooldown_length: float = 0

var EXPERIENCE = 50

export var MASS_FACTOR: float = 1.0

export var HEALTH_DROP_CHANCE: = 10
export var WEAPON_UP_CHANCE: = 10

var rng = RandomNumberGenerator.new()
var HealthOrb = load("res://src/objects/pickups/HealthOrb.tscn")
var DamageUpOrb = load("res://src/objects/pickups/DamageUpOrb.tscn")
var AmmoUpOrb = load("res://src/objects/pickups/AmmoUpOrb.tscn")


var movement_target = null
var movement_targets_in_range = []
var player

var attack_target = null
var attack_targets = []
var can_attack = true

var sigil = null
var default_target = null


var velocity: = Vector2.ZERO
var _dead = false
var _drop_loot = true

var knocked_back = false

signal gain_experience(experience)

func _ready():
	movement_target = sigil
	player = get_tree().get_current_scene().get_node("player")


func set_sigils(t, default) -> void:
	sigil = t
	default_target = default


func trigger_death(drop_loot = true) -> void:
	_drop_loot = drop_loot
	emit_signal("gain_experience", EXPERIENCE)
	set_collision_layer_bit(1, false)
	set_collision_mask_bit(0, false)
	set_collision_mask_bit(1, false)
	remove_child(get_node("CollisionPolygon2D"))
	remove_child(bullet_collider.get_node("CollisionShape2D2"))
	$Die.play()
	_dead = true
	drop_items()
	anim.animation = "death"


func _physics_process(delta) -> void:
	if sigil == null || _dead:
		return
	
	if knocked_back:
		return

	if movables_in_range.size() > 0:
		bounce()
	else:
		set_velocity()
	velocity = move_and_slide(velocity)


func bounce():
	var steerAway := Vector2.ZERO

	for movable in movables_in_range:
		steerAway -= (movable.global_position - global_position) * (separation_factor / (global_position - movable.global_position).length())

	velocity += steerAway


func set_velocity() -> void:
	if movement_target:
		velocity = position.direction_to(movement_target.get_position()) * _speed if !_dead else Vector2.ZERO
		anim.flip_h = true if velocity.x < 0 else false


func _on_vision_area_entered(area:Area2D):
	if area != self && area.is_in_group("bounceable"):
		movables_in_range.append(area)

func _on_vision_area_exited(area:Area2D):
	if area && movables_in_range.size() > 0:
		movables_in_range.erase(area)


func attack() -> void:
	attack_timer.stop()

	if !_dead:
		anim.animation = "attack"
		attack_target.hit(attack_damage, false, self)
		attack_timer.start(cooldown_length)


func take_damage(damage, attacker = null) -> void:
	var old_velocity = velocity
	velocity = Vector2.ZERO

	$Hit.play()
	health = health - damage
	if health <= 0:
		Game.mob_killed()
		trigger_death()

	modulate = Color.red
	yield(get_tree().create_timer(0.1), "timeout")
	modulate = Color.white
	yield(get_tree().create_timer(0.1), "timeout")
	modulate = Color.red
	yield(get_tree().create_timer(0.1), "timeout")
	modulate = Color.white

	yield(get_tree().create_timer(0.5), "timeout")
	velocity = old_velocity


func drop_items() -> void:
	if Utils.percentage(WEAPON_UP_CHANCE) && _drop_loot:
		var h = choose_weapon_upgrade()
		h.position = global_position
		get_parent().get_parent().get_node('ItemNode').add_child(h)
		return # If a weapon upgrade is dropped, don't also drop health
	if Utils.percentage(HEALTH_DROP_CHANCE) && _drop_loot:
		var h = HealthOrb.instance()
		h.position = global_position
		get_parent().get_parent().get_node('ItemNode').add_child(h)


func choose_weapon_upgrade():
	if Utils.percentage(50): # choose between weapon upgrades
		return DamageUpOrb.instance()
	else:
		return AmmoUpOrb.instance()


func move_to_sigil():
	if sigil != null && sigil.locked:
		return default_target
	else:
		return sigil

func _on_anim_finished() -> void:
	if anim.animation == "death":
		queue_free()
	elif anim.animation == "attack" && !attack_target:
		anim.animation = "move"


# Attacks target if target is identified
func _on_AttackTimer_timeout() -> void:
	if attack_target:
		attack()


# Resets cooldown for attack
func _on_CooldownTimer_timeout() -> void:
	can_attack = true


# Identify target as attackable and attack if not attacking
func _on_AttackArea_body_entered(body:Node) -> void:
	attack_targets.push_back(body)
	if attack_target == null:
		attack_target = attack_targets.back()
		attack_timer.start(.1)


func _on_AttackArea_body_exited(body:Node) -> void:
	attack_targets.erase(body)

	# Start cooldown to prevent stutter-step damage
	if attack_targets.empty():
		attack_target = null
		can_attack = false
		cooldown_timer.start(cooldown_length)
	# Assign new target if former target leaves
	elif attack_target == body:
		attack_target = attack_targets.front()



# If mob isn't attacking anyone, move towards new thing that it identifies
# unless it's chasing the player
func _on_Radar_body_entered(body:Node) -> void:
	movement_targets_in_range.push_back(body)
	if attack_target == null && movement_target != player:
		movement_target = movement_targets_in_range.back()


# Move towards next thing in queue, or fallback to sigils
func _on_Radar_body_exited(body:Node) -> void:
	movement_targets_in_range.erase(body)
	if movement_targets_in_range.empty():
		movement_target = move_to_sigil()
	else:
		movement_target = movement_targets_in_range.front()
	
	# When the player leaves movement range, make sure enemy re-attacks the first thing in queue
	if !attack_targets.empty():
		attack_target = attack_targets.front()


# Player shooting mob creates aggro
# If player isn't in movement range, then no aggro
# If player in movement range and is colliding, then attack
# If player in movement range but not colliding, no attack
func hit(damage, knockback = false, _attacker = null) -> void:
	if damage && !_dead:
		take_damage(damage)

		if knockback:
			knockback_target()

		if movement_targets_in_range.has(player):
			movement_target = player
			if attack_targets.has(player):
				attack_target = player
			else:
				attack_target = null


func knockback_target():
	position = position.move_toward(get_global_mouse_position(), 20)
	knocked_back = true
	yield(get_tree().create_timer(0.1), "timeout")
	knocked_back = false

