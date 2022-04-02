extends KinematicBody2D

var walls := []
var wall = null
var _speed = 75
var _velocity: = Vector2.ZERO
var collision = null

func _physics_process(delta) -> void:
	walls = get_node("/root/play_scene/Walls").get("walls") as Array
	wall = get_node("/root/play_scene/Walls").get_node(walls[0])
	if wall:
		_velocity = position.direction_to(wall.position) * _speed
	_velocity = move_and_slide(_velocity)
