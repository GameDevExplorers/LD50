extends MeleeMob

const INSTANCE_NAME = "hellhound"

func _ready():
	anim = $hellhound_anim
	max_health = 500
	health = 500
	_speed = 25
	attack_damage = 30
	cooldown_length = 2
	MASS_FACTOR = 10.0
	HEALTH_DROP_CHANCE = 20
	WEAPON_UP_CHANCE = 10
	EXPERIENCE = 300

	anim.play("move")
	._ready()
