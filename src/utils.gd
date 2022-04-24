class_name Utils

static func percentage(n = 0) -> bool:
	return randf() <= n * .01

static func calculate_resistance(object_a, object_b):
	return min(object_a.MASS_FACTOR / object_b.MASS_FACTOR, 0.9)
