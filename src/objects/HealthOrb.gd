extends Area2D

onready var timer = $Timer

var pickedup = false

func _on_HealthOrb_body_entered(body: Node) -> void:
	if body.has_method("heal") and not pickedup:
		pickedup = true
		$AudioStreamPlayer2D.play()
		visible = false
		body.heal()


func _on_Timer_timeout() -> void:
	queue_free()


func _on_AudioStreamPlayer2D_finished():
	queue_free()
