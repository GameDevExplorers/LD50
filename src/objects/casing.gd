extends Sprite


var on_floor = false
var fall_height = 32

func _ready():
	$Tween.interpolate_property(self, "position",
		Vector2(global_position.x, global_position.y), Vector2(global_position.x, global_position.y + fall_height), 0.25,
		Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	$Tween.start()

func _process(delta):
	pass

