extends Node

const DEFAULT_SUMMON_TIMER = 300

var summon_timer = DEFAULT_SUMMON_TIMER
var start_time = 0
var mobs_killed = 0
var mobs_sacrificed = 0
var sigils = 0

var crosshair:Vector2 = Vector2(0,0)

export var paused = false
export var player_health:int = 10
export var player_location:Vector2 = Vector2(0,0)
export var demon_summoned = false

var pause_scene:Control = load("res://pause_menu.tscn").instance()

func _ready():
	start_time = OS.get_unix_time()

func current_scene():
	return get_tree().get_current_scene().get_name()

func reset():
	start_time = OS.get_unix_time()
	summon_timer = DEFAULT_SUMMON_TIMER
	demon_summoned = false

	sigils = 0


func elapsed_time():
	if start_time == 0:
		start_time = OS.get_unix_time()

	return OS.get_unix_time() - start_time


func pause():
	paused = true
	get_tree().paused = true

func unpause():
	paused = false
	get_tree().paused = false

func mob_killed():
	mobs_killed += 1

func mob_sacrificed():
	mobs_sacrificed += 1

func sigil_locked():
	sigils += 1
	summon_timer -= 45

func activated_sigils():
	return sigils

func _input(event):
	var input = Input.get_vector("nav-left", "nav-right", "nav-up", "nav-down")
	if input:
		print(input)
		crosshair += input * 400 * get_process_delta_time()
		if crosshair.x < 0:
			crosshair.x = 0
		if crosshair.y < 0:
			crosshair.y = 0
		if crosshair.x > get_viewport().size.x:
			crosshair.x = get_viewport().size.x
		if crosshair.y > get_viewport().size.y:
			crosshair.y = get_viewport().size.y
		get_viewport().warp_mouse(crosshair + input)
	if event.is_action_pressed("pause"):
		if current_scene() != "main_menu":
			if paused == false:
				pause()
				get_tree().get_current_scene().find_node("CanvasLayer").add_child(pause_scene)
				var popup = pause_scene.get_node("PopupDialog") as PopupDialog
				popup.popup_centered()
				popup.show()
