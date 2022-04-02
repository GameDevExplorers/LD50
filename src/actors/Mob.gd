extends KinematicBody2D

onready var anim = $skele_anim

var _sigil = null
var _speed = 75
var _velocity: = Vector2.ZERO
var _target = null

var rng = RandomNumberGenerator.new()

func set_sigil(t) -> void:
	_sigil = t

func _physics_process(delta) -> void:
	if _sigil:
		_velocity = position.direction_to(_sigil.position) * _speed
		anim.flip_h = true if _velocity.x < 0 else false
		var collision = move_and_collide(_velocity * delta)
		if collision && collision.collider.has_method("hit"):
			if _target == null:
				anim.animation = "attack"
				set_target(collision.collider)
		else:
			_target = null
			anim.animation = "walk"
			
func set_target(t) -> void:
	_target = t
	$Timer.start(0.1)
	
func attack() -> void:
	$Timer.stop()
	if _target:
		_target.hit()
		$Timer.start(2)


func _on_Timer_timeout() -> void:
	if _target:
		attack()
