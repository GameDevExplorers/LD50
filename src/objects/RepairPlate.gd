extends Area2D


onready var timer = $Timer
onready var progress_bar = $TextureProgress

signal repaired

var count: = 0

func _on_RepairPlate_body_entered(body: Node) -> void:
	timer.start(1)


func _on_RepairPlate_body_exited(body: Node) -> void:
	count = 0
	progress_bar.value = count
	timer.stop()


func _on_Timer_timeout() -> void:
	count = count + 1
	progress_bar.value = count
	if count == 5:
		emit_signal("repaired")
