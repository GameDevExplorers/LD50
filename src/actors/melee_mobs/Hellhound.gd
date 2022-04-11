extends MeleeMob


func _ready():
	anim = $hellhound_anim
	
	health = 500
	_speed = 25
	HEALTH_DROP_CHANCE = 20
	WEAPON_UP_CHANCE = 10
