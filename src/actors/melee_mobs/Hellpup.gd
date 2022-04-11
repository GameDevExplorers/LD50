extends MeleeMob


func _ready():
	anim = $hellpup_anim
	
	health = 100
	_speed = 180
	HEALTH_DROP_CHANCE = 10
	WEAPON_UP_CHANCE = 0
