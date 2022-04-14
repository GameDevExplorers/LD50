extends KinematicBody2D

class_name MeleeMob

onready var anim
onready var bullet_collider = $BulletCollider

export var health: = 30

export var HEALTH_DROP_CHANCE: = 10
export var WEAPON_UP_CHANCE: = 10

var rng = RandomNumberGenerator.new()
var HealthOrb = load("res://src/objects/pickups/HealthOrb.tscn")
var DamageUpOrb = load("res://src/objects/pickups/DamageUpOrb.tscn")
var AmmoUpOrb = load("res://src/objects/pickups/AmmoUpOrb.tscn")


var target_in_range = false
var target = Vector2()
var targets_in_range = []
var player

var sigil = null
var default_target = null
var collision_target = null


var _speed = 55
var velocity: = Vector2.ZERO
var _dead = false
var _drop_loot = true


func _ready():
	target = sigil
	player = get_parent().get_parent().get_node('player')


func set_sigils(t, default) -> void:
	sigil = t
	default_target = default


func trigger_death(drop_loot = true) -> void:
	_drop_loot = drop_loot
	set_collision_layer_bit(1, false)
	set_collision_mask_bit(0, false)
	set_collision_mask_bit(1, false)
	remove_child(get_node("CollisionShape2D"))
	remove_child(bullet_collider.get_node("CollisionShape2D2"))
	$Die.play()
	_dead = true
	drop_items()
	anim.animation = "death"


func _physics_process(delta) -> void:
	if sigil == null || _dead:
		return

	set_velocity()
	var collision = move_and_collide(velocity * delta)
	handle_collision(collision)


# handle_collision -> _on_Timer_timeout -> attack -> collision_target.hit()
# everytime the mob moves, the attack timer resets
func handle_collision(collision) -> void:
	if !collision:
		collision_target = null
		# anim.animation = "move"
		return

	var collider = collision.collider

	if collider.has_method("hit"):
		if collision_target == null:
			collision_target = collider
			$Timer.start(0.1)


func set_velocity() -> void:
	if target:
		velocity = position.direction_to(target.get_position()) * _speed if !_dead else Vector2.ZERO
		anim.flip_h = true if velocity.x < 0 else false


func attack() -> void:
	$Timer.stop()

	if collision_target == target && !_dead:
		anim.animation = "attack"
		collision_target.hit()
		$Timer.start(2)


func take_damage(damage) -> void:
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


func _on_bullet_entered(body: Node) -> void:
	if body.get("damage") && !_dead:
		body.queue_free()
		take_damage(body.get("damage"))
		# Something weird is happening -- the enemies transition to move and face the player,
		# but they are running in place
		# Are they stuck on the wall?
		if targets_in_range.has(player):
			target = player


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


func _on_Timer_timeout() -> void:
	if collision_target:
		attack()


func _on_anim_finished() -> void:
	if anim.animation == "death":
		queue_free()
	elif anim.animation == "attack" && !collision_target:
		anim.animation = "move"


func _on_Radar_body_entered(body:Node):
	targets_in_range.push_back(body)
	if collision_target == null:
		target = targets_in_range.back()


func _on_Radar_body_exited(body:Node):
	targets_in_range.erase(body)
	if targets_in_range.empty():
		if sigil != null && sigil.locked:
			target = default_target
		else:
			target = sigil
	else:
		target = targets_in_range.front()
