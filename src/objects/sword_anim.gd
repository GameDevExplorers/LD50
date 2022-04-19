extends Node2D

var source

func start(r, s, spawned_by, slash_frame, damage):
	print(slash_frame)
	var anim = $AnimationPlayer
	var sword_body = $sword_body
	sword_body.spawned_by = spawned_by
	sword_body.damage = damage
	rotation = r
	source = s
	$sword_body/Slash1.frame = 0
	$sword_body/Slash1.play("slash1")
	
	# $sword_body/Slash2.frame = 0
	# $sword_body/Slash1.play("slash2")
	
	anim.play("Swing")


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	queue_free()


func _on_AnimationPlayer2_animation_finished(_anim_name:String):
	queue_free()
