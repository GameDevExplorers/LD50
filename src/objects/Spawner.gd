extends Node2D

export var defaultTarget: NodePath
export var target: NodePath
export var spawn_index: int

var Skeleton = load("res://src/actors/melee_mobs/Skeleton.tscn")
var Hellhound = load("res://src/actors/melee_mobs/Hellhound.tscn")
var Hellpup = load("res://src/actors/melee_mobs/Hellpup.tscn")
var rng = RandomNumberGenerator.new()

onready var default_target_node = get_node(defaultTarget)
onready var target_node = get_node(target)


func _ready() -> void:
	get_parent().connect("spawn_wave", self, "_on_spawn")
	
func _on_Timer_timeout() -> void:
	#spawn()
	pass

func _on_spawn(arr) -> void:
	var count = arr[spawn_index]
	for _i in range(count):
		if Utils.percentage(95):
			if Utils.percentage(50):
				spawn("Skeleton")
			else:
				spawn("Hellpup")
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
	match type:
		"Hellhound":
			return Hellhound.instance()
		"Hellpup":
			return Hellpup.instance()
		"Skeleton":
			return Skeleton.instance()
