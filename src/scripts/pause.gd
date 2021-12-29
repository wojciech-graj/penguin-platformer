extends Control
class_name Pause


func _ready() -> void:
	self.visible = false


func _physics_process(
	_delta: float
) -> void:
	if Input.is_action_just_pressed("pause"):
		var paused = not get_tree().paused
		get_tree().paused = paused
		self.visible = paused
