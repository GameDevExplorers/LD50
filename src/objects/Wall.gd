extends KinematicBody2D

onready var anim = $gate_anim
onready var repair_plate = $RepairPlate

export var health: = 5000
var _velocity: = Vector2.ZERO
var _broken = false

func _ready():
	repair_plate.connect("repaired", self, "_on_repaired")
	repair_plate.set_process(false)
	repair_plate.visible = false

func _on_repaired():
	repair()

func repair() -> void:
	repair_plate.reset()
	$CollisionPolygon2D.disabled = false
	health = 5000
	anim.set_animation("solid")
	$Repaired.play()
	_broken = false

func take_damage(damage) -> void:
	$Hit.play()
	health -= damage
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

func hit(damage) -> void:
	take_damage(damage)
