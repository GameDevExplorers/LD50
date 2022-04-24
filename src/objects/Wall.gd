extends KinematicBody2D

onready var anim = $gate_anim
onready var repair_plate = $RepairPlate
onready var health_bar = $Healthbar

var _velocity: = Vector2.ZERO
var max_health: int = 5000
var health: int = 5000
var _broken = false
var has_thorns = false

func _ready():
	repair_plate.connect("repaired", self, "_on_repaired")
	repair_plate.set_process(false)
	repair_plate.visible = false
	health_bar.set_max_health(max_health)
	health_bar.set_health(health)


func _on_repaired():
	repair()

func repair() -> void:
	repair_plate.reset()
	$CollisionPolygon2D.disabled = false
	health = 5000
	health_bar.set_health(health)
	anim.set_animation("solid")
	$Repaired.play()
	_broken = false

func take_damage(damage, crit) -> void:
	$Hit.play()
	health -= damage
	health_bar.set_health(health)

	if health < 3700:
		anim.set_animation("damaged")
		repair_plate.visible = true
		repair_plate.set_process(true)
	if health <= 0:
		if _broken == false:
			$Broken.play()
			_broken = true
		anim.set_animation("broken")
		$CollisionPolygon2D.disabled = true

func hit(source = null, weapon = null, damage = 0, _knockback = false, crit = false) -> void:
	take_damage(damage, crit)
	if has_thorns && weapon.damage_type == "melee":
		source.take_damage(damage * 0.5, crit)
