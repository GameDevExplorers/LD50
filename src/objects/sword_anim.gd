extends Node2D

func start(r, spawned_by):
	var anim = $AnimationPlayer
	var sword_body = $sword_body
	sword_body.spawned_by = spawned_by
	rotation = r
	anim.play("Swing")

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	queue_free()
