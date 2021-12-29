extends Area


const TURN_SPEED = 10


onready var tornado = $Tornado


func _physics_process(
	delta: float
) -> void:
	tornado.rotate_y(delta * TURN_SPEED)


func _on_body_entered(body: Node) -> void:
	if body.get_name() == "Player":
		body.tornado = self


func _on_body_exited(body: Node) -> void:
	if body.get_name() == "Player":
		body.tornado = null
