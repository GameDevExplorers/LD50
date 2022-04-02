extends Node


export var paused = false
export var player_health:int = 10

var pause_scene:Control = load("res://pause_menu.tscn").instance()

func current_scene():
	return get_tree().get_current_scene().get_name()


func pause():
	paused = true
	get_tree().paused = true


func unpause():
	paused = false
	get_tree().paused = false


func _input(event):
	if event.is_action_pressed("pause"):
		if current_scene() != "main_menu":
			if paused == false:
				pause()
				get_tree().get_current_scene().add_child(pause_scene)
				var popup = pause_scene.get_node("PopupDialog") as PopupDialog
				popup.popup_centered()
				popup.show()
