extends KinematicBody2D

onready var anim = $gate_anim
onready var repair_plate = $RepairPlate

export var health: = 400
var _velocity: = Vector2.ZERO

func _ready():
	repair_plate.connect("repaired", self, "_on_repaired")
	remove_child(repair_plate)

func _on_repaired():
	repair()
	
func repair() -> void:
	remove_child(repair_plate)
	$CollisionShape2D.disabled = false
	health = 400
	anim.set_animation("solid")

func take_damage() -> void:
	$Hit.play()
	health -= 40
	if health < 250:
		anim.set_animation("damaged")
	if health <= 0:
		add_child(repair_plate)
		anim.set_animation("broken")
		$CollisionShape2D.disabled = true

func hit() -> void:
	take_damage()
