extends Node2D

var rng = RandomNumberGenerator.new()

var root_scene
var boon1
var boon2
var boon3
var player
var boons_enabled = false

const BOONS = [
	"defensive-idle-heal",
	"defensive-magic-reflect",
	"defensive-shield",
	"defensive-speed-up",
	"defensive-thorns",
	"special-laser-turrets",
	"special-more-turrets",
	"weapon-attack-speed-up",
	"weapon-bigger-bullets",
	"weapon-blood-bullets",
	"weapon-cooldown-reduction",
	"weapon-critical-damage",
	"weapon-enemy-explode-on-death",
	"weapon-frost-bullets",
	"weapon-homing-bullets",
	"weapon-more-bullets",
	"weapon-piercing-bullets",
	"weapon-saw-blades",
	"weapon-sword",
]

var trial_boon = "weapon-sword"

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
	
	var all_boons = BOONS

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
	print("boon: ", get_node("Animation").animation)
	match get_node("Animation").animation:
		"defensive-idle-heal":
			idle_heal()
		"defensive-magic-reflect":
			magic_reflect()
		"defensive-shield":
			shield()
		"defensive-speed-up":
			speed_up()
		"defensive-thorns":
			thorns()
		"special-laser-turrets":
			laser_turrets()
		"special-more-turrets":
			more_turrets()
		"weapon-attack-speed-up":
			attack_speed_up()
		"weapon-bigger-bullets":
			bigger_bullets()
		"weapon-blood-bullets":
			blood_bullets()
		"weapon-cooldown-reduction":
			cooldown_reduction()
		"weapon-critical-damage":
			critical_damage()
		"weapon-enemies-explode-on-death":
			explode_on_death()
		"weapon-frost-bullets":
			frost_bullets()
		"weapon-homing-bullets":
			homing_bullets()
		"weapon-more-bullets":
			more_bullets()
		"weapon-piercing-bullets":
			piercing_bullets()
		"weapon-saw-blades":
			saw_blades()
		"weapon-sword":
			equip_sword()
		_:
		    assert(false, "unknown boon")



func idle_heal() -> void:
	player.has_idle_heal_boon = true
	player.idle_heal_amount += 1
	player.set_idle_timer()

	
func magic_reflect() -> void:
	pass


func shield() -> void:
	player.has_shield = true


func speed_up() -> void:
	# 10% faster
	player.speed *= 1.1


func thorns() -> void:
	player.has_thorns = true


func laser_turrets() -> void:
	var size = 5.0
	player.turret_bullet_type = "laser"
	player.turret_bullet_size = size
	var turrets = player.get_node("TurretContainer").get_children()
	for turret in turrets:
		if turret.is_in_group("turrets"):
			turret.bullet_type = "laser"
			turret.bullet_size = size


func more_turrets() -> void:
	player.available_turrets += 2


func attack_speed_up() -> void:
	# 10% faster
	player.primary_weapon_cooldown -= player.primary_weapon_cooldown * 0.1


func bigger_bullets() -> void:
	# 10% larger
	player.bullet_size *= 1.1

		
func blood_bullets() -> void:
	# 100% stronger
	player.bullet_damage *= 2
	player.blood_loss += 1
	
func cooldown_reduction() -> void:
	# 20% faster
	player.primary_weapon_cooldown -= player.primary_weapon_cooldown * 0.2

func critical_damage() -> void:
	pass


func explode_on_death() -> void:
	pass


func frost_bullets() -> void:
	pass


func homing_bullets() -> void:
	pass


func more_bullets() -> void:
	player.primary_bullet_count += 1
	player.secondary_bullet_count += 2


func piercing_bullets() -> void:
	player.piercing_amount += 1
	player.has_piercing = true


func equip_sword() -> void:
	player.weapon_state = player.Weapon.SWORD


func saw_blades() -> void:
	pass