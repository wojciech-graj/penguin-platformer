extends StaticBody
class_name TreeObstacle


export (ShaderMaterial) var shader_material = null


func _ready() -> void:
	$Tree/Circle.set_surface_material(0, shader_material)
