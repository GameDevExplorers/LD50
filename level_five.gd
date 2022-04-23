extends Node2D

export (Array, int) var spawn_count = [10, 10, 15, 20, 20, 25, 1, 1, 25, 25, 30, 1, 0, 20, 20, 25, 25, 30, 30]
export var spawn_timer = 7
export var boon_timer = 5
var Demon = load("res://src/actors/Demon.tscn")

var demon_instance = null

signal demon_summoned

signal spawn_wave(spawn_arr)
signal spawn_boons()


var rng = RandomNumberGenerator.new()
var tick_count = 0

var sigil_lock_count = 0

var player
var hud

func _ready():
	Game.reset()
	$Timer.start(1)
	emit_signal("spawn_boons")

	player = get_tree().get_current_scene().get_node("player")
	hud = $CanvasLayer/hud
	hud.update_experience_for_next_level(calculate_level_formula(player.level))



func _on_Timer_timeout():
	tick_count = tick_count + 1
	handle_spawns()
	$Timer.start(1)
	var time = Game.summon_timer - Game.elapsed_time()
	hud.update_demon_timer(time)
	hud.update_sigils()

	if time <= 0 and Game.demon_summoned == false:
		Game.demon_summoned = true
		demon_instance = Demon.instance()
		demon_instance.max_health = demon_instance.max_health + (sigil_lock_count * demon_instance.sigil_buff)
		demon_instance.health = demon_instance.max_health
		demon_instance.position = $EternalSigil.position
		add_child(demon_instance)
		emit_signal("demon_summoned")

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

		for _n in range(divide):
			var i = rng.randi_range(0, 4)
			new_arr[i] = new_arr[i] + each_node

		emit_signal("spawn_wave", new_arr)



func _on_AudioStreamPlayer_finished():
	$AudioStreamPlayer.play()

func _on_sigil_lock():
	sigil_lock_count = sigil_lock_count + 1
	if demon_instance:
		demon_instance.max_health = demon_instance.max_health + demon_instance.sigil_buff
		demon_instance.health = demon_instance.health + demon_instance.sigil_buff
		demon_instance.set_health_bar()


func _on_Experience_gain(experience) -> void:
	Game.score += experience
	hud.update_experience()
	if Game.score >= calculate_level_formula(player.level):
		player.level += 1
		hud.update_player_level(player)
		hud.update_experience_for_next_level(calculate_level_formula(player.level))
		emit_signal("spawn_boons")


func calculate_level_formula(level):
	var a = 4 # ^ will make leveling more difficult
	var b = 2 # ^ will make leveling dramatically more difficult
	var c = 5 # ^ will make leveling easier
	var d = 1_000 # degree mod

	return ((a * pow(level, b)) / c) * d

