extends Node2D


var Demon = load("res://src/actors/Demon.tscn")

signal demon_summoned

func _ready():
	$Timer.start(1)


func _on_Timer_timeout():
	$Timer.start(1)
	$Label.text = "Demon Time in: " + str(Game.elapsed_time() - Game.summon_timer) + " seconds"
	if Game.elapsed_time() > Game.summon_timer and Game.demon_summoned == false:
		Game.demon_summoned = true
		emit_signal("demon_summoned")
		var d = Demon.instance()
		d.position = $EternalSigil.position
		add_child(d)
