extends Area
class_name Checkpoint


onready var particles = $Particles


func _on_body_entered(body: Node) -> void:
	if body.get_name() == "Player":
		particles.emitting = true
		body.set_checkpoint(self)
		$AudioStreamPlayer.play()
