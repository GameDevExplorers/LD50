extends Node2D

var DamageNumbers = preload("res://src/objects/DamageNumbers.tscn")

export var travel = Vector2(0, -40)
export var duration = 1
export var spread = PI/2

func show_value(value, crit = false):
    var damage_numbers = DamageNumbers.instance()
    add_child(damage_numbers)
    damage_numbers.show_value(str(value), travel, duration, spread, crit)
