extends Area2D

func _on_Sigil_body_entered(body: Node) -> void:
	if body.has_method("trigger_death"):
		body.trigger_death()
