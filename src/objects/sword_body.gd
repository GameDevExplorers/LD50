extends KinematicBody2D

export var damage: = 60
var spawned_by

func hit_triggered():
	pass

func _on_HitboxRotator_animation_finished():
	queue_free()
