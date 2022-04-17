extends MeleeMob

func _ready():
	anim = $skele_anim
	health = 30
	_speed = 55
	attack_damage = 10
	cooldown_length = 2
	MASS_FACTOR = 3.0
	HEALTH_DROP_CHANCE = 20
	WEAPON_UP_CHANCE = 0
	EXPERIENCE = 80
