extends Node2D

export var defaultTarget: NodePath
export var target: NodePath

var Mob = load("res://src/actors/Mob.tscn")
var rng = RandomNumberGenerator.new()

onready var default_target_node = get_node(defaultTarget)
onready var target_node = get_node(target)


func _ready() -> void:
	$Timer.start(5)

func _on_Timer_timeout() -> void:
	spawn()

func spawn() -> void:
	rng.randomize()
	var m = Mob.instance()
	m.set_sigils(target_node, default_target_node)
	var ran_1 = rng.randf_range(-100.0, 100.0)
	var ran_2 = rng.randf_range(-100.0, 100.0)
	m.global_position = global_position + Vector2(ran_1, ran_2)
	get_parent().add_child(m)
