class_name Strike

var name = "strike"
var spawned_by
var attack_target
var damage
var damage_type = "melee"
var knockback = false


func start(source, target, dam):
	spawned_by = source
	attack_target = target
	damage = dam
	attack_target.hit(spawned_by, self, damage, knockback)


func get_name() -> String:
	return name
