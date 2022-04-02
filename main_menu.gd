extends Control


func _on_StartBtn_pressed():
	var result = get_tree().change_scene("res://src/scenes/ViveksPlayTest.tscn")
	if result != OK:
	  print("Error loading scene")


func _on_ExitBtn_pressed():
	get_tree().quit()
