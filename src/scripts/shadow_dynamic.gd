extends RayCast
class_name ShadowDynamic


export (float) var height_offset = 1.0
export (float) var scale_coeff = 1.0


onready var mesh = $ShadowMesh


func _physics_process(_delta: float) -> void:
	if is_colliding():
		self.visible = true
		var point = get_collision_point()
		var normal = get_collision_normal()
		var scale_factor = scale_coeff / ((get_global_transform().origin - point).y + height_offset)
		mesh.set_global_transform(
			Transform(
				Basis(
					Vector3(1, -normal.x / normal.y, 0).normalized() * scale_factor, 
					Vector3(0, normal.z / normal.y, -1).normalized() * scale_factor, 
					normal
				), 
				point
			)
		)
	else:
		self.visible = false
