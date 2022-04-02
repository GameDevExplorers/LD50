extends KinematicBody2D

onready var solid_gate = $SolidGate
onready var damaged_gate = $DamagedGate
onready var broken_gate = $BrokenGate

export var health: = 400
var _velocity: = Vector2.ZERO

func _ready() -> void:
	self.remove_child(damaged_gate)
	self.remove_child(broken_gate)

func repair() -> void:
	$CollisionShape2D.disabled = false
	health = 400
	solid_gate.active = true
	damaged_gate.active = false
	broken_gate.active = false

func take_damage() -> void:
	health -= 40
	if health < 250:
		self.remove_child(solid_gate)
		self.add_child(damaged_gate)
	if health <= 0:
		self.remove_child(damaged_gate)
		self.add_child(broken_gate)
		$CollisionShape2D.disabled = true

func hit() -> void:
	take_damage()
