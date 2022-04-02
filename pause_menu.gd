extends Control


func _on_PopupDialog_popup_hide():
	Game.unpause()


func _on_ResumeBtn_pressed():
	get_node("PopupDialog").hide()


func _on_ExitBtn_pressed():
	get_tree().quit()
