extends Label



func _ready():
	pass # Replace with function body.

func show_value(value, travel, duration, crit=false) -> void:
	text = value
	var movement = travel.rotated(0)
	rect_pivot_offset = rect_size / 2

	$tween.interpolate_property(
		self,
		"rect_position",
		rect_position,
		rect_position + movement,
		duration,
		Tween.TRANS_BACK,
		Tween.EASE_OUT
	)
	$tween.interpolate_property(
		self,
		"modulate:a",
		1.0,
		0.0,
		duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_OUT
	)

	handle_crits(crit)

	$tween.start()
	yield($tween, "tween_all_completed")
	queue_free()


func handle_crits(crit) -> void:
	if crit:
		modulate = Color(1, 0, 0)
		$tween.interpolate_property(
			self,
			"rect_scale",
			rect_scale*2,
			rect_scale,
			0.4,
			Tween.TRANS_BACK,
			Tween.EASE_IN
		)
