class_name Strike

var name = "strike"
var spawned_by
var attack_target
var damage
var damage_with_mods
var damage_type = "melee"
var knockback = false
var crit
var crit_chance


func start(source, target, dam, _crit_chance = 0):
	spawned_by = source
	attack_target = target
	damage = dam
	crit_chance = _crit_chance
	crit = is_crit()

	attack_target.hit(spawned_by, self, damage_with_mods, knockback, crit)


func get_name() -> String:
	return name

func is_crit() -> bool:
	if Utils.percentage(crit_chance):
		damage_with_mods = damage * 2
		return true
	else:
		damage_with_mods = damage
		return false
