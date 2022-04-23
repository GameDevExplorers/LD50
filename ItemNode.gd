extends YSort


func _ready():
	Events.connect("loot_dropped", self, "_on_loot_dropped")
	pass


func _on_loot_dropped(loot: Node) -> void:
	add_child(loot)
