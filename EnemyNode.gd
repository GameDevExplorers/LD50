extends YSort

func _ready() -> void:
	Events.connect("spawn_enemy", self, "_on_spawn_enemy")


func _on_spawn_enemy(mob: Node) -> void:
	add_child(mob)
