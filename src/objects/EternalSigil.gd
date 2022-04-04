extends Area2D

export var locked: = false
signal soul_absorbed

func _ready():
	var _i = get_parent().connect("demon_summoned", self, "_on_demon_summoned")
	print("start")

func _on_demon_summoned():
	var demon = get_parent().get_node("Demon")
	var _i = self.connect("soul_absorbed", demon, "absorb_souls")

func _on_Sigil_body_entered(body: Node) -> void:
	if body.has_method("trigger_death"):
		emit_signal("soul_absorbed")
		$AnimatedSprite.play()
		$PoweredUp.play()
		Game.mob_sacrificed()
		body.trigger_death(false)



func _on_AnimatedSprite_animation_finished():
	$AnimatedSprite.stop()
	$AnimatedSprite.frame = 0
