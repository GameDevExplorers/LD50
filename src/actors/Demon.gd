extends KinematicBody2D

export (int) var speed = 200
export (int) var spread = 10
export (int) var health = 10000
export (int) var max_health = 10000

var Bullet = load("res://src/objects/bullet.tscn")
var velocity:Vector2 = Vector2()
var player_nearby = false

enum State { IDLE, ATTACKING, ATTACK_PAUSE }
enum Attack { SPIRAL, BEAM }

var state:int = State.IDLE
var attack:int = -1
var attack_progress = -5

onready var health_bar = get_node("CanvasLayer/Healthbar")

# The demon has a Timer which fires an event every second
# In the callback, it will decide if its time to attack again, pick an attack and commit to it.
# Then reset the timer

func _ready():
	health_bar.set_max_health(max_health)
	health_bar.set_health(health)
	$Timer.start(5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var dir = Vector2.ZERO
	if state == State.ATTACKING:
		if attack == Attack.SPIRAL:
			var count = 10
			var radius = Vector2(10, 0)
			var step = 2 * PI / count
			var b = Bullet.instance()
			b.start(position + radius.rotated(step * attack_progress), 0, "demon", speed)
			b.set_animation("demon")
			get_parent().add_child(b)
			state = State.ATTACK_PAUSE
		if attack == Attack.BEAM:
			fire()
			fire()
			state = State.ATTACK_PAUSE
	else:
		if !player_nearby:
			if Game.player_location and position and speed:
				dir = global_position.direction_to(Game.player_location)
				velocity = dir * speed
		else:
			$AnimatedSprite.play("default")
			velocity = Vector2.ZERO

func _physics_process(delta):
	velocity = move_and_slide(velocity * delta)


func fire():
	var b = Bullet.instance()
	b.start(position, 0, "demon", speed)
	b.set_animation("demon")
	get_parent().add_child(b)
	b.set_target(Game.player_location)

func _on_Timer_timeout():
	if state == State.IDLE:
		assign_attack()
		$Timer.start(0.2)
	if state == State.ATTACK_PAUSE:
		if attack_progress < 10:
			attack_progress += 1
			state = State.ATTACKING
			$Timer.start(0.2)
		else:
			# If attack progress is 10, this attack is done. go back to idle.
			attack_progress = 0
			state = State.IDLE
			$Timer.start(5)

func assign_attack():
	$AnimatedSprite.play("jumping")
	state  = State.ATTACKING
	if randf() > 0.5:
		attack = Attack.SPIRAL
	else:
		attack = Attack.BEAM
		
func take_damage(damage) -> void:
	health = health - damage
	health_bar.set_health(health)
	#if health <= 0:
		#trigger_death()

func _on_Area2D_body_exited(body:Node):
	if body.get_name() == "player":
		player_nearby = false


func _on_Area2D_body_entered(body:Node):
	if body.get_name() == "player":
		player_nearby = true


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "jumping":
		$AnimatedSprite.play("flying")


func _on_BulletCollider_body_entered(body: Node) -> void:
	if body.get("damage") && body.get("spawned_by") != "demon":	
		body.queue_free()
		take_damage(body.get("damage"))
