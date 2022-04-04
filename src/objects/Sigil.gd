extends Area2D

export var color: = "red"
export var charge: = 0
export var locked: = false
export var spawn_index: int

onready var anim = $sigil_base
onready var fire_anim = $sigil_fire

signal on_lock

func _ready() -> void:
	anim.set_animation(color)
	anim.set_frame(0)
	get_parent().connect("spawn_skeles", self, "_on_spawn")

func _on_spawn(arr):
	if arr[spawn_index] > 0:
		fire_anim.play(color)
	else:
		fire_anim.play("blank")

func _on_Sigil_body_entered(body: Node) -> void:
	if !locked && body.has_method("trigger_death"):
		$PoweredUp.play()
		charge = min(charge + 15, 100)
		anim.set_frame(charge / 10)
		if charge == 100:
			lock()
		body.trigger_death()
#		fire_anim.set_frame(0)
#		fire_anim.play(color)

func lock() -> void:
	anim.set_frame(10)
	$collider.disabled = true
	locked = true
	Game.sigil_locked()
	emit_signal("on_lock")


func _on_sigil_fire_animation_finished() -> void:
	pass
#	if locked:
#		fire_anim.set_frame(0)
#		fire_anim.play(color)
#	else:
#		fire_anim.set_animation("blank")
