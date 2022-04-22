extends KinematicBody2D

export (int) var speed = 3000
export (int) var bullet_speed = 200
export (int) var bullet_damage = 30
export (int) var bullet_size: float = 1.0
export (int) var spread = 10
export (int) var health = 2500
export (int) var max_health = 2500
export (int) var sigil_buff = 500
export var demo = false

var Bullet = load("res://src/objects/bullet.tscn")
var velocity:Vector2 = Vector2()
var player_nearby = false

enum State { IDLE, ATTACKING, ATTACK_PAUSE }
enum Attack { SPIRAL, BEAM, BLAST }

var state:int = State.IDLE
var attack:int = -1
var attack_progress = -5

onready var health_bar = get_node("CanvasLayer/Healthbar")

var has_piercing = false
var knocked_back = false

# The demon has a Timer which fires an event every second
# In the callback, it will decide if its time to attack again, pick an attack and commit to it.
# Then reset the timer

func _ready():
	$Timer.start(1)
	set_health_bar()
	if demo:
		health_bar.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if demo:
		return
	var dir = Vector2.ZERO
	if !player_nearby:
		if Game.player_location:
			dir = global_position.direction_to(Game.player_location)
			velocity = dir * speed
	else:
		$AnimatedSprite.play("default")
		velocity = Vector2.ZERO

	if state == State.ATTACKING:
		if attack == Attack.SPIRAL:
			var count = 20
			var radius = Vector2(10, 0)
			var step = 2 * PI / count
			var b = Bullet.instance()
			b.start(position + radius.rotated(step * attack_progress), (step * attack_progress) + 5, self, bullet_speed)
			b.set_animation("demon")
			get_parent().add_child(b)
			state = State.ATTACK_PAUSE
		if attack == Attack.BEAM:
			fire()
			fire()
			state = State.ATTACK_PAUSE
		if attack == Attack.BLAST:
			$AnimatedSprite.play("default")
			var vecs = [Vector2(0, -1), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0), Vector2(0.5, 0.5), Vector2(-0.5, 0.5), Vector2(0.5, -0.5), Vector2(-0.5, -0.5)]
			var vel = vecs[attack_progress % vecs.size()]
			var b = Bullet.instance()
			b.start(position, 0, self, bullet_speed)
			b.set_animation("demon")
			b.set_velocity(vel)
			get_parent().add_child(b)
			state = State.ATTACK_PAUSE


func _physics_process(delta):
	velocity = move_and_slide(velocity * delta)


func is_ally(source) -> bool:
	return source.is_in_group("enemy")


func set_health_bar():
	health_bar.set_max_health(max_health)
	health_bar.set_health(health)


func absorb_souls():
	health += 15
	if health > max_health:
		max_health = health
	set_health_bar()


func fire():
	var b = Bullet.instance()
	b.start(position, 0, self, bullet_speed, bullet_damage, bullet_size, [Game.Masks.PLAYER, Game.Masks.MOB])
	b.set_animation("demon")
	b.set_target(Game.player_location)
	get_parent().add_child(b)


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
			$Timer.start(1)

func assign_attack():
	$AudioRoar.play()
	$AnimatedSprite.play("jumping")
	state  = State.ATTACKING
	if randf() > 0.5:
		attack = Attack.SPIRAL
	else:
		if randf() > 0.5:
			attack = Attack.BEAM
		else:
			attack = Attack.BLAST

func take_damage(damage) -> void:
	health = health - damage
	set_health_bar()
	modulate = Color.white
	yield(get_tree().create_timer(0.1), "timeout")
	modulate = Color.black
	yield(get_tree().create_timer(0.1), "timeout")
	modulate = Color.white
	yield(get_tree().create_timer(0.1), "timeout")
	modulate = Color.black
	yield(get_tree().create_timer(0.1), "timeout")
	modulate = Color.white

	if health <= 0:
		get_tree().change_scene("res://victory.tscn")


func hit(_source = null, _weapon = null, damage = 0, knockback = false) -> void:
	if damage:
		take_damage(damage)
		if knockback:
			knockback_target()


func knockback_target():
	position = position.move_toward(get_global_mouse_position(), 20)
	knocked_back = true
	yield(get_tree().create_timer(0.1), "timeout")
	knocked_back = false


func _on_Area2D_body_exited(body:Node):
	if body.get_name() == "player":
		modulate = Color.white
		player_nearby = false


func _on_Area2D_body_entered(body:Node):
	if body.get_name() == "player":
		player_nearby = true


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "jumping":
		$AnimatedSprite.play("flying")
