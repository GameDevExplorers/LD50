extends KinematicBody2D

var _sigil = null
var _speed = 75
var _velocity: = Vector2.ZERO
var _target = null

func set_sigil(t) -> void:
	_sigil = t

func _physics_process(delta) -> void:
	#walls = get_node("/root/play_scene/Walls").get("walls") as Array
	#wall = get_node("/root/play_scene/Walls").get_node(walls[0])
	if _sigil:
		_velocity = position.direction_to(_sigil.position) * _speed
		var collision = move_and_collide(_velocity * delta)
		if collision && collision.collider.has_method("hit"):
			if _target == null:
				set_target(collision.collider)
		else:
			_target = null
			
func set_target(t) -> void:
	_target = t
	$Timer.start(0.1)
	
func attack() -> void:
	if _target:
		_target.hit()
		$Timer.start(2)


func _on_Timer_timeout() -> void:
	if _target:
		attack()
