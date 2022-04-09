extends Node2D

export var defaultTarget: NodePath
export var target: NodePath
export var spawn_index: int

var Mob = load("res://src/actors/Mob.tscn")
var Hellhound = load("res://src/actors/Hellhound.tscn")
var rng = RandomNumberGenerator.new()

onready var default_target_node = get_node(defaultTarget)
onready var target_node = get_node(target)


func _ready() -> void:
	get_parent().connect("spawn_wave", self, "_on_spawn")
	
func _on_Timer_timeout() -> void:
	#spawn()
	pass

func _on_spawn(arr):
	var count = arr[spawn_index]
	for i in range(count):
		if percentage(90):
			spawn("Mob")
		else:
			spawn("Hellhound")
	
func spawn(type) -> void:
	rng.randomize()

	var mob = find_mob(type)

	mob.set_sigils(target_node, default_target_node)
	var ran_1 = rng.randf_range(-100.0, 100.0)
	var ran_2 = rng.randf_range(-100.0, 100.0)
	mob.global_position = global_position + Vector2(ran_1, ran_2)
	get_parent().add_child(mob)


func find_mob(type):
	if type == "Hellhound":
		return Hellhound.instance()

	return Mob.instance()



func percentage(n) -> bool:
	return randf() <= n * .01
