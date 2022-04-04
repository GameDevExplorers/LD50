extends Node

var summon_timer = 300
var start_time = 0
var mobs_killed = 0
var mobs_sacrificed = 0

export var paused = false
export var player_health:int = 10
export var player_location:Vector2 = Vector2(0,0)
export var demon_summoned = false

var pause_scene:Control = load("res://pause_menu.tscn").instance()

func _start():
	start_time = OS.get_unix_time()

func current_scene():
	return get_tree().get_current_scene().get_name()

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
	summon_timer -= 45

func _input(event):
	if event.is_action_pressed("pause"):
		if current_scene() != "main_menu":
			if paused == false:
				pause()
				get_tree().get_current_scene().find_node("CanvasLayer").add_child(pause_scene)
				var popup = pause_scene.get_node("PopupDialog") as PopupDialog
				popup.popup_centered()
				popup.show()
