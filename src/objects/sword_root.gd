extends Node2D

var spawned_by
var damage
var sword_body
var hitbox_rotator
var slash

func start(r, spawner, _slash_frame, d):
	print("Sword Starting")
	load_nodes()
	rotation = r
	spawned_by = spawner
	damage = d
	
	set_sword_body_data()
	play_animations()

func _on_HitboxRotator_animation_finished(_anim_name: String) -> void:
	queue_free()

# These are loaded here because the onready var doesn't happen until after start is called from player.gd
func load_nodes():
	hitbox_rotator = $HitboxRotator
	sword_body = $sword_body
	slash = $sword_body/Slash1
	
func set_sword_body_data():
	sword_body.spawned_by = spawned_by
	sword_body.damage = damage

func play_animations():
	slash.show()
	slash.frame = 0
	slash.play("default")
	hitbox_rotator.play("Slash")