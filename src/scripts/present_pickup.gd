extends Area
class_name PresentPickup


const SPEED := 2.0


export (ShaderMaterial) var shader_material = null


func _ready() -> void:
	$Present/Cube.set_surface_material(0, shader_material)


func _physics_process(delta):
	self.rotate_y(SPEED * delta)


func _on_body_entered(
	body: Node
) -> void:
	if body.get_name() == "Player":
		body.collect_present(self)
		$Present.visible = false
		var shadow_static = get_node_or_null("ShadowStatic")
		if shadow_static:
			shadow_static.visible = false
		$Particles.emitting = true
		$AudioStreamPlayer.play()
		set_deferred("monitoring", false)

	
func uncollect() -> void:
	set_deferred("monitoring", true)
	$Present.visible = true
	var shadow_static = get_node_or_null("ShadowStatic")
	if shadow_static:
		shadow_static.visible = false
