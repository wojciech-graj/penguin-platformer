extends KinematicBody
class_name Player


signal display_text(text)
signal display_present_count(count, shader_material_)


enum {STATE_PLAYING, STATE_DIALOG}


const MAX_SPEED := 15.0
const TURN_SPEED := 60.0
const JUMP_VELOCITY := 30.0
const DOUBLE_JUMP_VELOCITY := 8.0
const AIR_IDLE_DEACCEL := false
const ACCEL := 32.0
const DEACCEL := 40.0
const AIR_ACCEL_FACTOR := .55
const SHARP_TURN_THRESHOLD := 2.27
const GRAVITY := Vector3.DOWN * 25.0
const JUMP_HOLD_DURATION := .13
const TORNADO_RISE_SPEED := 45.0
const TORNADO_CENTRIPETAL_SPEED := 25.0


var checkpoint = null
var movement_dir := Vector3()
var linear_velocity := Vector3()
var jumping := false
var prev_on_floor := false
var can_double_jump := false
var jump_timer := .0
var talkable_npc = null
var state = STATE_PLAYING
var present_count = 0
var tornado = null
var presents = []


onready var camera = $Camera
onready var particles_smoke = $ParticlesSmoke
onready var particles_snowflake = $ParticlesSnowflake
onready var penguin = $Penguin
onready var animation_tree = $Penguin/AnimationTree
onready var audio_jump = $AudioJump


func _perp_distance(line: Vector3, point: Vector3) -> float:
	return (line.dot(point) * line).distance_to(point)


func _physics_process(
	delta: float
) -> void:
	if state == STATE_DIALOG:
		return
		
	if get_global_transform().origin.y < .0:
		reset()
		return
		
	if tornado:
		var tornado_xform = tornado.get_global_transform()
		var tornado_up_dir = tornado_xform.basis.y.normalized()
		self.linear_velocity += tornado_up_dir * TORNADO_RISE_SPEED * delta
		var tornado_relative_pos = get_global_transform().origin - tornado_xform.origin
		var centripetal_dir = tornado_up_dir.dot(tornado_relative_pos) * tornado_up_dir - tornado_relative_pos
		self.linear_velocity += centripetal_dir * TORNADO_CENTRIPETAL_SPEED * delta
	
	linear_velocity += GRAVITY * delta

	var vv := linear_velocity.y # Vertical velocity
	var hv := Vector3(linear_velocity.x, .0, linear_velocity.z) # Horizontal velocity

	var hdir := hv.normalized()
	var hspeed := hv.length()

	var cam_basis: Basis = camera.get_global_transform().basis
	var movement_vec2 := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var dir := cam_basis * Vector3(movement_vec2.x, 0, movement_vec2.y)
	dir.y = 0  # Is neccessary
	dir = dir.normalized()
	
	var jump_attempt := Input.is_action_pressed("jump")

	if is_on_floor():
		if not prev_on_floor:
			# Just landed
			can_double_jump = true
			animation_tree["parameters/blend_bounce/blend_amount"] = 0
			animation_tree["parameters/oneshot_bounce/active"] = true

		var sharp_turn := hspeed > 0.1 and acos(dir.dot(hdir)) > SHARP_TURN_THRESHOLD

		if dir.length() > 0.1 and not sharp_turn:
			if hspeed > 0.001:
				hdir = adjust_facing(hdir, dir, delta, 1.0 / hspeed * TURN_SPEED, Vector3.UP)
			else:
				hdir = dir

			if hspeed < MAX_SPEED:
				hspeed += ACCEL * delta
		else:
			hspeed -= DEACCEL * delta
			if hspeed < 0:
				hspeed = 0

		hv = hdir * hspeed

		var mesh_xform: Transform = penguin.get_transform()
		var facing_mesh := -mesh_xform.basis[0].normalized()
		facing_mesh = (facing_mesh - Vector3.UP * facing_mesh.dot(Vector3.UP)).normalized()

		if hspeed > 0:
			facing_mesh = adjust_facing(facing_mesh, dir, delta, 1.0 / hspeed * TURN_SPEED, Vector3.UP)
		var m3 := Basis(-facing_mesh, Vector3.UP, -facing_mesh.cross(Vector3.UP).normalized())
		
		penguin.set_transform(Transform(m3, mesh_xform.origin))

		if jump_attempt:
			if talkable_npc and jump_attempt:
				talkable_npc.talk_begin()
				emit_signal("display_text", talkable_npc.text)
				camera.talk_begin(talkable_npc)
				state = STATE_DIALOG
				return
			jumping = true
			vv = 0
			animation_jump()
	else:
		if dir.length() > 0.1:
			hv += dir * (ACCEL * AIR_ACCEL_FACTOR * delta)
			if hv.length() > MAX_SPEED:
				hv = hv.normalized() * MAX_SPEED
		elif AIR_IDLE_DEACCEL:
			hspeed = hspeed - (DEACCEL * AIR_ACCEL_FACTOR * delta)
			if hspeed < 0:
				hspeed = 0
			hv = hdir * hspeed
		
		if can_double_jump and Input.is_action_just_pressed("jump"):
			vv = max(vv, DOUBLE_JUMP_VELOCITY)
			can_double_jump = false
			animation_jump()
	
	if jumping:
		if jump_attempt:
			jump_timer += delta
			vv += JUMP_VELOCITY / JUMP_HOLD_DURATION * delta * (1 - (jump_timer / JUMP_HOLD_DURATION))
		if not jump_attempt or jump_timer > JUMP_HOLD_DURATION:
			jump_timer = .0
			jumping = false

	linear_velocity = hv + Vector3.UP * vv
	
	if is_on_floor() or prev_on_floor:
		movement_dir = linear_velocity
		animation_tree["parameters/time_scale_walk/scale"] = 3 * hspeed / MAX_SPEED
		animation_tree["parameters/blend_walk/blend_amount"] = clamp(1 - 2 * hspeed / MAX_SPEED, 0, 1)
		animation_tree["parameters/blend_floor/blend_amount"] = .0
		particles_smoke.emitting = bool(hspeed)
	else:
		animation_tree["parameters/blend_floor/blend_amount"] = 1.0
		animation_tree["parameters/blend_air/blend_amount"] = clamp(-linear_velocity.y / 4 + .5, 0, 1)
		particles_smoke.emitting = false
		
	prev_on_floor = is_on_floor()
		
	linear_velocity = move_and_slide(linear_velocity, Vector3.UP)


func animation_jump() -> void:
	animation_tree["parameters/blend_bounce/blend_amount"] = 1
	animation_tree["parameters/oneshot_bounce/active"] = true
	particles_snowflake.restart()
	particles_snowflake.emitting = true
	audio_jump.play()


func adjust_facing(
	p_facing: Vector3, 
	p_target: Vector3, 
	p_step: float, 
	p_adjust_rate: float, 
	current_gn: Vector3
) -> Vector3:
	var n = p_target # Normal.
	var t = n.cross(current_gn).normalized()

	var x = n.dot(p_facing)
	var y = t.dot(p_facing)

	var ang = atan2(y,x)

	if abs(ang) < 0.001: # Too small.
		return p_facing

	var s = sign(ang)
	ang = ang * s
	var turn = ang * p_adjust_rate * p_step
	var a = ang if ang < turn else turn
	ang = (ang - a) * s

	return (n * cos(ang) + t * sin(ang)) * p_facing.length()


func _on_finish_dialog() -> void:
	state = STATE_PLAYING
	talkable_npc.talk_end()
	camera.talk_end()
	talkable_npc = null


func collect_present(present) -> void:
	present_count += 1
	presents.append(present)
	emit_signal("display_present_count", present_count, present.shader_material)


func reset() -> void:
	present_count -= presents.size()
	for present in presents:
		present.uncollect()
	presents = []
	linear_velocity = Vector3.ZERO
	can_double_jump = false
	set_global_transform(Transform(get_global_transform().basis, checkpoint.get_global_transform().origin))
	

func set_checkpoint(cp) -> void:
	for present in presents:
		present.queue_free()
	presents = []
	checkpoint = cp
