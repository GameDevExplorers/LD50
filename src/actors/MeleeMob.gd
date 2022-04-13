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


var _sigil = null
var _default_target = null
var _speed = 55
var _velocity: = Vector2.ZERO
var _target = null
var _dead = false
var _drop_loot = true


func set_sigils(t, default) -> void:
	_sigil = t
	_default_target = default


func trigger_death(drop_loot = true) -> void:
	_drop_loot = drop_loot
	set_collision_layer_bit(1, false)
	set_collision_mask_bit(0, false)
	set_collision_mask_bit(1, false)
	get_node("CollisionShape2D").disabled = true
	bullet_collider.get_node("CollisionShape2D2").disabled = true
	$Die.play()
	_dead = true
	drop_items()
	anim.animation = "death"


func _physics_process(delta) -> void:
	if _sigil == null || _dead:
		return

	if _sigil.locked:
		_sigil = _default_target

	set_velocity()
	var collision = move_and_collide(_velocity * delta)
	handle_collision(collision)


func handle_collision(collision) -> void:
	if !collision:
		_target = null
		anim.animation = "move"
		return

	var collider = collision.collider

	if collider.has_method("hit"):
		if _target == null:
			_target = collision.collider
			$Timer.start(0.1)


func set_velocity() -> void:
	_velocity = position.direction_to(_sigil.position) * _speed if !_dead else Vector2.ZERO
	anim.flip_h = true if _velocity.x < 0 else false


func attack() -> void:
	$Timer.stop()
	if _target && !_dead:
		anim.animation = "attack"
		_target.hit()
		$Timer.start(2)


func take_damage(damage) -> void:
	var old_velocity = _velocity
	_velocity = Vector2.ZERO

	if anim.animation == "attack":
		anim.animation = "walk"

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
	_velocity = old_velocity



func _on_Timer_timeout() -> void:
	if _target:
		attack()


func _on_anim_finished() -> void:
	if anim.animation == "death":
		queue_free()


func _on_bullet_entered(body: Node) -> void:
	if body.get("damage") && !_dead:
		body.queue_free()
		take_damage(body.get("damage"))


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
