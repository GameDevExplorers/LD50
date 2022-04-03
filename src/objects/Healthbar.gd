extends Control

onready var health_bar = $healthbar_slider
onready var update_tween = $Tween

func set_health(health):
	health_bar.value = health

func set_max_health(max_health):
	health_bar.max_value = max_health
