extends KinematicBody2D

export (int) var speed = 200
export (int) var spread = 10

# TODO: Add Demon Bullet(s)
var Bullet = load("res://src/objects/bullet.tscn")
var velocity:Vector2 = Vector2()

enum State { IDLE, ATTACKING, ATTACK_PAUSE }
enum Attack { SPIRAL }

var state:int = State.IDLE
var attack:int = -1
var attack_progress = -5

# The demon has a Timer which fires an event every second
# In the callback, it will decide if its time to attack again, pick an attack and commit to it.
# Then reset the timer

func _ready():
	$Timer.start(5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	look_at(Game.player_location)
	if state == State.ATTACKING and attack == Attack.SPIRAL:
		var count = 10
		var radius = Vector2(10, 0)

		var step = 2 * PI / count
		var b = Bullet.instance()
		b.start(position + radius.rotated(step * attack_progress), 0, speed)
		get_parent().add_child(b)
		state = State.ATTACK_PAUSE

func _on_Timer_timeout():
	if state == State.IDLE:
		assign_attack()
		$Timer.start(0.2)
	if state == State.ATTACK_PAUSE:
		if attack_progress < 100:
			attack_progress += 1
			state = State.ATTACKING
			$Timer.start(0.2)
		else:
			# If attack progress is 10, this attack is done. go back to idle.
			attack_progress = 0
			state = State.IDLE
			$Timer.start(5)

func assign_attack():
	state  = State.ATTACKING
	attack = Attack.SPIRAL
