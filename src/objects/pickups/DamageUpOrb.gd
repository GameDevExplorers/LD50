extends Area2D

onready var timer = $Timer

var pickedup = false

func _on_body_entered(body: Node) -> void:
	if body.has_method("damage_up") and not pickedup:
		pickedup = true
		$AudioStreamPlayer2D.play()
		visible = false
		body.damage_up()


func _on_Timer_timeout() -> void:
	queue_free()


func _on_AudioStreamPlayer2D_finished():
	queue_free()
