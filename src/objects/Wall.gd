extends KinematicBody2D

onready var anim = $gate_anim
onready var repair_plate = $RepairPlate

export var health: = 1200
var _velocity: = Vector2.ZERO

func _ready():
	repair_plate.connect("repaired", self, "_on_repaired")
	repair_plate.set_process(false)
	repair_plate.visible = false

func _on_repaired():
	repair()
	
func repair() -> void:
	repair_plate.set_process(false)
	repair_plate.visible = false
	$CollisionShape2D.disabled = false
	health = 1200
	anim.set_animation("solid")

func take_damage() -> void:
	$Hit.play()
	health -= 20
	if health < 800:
		anim.set_animation("damaged")
	if health <= 0:
		repair_plate.set_process(true)
		repair_plate.visible = true
		anim.set_animation("broken")
		$CollisionShape2D.disabled = true

func hit() -> void:
	take_damage()
