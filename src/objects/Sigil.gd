extends Area2D

export var charge: = 0
export var locked: = false

func _on_Sigil_body_entered(body: Node) -> void:
	if !locked && body.has_method("trigger_death"):
		charge = min(charge + 15, 100)
		if charge == 100:
			lock()
		body.trigger_death()

func lock() -> void:
	$collider.disabled = true
	locked = true
