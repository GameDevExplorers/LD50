extends MeleeMob

func _ready():
	anim = $hellpup_anim
	health = 100
	_speed = 180
	attack_damage = 5
	cooldown_length = 0.2
	HEALTH_DROP_CHANCE = 10
	WEAPON_UP_CHANCE = 0
