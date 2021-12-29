extends StaticBody


var text


onready var animation_player = $Duck/AnimationPlayer


func talk_begin() -> void: # TODO: Create proper dialog system
	var player = get_tree().get_root().get_node("Level/Player")
	if player.present_count >= 25:
		text = ["Well Done! You actually did it! You found all 25 presents and saved Christmas!"]
	else:
		text = ["Well Done! You found %d of 25 presents, which will be enough for this year's Christmas!" % player.present_count]
	text.append("If you're looking for an additional challenge, 3 more gifts have been scattered further ahead.")
	text.append("And now I, the developer, would like to personally thank you for playing my game.")
	text.append("If you enjoyed this game, feel free to leave a review!")
	text.append("A full release with more obstacles, mechanics, and levels is coming soon to a christmas tree near you!")
	animation_player.play("Talk-loop", -1, 2.0)


func talk_end() -> void:
	animation_player.play("Stand")
