extends MeleeMob


func _ready():
	anim = $skele_anim
	
	health = 30
	HEALTH_DROP_CHANCE = 20
	WEAPON_UP_CHANCE = 0
	_speed = 55

