extends KinematicBody2D

onready var anim = $gate_anim

export var health: = 400
var _velocity: = Vector2.ZERO

func repair() -> void:
	$CollisionShape2D.disabled = false
	health = 400
	anim.set_animation("solid")

func take_damage() -> void:
	health -= 40
	if health < 250:
		anim.set_animation("damaged")
	if health <= 0:
		anim.set_animation("broken")
		$CollisionShape2D.disabled = true

func hit() -> void:
	take_damage()
