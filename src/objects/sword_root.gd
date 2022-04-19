extends Node2D

var source
var sword_body
var hitbox_rotator
var slash

func start(r, s, spawned_by, slash_frame, damage):
	load_nodes()
	rotation = r
	source = s
	
	set_sword_body_data(spawned_by, damage)
	play_animations()

func _on_HitboxRotator_animation_finished(_anim_name: String) -> void:
	queue_free()

# These are loaded here because the onready var doesn't happen until after start is called from player.gd
func load_nodes():
	hitbox_rotator = $HitboxRotator
	sword_body = $sword_body
	slash = $sword_body/Slash1
	
func set_sword_body_data(spawned_by, damage):
	sword_body.spawned_by = spawned_by
	sword_body.damage = damage

func play_animations():
	slash.show()
	slash.frame = 0
	slash.play("default")
	hitbox_rotator.play("Slash")
