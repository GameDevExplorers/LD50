extends Sprite


var falling = false;
var on_floor = false
var fall_height = 32

func _ready():
	z_index = 1
	$Tween.interpolate_property(self, "position",
		Vector2(global_position.x, global_position.y), Vector2(global_position.x + rand_range(-4, 4), global_position.y + fall_height + rand_range(-1, 1)), 0.4,
		Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT)
	$Tween.start()

func _on_Tween_tween_all_completed():
	z_index = 0

func _on_Timer_timeout():
	queue_free()
