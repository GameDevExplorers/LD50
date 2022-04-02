extends KinematicBody2D

var wall_base = preload("res://src/BlueTexture.jpg")
var wall_damaged = preload("res://src/DarkBlueTexture.jpg")
var wall_down = preload("res://src/YellowTexture.jpg")

onready var wall_sprite = $wall_sprite

export var health: = 400
var _velocity: = Vector2.ZERO

func repair() -> void:
	$CollisionShape2D.disabled = false
	health = 400
	wall_sprite.set_texture(wall_base)

func take_damage() -> void:
	health -= 40
	if health < 250:
		wall_sprite.set_texture(wall_damaged)
	if health <= 0:
		wall_sprite.set_texture(wall_down)
		$CollisionShape2D.disabled = true

func hit() -> void:
	take_damage()
