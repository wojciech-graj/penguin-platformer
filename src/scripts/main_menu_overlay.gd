extends Control
class_name MainMenuOverlay


const DEFAULT_RESOLUTION = Vector2(384, 288)
const SCALE_FACTOR_MAX = 5


var scale_factor = 2


onready var resolution = $Options/Resolution


func _ready():
	apply_resolution()


func _physics_process(_delta):
	var input_direction = int(Input.is_action_just_pressed("ui_right")) - int(Input.is_action_just_pressed("ui_left"))
	if input_direction:
		scale_factor += input_direction
		if scale_factor < 1:
			scale_factor = SCALE_FACTOR_MAX
		elif scale_factor > SCALE_FACTOR_MAX:
			scale_factor = 1
		apply_resolution()


func apply_resolution() -> void:
	var scaled_resolution = DEFAULT_RESOLUTION * scale_factor
	resolution.text = "<%dx%d>" % [scaled_resolution.x, scaled_resolution.y]
	OS.window_size = scaled_resolution
