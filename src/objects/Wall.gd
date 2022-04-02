extends KinematicBody2D

export var health: = 1000
var _velocity: = Vector2.ZERO

func take_damage() -> void:
	health -= 10

func _on_Area2D_body_entered(body: Node) -> void:
	take_damage()
