extends KinematicBody2D

onready var anim = $gate_anim
onready var repair_plate = $RepairPlate

export var health: = 4000
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
	$CollisionShape2D.disabled = false
	health = 4000
	anim.set_animation("solid")
	$Repaired.play()
	_broken = false

func take_damage() -> void:
	$Hit.play()
	health -= 100
	if health < 3500:
		anim.set_animation("damaged")
		repair_plate.visible = true
		repair_plate.set_process(true)
	if health <= 0:
		if _broken == false:
			$Broken.play()
			_broken = true
		anim.set_animation("broken")
		$CollisionShape2D.disabled = true

func hit() -> void:
	take_damage()
