extends Node2D

export var defaultTarget: NodePath
export var target: NodePath

var Mob = load("res://src/actors/Mob.tscn")

onready var default_target_node = get_node(defaultTarget)
onready var target_node = get_node(target)

func _ready() -> void:
	$Timer.start(5)

func _on_Timer_timeout() -> void:
	spawn()

func spawn() -> void:
	var m = Mob.instance()
	m.set_sigils(target_node, default_target_node)
	m.global_position = global_position
	get_parent().add_child(m)
