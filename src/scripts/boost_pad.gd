extends StaticBody
class_name BoostPad


const SPEED = 20.0


func _ready() -> void:
	self.constant_linear_velocity = get_global_transform().basis.z * SPEED
