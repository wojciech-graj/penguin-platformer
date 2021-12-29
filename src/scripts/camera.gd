extends Camera
class_name PlayerCamera


enum {STATE_PLAYING, STATE_DIALOG}


const MAX_HEIGHT := 4.0
const MIN_HEIGHT := 2.0
const MIN_DISTANCE := 1.5
const MAX_DISTANCE := 12.0
const AUTOTURN_RAY_APERTURE := 0.43
const AUTOTURN_SPEED := 0.8
const PLAYER_HEIGHT := Vector3(0.0, 1.0, 0.0)
const AUTOTURN_ANGLE_THR := 0.75
const COLLISION_MASK := 0b11
const DIALOG_DISTANCE := 4.0
const DIALOG_HEIGHT := Vector3(0.0, 1.5, 0.0)


var state = STATE_PLAYING


onready var player = get_parent()
onready var penguin = get_node("../Penguin")


func _ready():
	set_physics_process(true)
	set_as_toplevel(true)


func _physics_process(dt: float) -> void:
	if state == STATE_DIALOG:
		return
	var target: Vector3 = player.get_global_transform().origin + PLAYER_HEIGHT
	var xform := get_global_transform()
	var pos := xform.origin

	var delta = pos - target

	# Check ranges.
	if delta.length() < MIN_DISTANCE:
		delta = delta.normalized() * MIN_DISTANCE
	elif  delta.length() > MAX_DISTANCE:
		delta = delta.normalized() * MAX_DISTANCE

	# Check upper and lower height.
	delta.y = clamp(delta.y, MIN_HEIGHT, MAX_HEIGHT)

	# Check autoturn.
	var ds := PhysicsServer.space_get_direct_state(get_world().get_space())

	var col_left := ds.intersect_ray(target, target + Basis(Vector3.UP, AUTOTURN_RAY_APERTURE).xform(delta), [], COLLISION_MASK)
	var col := ds.intersect_ray(target, target + delta, [], COLLISION_MASK)
	var col_right := ds.intersect_ray(target, target + Basis(Vector3.UP, -AUTOTURN_RAY_APERTURE).xform(delta), [], COLLISION_MASK)

	if not col.empty():
		# If main ray was occluded, get camera closer, this is the worst case scenario.
		delta = col.position - target
	elif not col_left.empty() and col_right.empty():
		# If only left ray is occluded, turn the camera around to the right.
		delta = Basis(Vector3.UP, -dt * AUTOTURN_SPEED).xform(delta)
	elif col_left.empty() and not col_right.empty():
		# If only right ray is occluded, turn the camera around to the left.
		delta = Basis(Vector3.UP, dt * AUTOTURN_SPEED).xform(delta)
	else:
		var forward := xform.basis.z
		forward.y = 0
		var ang := forward.signed_angle_to(penguin.get_global_transform().basis.x, Vector3.UP)
		if abs(ang) > AUTOTURN_ANGLE_THR:
			var turn_angle = dt * AUTOTURN_SPEED * ang
			var col_future := ds.intersect_ray(target, target + Basis(Vector3.UP, sign(turn_angle) * AUTOTURN_RAY_APERTURE + turn_angle).xform(delta), [], COLLISION_MASK)
			if col_future.empty():
				delta = Basis(Vector3.UP, turn_angle).xform(delta)

	# Apply lookat.
	if delta == Vector3():
		delta = (pos - target).normalized() * 0.0001

	pos = target + delta

	look_at_from_position(pos, target, Vector3.UP)
	
	
func talk_begin(npc: Spatial) -> void:
	state = STATE_DIALOG
	var player_xform = player.get_global_transform()
	var player_npc_diff = npc.get_global_transform().origin - player_xform.origin
	var target = player_xform.origin + player_npc_diff * 0.5 + DIALOG_HEIGHT
	var direction = Vector3.UP.cross(player_npc_diff).normalized()
	
	look_at_from_position(
		target + direction * DIALOG_DISTANCE, 
		target, 
		Vector3.UP
	)
	
func talk_end() -> void:
	state = STATE_PLAYING
