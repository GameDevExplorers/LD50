extends KinematicBody2D

export var damage: = 60
export var spawned_by: = ""

func hit_triggered():
	pass

func _on_Slash_animation_finished():
	queue_free()
