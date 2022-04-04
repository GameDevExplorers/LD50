extends Area2D


onready var timer = $Timer
onready var progress_bar = $TextureProgress
onready var repair_anim = $Repair_Beacon_Anim

signal repaired
signal repair_tick

var count: = 0

func _ready():
	reset_frame()

func _on_RepairPlate_body_entered(body: Node) -> void:
	timer_feedback()
	timer.start(0.1)
	repair_anim.play("default")
	if !is_connected("repair_tick", body, "_on_repair_tick"):
		var _i = self.connect("repair_tick", body, "_on_repair_tick")


func _on_RepairPlate_body_exited(body: Node) -> void:
	if is_connected("repair_tick", body, "_on_repair_tick"):
		self.disconnect("repair_tick", body, "_on_repair_tick")
	progress_bar.value = count
	timer.stop()
	repair_anim.stop()
	reset_frame()

func _on_Timer_timeout() -> void:
	timer_feedback()

func timer_feedback() -> void:
	count = count + 1
	progress_bar.value = count
	if count >= 30:
		emit_signal("repaired")
		timer.stop()
	else:
		emit_signal("repair_tick")

func reset_frame() -> void:
	repair_anim.set_frame(2)


func reset() -> void:
	set_process(false)
	visible = false
	count = 0
