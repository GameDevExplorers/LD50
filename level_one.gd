extends Node2D


var Demon = load("res://src/actors/Demon.tscn")
var demon_summoned = false

func _ready():
	$Timer.start(1)


func _on_Timer_timeout():
	$Timer.start(1)
	$Label.text = "Demon Time in: " + str(Game.elapsed_time() - Game.summon_timer) + " seconds"
	if Game.elapsed_time() > Game.summon_timer and demon_summoned == false:
		demon_summoned = true
		var d = Demon.instance()
		d.position = $EternalSigil.position
		add_child(d)
