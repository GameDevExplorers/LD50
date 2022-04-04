extends Area2D

onready var timer = $Timer

func _ready() -> void:
	timer.start(20)

func _on_HealthOrb_body_entered(body: Node) -> void:
	if body.has_method("heal"):
		body.heal()
		queue_free()


func _on_Timer_timeout() -> void:
	queue_free()
