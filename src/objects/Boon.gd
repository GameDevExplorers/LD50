extends Node2D

var rng = RandomNumberGenerator.new()

var root_scene
var boon1
var boon2
var boon3
var player
var boons_enabled = false

const DEFENSIVE_BOONS = [
	"defensive-shield",
	"defensive-speed-up"
]

const SPECIAL_BOONS = [
	"special-laser-turrets",
	"special-more-turrets",
]

const WEAPON_BOONS = [
	"weapon-bigger-bullets",
	"weapon-blood-bullets",
	"weapon-cooldown-reduction",
	"weapon-faster-bullets",
	"weapon-frost-bullets",
	"weapon-more-bullets"
]

var trial_boon = "weapon-frost-bullets"

func _ready() -> void:
	root_scene = self.owner # root scene
	root_scene.connect("spawn_boons", self, "_on_Boon_spawn")
	
	player = root_scene.get_node("player")

	boon1 = root_scene.get_node("Boons").get_node("Boon1")
	boon2 = root_scene.get_node("Boons").get_node("Boon2")
	boon3 = root_scene.get_node("Boons").get_node("Boon3")
	
func _on_Timer_timeout() -> void:
	#spawn()
	pass

func _on_Boon_spawn() -> void:
	boon1.boons_enabled = true
	boon2.boons_enabled = true
	boon3.boons_enabled = true
	
	var all_boons = DEFENSIVE_BOONS + SPECIAL_BOONS + WEAPON_BOONS

	randomize()
	all_boons.shuffle()

	var picked_boons = all_boons.slice(0, 2)

	if trial_boon:
		boon1.get_node("Animation").animation = trial_boon
	else:
		boon1.get_node("Animation").animation = picked_boons[0]
	boon2.get_node("Animation").animation = picked_boons[1]
	boon3.get_node("Animation").animation = picked_boons[2]

	boon1.show()
	boon2.show()
	boon3.show()


func _on_Boon_body_entered(body:Node):
	if body == player && boons_enabled:
		boon1.boons_enabled = false
		boon2.boons_enabled = false
		boon3.boons_enabled = false
		activate_boon()
		boon1.hide()
		boon2.hide()
		boon3.hide()


func activate_boon():
	match get_node("Animation").animation:
		"defensive-shield":
			shield()
		"defensive-speed-up":
			speed_up()
		"special-laser-turrets":
			laser_turrets()
		"special-more-turrets":
			more_turrets()
		"weapon-bigger-bullets":
			bigger_bullets()
		"weapon-blood-bullets":
			blood_bullets()
		"weapon-cooldown-reduction":
			cooldown_reduction()
		"weapon-faster-bullets":
			faster_bullets()
		"weapon-frost-bullets":
			# frost_bullets()
			equip_sword()
		"weapon-more-bullets":
			more_bullets()
		_:
			print("Something else")
		
func shield() -> void:
	print("shield")
	player.has_shield = true


func speed_up() -> void:
	print("speed_up")
	player.speed *= 1.5


func laser_turrets() -> void:
	print("laser_turrets")
	var size = 5.0
	player.turret_bullet_type = "laser"
	player.turret_bullet_size = size
	var turrets = player.get_node("TurretContainer").get_children()
	for turret in turrets:
		if turret.is_in_group("turrets"):
			turret.bullet_type = "laser"
			turret.bullet_size = size


func more_turrets() -> void:
	print("more_turrets")
	player.available_turrets += 2


func bigger_bullets() -> void:
	print("Bigger Bullets!")
	player.bullet_size *= 2

		
func blood_bullets() -> void:
	print("blood_bullets")
	player.bullet_damage *= 2
	player.blood_loss += 1
	
func cooldown_reduction() -> void:
	print("cooldown_reduction")
	player.secondary_weapon_cooldown -= .2

	
func faster_bullets() -> void:
	print("faster_bullets")
	player.bullet_speed *= 2

	
func frost_bullets() -> void:
	print("frost_bullets NEED TO IMPLEMENT!")

	
func more_bullets() -> void:
	print("more_bullets")
	player.primary_bullet_count += 1
	player.secondary_bullet_count += 2

func equip_sword() -> void:
	print("equip sword")
	player.weapon_state = player.Weapon.SWORD
