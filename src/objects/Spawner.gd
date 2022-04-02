extends Node2D

export var target: NodePath

var Mob = load("res://src/actors/Mob.tscn")

func _ready() -> void:
	$Timer.start(5)

func _get_configuration_warning() -> String:
	return "target must be set" if not target else ""


func _on_Timer_timeout() -> void:
	spawn()

func spawn() -> void:
	var m = Mob.instance()
	m.set_sigil(get_node(target))
	m.global_position = global_position
	get_parent().add_child(m)
