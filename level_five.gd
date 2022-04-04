extends Node2D

export (Array, int) var spawn_count = [10, 10, 15, 20, 20, 25, 1, 1, 25, 25, 30, 1, 0, 20, 20, 25, 25, 30, 30]
export var spawn_timer = 7
var Demon = load("res://src/actors/Demon.tscn")

signal demon_summoned

signal spawn_skeles(spawn_arr)

var rng = RandomNumberGenerator.new()
var tick_count = 0

func _ready():
	$Timer.start(1)


func _on_Timer_timeout():
	tick_count = tick_count + 1
	handle_spawns()
	$Timer.start(1)
	$Label.text = "Demon Time in: " + str(Game.elapsed_time() - Game.summon_timer) + " seconds"
	if Game.elapsed_time() > Game.summon_timer and Game.demon_summoned == false:
		Game.demon_summoned = true
		emit_signal("demon_summoned")
		var d = Demon.instance()
		d.position = $EternalSigil.position
		add_child(d)

func handle_spawns():
	if tick_count % spawn_timer == 0 || tick_count == 1:
		var new_arr = [0, 0, 0, 0, 0]
		
		rng.randomize()
		var divide = rng.randi_range(1, 5)

		var index = (tick_count / spawn_timer) - 1
		if index >= spawn_count.size():
			index = 8
		var spawns = spawn_count[index]
		var each_node = spawns / divide
		
		for n in range(divide):
			var i = rng.randi_range(0, 4)
			new_arr[i] = new_arr[i] + each_node

		emit_signal("spawn_skeles", new_arr)


func _on_AudioStreamPlayer2D_finished():
	$AudioStreamPlayer2D.play()
