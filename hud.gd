extends Control


func _ready():
	pass


func update_demon_timer(time) -> void:
	if time < 8:
		$HBoxContainer/DemonTimer.text = "Your Death is soon"
	elif time <= 2:
		$HBoxContainer/DemonTimer.text = "Your Death is now!"
	else:
		$HBoxContainer/DemonTimer.text = "Your Death is in " + str(time) + " seconds"


func update_sigils() -> void:
	$HBoxContainer/Sigils.text = "Activated Demon Sigils: " + str(Game.activated_sigils())


func update_experience() -> void:
	$HBoxContainer2/Experience.text = "Experience: " + str(Game.score)


func update_experience_for_next_level(next_level) -> void:
	$HBoxContainer3/NextLevel.text = "Next Level: " + str(next_level)


func update_player_level(player) -> void:
	$HBoxContainer4/Level.text = "Level: " + str(player.level)

