extends MeshInstance
class_name ShadowStatic


const COLLISION_MASK := 0b1
const RAY_LENGTH := 30.0


func _ready() -> void:
	var ds := PhysicsServer.space_get_direct_state(get_world().get_space())
	var xform := get_global_transform()
	var col := ds.intersect_ray(xform.origin, xform.origin + Vector3.DOWN * RAY_LENGTH, [get_parent()], COLLISION_MASK)
	
	if col.empty():
		queue_free()
	else:
		var scale_factor = xform.basis.get_scale()
		var normal = col["normal"]
		set_global_transform(
			Transform(
				Basis(
					Vector3(1, -normal.x / normal.y, 0).normalized() * scale_factor.x, 
					Vector3(0, normal.z / normal.y, -1).normalized() * scale_factor.y, 
					normal
				), 
				col["position"]
			)
		)
