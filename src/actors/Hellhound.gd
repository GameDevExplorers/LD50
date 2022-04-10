extends KinematicBody2D

onready var anim = $hellhound_anim
onready var bullet_collider = $BulletCollider

export var health: = 60

export var drop_chance: = 20

var rng = RandomNumberGenerator.new()
var health_orb = load("res://src/objects/HealthOrb.tscn")

var _sigil = null
var _default_target = null
var _speed = 85
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
	anim.animation = "die"

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
		anim.animation = "move"

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

func _on_hellhound_anim_finished() -> void:
	if anim.animation == "die":
		rng.randomize()
		var drop = rng.randi_range(1, 100)
		if drop < drop_chance && _drop_loot:
			var h = health_orb.instance()
			h.position = global_position
			get_parent().get_node('ItemNode').add_child(h)
		queue_free()


func _on_bullet_entered(body: Node) -> void:
	if body.get("damage") && !_dead:
		body.queue_free()
		take_damage(body.get("damage"))
