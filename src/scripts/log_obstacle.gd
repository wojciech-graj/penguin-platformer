extends StaticBody


enum MotionType {LINEAR, ROTATING}


var reverse := true


onready var tween = $Tween
onready var init_xform = get_global_transform()


export (MotionType) var motion = MotionType.LINEAR
export (float) var duration = 1.0
export (Vector3) var vector = Vector3.ZERO


func _ready():
	if motion == MotionType.ROTATING:
		tween.interpolate_method(self, "set_rotate", .0, 6.2831853, duration, Tween.TRANS_LINEAR)
		tween.repeat = true
	elif motion == MotionType.LINEAR:
		tween.interpolate_method(self, "set_position", Vector3.ZERO, vector, duration, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		tween.connect("tween_completed", self, "_on_tween_completed")
	tween.start()


func set_rotate(angle: float):
	set_global_transform(Transform(init_xform.basis.rotated(vector, angle), init_xform.origin))


func set_position(offset: Vector3):
	set_global_transform(Transform(init_xform.basis, init_xform.origin + offset))


func _on_tween_completed(_object, _key):
	reverse = not reverse
	if reverse:
		tween.interpolate_method(self, "set_position", Vector3.ZERO, vector, duration, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	else:
		tween.interpolate_method(self, "set_position", vector, Vector3.ZERO, duration, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.start()
