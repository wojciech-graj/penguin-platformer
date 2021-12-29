extends Area
class_name TextArea


onready var parent = get_parent()


func _on_body_entered(
	body: Node
) -> void:
	if body.get_name() == "Player":
		body.talkable_npc = parent


func _on_body_exited(
	body: Node
) -> void:
	if body.get_name() == "Player":
		body.talkable_npc = null
