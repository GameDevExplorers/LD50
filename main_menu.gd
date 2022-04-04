extends Control

func _on_StartBtn_pressed():
	$Select.play()
	yield(get_tree().create_timer(0.4), "timeout")
	var result = get_tree().change_scene("res://level_five.tscn")
	if result != OK:
		print("Error loading scene")


func _on_ExitBtn_pressed():
	$Select.play()
	yield(get_tree().create_timer(0.4), "timeout")
	get_tree().quit()
