extends StaticBody
class_name BunnyNPC


export (Array, String) var text = []


onready var animation_player = $Bunny/AnimationPlayer


func talk_begin() -> void:
	animation_player.play("Stand")


func talk_end() -> void:
	animation_player.play_backwards("Stand")
