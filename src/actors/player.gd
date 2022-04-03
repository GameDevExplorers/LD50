extends KinematicBody2D

export (int) var speed = 200
export (int) var spread = 10
export (int) var health = 91
export (int) var max_health = 91

var Bullet = load("res://src/objects/bullet.tscn")
var velocity:Vector2 = Vector2()

onready var health_bar = $Healthbar

func _ready():
	health_bar.set_max_health(max_health)
	health_bar.set_health(health)
	remove_child(health_bar)
	get_parent().connect("demon_summoned", self, "_on_demon_summoned")

func _on_demon_summoned():
	add_child(health_bar)
	
func get_input():
	look_at(get_global_mouse_position())
	velocity = Vector2()
	if Input.is_action_pressed("right"):
		velocity.x += 1
	if Input.is_action_pressed("left"):
		velocity.x -= 1
	if Input.is_action_pressed("down"):
		velocity.y += 1
	if Input.is_action_pressed("up"):
		velocity.y -= 1
	velocity = velocity.normalized() * speed
	if Input.is_action_just_released("fire"):
		fire_projectile(spread)
		fire_projectile(spread * -1)
		fire_projectile(0)

func _physics_process(delta):
	Game.player_location = position
	get_input()
	velocity = move_and_slide(velocity)
	Game.player_location = global_position

func fire_projectile(offset:int):
	var b = Bullet.instance()
	b.start($BulletSpawn.global_position, rotation + deg2rad(offset), "player")
	get_parent().add_child(b)

func take_damage(damage) -> void:
	health = health - damage
	health_bar.set_health(health)
	#if health <= 0:
		#trigger_death()

func _on_BulletCollider_body_entered(body: Node) -> void:
	if body.get("damage") && body.get("spawned_by") != "player":	
		body.queue_free()
		take_damage(body.get("damage"))
