extends Area2D

export var locked: = false

func _on_Sigil_body_entered(body: Node) -> void:
	if body.has_method("trigger_death"):
		Events.emit_signal("soul_absorbed")
		$AnimatedSprite.play()
		$PoweredUp.play()
		Game.mob_sacrificed()
		body.trigger_death(false)

func _on_AnimatedSprite_animation_finished():
	$AnimatedSprite.stop()
	$AnimatedSprite.frame = 0
