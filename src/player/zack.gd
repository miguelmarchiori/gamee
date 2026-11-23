class_name Zack
extends CharacterBody2D
## Zack Reddman, the player: run, jump and double jump, wall slide and wall jump,
## invulnerable roll, fast fall and the mouse-aimed dash (2 in the air).
## Movement is ported from the approved browser spike; every number is read
## live from the "player" section of assets/data/tuning.json.
##
## Usage: instance res://src/player/zack.tscn, set its position to a spawn's feet
## position, and give a GameCamera its `target`.

## Emitted when a dash starts, with its direction.
signal dashed(direction: Vector2)

const STAND_HEIGHT := 20.0
const ROLL_HEIGHT := 10.0
const WIDTH := 10.0
const GHOST_LIFE := 0.22
const GHOST_MAX := 14
const GHOST_TINTS: Array[Color] = [Color("#d8d2c4"), Color("#8a8478")]

## Which way Zack faces: 1 right, -1 left.
var facing := 1
## True when standing on the floor this physics frame.
var grounded := true
## True while rolling (low and invulnerable).
var rolling := false
## True while sliding down a wall he pushes into.
var wall_sliding := false
## Extra jumps left in the air (refilled on the floor or a wall).
var air_jumps := 0
## Dashes left in the air (refilled on the floor or a wall).
var air_dashes := 0
## Angle from Zack's chest to the aim point, in radians.
var aim_angle := 0.0
## World point the aim follows instead of the mouse while finite. Automated
## evidence runs set it; play leaves it at Vector2.INF.
var aim_override := Vector2.INF

var _coyote := 0.0
var _buffer := 0.0
var _wall_lock := 0.0
var _dash_time := 0.0
var _dash_kind := ""
var _dash_cooldown := 0.0
var _invulnerable_time := 0.0
var _flip_time := 0.0
var _roll_time := 0.0
var _no_cut := false
var _landed_time := 0.0
var _phase := 0.0
var _vy_before := 0.0
var _height := STAND_HEIGHT
var _ghosts: Array[Dictionary] = []
var _ghost_tick := 0

@onready var _body: CollisionShape2D = $Body


func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	_body.shape = _body.shape.duplicate()
	_set_height(STAND_HEIGHT)
	_refill_air_moves()


## True while Zack cannot be hurt: rolling, or during a dash.
func is_invulnerable() -> bool:
	return rolling or _invulnerable_time > 0.0


## Zack's chest, the point aim and hits are measured from.
func chest() -> Vector2:
	return global_position + Vector2(0.0, -_height / 2.0)


func _physics_process(delta: float) -> void:
	var dir := int(signf(Input.get_axis("move_left", "move_right")))
	var jump_hit := Input.is_action_just_pressed("jump")
	var jump_held := Input.is_action_pressed("jump")
	var down_hit := Input.is_action_just_pressed("down")
	var jump_height := _t("jump_height")
	var apex := _t("jump_apex_time")
	var gravity := 2.0 * jump_height / (apex * apex)
	var jump_speed := 2.0 * jump_height / apex

	var was_grounded := grounded
	grounded = is_on_floor()
	if grounded:
		_coyote = _t("coyote_time")
		_refill_air_moves()
	else:
		_coyote -= delta
	if grounded and not was_grounded and _vy_before > 200.0:
		_landed_time = 0.1
	_buffer = _t("jump_buffer") if jump_hit else _buffer - delta
	_wall_lock -= delta
	_dash_cooldown -= delta
	_invulnerable_time -= delta
	_flip_time -= delta
	_landed_time -= delta
	var was_dashing := _dash_time > 0.0
	_dash_time -= delta
	if was_dashing and _dash_time <= 0.0 and _dash_kind == "dash":
		var keep := _t("dash_end_keep")
		velocity.x *= keep
		if velocity.y < 0.0:
			velocity.y *= keep
		_dash_kind = ""
	var wall_left := not grounded and test_move(global_transform, Vector2(-2.0, 0.0))
	var wall_right := not grounded and test_move(global_transform, Vector2(2.0, 0.0))
	aim_angle = (_aim_point() - chest()).angle()

	# Roll on the floor, fast fall in the air.
	if down_hit and grounded and not rolling:
		var d := dir if dir != 0 else facing
		rolling = true
		_roll_time = _t("roll_time")
		_set_height(ROLL_HEIGHT)
		velocity.x = d * maxf(absf(velocity.x), _t("roll_speed"))
		facing = d
	elif down_hit and not grounded and not rolling and _dash_time <= 0.0:
		velocity.y = maxf(velocity.y, _t("max_fall_speed") * 0.85)
		_no_cut = false
	if rolling:
		_roll_time -= delta
		velocity.x = move_toward(velocity.x, 0.0, _t("roll_friction") * delta)
		if (_roll_time <= 0.0 or not grounded) and _can_stand():
			_end_roll()

	# Running: the momentum of a dash or a wall jump carries in the air.
	if not rolling and _wall_lock <= 0.0 and _dash_time <= 0.0:
		var run := _t("run_speed")
		var accel: float
		if dir != 0 and absf(velocity.x) > run and int(signf(velocity.x)) == dir:
			accel = _t("ground_friction") * 0.5 if grounded else 120.0
		elif dir != 0:
			accel = _t("ground_accel") if grounded else _t("air_accel")
		else:
			accel = _t("ground_friction") if grounded else _t("air_drag")
		velocity.x = move_toward(velocity.x, dir * run, accel * delta)
		if dir != 0:
			facing = dir

	# Jump, wall jump, double jump.
	if _buffer > 0.0 and (grounded or _coyote > 0.0) and (not rolling or _can_stand()):
		if rolling:
			_end_roll()
		velocity.y = -jump_speed
		_buffer = 0.0
		_coyote = 0.0
		grounded = false
	elif _buffer > 0.0 and not grounded and (wall_left or wall_right) and not rolling:
		var away := 1 if wall_left else -1
		velocity.y = -jump_speed * _t("wall_jump_up")
		velocity.x = away * _t("wall_jump_push")
		facing = away
		_wall_lock = _t("wall_jump_lock")
		_buffer = 0.0
		_refill_air_moves()
		_no_cut = true
	elif jump_hit and not grounded and air_jumps > 0 and not rolling:
		velocity.y = -jump_speed * _t("double_jump_mult")
		air_jumps -= 1
		_buffer = 0.0
		_flip_time = _t("flip_time")
		_dash_time = 0.0
		_dash_kind = ""
		if dir != 0:
			velocity.x = dir * maxf(absf(velocity.x), _t("run_speed") * 0.8)
			facing = dir

	# Gravity: falls faster than it rises; letting go of jump early cuts the jump.
	var g := gravity
	if velocity.y >= 0.0:
		_no_cut = false
	if _dash_time > 0.0:
		g = 0.0
	elif velocity.y > 0.0:
		g *= _t("fall_gravity_mult")
	elif not jump_held and not _no_cut:
		g *= _t("jump_cut_gravity_mult")
	velocity.y = minf(velocity.y + g * delta, _t("max_fall_speed"))

	wall_sliding = not grounded and velocity.y > 0.0 and ((wall_left and dir < 0) or (wall_right and dir > 0))
	if wall_sliding:
		velocity.y = minf(velocity.y, _t("wall_slide_speed"))
		facing = 1 if wall_left else -1
		_refill_air_moves()

	# Dash toward the aim: invulnerable, 2 in the air.
	if Input.is_action_just_pressed("dash") and _dash_cooldown <= 0.0 and (grounded or air_dashes > 0) and (not rolling or _can_stand()):
		if rolling:
			_end_roll()
		var ang := aim_angle
		if grounded and sin(ang) > 0.2:  # on the floor, a dash aimed down goes sideways
			ang = 0.0 if cos(ang) >= 0.0 else PI
		if not grounded:
			air_dashes -= 1
		var direction := Vector2.from_angle(ang)
		velocity = direction * _t("dash_speed")
		_dash_time = _t("dash_duration")
		_dash_kind = "dash"
		_invulnerable_time = _dash_time + 0.04
		_dash_cooldown = _t("dash_cooldown")
		_no_cut = true
		if absf(direction.x) > 0.2:
			facing = 1 if direction.x > 0.0 else -1
		dashed.emit(direction)

	_vy_before = velocity.y
	move_and_slide()
	_phase += absf(velocity.x) * delta * 0.09
	_update_ghosts(delta)
	queue_redraw()


func _draw() -> void:
	for ghost in _ghosts:
		var state: Dictionary = ghost["state"]
		state["tint"] = ghost["tint"]
		state["alpha"] = 0.45 * float(ghost["life"]) / GHOST_LIFE
		FigurePainter.paint(self, ghost["pos"] - global_position, ghost["facing"], ghost["pose"], "zack", state)
	FigurePainter.paint(self, Vector2.ZERO, facing, _pose(), "zack", _paint_state())


func _pose() -> String:
	if rolling or (_flip_time > 0.0 and not grounded):
		return "roll"
	if wall_sliding:
		return "wall"
	if not grounded:
		return "air"
	return "run" if absf(velocity.x) > 20.0 else "idle"


func _paint_state() -> Dictionary:
	var progress := 0.0
	if rolling:
		progress = 1.0 - maxf(0.0, _roll_time) / _t("roll_time")
	elif _flip_time > 0.0:
		progress = 1.0 - _flip_time / _t("flip_time")
	return {
		"phase": _phase,
		"vx": velocity.x,
		"landed": _landed_time,
		"roll_progress": progress,
		"flip": _flip_time > 0.0 and not rolling,
	}


func _update_ghosts(delta: float) -> void:
	for ghost in _ghosts:
		ghost["life"] = float(ghost["life"]) - delta
	while not _ghosts.is_empty() and float(_ghosts[0]["life"]) <= 0.0:
		_ghosts.pop_front()
	_ghost_tick += 1
	var fast := _dash_time > 0.0 or rolling or _wall_lock > 0.0 or absf(velocity.x) > _t("run_speed") * 1.15
	if fast and (_ghost_tick % 2 == 0 or _invulnerable_time > 0.0):
		_ghosts.append({
			"pos": global_position, "facing": facing, "pose": _pose(), "state": _paint_state(),
			"life": GHOST_LIFE, "tint": GHOST_TINTS[_ghost_tick % 2],
		})
		if _ghosts.size() > GHOST_MAX:
			_ghosts.pop_front()


func _aim_point() -> Vector2:
	return aim_override if aim_override.is_finite() else get_global_mouse_position()


func _refill_air_moves() -> void:
	air_jumps = int(_t("air_jumps"))
	air_dashes = int(_t("air_dashes"))


func _can_stand() -> bool:
	return not rolling or not test_move(global_transform, Vector2(0.0, -(STAND_HEIGHT - ROLL_HEIGHT)))


func _end_roll() -> void:
	rolling = false
	_set_height(STAND_HEIGHT)


func _set_height(h: float) -> void:
	_height = h
	(_body.shape as RectangleShape2D).size = Vector2(WIDTH, h)
	_body.position = Vector2(0.0, -h / 2.0)


func _t(key: String) -> float:
	return Tuning.value("player", key)
