extends Node2D

var spawned_by
var damage
var damage_with_mods
var sword_body
var hitbox_rotator
var slash
var size
var damage_type = "melee"
var knockback = true
var crit
var crit_chance

func start(r, spawner, dam, sword_size, _crit_chance, masks):
	load_nodes()
	rotation = r
	spawned_by = spawner
	damage = dam
	size = sword_size
	crit_chance = _crit_chance

	scale = Vector2(size, size)
	set_mask(masks)
	set_sword_body_data()
	play_animations()

func _on_HitboxRotator_animation_finished(_anim_name: String) -> void:
	queue_free()

# These are loaded here because the onready var doesn't happen until after start is called from player.gd
func load_nodes():
	hitbox_rotator = $HitboxRotator
	sword_body = $sword_body
	slash = $sword_body/Slash1


func set_mask(masks: Array) -> void:
	for m in masks:
		get_node("sword_body").get_node("Hitbox").set_collision_mask_bit(m, true)

func is_crit() -> bool:
	if Utils.percentage(crit_chance):
		damage_with_mods = damage * 2
		return true
	else:
		damage_with_mods = damage
		return false

func set_sword_body_data():
	sword_body.spawned_by = spawned_by
	sword_body.damage = damage

func play_animations():
	slash.show()
	slash.frame = 0
	slash.play("default")
	hitbox_rotator.play("Slash")


func _on_Hitbox_body_entered(body):
	if body == spawned_by: # prevents people from swording themselves
		return
	crit = is_crit()
	body.hit(spawned_by, self, damage_with_mods, knockback, crit)
