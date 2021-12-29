extends Spatial
class_name MainMenu


var level = preload("res://src/scenes/levels/World.tscn")


func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("ui_accept"):
		var root = get_tree().get_root()
		var level_inst = level.instance()
		
		var music = $BackgroundMusic
		self.remove_child(music)
		level_inst.add_child(music)
		music.set_owner(level_inst)
		
		root.remove_child(self)
		root.add_child(level_inst)
		queue_free()
