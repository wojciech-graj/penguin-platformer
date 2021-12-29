extends Control


const ROTATE_SPEED = 1.0
const VISIBLE_TIME = 2.0


onready var label = $Label
onready var present = $ViewportContainer/Viewport/Spatial/Present
onready var present_mesh = $ViewportContainer/Viewport/Spatial/Present/Cube
onready var timer = $Timer


func _ready() -> void:
	self.visible = false
	set_physics_process(false)


func _on_display_present_count(
	count: int,
	shader_material: ShaderMaterial
) -> void:
	present_mesh.set_surface_material(0, shader_material)
	label.text = str(count)
	set_physics_process(true)
	self.visible = true
	timer.start(VISIBLE_TIME)


func _physics_process(
	delta: float
) -> void:
	present.rotate_y(delta * ROTATE_SPEED)


func _on_timer_timeout() -> void:
	self.visible = false
	set_physics_process(false)
