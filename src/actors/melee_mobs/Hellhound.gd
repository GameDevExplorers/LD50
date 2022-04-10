extends MeleeMob


func _ready():
	anim = $hellhound_anim
	
	health = 60
	HEALTH_DROP_CHANCE = 20
	WEAPON_UP_CHANCE = 10
	_speed = 85
