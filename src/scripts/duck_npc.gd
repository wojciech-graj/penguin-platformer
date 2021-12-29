extends StaticBody
class_name DuckNPC


export (Array, String) var text = []


onready var animation_player = $Duck/AnimationPlayer


func talk_begin() -> void:
	animation_player.play("Talk-loop", -1, 2.0)


func talk_end() -> void:
	animation_player.play("Stand")
