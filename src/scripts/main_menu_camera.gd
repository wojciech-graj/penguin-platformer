extends Spatial


const SPEED = 0.5


func _physics_process(delta):
	self.rotate_y(SPEED * delta)
